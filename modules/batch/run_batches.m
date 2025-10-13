function batch_table = run_batches(config, seeds)
% RUN_BATCHES Execute multiple simulation batches and record key metrics.
% Usage:
%   T = run_batches(config, seeds)
% Inputs:
%   - config  struct returned by default_config() / interactive_config()
%   - seeds   [batch_count x 1] vector produced by get_batch_seeds()
% Output:
%   - batch_table  table with per-batch seed and products_final metadata

batch_count = numel(seeds);
if batch_count < 1
    error('run_batches: seeds input must not be empty.');
end

% =========================================================================
% Checkpoint Protection Setup (Batch-level for multi-batch runs)
% =========================================================================
enable_checkpoint = (batch_count > 1);
start_batch = 1;

if enable_checkpoint
    % Determine output file paths
    if isfield(config, 'io') && isfield(config.io, 'data_dir')
        data_dir = config.io.data_dir;
    else
        data_dir = fullfile(config.io.outdir, 'data');
    end
    
    % Batch results CSV path
    report_basename = 'batch_results';
    if isfield(config, 'batch') && isfield(config.batch, 'report_basename')
        report_basename = config.batch.report_basename;
    end
    batch_results_csv = fullfile(data_dir, [report_basename '.csv']);
    
    % Seeds CSV path
    seeds_csv = fullfile(data_dir, 'seeds.csv');
    
    % Check for existing results (checkpoint recovery)
    if isfile(batch_results_csv)
        fprintf('\n⚠️  Found existing batch results!\n');
        
        try
            % Read existing results
            existing_table = readtable(batch_results_csv);
            n_completed = height(existing_table);
            fprintf('   Completed: %d/%d batches\n', n_completed, batch_count);
            
            % Verify seeds match
            if isfile(seeds_csv)
                saved_seeds = readmatrix(seeds_csv);
                if isequal(saved_seeds, seeds)
                    val = input('   Resume from checkpoint? [y/n] [default=y]: ', 's');
                    if isempty(val) || strcmpi(val, 'y')
                        fprintf('   → Resuming from batch %d...\n\n', n_completed + 1);
                        start_batch = n_completed + 1;
                        
                        % Pre-fill completed results
                        for i = 1:n_completed
                            if i <= height(existing_table)
                                seed_col(i) = existing_table.seed(i);
                                prod_col(i) = existing_table.products_final(i);
                            end
                        end
                    else
                        fprintf('   → Starting fresh (existing results will be overwritten)\n\n');
                        delete(batch_results_csv);
                    end
                else
                    fprintf('   ⚠️  Seeds do not match. Starting fresh.\n\n');
                    delete(batch_results_csv);
                end
            end
        catch ME
            fprintf('   ⚠️  Failed to load existing results: %s\n', ME.message);
            fprintf('   Starting fresh.\n\n');
        end
    end
    
    fprintf('Checkpoint protection enabled: results saved after each batch\n');
    fprintf('Results file: %s\n', batch_results_csv);
end

% Preallocate output columns
seed_col          = zeros(batch_count,1);
prod_col          = nan(batch_count,1);
mode_col          = strings(batch_count,1);
enz_col           = zeros(batch_count,1);
gox_col           = zeros(batch_count,1);
hrp_col           = zeros(batch_count,1);
substrate_col     = zeros(batch_count,1);
dt_col            = zeros(batch_count,1);
total_time_col    = zeros(batch_count,1);

% Time-series data collection (for multi-batch runs)
time_axis = [];
product_curves = [];

% Extract static configuration values
batch_config = extract_batch_config(config);
sim_mode = batch_config.sim_mode;
N_total = batch_config.N_total;
gox_n = batch_config.gox_n;
hrp_n = batch_config.hrp_n;
num_sub = batch_config.num_sub;
dt = batch_config.dt;
T_total = batch_config.T_total;
use_gpu_mode = batch_config.use_gpu_mode;

fprintf('Starting batch execution: %d jobs\n', batch_count);

% Only use parallel for multiple batches
if batch_count == 1
    fprintf('Single batch: using serial execution (parallel not needed)\n');
    use_parfor = false;
else
    % Automatically detect and configure parallel pool
    pool_config = auto_configure_parallel(config); % [auto_configure_parallel()](auto_configure_parallel.m:1)
    use_parfor = pool_config.use_parfor;
    
    if ~use_parfor
        fprintf('Parallel mode: DISABLED (using serial for loop)\n');
    end
end

if use_parfor && batch_count > 1
    % Parallel execution with parfor
    fprintf('Executing %d batches in parallel...\n', batch_count);
    parfor b = 1:batch_count
        s = seeds(b);
        % Initialize RNG for this batch
        setup_rng(s, use_gpu_mode); % [setup_rng()](../rng/setup_rng.m:1)    
        
        % Execute simulation
        results = simulate_once(config, s); % [simulate_once()](../sim_core/simulate_once.m:1)
        
        % Capture summary fields
        [seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col] = ...
            record_batch_result(b, s, results, batch_config, ...
                               seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col);
        
        fprintf('  > %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
            b, batch_count, s, prod_col(b), sim_mode);
    end
else
    % Serial execution with regular for loop
    for b = start_batch:batch_count
        s = seeds(b);
        % Initialize RNG for this batch
        setup_rng(s, use_gpu_mode); % [setup_rng()](../rng/setup_rng.m:1)    
        
        % Execute simulation
        results = simulate_once(config, s); % [simulate_once()](../sim_core/simulate_once.m:1)
        
        % Capture summary fields
        [seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col] = ...
            record_batch_result(b, s, results, batch_config, ...
                               seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col);
        
        % Collect time-series data (for multi-batch runs)
        if batch_count > 1
            t_axis = getfield_or(results, 'time_axis', []);
            p_curve = getfield_or(results, 'product_curve', []);
            
            if b == start_batch
                % Initialize on first batch
                time_axis = t_axis(:);
                n_steps = numel(time_axis);
                product_curves = zeros(n_steps, batch_count);
            end
            
            % Store curve
            if ~isempty(p_curve) && numel(p_curve) == numel(time_axis)
                product_curves(:, b) = p_curve(:);
            elseif ~isempty(p_curve)
                % Interpolate if length mismatch
                product_curves(:, b) = interp1(1:numel(p_curve), p_curve(:), ...
                                               linspace(1, numel(p_curve), numel(time_axis)), ...
                                               'linear', 'extrap');
            else
                % Fallback: use final value
                product_curves(:, b) = prod_col(b);
            end
        end
        
        % Real-time CSV save (checkpoint protection)
        if enable_checkpoint
            try
                % Assemble current batch result
                row = table(...
                    b, s, prod_col(b), string(sim_mode), ...
                    N_total, gox_n, hrp_n, num_sub, dt, T_total, ...
                    'VariableNames', {'batch_index','seed','products_final','mode', ...
                                     'num_enzymes','gox_count','hrp_count', ...
                                     'num_substrate','dt','total_time'});
                
                % Write to CSV (append mode for subsequent batches)
                if b == start_batch && start_batch == 1
                    % First batch: create new file
                    writetable(row, batch_results_csv);
                else
                    % Subsequent batches: append
                    writetable(row, batch_results_csv, 'WriteMode', 'append');
                end
                
                fprintf('  ✓ %d/%d | Seed=%d | Products=%g | Saved\n', ...
                    b, batch_count, s, prod_col(b));
            catch ME
                fprintf('  ⚠️  Failed to save batch %d: %s\n', b, ME.message);
                fprintf('  > %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
                    b, batch_count, s, prod_col(b), sim_mode);
            end
        else
            fprintf('  > %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
                b, batch_count, s, prod_col(b), sim_mode);
        end
    end
end

% Assemble table
batch_table = table(...
    (1:batch_count).', seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, ...
    substrate_col, dt_col, total_time_col, ...
    'VariableNames', {'batch_index','seed','products_final','mode','num_enzymes','gox_count','hrp_count','num_substrate','dt','total_time'} ...
);

% Completion message
if enable_checkpoint
    fprintf('  ✓ All batches complete. Results saved to: %s\n', batch_results_csv);
end

% Save time-series data (if enabled and multi-batch)
if batch_count > 1 && ~isempty(time_axis) && ~isempty(product_curves)
    save_ts = true;
    if isfield(config, 'io') && isfield(config.io, 'save_timeseries')
        save_ts = config.io.save_timeseries;
    end
    
    if save_ts
        try
            ts_basename = sprintf('timeseries_products_%s', lower(sim_mode));
            ts_csv = save_timeseries(time_axis, product_curves, data_dir, ts_basename);
            fprintf('  ✓ Time-series data saved: %s\n', ts_csv);
        catch ME
            fprintf('  ⚠️  Failed to save time-series: %s\n', ME.message);
        end
    end
end

end

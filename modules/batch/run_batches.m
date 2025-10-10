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

% Extract static configuration values
sim_mode    = config.simulation_params.simulation_mode;
N_total     = config.particle_params.num_enzymes;
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count')
    gox_n = config.particle_params.gox_count;
    hrp_n = config.particle_params.hrp_count;
else
    r = config.particle_params.gox_hrp_split;
    gox_n = round(N_total * r);
    hrp_n = N_total - gox_n;
end
num_sub     = config.particle_params.num_substrate;
dt          = config.simulation_params.time_step;
T_total     = config.simulation_params.total_time;

% Extract GPU mode
use_gpu_mode = 'auto';
if isfield(config, 'batch') && isfield(config.batch, 'use_gpu')
    use_gpu_mode = config.batch.use_gpu;
end

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
        seed_col(b)       = s;
        if isfield(results, 'products_final')
            prod_col(b) = results.products_final;
        else
            prod_col(b) = NaN;
        end
        mode_col(b)       = string(sim_mode);
        enz_col(b)        = N_total;
        gox_col(b)        = gox_n;
        hrp_col(b)        = hrp_n;
        substrate_col(b)  = num_sub;
        dt_col(b)         = dt;
        total_time_col(b) = T_total;
        
        fprintf('  > %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
            b, batch_count, s, prod_col(b), sim_mode);
    end
else
    % Serial execution with regular for loop
    for b = 1:batch_count
        s = seeds(b);
        % Initialize RNG for this batch
        setup_rng(s, use_gpu_mode); % [setup_rng()](../rng/setup_rng.m:1)    
        
        % Execute simulation
        results = simulate_once(config, s); % [simulate_once()](../sim_core/simulate_once.m:1)
        
        % Capture summary fields
        seed_col(b)       = s;
        if isfield(results, 'products_final')
            prod_col(b) = results.products_final;
        else
            prod_col(b) = NaN;
        end
        mode_col(b)       = string(sim_mode);
        enz_col(b)        = N_total;
        gox_col(b)        = gox_n;
        hrp_col(b)        = hrp_n;
        substrate_col(b)  = num_sub;
        dt_col(b)         = dt;
        total_time_col(b) = T_total;
        
        fprintf('  > %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
            b, batch_count, s, prod_col(b), sim_mode);
    end
end

% Assemble table
batch_table = table(...
    (1:batch_count).', seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, ...
    substrate_col, dt_col, total_time_col, ...
    'VariableNames', {'batch_index','seed','products_final','mode','num_enzymes','gox_count','hrp_count','num_substrate','dt','total_time'} ...
);

end

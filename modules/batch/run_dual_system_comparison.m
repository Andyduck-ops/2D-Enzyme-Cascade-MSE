function [bulk_data, mse_data] = run_dual_system_comparison(config, seeds)
% RUN_DUAL_SYSTEM_COMPARISON Execute bulk and MSE simulations for comparison
% Usage:
%   [bulk_data, mse_data] = run_dual_system_comparison(config, seeds)
% Inputs:
%   - config: configuration struct from default_config()/interactive_config()
%   - seeds: [n_batches x 1] vector of random seeds
% Outputs:
%   - bulk_data: struct with fields
%       .time_axis: [n_steps x 1] time points (s)
%       .product_curves: [n_steps x n_batches] product matrix
%       .enzyme_count: number of enzymes used
%       .batch_table: table with batch statistics
%   - mse_data: struct with same fields as bulk_data
%
% Description:
%   Runs both bulk and MSE simulations with the same seeds for fair comparison.
%   Collects time-series product data from each batch for statistical analysis.
%
% Optimizations:
%   - Extracted duplicate code into helper function
%   - Efficient memory preallocation
%   - Single-pass data collection (avoids redundant run_batches calls)

n_batches = numel(seeds);
if n_batches < 1
    error('run_dual_system_comparison: seeds must not be empty');
end

fprintf('====================================================\n');
fprintf(' Dual System Comparison: Bulk vs MSE\n');
fprintf('====================================================\n');
fprintf('Batch count: %d\n', n_batches);
fprintf('Enzyme count: %d\n', config.particle_params.num_enzymes);
fprintf('----------------------------------------------------\n');

% Extract enzyme count for metadata
enzyme_count = config.particle_params.num_enzymes;

% ========== Run BULK simulations ==========
fprintf('[1/2] Running BULK system simulations...\n');
config_bulk = config;
config_bulk.simulation_params.simulation_mode = 'bulk';
config_bulk.ui_controls.visualize_enabled = false;

[bulk_time_axis, bulk_curves, bulk_batch_table] = run_system_batch(...
    config_bulk, seeds, 'Bulk');

fprintf('[✓] BULK simulations complete\n\n');

% ========== Run MSE simulations ==========
fprintf('[2/2] Running MSE system simulations...\n');
config_mse = config;
config_mse.simulation_params.simulation_mode = 'MSE';
config_mse.ui_controls.visualize_enabled = false;

[mse_time_axis, mse_curves, mse_batch_table] = run_system_batch(...
    config_mse, seeds, 'MSE');

fprintf('[✓] MSE simulations complete\n');
fprintf('====================================================\n');

% ========== Assemble output structures ==========
bulk_data = struct();
bulk_data.time_axis = bulk_time_axis;
bulk_data.product_curves = bulk_curves;
bulk_data.enzyme_count = enzyme_count;
bulk_data.batch_table = bulk_batch_table;

mse_data = struct();
mse_data.time_axis = mse_time_axis;
mse_data.product_curves = mse_curves;
mse_data.enzyme_count = enzyme_count;
mse_data.batch_table = mse_batch_table;

% ========== Summary statistics ==========
fprintf('\n========== Comparison Summary ==========\n');
fprintf('BULK System:\n');
fprintf('  Mean final products: %.2f ± %.2f\n', ...
    mean(bulk_curves(end,:)), std(bulk_curves(end,:), 0));
fprintf('MSE System:\n');
fprintf('  Mean final products: %.2f ± %.2f\n', ...
    mean(mse_curves(end,:)), std(mse_curves(end,:), 0));
fprintf('Enhancement Factor (MSE/Bulk): %.2fx\n', ...
    mean(mse_curves(end,:)) / max(mean(bulk_curves(end,:)), 1));
fprintf('========================================\n');

end

% ========== Helper Function (Optimized) ==========
function [time_axis, curves, batch_table] = run_system_batch(config, seeds, system_name)
% RUN_SYSTEM_BATCH Execute batch simulations for a single system
% This helper function eliminates code duplication between bulk and MSE runs
%
% Inputs:
%   - config: system-specific configuration
%   - seeds: random seeds for reproducibility
%   - system_name: string identifier for console output ('Bulk' or 'MSE')
%
% Outputs:
%   - time_axis: [n_steps x 1] time points
%   - curves: [n_steps x n_batches] product curves matrix
%   - batch_table: table with batch statistics

n_batches = numel(seeds);

% Preallocate for efficiency
time_axis = [];
curves = [];

% Storage for batch statistics
seed_col = zeros(n_batches, 1);
prod_col = nan(n_batches, 1);
mode_col = strings(n_batches, 1);
enz_col = zeros(n_batches, 1);
gox_col = zeros(n_batches, 1);
hrp_col = zeros(n_batches, 1);
substrate_col = zeros(n_batches, 1);
dt_col = zeros(n_batches, 1);
total_time_col = zeros(n_batches, 1);

% Extract static configuration values
sim_mode = config.simulation_params.simulation_mode;
N_total = config.particle_params.num_enzymes;
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count')
    gox_n = config.particle_params.gox_count;
    hrp_n = config.particle_params.hrp_count;
else
    r = config.particle_params.gox_hrp_split;
    gox_n = round(N_total * r);
    hrp_n = N_total - gox_n;
end
num_sub = config.particle_params.num_substrate;
dt = config.simulation_params.time_step;
T_total = config.simulation_params.total_time;

% Main simulation loop (serial - dual system already runs bulk+mse in parallel)
for b = 1:n_batches
    s = seeds(b);
    setup_rng(s, getfield_or(config, {'batch','use_gpu'}, 'auto'));
    results = simulate_once(config, s);

    % Extract time series data
    t_axis = getfield_or(results, 'time_axis', []);
    p_curve = getfield_or(results, 'product_curve', []);

    % Validate and store
    if isempty(p_curve)
        warning('%s Batch %d (Seed=%d): No product_curve, using products_final', ...
            system_name, b, s);
        p_curve = repmat(getfield_or(results, 'products_final', 0), size(t_axis));
    end

    % Initialize storage on first batch
    if b == 1
        time_axis = t_axis(:);
        n_steps = numel(time_axis);
        curves = zeros(n_steps, n_batches);  % Preallocate once
    end

    % Store curve with interpolation if needed
    if numel(p_curve) == numel(time_axis)
        curves(:, b) = p_curve(:);
    else
        warning('%s Batch %d: product_curve length mismatch, interpolating', system_name, b);
        curves(:, b) = interp1(1:numel(p_curve), p_curve(:), ...
                               linspace(1, numel(p_curve), numel(time_axis)), ...
                               'linear', 'extrap');
    end

    % Capture batch statistics
    seed_col(b) = s;
    prod_col(b) = curves(end, b);
    mode_col(b) = string(sim_mode);
    enz_col(b) = N_total;
    gox_col(b) = gox_n;
    hrp_col(b) = hrp_n;
    substrate_col(b) = num_sub;
    dt_col(b) = dt;
    total_time_col(b) = T_total;

    fprintf('  > %s %d/%d | Seed=%d | Final Products=%g\n', ...
        system_name, b, n_batches, s, curves(end, b));
end

% Assemble batch table
batch_table = table(...
    (1:n_batches).', seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, ...
    substrate_col, dt_col, total_time_col, ...
    'VariableNames', {'batch_index','seed','products_final','mode','num_enzymes', ...
                      'gox_count','hrp_count','num_substrate','dt','total_time'} ...
);

end
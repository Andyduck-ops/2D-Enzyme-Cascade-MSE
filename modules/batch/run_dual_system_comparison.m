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
config_bulk.ui_controls.visualize_enabled = false;  % Disable viz for batch

% Preallocate storage
bulk_curves = [];
bulk_time_axis = [];

for b = 1:n_batches
    s = seeds(b);
    setup_rng(s, getfield_or(config, {'batch','use_gpu'}, 'auto'));
    results = simulate_once(config_bulk, s);

    % Extract time series data
    time_axis = getfield_or(results, 'time_axis', []);
    product_curve = getfield_or(results, 'product_curve', []);

    % Validate and store
    if isempty(product_curve)
        warning('Batch %d (Seed=%d): No product_curve, using products_final', b, s);
        product_curve = repmat(getfield_or(results, 'products_final', 0), size(time_axis));
    end

    % Initialize storage on first batch
    if b == 1
        bulk_time_axis = time_axis(:);
        n_steps = numel(bulk_time_axis);
        bulk_curves = zeros(n_steps, n_batches);
    end

    % Store curve
    if numel(product_curve) == numel(bulk_time_axis)
        bulk_curves(:, b) = product_curve(:);
    else
        warning('Batch %d: product_curve length mismatch, interpolating', b);
        bulk_curves(:, b) = interp1(1:numel(product_curve), product_curve(:), ...
                                     linspace(1, numel(product_curve), numel(bulk_time_axis)), ...
                                     'linear', 'extrap');
    end

    fprintf('  > Bulk %d/%d | Seed=%d | Final Products=%g\n', ...
        b, n_batches, s, bulk_curves(end, b));
end

% Run standard batch processing for statistics table
bulk_batch_table = run_batches(config_bulk, seeds);

fprintf('[✓] BULK simulations complete\n\n');

% ========== Run MSE simulations ==========
fprintf('[2/2] Running MSE system simulations...\n');
config_mse = config;
config_mse.simulation_params.simulation_mode = 'MSE';
config_mse.ui_controls.visualize_enabled = false;

% Preallocate storage
mse_curves = [];
mse_time_axis = [];

for b = 1:n_batches
    s = seeds(b);
    setup_rng(s, getfield_or(config, {'batch','use_gpu'}, 'auto'));
    results = simulate_once(config_mse, s);

    % Extract time series data
    time_axis = getfield_or(results, 'time_axis', []);
    product_curve = getfield_or(results, 'product_curve', []);

    % Validate and store
    if isempty(product_curve)
        warning('Batch %d (Seed=%d): No product_curve, using products_final', b, s);
        product_curve = repmat(getfield_or(results, 'products_final', 0), size(time_axis));
    end

    % Initialize storage on first batch
    if b == 1
        mse_time_axis = time_axis(:);
        n_steps = numel(mse_time_axis);
        mse_curves = zeros(n_steps, n_batches);
    end

    % Store curve
    if numel(product_curve) == numel(mse_time_axis)
        mse_curves(:, b) = product_curve(:);
    else
        warning('Batch %d: product_curve length mismatch, interpolating', b);
        mse_curves(:, b) = interp1(1:numel(product_curve), product_curve(:), ...
                                    linspace(1, numel(product_curve), numel(mse_time_axis)), ...
                                    'linear', 'extrap');
    end

    fprintf('  > MSE %d/%d | Seed=%d | Final Products=%g\n', ...
        b, n_batches, s, mse_curves(end, b));
end

% Run standard batch processing for statistics table
mse_batch_table = run_batches(config_mse, seeds);

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
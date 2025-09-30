%% DEMO_DUAL_SYSTEM_COMPARISON
% Demonstration script for dual-system (Bulk vs MSE) comparison visualization
%
% Features:
%   - Configurable enzyme quantity parameter
%   - Batch Monte Carlo simulations for both systems
%   - Mean±S.D. visualization with shaded error bands
%   - Statistical comparison and enhancement factor calculation
%
% Usage:
%   Simply run this script in MATLAB:
%   >> demo_dual_system_comparison
%
% Output:
%   - Comparison plot saved to out/ directory
%   - CSV reports for both systems
%   - Console summary statistics

clc; clear; close all;

fprintf('====================================================\n');
fprintf(' Demo: Dual System Comparison (Bulk vs MSE)\n');
fprintf('====================================================\n');

% Add module paths
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
else
    error('Module directory not found: %s', modules_dir);
end

%% Configuration Setup
fprintf('\n[1/4] Loading configuration...\n');

% Load default configuration
config = default_config();

% Set output directory
config.io.outdir = fullfile(here, 'out');
if ~exist(config.io.outdir, 'dir')
    mkdir(config.io.outdir);
end

% ========== User-Configurable Parameters ==========
% You can modify these parameters to explore different conditions

% Enzyme quantity (total GOx + HRP count)
config.particle_params.num_enzymes = 400;  % Adjust this value as needed

% Batch count for Monte Carlo sampling
config.batch.batch_count = 20;  % Increase for better statistics (e.g., 50-100)

% Simulation time
config.simulation_params.total_time = 100;  % seconds

% Random seed configuration
config.batch.seed_mode = 'incremental';
config.batch.seed_base = 5000;

fprintf('Configuration loaded:\n');
fprintf('  - Enzyme count: %d\n', config.particle_params.num_enzymes);
fprintf('  - Batch count: %d\n', config.batch.batch_count);
fprintf('  - Total time: %.1f s\n', config.simulation_params.total_time);

%% Generate Seeds
fprintf('\n[2/4] Generating batch seeds...\n');
[seeds, seeds_csv] = get_batch_seeds(config);
fprintf('  - Seeds generated: %d\n', numel(seeds));
fprintf('  - Seed file: %s\n', seeds_csv);

%% Run Dual System Comparison
fprintf('\n[3/4] Running dual system comparison simulations...\n');
fprintf('  This may take several minutes depending on batch count...\n\n');

% Execute bulk and MSE simulations
[bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

fprintf('\n[✓] Simulations complete!\n');

%% Visualization
fprintf('\n[4/4] Generating comparison visualization...\n');

% Create dual-system comparison plot
fig = plot_dual_system_comparison(bulk_data, mse_data, config);

% Save figure
if config.ui_controls.enable_fig_save || true  % Always save demo output
    formats = {'fig', 'png', 'pdf'};
    base_name = sprintf('dual_comparison_enzymes_%d', config.particle_params.num_enzymes);
    try
        saved_paths = save_figures(fig, config.io.outdir, base_name, formats);
        fprintf('Figures saved:\n');
        for i = 1:numel(saved_paths)
            fprintf('  - %s\n', saved_paths{i});
        end
    catch ME
        warning('Failed to save figures: %s', ME.message);
    end
end

%% Save CSV Reports
fprintf('\nSaving CSV reports...\n');

% Save bulk results
bulk_csv = fullfile(config.io.outdir, 'bulk_batch_results.csv');
writetable(bulk_data.batch_table, bulk_csv);
fprintf('  - Bulk: %s\n', bulk_csv);

% Save MSE results
mse_csv = fullfile(config.io.outdir, 'mse_batch_results.csv');
writetable(mse_data.batch_table, mse_csv);
fprintf('  - MSE: %s\n', mse_csv);

%% Final Summary
fprintf('\n====================================================\n');
fprintf(' Dual System Comparison Complete\n');
fprintf('====================================================\n');
fprintf('Configuration:\n');
fprintf('  Enzyme count: %d\n', config.particle_params.num_enzymes);
fprintf('  Batch count: %d\n', config.batch.batch_count);
fprintf('\nResults:\n');
fprintf('  Bulk mean: %.2f ± %.2f products\n', ...
    mean(bulk_data.product_curves(end,:)), std(bulk_data.product_curves(end,:), 0));
fprintf('  MSE mean: %.2f ± %.2f products\n', ...
    mean(mse_data.product_curves(end,:)), std(mse_data.product_curves(end,:), 0));
fprintf('  Enhancement: %.2fx (MSE/Bulk)\n', ...
    mean(mse_data.product_curves(end,:)) / max(mean(bulk_data.product_curves(end,:)), 1));
fprintf('\nOutput files saved to: %s\n', config.io.outdir);
fprintf('====================================================\n');

fprintf('\n✓ Demo completed successfully!\n\n');
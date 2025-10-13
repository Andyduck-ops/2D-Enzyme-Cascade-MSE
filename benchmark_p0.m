% BENCHMARK_P0 Test P0 optimizations (KD-tree + ROI filtering)
%
% Compares baseline (pdist2) vs optimized (rangesearch + ROI)
% for MSE mode simulation

fprintf('=== P0 Optimization Benchmark ===\n\n');

% Load and validate configuration
config = default_config();
config = validate_config(config);

% Short simulation for quick benchmark
config.simulation_params.total_time = 10;  % 10 seconds
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 400;
config.particle_params.num_substrate = 3000;
config.ui_controls.visualize_enabled = false;

seed = 12345;

% -------------------------------------------------------------------------
% Baseline: pdist2 backend (no caching, no ROI)
% -------------------------------------------------------------------------
fprintf('Running BASELINE (pdist2, no ROI)...\n');
config_baseline = config;
config_baseline.compute.neighbor_backend = 'pdist2';

tic;
result_baseline = simulate_once(config_baseline, seed);
time_baseline = toc;

fprintf('  Time: %.2f s\n', time_baseline);
fprintf('  Products: %d\n\n', result_baseline.products_final);

% -------------------------------------------------------------------------
% Optimized: rangesearch backend (KD-tree caching + ROI filtering)
% -------------------------------------------------------------------------
fprintf('Running OPTIMIZED (rangesearch + KD-tree + ROI)...\n');
config_optimized = config;
config_optimized.compute.neighbor_backend = 'rangesearch';

tic;
result_optimized = simulate_once(config_optimized, seed);
time_optimized = toc;

fprintf('  Time: %.2f s\n', time_optimized);
fprintf('  Products: %d\n\n', result_optimized.products_final);

% -------------------------------------------------------------------------
% Results
% -------------------------------------------------------------------------
speedup = time_baseline / time_optimized;
product_diff = abs(result_optimized.products_final - result_baseline.products_final);
product_mse = product_diff / max(result_baseline.products_final, 1);

fprintf('=== RESULTS ===\n');
fprintf('Speedup: %.2fx\n', speedup);
fprintf('Product difference: %d (%.2f%%)\n', product_diff, product_mse * 100);

if product_mse < 0.01
    fprintf('✓ Accuracy: PASS (MSE < 1%%)\n');
else
    fprintf('✗ Accuracy: FAIL (MSE = %.2f%% > 1%%)\n', product_mse * 100);
end

if speedup >= 3.0
    fprintf('✓ Performance: EXCELLENT (%.2fx >= 3x target)\n', speedup);
elseif speedup >= 1.5
    fprintf('✓ Performance: GOOD (%.2fx >= 1.5x minimum)\n', speedup);
else
    fprintf('✗ Performance: BELOW TARGET (%.2fx < 1.5x)\n', speedup);
end

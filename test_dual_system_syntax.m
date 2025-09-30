%% TEST_DUAL_SYSTEM_SYNTAX
% Simple syntax and logic validation script
% Tests the new dual-system comparison modules without running full simulations

clc; clear;

fprintf('==================================================\n');
fprintf(' Syntax Validation: Dual System Comparison\n');
fprintf('==================================================\n\n');

% Add module paths
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
    fprintf('[✓] Module paths added\n');
else
    error('Module directory not found: %s', modules_dir);
end

%% Test 1: Configuration loading
fprintf('\n[Test 1] Configuration loading...\n');
try
    config = default_config();
    fprintf('[✓] default_config() succeeded\n');
    fprintf('    - simulation_mode: %s\n', config.simulation_params.simulation_mode);
    fprintf('    - num_enzymes: %d\n', config.particle_params.num_enzymes);
catch ME
    fprintf('[✗] Failed: %s\n', ME.message);
    return;
end

%% Test 2: Mock data structures
fprintf('\n[Test 2] Creating mock data structures...\n');
try
    n_steps = 100;
    n_batches = 5;

    % Mock bulk data
    bulk_data = struct();
    bulk_data.time_axis = linspace(0, 100, n_steps)';
    bulk_data.product_curves = cumsum(rand(n_steps, n_batches) * 2, 1);
    bulk_data.enzyme_count = 400;

    % Mock MSE data
    mse_data = struct();
    mse_data.time_axis = linspace(0, 100, n_steps)';
    mse_data.product_curves = cumsum(rand(n_steps, n_batches) * 3, 1);
    mse_data.enzyme_count = 400;

    fprintf('[✓] Mock data created\n');
    fprintf('    - bulk curves: %dx%d\n', size(bulk_data.product_curves));
    fprintf('    - mse curves: %dx%d\n', size(mse_data.product_curves));
catch ME
    fprintf('[✗] Failed: %s\n', ME.message);
    return;
end

%% Test 3: Visualization function
fprintf('\n[Test 3] Testing plot_dual_system_comparison()...\n');
try
    fig = plot_dual_system_comparison(bulk_data, mse_data, config);
    fprintf('[✓] plot_dual_system_comparison() succeeded\n');
    fprintf('    - Figure handle: valid\n');

    % Close figure to avoid cluttering
    close(fig);
    fprintf('    - Figure closed\n');
catch ME
    fprintf('[✗] Failed: %s\n', ME.message);
    fprintf('    Stack trace:\n');
    for k = 1:length(ME.stack)
        fprintf('      %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
    end
    return;
end

%% Test 4: Function existence check
fprintf('\n[Test 4] Checking function availability...\n');
functions_to_check = {
    'plot_dual_system_comparison', ...
    'run_dual_system_comparison', ...
    'default_config', ...
    'get_batch_seeds', ...
    'viz_style', ...
    'getfield_or'
};

all_ok = true;
for i = 1:length(functions_to_check)
    fname = functions_to_check{i};
    if exist(fname, 'file') == 2
        fprintf('[✓] %s exists\n', fname);
    else
        fprintf('[✗] %s NOT FOUND\n', fname);
        all_ok = false;
    end
end

%% Summary
fprintf('\n==================================================\n');
if all_ok
    fprintf(' ✓ All syntax validation tests PASSED\n');
    fprintf('==================================================\n');
    fprintf('\nThe dual-system comparison module is ready to use.\n');
    fprintf('To run full simulations, execute:\n');
    fprintf('  >> demo_dual_system_comparison\n\n');
else
    fprintf(' ✗ Some tests FAILED - please check errors above\n');
    fprintf('==================================================\n');
end
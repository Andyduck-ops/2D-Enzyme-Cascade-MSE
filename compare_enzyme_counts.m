function compare_enzyme_counts()
% COMPARE_ENZYME_COUNTS Compare bulk vs MSE across different enzyme counts
% Usage:
%   compare_enzyme_counts()
%
% Description:
%   Interactive script to compare bulk and MSE systems across different
%   enzyme concentrations. Generates a unified plot with multiple curves.
%
% Example Output:
%   4 curves on one plot:
%   - High enzyme Bulk
%   - High enzyme MSE
%   - Low enzyme Bulk
%   - Low enzyme MSE

clc;
fprintf('====================================================\n');
fprintf(' Multi-Enzyme Count Comparison Tool\n');
fprintf('====================================================\n');

% Add module paths
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
end

% ========== Browse Historical Runs ==========
fprintf('\nSearching for dual-mode batch runs...\n');

% Check if out directory exists
if ~exist('out', 'dir')
    fprintf('\n');
    fprintf('====================================================\n');
    fprintf(' No Historical Data Found\n');
    fprintf('====================================================\n');
    fprintf('The ''out/'' directory does not exist yet.\n');
    fprintf('\n');
    fprintf('To use this tool, you need to:\n');
    fprintf('1. Run main_2d_pipeline at least twice\n');
    fprintf('2. Use dual-system comparison mode (answer ''y'' to question 5b)\n');
    fprintf('3. Use different enzyme counts for each run\n');
    fprintf('\n');
    fprintf('Example workflow:\n');
    fprintf('  >> main_2d_pipeline\n');
    fprintf('     Enzymes = 400, Dual = y, Batches = 10\n');
    fprintf('  >> main_2d_pipeline\n');
    fprintf('     Enzymes = 20, Dual = y, Batches = 10\n');
    fprintf('  >> compare_enzyme_counts\n');
    fprintf('====================================================\n');
    return;
end

history_table = browse_history('batch', 'out');

if isempty(history_table)
    fprintf('\n');
    fprintf('====================================================\n');
    fprintf(' No Batch Runs Found\n');
    fprintf('====================================================\n');
    fprintf('No batch simulation runs found in out/batch/\n');
    fprintf('\n');
    fprintf('Please run some dual-mode batch simulations first:\n');
    fprintf('  >> main_2d_pipeline\n');
    fprintf('     Select dual-system comparison mode\n');
    fprintf('====================================================\n');
    return;
end

% Filter for dual-mode runs only
dual_mask = strcmp(history_table.mode, 'dual');
dual_runs = history_table(dual_mask, :);

if isempty(dual_runs)
    error('No dual-mode runs found. Please run dual-system comparison simulations first.');
end

% ========== Display Available Runs ==========
fprintf('\nAvailable dual-mode runs:\n');
fprintf('%-5s %-20s %-8s %-8s %-12s\n', ...
        'Index', 'Timestamp', 'Enzymes', 'Substrate', 'Batches');
fprintf('%s\n', repmat('-', 1, 60));

for i = 1:height(dual_runs)
    row = dual_runs(i, :);
    fprintf('%-5d %-20s %-8d %-8d %-12d\n', ...
            i, char(row.timestamp), row.num_enzymes, ...
            row.num_substrate, row.batch_count_or_seed);
end

fprintf('%s\n', repmat('-', 1, 60));

% ========== Get User Selection ==========
fprintf('\nSelect runs to compare (e.g., "1,2" for two enzyme counts):\n');
fprintf('Tip: Select runs with different enzyme counts for best comparison\n');
selection_str = input('Enter selection: ', 's');

if isempty(selection_str)
    error('No selection made');
end

% Parse selection
selected_indices = parse_selection(selection_str, height(dual_runs));

if isempty(selected_indices)
    error('Invalid selection');
end

fprintf('Selected %d run(s)\n', numel(selected_indices));

% ========== Load Data ==========
fprintf('\n====================================================\n');
fprintf(' Loading Data\n');
fprintf('====================================================\n');

datasets = struct([]);

for i = 1:numel(selected_indices)
    idx = selected_indices(i);
    row = dual_runs(idx, :);
    
    fprintf('\n--- Loading Run %d/%d ---\n', i, numel(selected_indices));
    fprintf('Timestamp: %s | Enzymes: %d\n', ...
            char(row.timestamp), row.num_enzymes);
    
    % Load data
    try
        data = load_run_data(char(row.dir_path), 'both');
        
        % Create label prefix
        ts_short = format_timestamp(char(row.timestamp));
        label_prefix = sprintf('[%s] enz=%d', ts_short, row.num_enzymes);
        
        % Add bulk dataset
        ds_bulk = struct();
        ds_bulk.time_axis = data.bulk.time_axis;
        ds_bulk.product_curves = data.bulk.product_curves;
        ds_bulk.label = sprintf('%s Bulk', label_prefix);
        ds_bulk.metadata = data.metadata;
        datasets = [datasets; ds_bulk];
        
        % Add MSE dataset
        ds_mse = struct();
        ds_mse.time_axis = data.mse.time_axis;
        ds_mse.product_curves = data.mse.product_curves;
        ds_mse.label = sprintf('%s MSE', label_prefix);
        ds_mse.metadata = data.metadata;
        datasets = [datasets; ds_mse];
        
        fprintf('✓ Loaded: Bulk + MSE\n');
        
    catch ME
        fprintf('Error loading run: %s\n', ME.message);
        continue;
    end
end

if isempty(datasets)
    error('No datasets loaded successfully');
end

% ========== Generate Comparison Plot ==========
fprintf('\n====================================================\n');
fprintf(' Generating Comparison Plot\n');
fprintf('====================================================\n');
fprintf('Total curves: %d\n', numel(datasets));

% Load default config for styling
config = default_config();

% Generate plot
try
    fig = plot_multi_comparison(datasets, config);
    
    % Update title
    title('Enzyme Count Comparison: Bulk vs MSE', ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    % Save figure
    fprintf('\nSave figure? [y/n]: ');
    save_choice = input('', 's');
    
    if strcmpi(save_choice, 'y')
        comp_dir = fullfile('out', 'comparisons');
        if ~exist(comp_dir, 'dir')
            mkdir(comp_dir);
        end
        
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        base_name = sprintf('enzyme_comparison_%s_n%d', timestamp, numel(datasets));
        formats = {'fig', 'png', 'pdf'};
        
        saved_paths = save_figures(fig, comp_dir, base_name, formats);
        fprintf('Saved %d files to: %s\n', numel(saved_paths), comp_dir);
        for j = 1:numel(saved_paths)
            fprintf('  - %s\n', saved_paths{j});
        end
    end
    
    fprintf('\n✓ Comparison plot generated successfully\n');
    
catch ME
    fprintf('Error generating plot: %s\n', ME.message);
    fprintf('Stack trace:\n');
    disp(ME.stack);
end

fprintf('\n====================================================\n');
fprintf(' Comparison Complete\n');
fprintf('====================================================\n');

end

% ========== Helper Functions ==========
function indices = parse_selection(selection_str, max_index)
% Parse selection string to index array

indices = [];
parts = strsplit(selection_str, ',');

for i = 1:numel(parts)
    part = strtrim(parts{i});
    
    if contains(part, '-')
        % Range
        range_parts = strsplit(part, '-');
        if numel(range_parts) == 2
            start_idx = str2double(strtrim(range_parts{1}));
            end_idx = str2double(strtrim(range_parts{2}));
            
            if isfinite(start_idx) && isfinite(end_idx) && ...
               start_idx >= 1 && end_idx <= max_index && start_idx <= end_idx
                indices = [indices, start_idx:end_idx];
            end
        end
    else
        % Single index
        idx = str2double(part);
        if isfinite(idx) && idx >= 1 && idx <= max_index
            indices = [indices, idx];
        end
    end
end

indices = unique(indices);
end

function ts_short = format_timestamp(timestamp)
% Format timestamp to short format

try
    dt = datetime(timestamp, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    ts_short = datestr(dt, 'mm/dd HH:MM');
catch
    if length(timestamp) >= 16
        ts_short = sprintf('%s/%s %s:%s', ...
                          timestamp(6:7), timestamp(9:10), ...
                          timestamp(12:13), timestamp(15:16));
    else
        ts_short = timestamp;
    end
end
end

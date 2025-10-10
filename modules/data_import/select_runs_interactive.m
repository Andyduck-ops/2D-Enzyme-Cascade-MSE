function selected_runs = select_runs_interactive(run_type, base_dir)
% SELECT_RUNS_INTERACTIVE Interactive selection of historical runs
% Usage:
%   selected_runs = select_runs_interactive()
%   selected_runs = select_runs_interactive(run_type)
%   selected_runs = select_runs_interactive(run_type, base_dir)
%
% Inputs:
%   - run_type: 'single', 'batch', or 'all' (default: 'all')
%   - base_dir: base output directory (default: 'out')
%
% Output:
%   - selected_runs: struct array with fields:
%       .dir_path: path to run directory
%       .metadata: run metadata struct
%       .label: display label for plots
%       .system: for dual runs, 'bulk', 'mse', or 'both'
%       .data: loaded data struct (from load_run_data)
%
% Description:
%   Provides interactive interface for selecting historical runs.
%   Displays formatted table of available runs.
%   Supports multiple selection (comma-separated or ranges).
%   For dual-mode runs, asks which system(s) to import.

if nargin < 1 || isempty(run_type)
    run_type = 'all';
end

if nargin < 2 || isempty(base_dir)
    base_dir = 'out';
end

% ========== Browse Available Runs ==========
fprintf('\n====================================================\n');
fprintf(' Historical Run Selection\n');
fprintf('====================================================\n');

history_table = browse_history(run_type, base_dir);

if isempty(history_table)
    fprintf('No historical runs found.\n');
    selected_runs = struct([]);
    return;
end

% ========== Display Table ==========
fprintf('\nAvailable runs:\n');
fprintf('%-5s %-20s %-8s %-8s %-8s %-12s %-8s\n', ...
        'Index', 'Timestamp', 'Mode', 'Enzymes', 'Substrate', 'Batch/Seed', 'Type');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:height(history_table)
    row = history_table(i, :);
    fprintf('%-5d %-20s %-8s %-8d %-8d %-12d %-8s\n', ...
            row.index, char(row.timestamp), char(row.mode), ...
            row.num_enzymes, row.num_substrate, row.batch_count_or_seed, ...
            char(row.run_type));
end

fprintf('%s\n', repmat('-', 1, 80));

% ========== Get User Selection ==========
fprintf('\nSelect runs to import:\n');
fprintf('  - Single: 3\n');
fprintf('  - Multiple: 1,3,5\n');
fprintf('  - Range: 1-3\n');
fprintf('  - Mixed: 1-3,5,7\n');

selection_str = input('Enter selection: ', 's');

if isempty(selection_str)
    fprintf('No selection made.\n');
    selected_runs = struct([]);
    return;
end

% Parse selection
selected_indices = parse_selection(selection_str, height(history_table));

if isempty(selected_indices)
    fprintf('Invalid selection.\n');
    selected_runs = struct([]);
    return;
end

fprintf('Selected %d run(s)\n', numel(selected_indices));

% ========== Process Selected Runs ==========
selected_runs = struct([]);

for i = 1:numel(selected_indices)
    idx = selected_indices(i);
    row = history_table(idx, :);
    
    fprintf('\n--- Processing Run %d/%d ---\n', i, numel(selected_indices));
    fprintf('Timestamp: %s | Mode: %s | Enzymes: %d\n', ...
            char(row.timestamp), char(row.mode), row.num_enzymes);
    
    % Determine system selection for dual runs
    system_filter = 'both';
    if strcmp(row.mode, 'dual')
        fprintf('This is a dual-mode run (bulk + MSE).\n');
        fprintf('Which system(s) to import?\n');
        fprintf('  [1] Bulk only\n');
        fprintf('  [2] MSE only\n');
        fprintf('  [3] Both (default)\n');
        
        choice = input('Enter choice [1-3]: ', 's');
        if isempty(choice)
            choice = '3';
        end
        
        switch choice
            case '1'
                system_filter = 'bulk';
            case '2'
                system_filter = 'mse';
            case '3'
                system_filter = 'both';
            otherwise
                fprintf('Invalid choice, using both systems.\n');
                system_filter = 'both';
        end
    end
    
    % Load data
    try
        data = load_run_data(char(row.dir_path), system_filter);
        
        % Create label for plotting
        ts_short = format_timestamp(char(row.timestamp));
        label = sprintf('[%s] %s enz=%d sub=%d', ...
                       ts_short, char(row.mode), row.num_enzymes, row.num_substrate);
        
        % Add to selected runs
        if strcmp(row.mode, 'dual') && strcmp(system_filter, 'both')
            % Add bulk system
            run_struct = struct();
            run_struct.dir_path = char(row.dir_path);
            run_struct.metadata = data.metadata;
            run_struct.label = [label ' (bulk)'];
            run_struct.system = 'bulk';
            run_struct.data = data.bulk;
            selected_runs = [selected_runs; run_struct];
            
            % Add MSE system
            run_struct = struct();
            run_struct.dir_path = char(row.dir_path);
            run_struct.metadata = data.metadata;
            run_struct.label = [label ' (mse)'];
            run_struct.system = 'mse';
            run_struct.data = data.mse;
            selected_runs = [selected_runs; run_struct];
        else
            % Add single system
            run_struct = struct();
            run_struct.dir_path = char(row.dir_path);
            run_struct.metadata = data.metadata;
            run_struct.label = label;
            run_struct.system = system_filter;
            run_struct.data = data;
            selected_runs = [selected_runs; run_struct];
        end
        
    catch ME
        fprintf('Error loading run: %s\n', ME.message);
        continue;
    end
end

fprintf('\n====================================================\n');
fprintf('Successfully loaded %d dataset(s)\n', numel(selected_runs));
fprintf('====================================================\n\n');

end

% ========== Helper Functions ==========
function indices = parse_selection(selection_str, max_index)
% PARSE_SELECTION Parse selection string to index array
% Supports: "1", "1,3,5", "1-3", "1-3,5,7"

indices = [];

% Split by comma
parts = strsplit(selection_str, ',');

for i = 1:numel(parts)
    part = strtrim(parts{i});
    
    if contains(part, '-')
        % Range: "1-3"
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
        % Single index: "3"
        idx = str2double(part);
        if isfinite(idx) && idx >= 1 && idx <= max_index
            indices = [indices, idx];
        end
    end
end

% Remove duplicates and sort
indices = unique(indices);
end

function ts_short = format_timestamp(timestamp)
% FORMAT_TIMESTAMP Convert timestamp to short format for display
% Input: "2025-10-10T14:30:22"
% Output: "10/10 14:30"

try
    dt = datetime(timestamp, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    ts_short = datestr(dt, 'mm/dd HH:MM');
catch
    % Fallback: extract manually
    if length(timestamp) >= 16
        ts_short = sprintf('%s/%s %s:%s', ...
                          timestamp(6:7), timestamp(9:10), ...
                          timestamp(12:13), timestamp(15:16));
    else
        ts_short = timestamp;
    end
end
end

function browse_history_cli(run_type, base_dir)
% BROWSE_HISTORY_CLI Command-line interface for browsing historical runs
% Usage:
%   browse_history_cli()              % Browse all runs
%   browse_history_cli('batch')       % Browse batch runs only
%   browse_history_cli('single')      % Browse single runs only
%   browse_history_cli('all', 'out')  % Specify base directory
%
% Description:
%   Standalone script for browsing historical simulation runs.
%   Displays formatted table with key information.
%   Useful for quick inspection without running full pipeline.

if nargin < 1 || isempty(run_type)
    run_type = 'all';
end

if nargin < 2 || isempty(base_dir)
    base_dir = 'out';
end

% Add module paths
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
end

% ========== Browse History ==========
fprintf('\n====================================================\n');
fprintf(' Historical Run Browser\n');
fprintf('====================================================\n');
fprintf('Base directory: %s\n', base_dir);
fprintf('Run type filter: %s\n', run_type);
fprintf('----------------------------------------------------\n\n');

try
    history_table = browse_history(run_type, base_dir);
    
    if isempty(history_table)
        fprintf('No historical runs found.\n');
        return;
    end
    
    % ========== Display Table ==========
    fprintf('Found %d run(s):\n\n', height(history_table));
    
    % Header
    fprintf('%-5s %-20s %-8s %-8s %-8s %-12s %-8s\n', ...
            'Index', 'Timestamp', 'Mode', 'Enzymes', 'Substrate', 'Batch/Seed', 'Type');
    fprintf('%s\n', repmat('-', 1, 80));
    
    % Rows
    for i = 1:height(history_table)
        row = history_table(i, :);
        fprintf('%-5d %-20s %-8s %-8d %-8d %-12d %-8s\n', ...
                row.index, char(row.timestamp), char(row.mode), ...
                row.num_enzymes, row.num_substrate, row.batch_count_or_seed, ...
                char(row.run_type));
    end
    
    fprintf('%s\n', repmat('-', 1, 80));
    fprintf('Total: %d run(s)\n', height(history_table));
    
    % ========== Summary Statistics ==========
    fprintf('\n--- Summary Statistics ---\n');
    
    % Count by type
    if strcmp(run_type, 'all')
        n_single = sum(strcmp(history_table.run_type, 'single'));
        n_batch = sum(strcmp(history_table.run_type, 'batch'));
        fprintf('Single runs: %d\n', n_single);
        fprintf('Batch runs: %d\n', n_batch);
    end
    
    % Count by mode
    modes = unique(history_table.mode);
    fprintf('Modes: ');
    for i = 1:numel(modes)
        mode = char(modes(i));
        count = sum(strcmp(history_table.mode, mode));
        fprintf('%s(%d) ', mode, count);
    end
    fprintf('\n');
    
    % Date range
    if height(history_table) > 0
        fprintf('Date range: %s to %s\n', ...
                char(history_table.timestamp(end)), ...
                char(history_table.timestamp(1)));
    end
    
    fprintf('====================================================\n\n');
    
catch ME
    fprintf('Error browsing history: %s\n', ME.message);
    fprintf('Stack trace:\n');
    disp(ME.stack);
end

end

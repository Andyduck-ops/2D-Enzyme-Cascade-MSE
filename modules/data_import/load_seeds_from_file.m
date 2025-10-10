function [seeds, seed_source] = load_seeds_from_file(desired_batch_count, base_dir)
% LOAD_SEEDS_FROM_FILE Load seeds from a historical run
% Usage:
%   [seeds, seed_source] = load_seeds_from_file(desired_batch_count)
%   [seeds, seed_source] = load_seeds_from_file(desired_batch_count, base_dir)
%
% Inputs:
%   - desired_batch_count: number of seeds needed for current run
%   - base_dir: base output directory (default: 'out')
%
% Outputs:
%   - seeds: [n x 1] array of seeds
%   - seed_source: struct with source information
%       .source_run: path to source run directory
%       .source_file: path to seeds.csv file
%       .original_count: original number of seeds in file
%       .adjustment: 'none', 'truncated', 'cycled', or 'batch_adjusted'
%
% Description:
%   Interactively selects a historical batch run and loads its seeds.
%   Handles seed count mismatches:
%     - If counts match: use as-is
%     - If file has more seeds: truncate with warning
%     - If file has fewer seeds: ask user to adjust batch count or cycle
%
% Example:
%   [seeds, info] = load_seeds_from_file(10);

if nargin < 2 || isempty(base_dir)
    base_dir = 'out';
end

fprintf('\n====================================================\n');
fprintf(' Load Seeds from Historical Run\n');
fprintf('====================================================\n');

% ========== Browse Batch Runs ==========
history_table = browse_history('batch', base_dir);

if isempty(history_table)
    error('No historical batch runs found');
end

% ========== Display Available Runs ==========
fprintf('\nAvailable batch runs:\n');
fprintf('%-5s %-20s %-8s %-8s %-8s %-12s\n', ...
        'Index', 'Timestamp', 'Mode', 'Enzymes', 'Substrate', 'Batches');
fprintf('%s\n', repmat('-', 1, 70));

for i = 1:height(history_table)
    row = history_table(i, :);
    fprintf('%-5d %-20s %-8s %-8d %-8d %-12d\n', ...
            row.index, char(row.timestamp), char(row.mode), ...
            row.num_enzymes, row.num_substrate, row.batch_count_or_seed);
end

fprintf('%s\n', repmat('-', 1, 70));

% ========== Get User Selection ==========
selection = input(sprintf('Select run to load seeds from [1-%d]: ', height(history_table)));

if isempty(selection) || ~isnumeric(selection) || ...
   selection < 1 || selection > height(history_table)
    error('Invalid selection');
end

selected_row = history_table(selection, :);
run_dir = char(selected_row.dir_path);

fprintf('\nSelected: %s | Mode: %s | %d batches\n', ...
        char(selected_row.timestamp), char(selected_row.mode), ...
        selected_row.batch_count_or_seed);

% ========== Load Seeds File ==========
seeds_file = fullfile(run_dir, 'data', 'seeds.csv');

if ~exist(seeds_file, 'file')
    error('Seeds file not found: %s', seeds_file);
end

try
    seeds_table = readtable(seeds_file);
    
    % Extract seed column
    if ismember('seed', seeds_table.Properties.VariableNames)
        file_seeds = seeds_table.seed;
    else
        % Fallback: assume second column is seed
        file_seeds = seeds_table{:, 2};
    end
    
    original_count = numel(file_seeds);
    fprintf('Loaded %d seeds from file\n', original_count);
    
catch ME
    error('Failed to read seeds file: %s', ME.message);
end

% ========== Handle Seed Count Mismatch ==========
seed_source = struct();
seed_source.source_run = run_dir;
seed_source.source_file = seeds_file;
seed_source.original_count = original_count;

if original_count == desired_batch_count
    % Perfect match
    seeds = file_seeds;
    seed_source.adjustment = 'none';
    fprintf('✓ Seed count matches desired batch count (%d)\n', desired_batch_count);
    
elseif original_count > desired_batch_count
    % More seeds than needed - truncate
    seeds = file_seeds(1:desired_batch_count);
    seed_source.adjustment = 'truncated';
    fprintf('⚠ File has more seeds (%d) than needed (%d)\n', original_count, desired_batch_count);
    fprintf('  Using first %d seeds\n', desired_batch_count);
    
else
    % Fewer seeds than needed
    fprintf('\n⚠ File has fewer seeds (%d) than needed (%d)\n', original_count, desired_batch_count);
    fprintf('Options:\n');
    fprintf('  [1] Adjust batch count to %d (recommended)\n', original_count);
    fprintf('  [2] Cycle/repeat seeds to reach %d batches\n', desired_batch_count);
    fprintf('  [3] Cancel\n');
    
    choice = input('Select option [1-3]: ', 's');
    
    switch choice
        case '1'
            % Adjust batch count
            seeds = file_seeds;
            seed_source.adjustment = 'batch_adjusted';
            fprintf('✓ Batch count adjusted to %d\n', original_count);
            
        case '2'
            % Cycle seeds
            reps = ceil(desired_batch_count / original_count);
            seeds = repmat(file_seeds, reps, 1);
            seeds = seeds(1:desired_batch_count);
            seed_source.adjustment = 'cycled';
            fprintf('✓ Seeds cycled to reach %d batches\n', desired_batch_count);
            fprintf('  (Seeds will repeat after every %d batches)\n', original_count);
            
        otherwise
            error('Seed loading cancelled');
    end
end

% ========== Summary ==========
fprintf('\n====================================================\n');
fprintf('Seeds loaded successfully\n');
fprintf('Source: %s\n', seed_source.source_run);
fprintf('Count: %d seeds\n', numel(seeds));
fprintf('Adjustment: %s\n', seed_source.adjustment);
fprintf('====================================================\n\n');

end

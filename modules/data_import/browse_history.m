function history_table = browse_history(run_type, base_dir)
% BROWSE_HISTORY Browse and list historical simulation runs
% Usage:
%   history_table = browse_history()
%   history_table = browse_history(run_type)
%   history_table = browse_history(run_type, base_dir)
%
% Inputs:
%   - run_type: 'single', 'batch', or 'all' (default: 'all')
%   - base_dir: base output directory (default: 'out')
%
% Output:
%   - history_table: table with columns:
%       .index: sequential index for selection
%       .timestamp: run timestamp string
%       .mode: simulation mode ('bulk', 'mse', 'dual')
%       .num_enzymes: number of enzymes
%       .num_substrate: number of substrate molecules
%       .batch_count_or_seed: batch count (for batch runs) or seed (for single runs)
%       .run_type: 'single' or 'batch'
%       .dir_path: absolute path to run directory
%
% Description:
%   Scans out/single/ and out/batch/ directories for historical runs.
%   Reads run_metadata.json from each directory to extract key information.
%   Returns sorted table (newest first) for easy selection.

if nargin < 1 || isempty(run_type)
    run_type = 'all';
end

if nargin < 2 || isempty(base_dir)
    base_dir = 'out';
end

% Validate run_type
run_type = lower(run_type);
if ~ismember(run_type, {'single', 'batch', 'all'})
    error('browse_history: run_type must be ''single'', ''batch'', or ''all''');
end

% Check if base directory exists
if ~exist(base_dir, 'dir')
    warning('Base directory does not exist: %s', base_dir);
    history_table = table();
    return;
end

% ========== Scan Directories ==========
run_dirs = {};
run_types = {};

% Scan single runs
if ismember(run_type, {'single', 'all'})
    single_dir = fullfile(base_dir, 'single');
    if exist(single_dir, 'dir')
        single_runs = scan_run_directory(single_dir);
        run_dirs = [run_dirs; single_runs];
        run_types = [run_types; repmat({'single'}, numel(single_runs), 1)];
    end
end

% Scan batch runs
if ismember(run_type, {'batch', 'all'})
    batch_dir = fullfile(base_dir, 'batch');
    if exist(batch_dir, 'dir')
        batch_runs = scan_run_directory(batch_dir);
        run_dirs = [run_dirs; batch_runs];
        run_types = [run_types; repmat({'batch'}, numel(batch_runs), 1)];
    end
end

if isempty(run_dirs)
    fprintf('No historical runs found in %s\n', base_dir);
    history_table = table();
    return;
end

% ========== Extract Metadata ==========
n_runs = numel(run_dirs);
timestamps = cell(n_runs, 1);
modes = cell(n_runs, 1);
num_enzymes = zeros(n_runs, 1);
num_substrate = zeros(n_runs, 1);
batch_count_or_seed = zeros(n_runs, 1);
valid_mask = true(n_runs, 1);

for i = 1:n_runs
    metadata_path = fullfile(run_dirs{i}, 'data', 'run_metadata.json');
    
    if ~exist(metadata_path, 'file')
        % No metadata file - try to extract from directory name
        [timestamp, mode, enz, sub, batch_seed] = parse_dirname(run_dirs{i});
        if ~isempty(timestamp)
            timestamps{i} = timestamp;
            modes{i} = mode;
            num_enzymes(i) = enz;
            num_substrate(i) = sub;
            batch_count_or_seed(i) = batch_seed;
        else
            valid_mask(i) = false;
        end
        continue;
    end
    
    % Read metadata JSON
    try
        metadata = read_json(metadata_path);
        
        % Extract fields
        timestamps{i} = getfield_or(metadata, 'timestamp', '');
        modes{i} = getfield_or(metadata, 'mode', 'unknown');
        
        if isfield(metadata, 'parameters')
            num_enzymes(i) = getfield_or(metadata.parameters, 'num_enzymes', 0);
            num_substrate(i) = getfield_or(metadata.parameters, 'num_substrate', 0);
            batch_count_or_seed(i) = getfield_or(metadata.parameters, 'batch_count', 0);
        end
        
        % For single runs, try to get seed instead of batch_count
        if strcmp(run_types{i}, 'single')
            if isfield(metadata, 'seed_info')
                seed = getfield_or(metadata.seed_info, 'fixed_seed', 0);
                if seed > 0
                    batch_count_or_seed(i) = seed;
                end
            end
        end
        
    catch ME
        warning('Failed to read metadata from %s: %s', metadata_path, ME.message);
        valid_mask(i) = false;
    end
end

% Filter out invalid entries
run_dirs = run_dirs(valid_mask);
run_types = run_types(valid_mask);
timestamps = timestamps(valid_mask);
modes = modes(valid_mask);
num_enzymes = num_enzymes(valid_mask);
num_substrate = num_substrate(valid_mask);
batch_count_or_seed = batch_count_or_seed(valid_mask);

if isempty(run_dirs)
    fprintf('No valid historical runs found\n');
    history_table = table();
    return;
end

% ========== Sort by Timestamp (Newest First) ==========
% Convert timestamps to datetime for sorting
try
    dt_array = datetime(timestamps, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    [~, sort_idx] = sort(dt_array, 'descend');
catch
    % Fallback: sort by directory name
    [~, sort_idx] = sort(run_dirs, 'descend');
end

run_dirs = run_dirs(sort_idx);
run_types = run_types(sort_idx);
timestamps = timestamps(sort_idx);
modes = modes(sort_idx);
num_enzymes = num_enzymes(sort_idx);
num_substrate = num_substrate(sort_idx);
batch_count_or_seed = batch_count_or_seed(sort_idx);

% ========== Build Table ==========
n_valid = numel(run_dirs);
index = (1:n_valid)';

history_table = table(index, timestamps, modes, num_enzymes, num_substrate, ...
                      batch_count_or_seed, run_types, run_dirs, ...
                      'VariableNames', {'index', 'timestamp', 'mode', 'num_enzymes', ...
                                       'num_substrate', 'batch_count_or_seed', 'run_type', 'dir_path'});

% Convert cell arrays to string arrays for better display
history_table.timestamp = string(history_table.timestamp);
history_table.mode = string(history_table.mode);
history_table.run_type = string(history_table.run_type);
history_table.dir_path = string(history_table.dir_path);

end

% ========== Helper Functions ==========
function run_dirs = scan_run_directory(type_dir)
% SCAN_RUN_DIRECTORY Scan a type directory for run subdirectories
% Returns cell array of absolute paths to run directories

run_dirs = {};

% Get all subdirectories
items = dir(type_dir);
items = items([items.isdir]);
items = items(~ismember({items.name}, {'.', '..', 'latest', 'latest.lnk'}));

for i = 1:numel(items)
    run_dir = fullfile(type_dir, items(i).name);
    
    % Check if it has a data subdirectory (basic validation)
    data_dir = fullfile(run_dir, 'data');
    if exist(data_dir, 'dir')
        run_dirs{end+1, 1} = run_dir;
    end
end
end

function [timestamp, mode, enz, sub, batch_seed] = parse_dirname(dir_path)
% PARSE_DIRNAME Extract information from directory name
% Format: YYYYMMDD_HHMMSS_mode_enzN_subM_seedS (single)
%         YYYYMMDD_HHMMSS_mode_enzN_subM_nB (batch)

timestamp = '';
mode = 'unknown';
enz = 0;
sub = 0;
batch_seed = 0;

[~, dirname] = fileparts(dir_path);

% Try to parse timestamp
parts = strsplit(dirname, '_');
if numel(parts) < 2
    return;
end

try
    % Parse timestamp
    date_str = parts{1};
    time_str = parts{2};
    timestamp = sprintf('%s-%s-%sT%s:%s:%s', ...
                       date_str(1:4), date_str(5:6), date_str(7:8), ...
                       time_str(1:2), time_str(3:4), time_str(5:6));
catch
    return;
end

% Parse mode
if numel(parts) >= 3
    mode = parts{3};
end

% Parse parameters
for i = 4:numel(parts)
    part = parts{i};
    if startsWith(part, 'enz')
        enz = str2double(part(4:end));
    elseif startsWith(part, 'sub')
        sub = str2double(part(4:end));
    elseif startsWith(part, 'seed')
        batch_seed = str2double(part(5:end));
    elseif startsWith(part, 'n')
        batch_seed = str2double(part(2:end));
    end
end
end

function metadata = read_json(json_path)
% READ_JSON Read JSON file and return struct
% Uses jsondecode (MATLAB R2016b+)

fid = fopen(json_path, 'r');
if fid == -1
    error('Unable to open JSON file: %s', json_path);
end

json_str = fread(fid, '*char')';
fclose(fid);

metadata = jsondecode(json_str);
end

function v = getfield_or(s, field, default)
% GETFIELD_OR Get struct field with default fallback

if isstruct(s) && isfield(s, field)
    v = s.(field);
else
    v = default;
end
end

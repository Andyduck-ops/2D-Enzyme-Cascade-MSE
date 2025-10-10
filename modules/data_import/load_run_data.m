function data = load_run_data(run_dir, system_filter)
% LOAD_RUN_DATA Load historical run data from directory
% Usage:
%   data = load_run_data(run_dir)
%   data = load_run_data(run_dir, system_filter)
%
% Inputs:
%   - run_dir: path to run directory
%   - system_filter: for dual mode runs, specify 'bulk', 'mse', or 'both' (default: 'both')
%
% Output:
%   - data: struct with fields compatible with run_dual_system_comparison output
%       For single-mode runs:
%           .time_axis: [n_steps x 1] time points
%           .product_curves: [n_steps x n_batches] product matrix
%           .batch_table: table with batch statistics
%           .metadata: run metadata struct
%           .enzyme_count: number of enzymes
%       
%       For dual-mode runs (system_filter='both'):
%           .bulk: struct with above fields for bulk system
%           .mse: struct with above fields for MSE system
%           .metadata: run metadata struct
%
% Description:
%   Loads time-series data, batch results, and metadata from a historical run.
%   Handles both single-mode and dual-mode runs.
%   Returns data structure compatible with existing visualization functions.

if nargin < 2 || isempty(system_filter)
    system_filter = 'both';
end

% Validate inputs
if ~exist(run_dir, 'dir')
    error('load_run_data: run directory does not exist: %s', run_dir);
end

system_filter = lower(system_filter);
if ~ismember(system_filter, {'bulk', 'mse', 'both'})
    error('load_run_data: system_filter must be ''bulk'', ''mse'', or ''both''');
end

% ========== Load Metadata ==========
metadata_path = fullfile(run_dir, 'data', 'run_metadata.json');
if ~exist(metadata_path, 'file')
    error('load_run_data: metadata file not found: %s', metadata_path);
end

metadata = read_json(metadata_path);
mode = getfield_or(metadata, 'mode', 'unknown');
is_dual = strcmp(mode, 'dual');

% ========== Load Data Based on Mode ==========
if is_dual
    % Dual-mode run
    if strcmp(system_filter, 'both')
        % Load both systems
        data = struct();
        data.bulk = load_system_data(run_dir, 'bulk', metadata);
        data.mse = load_system_data(run_dir, 'mse', metadata);
        data.metadata = metadata;
    else
        % Load single system
        data = load_system_data(run_dir, system_filter, metadata);
        data.metadata = metadata;
    end
else
    % Single-mode run
    data = load_system_data(run_dir, mode, metadata);
    data.metadata = metadata;
end

fprintf('Successfully loaded run data from: %s\n', run_dir);

end

% ========== Helper Functions ==========
function system_data = load_system_data(run_dir, system_name, metadata)
% LOAD_SYSTEM_DATA Load data for a single system (bulk or mse)

system_data = struct();

% Determine file suffixes
if strcmp(system_name, 'bulk')
    suffix = '_bulk';
elseif strcmp(system_name, 'mse')
    suffix = '_mse';
else
    suffix = '';
end

data_dir = fullfile(run_dir, 'data');

% ========== Load Time-Series Data ==========
timeseries_file = fullfile(data_dir, ['timeseries_products' suffix '.csv']);

if exist(timeseries_file, 'file')
    try
        ts_table = readtable(timeseries_file);
        
        % Extract time axis (first column)
        system_data.time_axis = ts_table{:, 1};
        
        % Extract product curves (remaining columns)
        system_data.product_curves = ts_table{:, 2:end};
        
        fprintf('  Loaded time-series: %d steps x %d batches\n', ...
                size(system_data.product_curves, 1), size(system_data.product_curves, 2));
    catch ME
        warning('Failed to load time-series data: %s', ME.message);
        system_data.time_axis = [];
        system_data.product_curves = [];
    end
else
    warning('Time-series file not found: %s', timeseries_file);
    system_data.time_axis = [];
    system_data.product_curves = [];
end

% ========== Load Batch Results ==========
batch_file = fullfile(data_dir, ['batch_results' suffix '.csv']);

if exist(batch_file, 'file')
    try
        system_data.batch_table = readtable(batch_file);
        fprintf('  Loaded batch results: %d batches\n', height(system_data.batch_table));
    catch ME
        warning('Failed to load batch results: %s', ME.message);
        system_data.batch_table = table();
    end
else
    warning('Batch results file not found: %s', batch_file);
    system_data.batch_table = table();
end

% ========== Extract Enzyme Count ==========
if isfield(metadata, 'parameters') && isfield(metadata.parameters, 'num_enzymes')
    system_data.enzyme_count = metadata.parameters.num_enzymes;
else
    system_data.enzyme_count = 0;
end

% ========== Validate Data Consistency ==========
if ~isempty(system_data.product_curves) && ~isempty(system_data.batch_table)
    n_batches_ts = size(system_data.product_curves, 2);
    n_batches_table = height(system_data.batch_table);
    
    if n_batches_ts ~= n_batches_table
        warning('Batch count mismatch: time-series has %d batches, table has %d batches', ...
                n_batches_ts, n_batches_table);
    end
end

end

function metadata = read_json(json_path)
% READ_JSON Read JSON file and return struct

fid = fopen(json_path, 'r');
if fid == -1
    error('Unable to open JSON file: %s', json_path);
end

json_str = fread(fid, '*char')';
fclose(fid);

try
    metadata = jsondecode(json_str);
catch ME
    error('Failed to parse JSON: %s', ME.message);
end
end

function v = getfield_or(s, field, default)
% GETFIELD_OR Get struct field with default fallback

if isstruct(s) && isfield(s, field)
    v = s.(field);
else
    v = default;
end
end

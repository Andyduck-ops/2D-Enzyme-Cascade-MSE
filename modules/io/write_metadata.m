function json_path = write_metadata(config, output_paths, output_files, run_stats)
% WRITE_METADATA Write run metadata to JSON file
% Usage:
%   json_path = write_metadata(config, output_paths, output_files)
%   json_path = write_metadata(config, output_paths, output_files, run_stats)
%
% Inputs:
%   - config: configuration struct from default_config()/interactive_config()
%   - output_paths: struct from output_manager()
%   - output_files: struct containing paths to generated files
%       .seeds_csv: path to seeds.csv
%       .batch_results: path(s) to batch_results*.csv
%       .timeseries: path(s) to timeseries_products*.csv
%       .figures: cell array of figure file paths
%   - run_stats: optional struct with runtime statistics
%       .start_time: run start timestamp
%       .end_time: run end timestamp
%       .duration_seconds: total runtime
%       .n_batches_completed: number of batches completed
%
% Output:
%   - json_path: absolute path of the JSON file that was written
%
% Metadata Structure:
%   {
%     "timestamp": "2025-10-10T14:30:22",
%     "run_type": "batch",
%     "mode": "dual",
%     "parameters": {
%       "num_enzymes": 400,
%       "num_substrate": 3000,
%       "batch_count": 10,
%       "simulation_mode": "MSE",
%       "dual_comparison": true,
%       ...
%     },
%     "seed_info": {
%       "seed_mode": "fixed",
%       "fixed_seed": 1234,
%       ...
%     },
%     "output_files": {
%       "seeds": "data/seeds.csv",
%       "batch_results": ["data/batch_results_bulk.csv", ...],
%       "timeseries": ["data/timeseries_products_bulk.csv", ...],
%       "figures": ["figures/dual_comparison.png", ...]
%     },
%     "system_info": {
%       "matlab_version": "R2023b",
%       "platform": "win64",
%       "hostname": "DESKTOP-ABC123"
%     },
%     "runtime": {
%       "start_time": "2025-10-10T14:30:22",
%       "end_time": "2025-10-10T14:35:45",
%       "duration_seconds": 323.5
%     }
%   }

if nargin < 4
    run_stats = struct();
end

% ========== Build Metadata Structure ==========
metadata = struct();

% Timestamp
metadata.timestamp = datestr(now, 'yyyy-mm-ddTHH:MM:SS');

% Run type (single or batch)
if getfield_or(config, {'batch', 'batch_count'}, 1) == 1
    metadata.run_type = 'single';
else
    metadata.run_type = 'batch';
end

% Mode
is_dual = getfield_or(config, {'ui_controls', 'dual_system_comparison'}, false);
if is_dual
    metadata.mode = 'dual';
else
    metadata.mode = getfield_or(config, {'simulation_params', 'simulation_mode'}, 'unknown');
end

% ========== Parameters ==========
metadata.parameters = struct();
metadata.parameters.num_enzymes = getfield_or(config, {'particle_params', 'num_enzymes'}, 0);
metadata.parameters.num_substrate = getfield_or(config, {'particle_params', 'num_substrate'}, 0);
metadata.parameters.gox_hrp_split = getfield_or(config, {'particle_params', 'gox_hrp_split'}, 0.5);
metadata.parameters.batch_count = getfield_or(config, {'batch', 'batch_count'}, 1);
metadata.parameters.simulation_mode = getfield_or(config, {'simulation_params', 'simulation_mode'}, 'unknown');
metadata.parameters.dual_comparison = is_dual;
metadata.parameters.box_size = getfield_or(config, {'simulation_params', 'box_size'}, 0);
metadata.parameters.total_time = getfield_or(config, {'simulation_params', 'total_time'}, 0);
metadata.parameters.time_step = getfield_or(config, {'simulation_params', 'time_step'}, 0);
metadata.parameters.auto_dt_enabled = getfield_or(config, {'simulation_params','enable_auto_dt'}, false);
% Record dt auto-adjust information if available
if isfield(config, 'meta') && isfield(config.meta, 'dt_auto') && ~isempty(config.meta.dt_auto)
    dta = config.meta.dt_auto;
    metadata.parameters.dt_initial = getfield(dta, 'initial_dt');
    metadata.parameters.dt_final = getfield(dta, 'final_dt');
    metadata.parameters.dt_history = getfield(dta, 'history');
    metadata.parameters.kdt_final = getfield(dta, 'kdt_final');
    metadata.parameters.sigma_final = getfield(dta, 'sigma_final');
    metadata.parameters.dt_targets = struct( ...
        'k_fraction', getfield(dta,'target_k_fraction'), ...
        'sigma_fraction', getfield(dta,'target_sigma_fraction'), ...
        'sigma_abs_nm', getfield(dta,'target_sigma_abs_nm') ...
    );
end
metadata.parameters.diff_coeff_bulk = getfield_or(config, {'particle_params', 'diff_coeff_bulk'}, 0);
metadata.parameters.diff_coeff_film = getfield_or(config, {'particle_params', 'diff_coeff_film'}, 0);
metadata.parameters.k_cat_GOx = getfield_or(config, {'particle_params', 'k_cat_GOx'}, 0);
metadata.parameters.k_cat_HRP = getfield_or(config, {'particle_params', 'k_cat_HRP'}, 0);

% ========== Seed Info ==========
metadata.seed_info = struct();
metadata.seed_info.seed_mode = getfield_or(config, {'batch', 'seed_mode'}, 'unknown');
metadata.seed_info.fixed_seed = getfield_or(config, {'batch', 'fixed_seed'}, []);
metadata.seed_info.seed_base = getfield_or(config, {'batch', 'seed_base'}, []);
metadata.seed_info.seed_list = getfield_or(config, {'batch', 'seed_list'}, []);

% Add seed source info if available
if isfield(config, 'batch') && isfield(config.batch, 'seed_source')
    metadata.seed_info.seed_source = config.batch.seed_source;
end

% ========== Output Files ==========
metadata.output_files = struct();

% Convert absolute paths to relative paths (relative to run_dir)
run_dir = output_paths.run_dir;

if isfield(output_files, 'seeds_csv') && ~isempty(output_files.seeds_csv)
    metadata.output_files.seeds = make_relative_path(output_files.seeds_csv, run_dir);
end

if isfield(output_files, 'batch_results')
    if iscell(output_files.batch_results)
        metadata.output_files.batch_results = cellfun(@(p) make_relative_path(p, run_dir), ...
                                                       output_files.batch_results, 'UniformOutput', false);
    else
        metadata.output_files.batch_results = make_relative_path(output_files.batch_results, run_dir);
    end
end

if isfield(output_files, 'timeseries')
    if iscell(output_files.timeseries)
        metadata.output_files.timeseries = cellfun(@(p) make_relative_path(p, run_dir), ...
                                                    output_files.timeseries, 'UniformOutput', false);
    else
        metadata.output_files.timeseries = make_relative_path(output_files.timeseries, run_dir);
    end
end

if isfield(output_files, 'figures') && ~isempty(output_files.figures)
    if iscell(output_files.figures)
        metadata.output_files.figures = cellfun(@(p) make_relative_path(p, run_dir), ...
                                                 output_files.figures, 'UniformOutput', false);
    else
        metadata.output_files.figures = {make_relative_path(output_files.figures, run_dir)};
    end
end

% ========== System Info ==========
metadata.system_info = struct();
metadata.system_info.matlab_version = version;
metadata.system_info.platform = computer;
try
    [~, hostname] = system('hostname');
    metadata.system_info.hostname = strtrim(hostname);
catch
    metadata.system_info.hostname = 'unknown';
end

% ========== Runtime Stats ==========
if ~isempty(run_stats)
    metadata.runtime = struct();
    if isfield(run_stats, 'start_time')
        metadata.runtime.start_time = run_stats.start_time;
    end
    if isfield(run_stats, 'end_time')
        metadata.runtime.end_time = run_stats.end_time;
    end
    if isfield(run_stats, 'duration_seconds')
        metadata.runtime.duration_seconds = run_stats.duration_seconds;
    end
    if isfield(run_stats, 'n_batches_completed')
        metadata.runtime.n_batches_completed = run_stats.n_batches_completed;
    end
end

% ========== Write JSON ==========
json_path = fullfile(output_paths.data_dir, 'run_metadata.json');

try
    % Use jsonencode (MATLAB R2016b+)
    json_str = jsonencode(metadata);
    
    % Pretty print (add indentation)
    json_str = prettify_json(json_str);
    
    % Write to file
    fid = fopen(json_path, 'w');
    if fid == -1
        error('Unable to open JSON file for writing: %s', json_path);
    end
    fprintf(fid, '%s', json_str);
    fclose(fid);
    
    fprintf('Run metadata saved: %s\n', json_path);
catch ME
    warning('Failed to write metadata JSON: %s', ME.message);
    json_path = '';
end

end

% ========== Helper Functions ==========
function rel_path = make_relative_path(abs_path, base_dir)
% MAKE_RELATIVE_PATH Convert absolute path to relative path
% If path is already relative or conversion fails, return as-is

if isempty(abs_path)
    rel_path = '';
    return;
end

try
    % Normalize paths
    abs_path = char(abs_path);
    base_dir = char(base_dir);
    
    % Ensure base_dir ends with separator
    if ~endsWith(base_dir, filesep)
        base_dir = [base_dir filesep];
    end
    
    % Check if abs_path starts with base_dir
    if startsWith(abs_path, base_dir)
        rel_path = abs_path(length(base_dir)+1:end);
    else
        % Path is not under base_dir, return as-is
        rel_path = abs_path;
    end
catch
    rel_path = abs_path;
end
end

function pretty_json = prettify_json(json_str)
% PRETTIFY_JSON Add indentation to JSON string for readability
% Simple implementation: add newlines and indentation

try
    % Decode and re-encode with formatting (if available)
    data = jsondecode(json_str);
    
    % For MATLAB R2020b+, jsonencode supports 'PrettyPrint'
    if exist('jsonencode', 'file') == 2
        try
            pretty_json = jsonencode(data, 'PrettyPrint', true);
            return;
        catch
            % Fall through to manual formatting
        end
    end
    
    % Manual formatting (basic)
    pretty_json = strrep(json_str, ',', sprintf(',\n  '));
    pretty_json = strrep(pretty_json, '{', sprintf('{\n  '));
    pretty_json = strrep(pretty_json, '}', sprintf('\n}'));
    pretty_json = strrep(pretty_json, '[', sprintf('[\n  '));
    pretty_json = strrep(pretty_json, ']', sprintf('\n]'));
catch
    pretty_json = json_str;
end
end

function v = getfield_or(s, path, default)
% GETFIELD_OR Get nested struct field with default fallback
v = default;
try
    for i = 1:numel(path)
        key = path{i};
        if isstruct(s) && isfield(s, key)
            s = s.(key);
        else
            return;
        end
    end
    v = s;
catch
    v = default;
end
end

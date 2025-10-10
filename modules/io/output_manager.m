function output_paths = output_manager(config, run_type)
% OUTPUT_MANAGER Create timestamped output directory structure
% Usage:
%   paths = output_manager(config, run_type)
%
% Inputs:
%   - config: configuration struct from default_config()/interactive_config()
%   - run_type: 'single' or 'batch'
%
% Outputs:
%   - output_paths: struct containing all directory paths
%       .base_dir: base output directory (out/)
%       .type_dir: type-specific directory (out/single/ or out/batch/)
%       .run_dir: timestamped run directory
%       .data_dir: data subdirectory
%       .figures_dir: figures subdirectory
%       .single_viz_dir: single visualization subdirectory (batch mode only)
%       .latest_link: path to 'latest' shortcut/symlink
%
% Directory Structure:
%   out/
%   ├── single/
%   │   ├── 20251010_143022_mse_enz400_sub3000_seed1234/
%   │   │   ├── data/
%   │   │   │   ├── run_metadata.json
%   │   │   │   └── batch_results.csv
%   │   │   └── figures/
%   │   └── latest -> (shortcut to most recent)
%   └── batch/
%       ├── 20251010_143530_dual_enz400_sub3000_n10/
%       │   ├── data/
%       │   │   ├── run_metadata.json
%       │   │   ├── seeds.csv
%       │   │   ├── batch_results_bulk.csv
%       │   │   ├── batch_results_mse.csv
%       │   │   ├── timeseries_products_bulk.csv
%       │   │   └── timeseries_products_mse.csv
%       │   ├── figures/
%       │   └── single_viz/
%       └── latest -> (shortcut to most recent)

if nargin < 2 || isempty(run_type)
    run_type = 'batch';
end

% Validate run_type
if ~ismember(lower(run_type), {'single', 'batch'})
    error('output_manager: run_type must be ''single'' or ''batch''');
end
run_type = lower(run_type);

% Check if using timestamped structure
output_structure = getfield_or(config, {'io', 'output_structure'}, 'timestamped');
if ~strcmp(output_structure, 'timestamped')
    % Legacy mode: return simple structure
    output_paths = struct();
    output_paths.base_dir = config.io.outdir;
    output_paths.type_dir = config.io.outdir;
    output_paths.run_dir = config.io.outdir;
    output_paths.data_dir = config.io.outdir;
    output_paths.figures_dir = config.io.outdir;
    output_paths.single_viz_dir = config.io.outdir;
    output_paths.latest_link = '';
    fprintf('Output manager: Using legacy output structure\n');
    return;
end

% ========== Create Base Directory Structure ==========
% Get base output directory from config
base_dir = getfield_or(config, {'io', 'outdir'}, fullfile('2D', 'out'));
if ~exist(base_dir, 'dir')
    mkdir(base_dir);
end

% Create type-specific directory
type_dir = fullfile(base_dir, run_type);
if ~exist(type_dir, 'dir')
    mkdir(type_dir);
end

% ========== Generate Timestamped Directory Name ==========
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Extract key parameters for directory naming
mode = getfield_or(config, {'simulation_params', 'simulation_mode'}, 'unknown');
num_enzymes = getfield_or(config, {'particle_params', 'num_enzymes'}, 0);
num_substrate = getfield_or(config, {'particle_params', 'num_substrate'}, 0);

% Build directory name based on run type
if strcmp(run_type, 'single')
    % Single run: include seed
    seed = getfield_or(config, {'batch', 'fixed_seed'}, 0);
    dir_name = sprintf('%s_%s_enz%d_sub%d_seed%d', ...
        timestamp, lower(mode), num_enzymes, num_substrate, seed);
else
    % Batch run: include batch count and check for dual mode
    batch_count = getfield_or(config, {'batch', 'batch_count'}, 1);
    is_dual = getfield_or(config, {'ui_controls', 'dual_system_comparison'}, false);
    
    if is_dual
        dir_name = sprintf('%s_dual_enz%d_sub%d_n%d', ...
            timestamp, num_enzymes, num_substrate, batch_count);
    else
        dir_name = sprintf('%s_%s_enz%d_sub%d_n%d', ...
            timestamp, lower(mode), num_enzymes, num_substrate, batch_count);
    end
end

% Create run directory
run_dir = fullfile(type_dir, dir_name);
if ~exist(run_dir, 'dir')
    mkdir(run_dir);
end

% ========== Create Subdirectories ==========
data_dir = fullfile(run_dir, 'data');
if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end

figures_dir = fullfile(run_dir, 'figures');
if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end

% Don't create single_viz subdirectory - it's deprecated
% Batch runs should only have statistical plots in figures/
% Single runs have their visualization in figures/
single_viz_dir = '';

% ========== Create 'latest' Shortcut/Symlink ==========
latest_link = fullfile(type_dir, 'latest');
create_latest_link(latest_link, run_dir);

% ========== Assemble Output Structure ==========
output_paths = struct();
output_paths.base_dir = base_dir;
output_paths.type_dir = type_dir;
output_paths.run_dir = run_dir;
output_paths.data_dir = data_dir;
output_paths.figures_dir = figures_dir;
output_paths.single_viz_dir = single_viz_dir;
output_paths.latest_link = latest_link;

% ========== Console Output ==========
fprintf('\n====================================================\n');
fprintf(' Output Directory Structure Created\n');
fprintf('====================================================\n');
fprintf('Run Type: %s\n', run_type);
fprintf('Run Directory: %s\n', run_dir);
fprintf('  ├── data/\n');
fprintf('  └── figures/\n');
if ~isempty(single_viz_dir)
    fprintf('  └── single_viz/ (created on demand)\n');
end
fprintf('Latest link: %s\n', latest_link);
fprintf('====================================================\n\n');

end

% ========== Helper Functions ==========
function create_latest_link(link_path, target_path)
% CREATE_LATEST_LINK Create shortcut (Windows) or symlink (Linux/Mac)
% Inputs:
%   - link_path: path to the link/shortcut
%   - target_path: path to the target directory

% Remove existing link if it exists
if exist(link_path, 'file') || exist(link_path, 'dir')
    try
        if ispc
            % Windows: delete shortcut file
            if exist([link_path '.lnk'], 'file')
                delete([link_path '.lnk']);
            end
        else
            % Unix: delete symlink
            delete(link_path);
        end
    catch ME
        warning('Failed to remove existing latest link: %s', ME.message);
    end
end

% Create new link
if ispc
    % Windows: Create shortcut using PowerShell
    create_windows_shortcut(link_path, target_path);
else
    % Unix: Create symbolic link
    try
        system(sprintf('ln -sf "%s" "%s"', target_path, link_path));
    catch ME
        warning('Failed to create symlink: %s', ME.message);
    end
end
end

function create_windows_shortcut(link_path, target_path)
% CREATE_WINDOWS_SHORTCUT Create Windows shortcut using PowerShell
% Inputs:
%   - link_path: path to the shortcut (without .lnk extension)
%   - target_path: path to the target directory

% Add .lnk extension
shortcut_path = [link_path '.lnk'];

% Convert to absolute paths
target_path = char(java.io.File(target_path).getCanonicalPath());
shortcut_path = char(java.io.File(shortcut_path).getCanonicalPath());

% PowerShell command to create shortcut
ps_cmd = sprintf(['$WshShell = New-Object -ComObject WScript.Shell; ' ...
                  '$Shortcut = $WshShell.CreateShortcut(''%s''); ' ...
                  '$Shortcut.TargetPath = ''%s''; ' ...
                  '$Shortcut.Save()'], ...
                  shortcut_path, target_path);

% Execute PowerShell command
try
    [status, ~] = system(['powershell -Command "' ps_cmd '"']);
    if status ~= 0
        warning('Failed to create Windows shortcut via PowerShell');
    end
catch ME
    warning('Failed to create Windows shortcut: %s', ME.message);
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

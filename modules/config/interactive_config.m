function config = interactive_config(config)
% INTERACTIVE_CONFIG Interactive configuration collection for simulation
% Usage:
%   cfg = interactive_config();                % Interactive setup based on [default_config()](./default_config.m) defaults
%   cfg = interactive_config(existing_config); % Fine-tune based on passed configuration
%
% Interactive items covered:
%   - Particle scale: total enzymes(num_enzymes), GOx ratio(gox_hrp_split), substrate count(num_substrate)
%   - Mode: surface/bulk
%   - Visualization toggle: visualize_enabled
%   - Batch & RNG: batch_count, seed_mode(fixed/per_batch_random/manual_list/incremental),
%                fixed_seed/seed_base/seed_list, use_gpu, use_parfor
%
% Note:
%   - This function only writes decisions and parameters, subsequent [get_batch_seeds()](../seed_utils/get_batch_seeds.m) will actually generate batch seeds
%   - Visualization aesthetics and plotting are handled by [viz_style()](../viz/viz_style.m) and various plot_* functions
%
% Reference baseline: [refactored_2d_model.m](../../refactored_2d_model.m)

if nargin < 1 || isempty(config)
    config = default_config();
end

fprintf('====================================================\n');
fprintf(' 2D Simulation Interactive Configuration\n');
fprintf(' (Press Enter to use default values, input numbers or options to override)\n');
fprintf('====================================================\n');

% -----------------------------
% Run mode selection
% -----------------------------
fprintf('\nRun Mode:\n');
fprintf('  [1] Run new simulation\n');
fprintf('  [2] Import historical data for comparison\n');
val = input('Select run mode [1-2] [default=1]: ', 's');
if isempty(val)
    val = '1';
end

run_mode = 'new';
if strcmp(val, '2')
    run_mode = 'import';
end

config.ui_controls.run_mode = run_mode;

% If import mode, skip most simulation configuration
if strcmp(run_mode, 'import')
    fprintf('\n--- Import Mode: Selecting Historical Runs ---\n');
    
    % Call interactive run selector
    selected_runs = select_runs_interactive('all', 'out');
    
    if isempty(selected_runs)
        fprintf('No runs selected. Switching to new simulation mode.\n');
        config.ui_controls.run_mode = 'new';
    else
        config.ui_controls.import_datasets = selected_runs;
        fprintf('\n%d dataset(s) selected for comparison.\n', numel(selected_runs));
        fprintf('Skipping simulation configuration...\n');
        return;
    end
end

fprintf('\n--- New Simulation Configuration ---\n');

% -----------------------------
% Basic scale settings
% -----------------------------
% Total enzyme count
def_num_enz = config.particle_params.num_enzymes;
val = input(sprintf('1) Total enzyme count num_enzymes [default=%d]: ', def_num_enz));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val > 0
    config.particle_params.num_enzymes = round(val);
end

% GOx ratio
def_ratio = config.particle_params.gox_hrp_split;
val = input(sprintf('2) GOx ratio gox_hrp_split (0-1) [default=%.2f]: ', def_ratio));
if ~isempty(val) && isnumeric(val) && isfinite(val)
    config.particle_params.gox_hrp_split = max(0, min(1, val));
end

% Substrate count
def_num_sub = config.particle_params.num_substrate;
val = input(sprintf('3) Substrate count num_substrate [default=%d]: ', def_num_sub));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val >= 0
    config.particle_params.num_substrate = round(val);
end

% -----------------------------
% Mode and visualization
% -----------------------------
% Mode
def_mode = config.simulation_params.simulation_mode;
val = input(sprintf('4) Mode simulation_mode [MSE/bulk] [default=%s]: ', def_mode), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    % Compatibility: map surface to MSE
    if any(strcmp(v, {'mse','surface','bulk'}))
        if strcmp(v,'surface'), v = 'mse'; end
        config.simulation_params.simulation_mode = v;
    else
        fprintf('   Invalid input, keeping default: %s\n', def_mode);
    end
end

% Visualization toggle
def_vis = config.ui_controls.visualize_enabled;
val = input(sprintf('5) Enable visualization visualize_enabled [y/n] [default=%s]: ', tf(def_vis)), 's');
if ~isempty(val)
    config.ui_controls.visualize_enabled = is_yes(val);
end

% Animation generation toggle (only relevant if visualization is enabled)
if ~isfield(config.ui_controls, 'enable_animation')
    config.ui_controls.enable_animation = false;
end
if config.ui_controls.visualize_enabled
    def_anim = config.ui_controls.enable_animation;
    val = input(sprintf('5a) Enable snapshot animation (MP4 video for single-run visualization) [y/n] [default=%s]: ', tf(def_anim)), 's');
    if ~isempty(val)
        config.ui_controls.enable_animation = is_yes(val);
    end
else
    % If visualization disabled, animation is meaningless
    config.ui_controls.enable_animation = false;
end

% Dual-system comparison mode
if ~isfield(config.ui_controls, 'dual_system_comparison')
    config.ui_controls.dual_system_comparison = false;
end
def_dual = config.ui_controls.dual_system_comparison;
val = input(sprintf('5b) Run dual-system comparison (bulk vs MSE) [y/n] [default=%s]: ', tf(def_dual)), 's');
if ~isempty(val)
    config.ui_controls.dual_system_comparison = is_yes(val);
end

% Figure saving toggle
if ~isfield(config.ui_controls, 'enable_fig_save')
    config.ui_controls.enable_fig_save = false;
end
def_fig_save = config.ui_controls.enable_fig_save;
val = input(sprintf('5c) Enable figure saving (save plots to files) [y/n] [default=%s]: ', tf(def_fig_save)), 's');
if ~isempty(val)
    config.ui_controls.enable_fig_save = is_yes(val);
end

% -----------------------------
% Batch and RNG strategy
% -----------------------------
% Batch count
def_batches = config.batch.batch_count;
val = input(sprintf('6) Batch count batch_count [default=%d]: ', def_batches));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val > 0
    config.batch.batch_count = round(val);
end

% RNG mode
def_seed_mode = config.batch.seed_mode;
val = input(sprintf(['7) Seed mode seed_mode [fixed/per_batch_random/manual_list/incremental/from_file]\n' ...
                     '   [default=%s]: '], def_seed_mode), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    if any(strcmp(v, {'fixed','per_batch_random','manual_list','incremental','from_file'}))
        config.batch.seed_mode = v;
    else
        fprintf('   Invalid input, keeping default: %s\n', def_seed_mode);
    end
end

% Additional parameters by mode
switch config.batch.seed_mode
    case 'fixed'
        def_seed = config.batch.fixed_seed;
        val = input(sprintf('   - Fixed seed fixed_seed [default=%d]: ', def_seed));
        if ~isempty(val) && isnumeric(val) && isfinite(val)
            config.batch.fixed_seed = round(val);
        end
    case 'incremental'
        def_base = config.batch.seed_base;
        val = input(sprintf('   - Incremental seed base seed_base [default=%d]: ', def_base));
        if ~isempty(val) && isnumeric(val) && isfinite(val)
            config.batch.seed_base = round(val);
        end
    case 'manual_list'
        val = input('   - Manual seed list seed_list (e.g., 101,202,303): ', 's');
        if ~isempty(val)
            nums = parse_list_to_int(val);
            if ~isempty(nums)
                config.batch.seed_list = nums(:).';
                if numel(nums) < config.batch.batch_count
                    fprintf('   Warning: List length is less than batch count (%d), subsequent modules will truncate/cycle as needed.\n', config.batch.batch_count);
                end
            else
                fprintf('   No valid integer list parsed, keeping default empty list.\n');
            end
        end
    case 'per_batch_random'
        % No additional parameters needed; get_batch_seeds() will use random strategy
    case 'from_file'
        % Load seeds from historical run
        try
            [loaded_seeds, seed_source] = load_seeds_from_file(config.batch.batch_count, 'out');
            config.batch.seed_list = loaded_seeds(:).';
            config.batch.seed_source = seed_source;
            
            % Adjust batch count if needed
            if strcmp(seed_source.adjustment, 'batch_adjusted')
                config.batch.batch_count = numel(loaded_seeds);
            end
        catch ME
            fprintf('   Error loading seeds from file: %s\n', ME.message);
            fprintf('   Falling back to fixed seed mode.\n');
            config.batch.seed_mode = 'fixed';
        end
end

% GPU strategy
def_gpu = config.batch.use_gpu;
val = input(sprintf('8) GPU strategy use_gpu [auto/on/off] [default=%s]: ', def_gpu), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    if any(strcmp(v, {'auto','on','off'}))
        config.batch.use_gpu = v;
    else
        fprintf('   Invalid input, keeping default: %s\n', def_gpu);
    end
end

% parfor
def_pf = config.batch.use_parfor;
val = input(sprintf('9) Enable parallel parfor [y/n] [default=%s]: ', tf(def_pf)), 's');
if ~isempty(val)
    config.batch.use_parfor = is_yes(val);
end

% -----------------------------
% Calculate derived: GOx/HRP counts (optional storage)
% -----------------------------
N = config.particle_params.num_enzymes;
r = config.particle_params.gox_hrp_split;
gox_count = round(N * r);
hrp_count = N - gox_count;
config.particle_params.gox_count = gox_count;
config.particle_params.hrp_count = hrp_count;

% -----------------------------
% Summary print
% -----------------------------
fprintf('\n--------------- Configuration Summary ---------------\n');
fprintf('Mode: %s | Box: L=%g nm | T=%gs, dt=%gs\n', ...
    config.simulation_params.simulation_mode, ...
    config.simulation_params.box_size, ...
    config.simulation_params.total_time, ...
    config.simulation_params.time_step);
fprintf('Enzymes: total=%d (GOx=%d, HRP=%d, ratio=%.2f), substrate=%d\n', ...
    N, gox_count, hrp_count, r, config.particle_params.num_substrate);
fprintf('Batches: %d | Seed mode: %s\n', config.batch.batch_count, config.batch.seed_mode);
switch config.batch.seed_mode
    case 'fixed'
        fprintf('  fixed_seed=%d\n', config.batch.fixed_seed);
    case 'incremental'
        fprintf('  seed_base=%d\n', config.batch.seed_base);
    case 'manual_list'
        fprintf('  seed_list=[%s]\n', join_ints(config.batch.seed_list));
    case 'per_batch_random'
        fprintf('  per-batch will auto-generate random seeds\n');
end
fprintf('GPU: %s | parfor: %s | Visualization: %s\n', ...
    upper(config.batch.use_gpu), tf(config.batch.use_parfor), tf(config.ui_controls.visualize_enabled));
fprintf('Output directory: %s\n', config.io.outdir);
fprintf('----------------------------------------\n');

end

% ----------------- Utility Functions ---------------
function t = tf(b)
% Convert boolean to ON/OFF string
if b, t = 'ON'; else, t = 'OFF'; end
end

function result = is_yes(str)
% Check if string represents yes/true
str = lower(strtrim(str));
result = any(strcmp(str, {'y','yes','true','1','on'}));
end

function nums = parse_list_to_int(str)
% Parse comma-separated string to integer array
nums = [];
try
    parts = strsplit(str, ',');
    nums = cellfun(@(x) round(str2double(strtrim(x))), parts);
    nums = nums(isfinite(nums)); % Remove NaN values
catch
    nums = [];
end
end

function str = join_ints(nums)
% Join integer array to comma-separated string
if isempty(nums)
    str = '';
else
    str = sprintf('%d,', nums);
    str = str(1:end-1); % Remove trailing comma
end
end
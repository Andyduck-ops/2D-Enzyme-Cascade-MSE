function main_2d_pipeline()
% MAIN_2D_PIPELINE 2D Enzyme Cascade Simulation Main Control Entry
% Workflow:
%   1) Load default configuration [default_config()](modules/config/default_config.m:1)
%   2) Interactive input override [interactive_config()](modules/config/interactive_config.m:1)
%   3) Generate batch seeds [get_batch_seeds()](modules/seed_utils/get_batch_seeds.m:1) → output seeds.csv
%   4) Batch execution [run_batches()](modules/batch/run_batches.m:1)
%   5) Write report [write_report_csv()](modules/io/write_report_csv.m:1) → batch_results.csv
%
% Notes:
%   - Current version defaults to serial execution, visualization controlled by interactive switches; future extensions may include parfor and GPU optimization
%   - Sub-modules will be gradually migrated from [refactored_2d_model.m](refactored_2d_model.m) to modules directory

clc;
fprintf('====================================================\n');
fprintf(' 2D Main Control Pipeline Starting main_2d_pipeline\n');
fprintf('====================================================\n');

% --- Add unified module paths ---
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
else
    warning('Module directory not found: %s', modules_dir);
end

% --- 1) Default configuration ---
config = default_config();

% Normalize outdir relative to this script directory for cross-machine compatibility
config.io.outdir = fullfile(here, 'out');
if ~exist(config.io.outdir, 'dir')
    mkdir(config.io.outdir);
end

% --- 2) Interactive configuration override ---
config = interactive_config(config);

% --- 3) Batch seeds ---
[seeds, seeds_csv] = get_batch_seeds(config);
fprintf('Seed file: %s\n', seeds_csv);

% --- 4) Batch execution ---
batch_table = run_batches(config, seeds);

% --- 5) Write report ---
report_basename = getfield_or(config, {'batch','report_basename'}, 'batch_results');
report_csv = write_report_csv(batch_table, config.io.outdir, report_basename);


% --- Additional visualization and image saving integration ---
if getfield_or(config, {'ui_controls','visualize_enabled'}, false)
    viz_seed = seeds(1);
    fprintf('Visualization enabled: Using first batch seed Seed=%d to execute single simulation for image generation...\n', viz_seed);
    % To ensure trajectory plots are generated, force enable particle tracing for visualization single simulation
    viz_config = config;
    if ~isfield(viz_config, 'ui_controls'), viz_config.ui_controls = struct(); end
    viz_config.ui_controls.visualize_enabled = true; % Force visualization ON
    if ~isfield(viz_config, 'analysis_switches'), viz_config.analysis_switches = struct(); end
    viz_config.analysis_switches.enable_particle_tracing = true; % Force enable trajectory tracing
    if ~isfield(viz_config.analysis_switches, 'num_tracers_to_follow') || viz_config.analysis_switches.num_tracers_to_follow < 1
        viz_config.analysis_switches.num_tracers_to_follow = 5; % Minimum 1-5 tracers to follow
    end
    fprintf('Visualization single simulation: Force enabled tracer trajectories (num_tracers_to_follow=%d)\n', viz_config.analysis_switches.num_tracers_to_follow);
    results_viz = simulate_once(viz_config, viz_seed); % [simulate_once()](modules/sim_core/simulate_once.m:1)

    figs_all = gobjects(0,1);
    % Product curves
    try
        f = plot_product_curve(results_viz, config); % [plot_product_curve()](modules/viz/plot_product_curve.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_product_curve warning: %s\n', ME.message);
    end
    % Rate analysis
    try
        f = plot_reaction_rate_analysis(results_viz, config); % [plot_reaction_rate_analysis()](modules/viz/plot_reaction_rate_analysis.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end;
    catch ME
        fprintf('plot_reaction_rate_analysis warning: %s\n', ME.message);
    end
    % Snapshots
    try
        fs = plot_snapshot(results_viz, config); % [plot_snapshot()](modules/viz/plot_snapshot.m:1)
        if ~isempty(fs)
            fs = fs(isgraphics(fs));
            figs_all = [figs_all; fs(:)]; 
        end
    catch ME
        fprintf('plot_snapshot warning: %s\n', ME.message);
    end
    % Event maps
    try
        f = plot_event_map(results_viz, config); % [plot_event_map()](modules/viz/plot_event_map.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_event_map warning: %s\n', ME.message);
    end

    % Trajectories
    try
        if isfield(results_viz, 'tracer_paths') && ~isempty(results_viz.tracer_paths)
            fs = plot_tracers(results_viz, config); % [plot_tracers()](modules/viz/plot_tracers.m:1)
            if ~isempty(fs)
                fs = fs(isgraphics(fs)); 
                figs_all = [figs_all; fs(:)];
            end
        end
    catch ME
        fprintf('plot_tracers warning: %s\n', ME.message);
    end

    % Shell dynamics
    try
        f = plot_shell_dynamics(results_viz, config); % [plot_shell_dynamics()](modules/viz/plot_shell_dynamics.m:1).
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_shell_dynamics warning: %s\n', ME.message);
    end

    % Save images
    if getfield_or(config, {'ui_controls','enable_fig_save'}, false)
        formats = {'fig','png','pdf'};
        base_name = sprintf('viz_seed_%d', viz_seed);
        try
            saved_paths = save_figures(figs_all, config.io.outdir, base_name, formats); % [save_figures()](modules/io/save_figures.m:1)
            fprintf('Number of saved image files: %d\n', numel(saved_paths));
        catch ME
            fprintf('Failed to save images: %s\n', ME.message);
        end
    end
end

% --- Summary output ---
fprintf('\n================= Execution Complete =================\n');
fprintf('Report file: %s\n', report_csv);
if isfile(seeds_csv)
    fprintf('Seed record: %s\n', seeds_csv);
end
fprintf('Batch count: %d | Mode: %s | Visualization switch: %s\n', ...
    height(batch_table), config.simulation_params.simulation_mode, tf(config.ui_controls.visualize_enabled));

% --- Monte Carlo confidence interval statistics (based on batch products_final) ---
try
    pf = batch_table.products_final;
    valid_mask = isfinite(pf);
    n_total = height(batch_table);
    n_eff = sum(valid_mask);
    if n_eff >= 1
        pf_valid = pf(valid_mask);
        % Use sample standard deviation (n-1)
        mu = mean(pf_valid);
        sd = std(pf_valid, 0);
        se = sd / sqrt(n_eff);
        if n_eff >= 2 
            if exist('tinv', 'file') == 2
                tcrit = tinv(0.975, n_eff - 1);
                dist_name = 't';
            else
                tcrit = 1.96;  % Normal approximation
                dist_name = 'normal';
            end
            ci_lower = mu - tcrit * se;
            ci_upper = mu + tcrit * se;
        else
            ci_lower = NaN; ci_upper = NaN; dist_name = 'NA';
        end
        fprintf(['Monte Carlo statistics (products_final): Valid batches=%d/%d | Mean=%.3f | Std=%.3f | ' ...
                 '95%%CI=[%.3f, %.3f] (%s)\n'], n_eff, n_total, mu, sd, ci_lower, ci_upper, dist_name);
        % Write summary CSV
        summary_tbl = table(n_total, n_eff, mu, sd, se, ci_lower, ci_upper, 0.95, string(dist_name), ...
            'VariableNames', {'n_total','n_valid','mean','std','se','ci_lower','ci_upper','ci_level','dist'});
        mc_csv = fullfile(config.io.outdir, 'mc_summary.csv');
        try
            writetable(summary_tbl, mc_csv);
            fprintf('MC confidence intervals written: %s\n', mc_csv);
        catch ME
            fprintf('Failed to write mc_summary.csv: %s\n', ME.message);
        end
    else
        fprintf('Monte Carlo statistics: No valid products_final, skipping confidence interval calculation.\n');
    end
catch ME
    fprintf('Monte Carlo statistics error: %s\n', ME.message);
end
fprintf('====================================================\n');
end

% ----------------- Utility Functions ---------------
function v = getfield_or(s, path, default)
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

function t = tf(b)
if b, t = 'ON'; else, t = 'OFF'; end
end
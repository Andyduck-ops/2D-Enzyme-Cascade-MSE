function main_2d_pipeline()
% MAIN_2D_PIPELINE 2D Enzyme Cascade Simulation Main Control Entry
% Workflow:
%   1) Load default configuration [default_config()](modules/config/default_config.m:1)
%   2) Interactive input override [interactive_config()](modules/config/interactive_config.m:1)
%   3) Generate batch seeds [get_batch_seeds()](modules/seed_utils/get_batch_seeds.m:1) -> output seeds.csv
%   4) Batch execution [run_batches()](modules/batch/run_batches.m:1)
%   5) Write report [write_report_csv()](modules/io/write_report_csv.m:1) -> batch_results.csv
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

% --- 2.5) Check run mode ---
run_mode = getfield_or(config, {'ui_controls', 'run_mode'}, 'new');

if strcmp(run_mode, 'import')
    % ========== IMPORT MODE ==========
    fprintf('\n====================================================\n');
    fprintf(' Import Mode: Loading Historical Data\n');
    fprintf('====================================================\n');
    
    % Get selected datasets
    import_datasets = getfield_or(config, {'ui_controls', 'import_datasets'}, []);
    
    if isempty(import_datasets)
        error('No datasets selected for import');
    end
    
    % Create comparison output directory
    comp_dir = fullfile(here, 'out', 'comparisons');
    if ~exist(comp_dir, 'dir')
        mkdir(comp_dir);
    end
    
    % ========== Build Datasets Array for Plotting ==========
    fprintf('\nPreparing datasets for comparison...\n');
    n_datasets = numel(import_datasets);
    datasets = struct([]);
    
    for i = 1:n_datasets
        ds = struct();
        ds.time_axis = import_datasets(i).data.time_axis;
        ds.product_curves = import_datasets(i).data.product_curves;
        ds.label = import_datasets(i).label;
        ds.metadata = import_datasets(i).metadata;
        datasets = [datasets; ds];
        
        fprintf('  %d. %s\n', i, ds.label);
    end
    
    % ========== Generate Comparison Plot ==========
    fprintf('\nGenerating multi-dataset comparison plot...\n');
    
    try
        fig = plot_multi_comparison(datasets, config);
        
        % Save figure
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        base_name = sprintf('comparison_%s_n%d', timestamp, n_datasets);
        
        if getfield_or(config, {'ui_controls','enable_fig_save'}, false)
            formats = {'fig','png','pdf'};
            try
                saved_paths = save_figures(fig, comp_dir, base_name, formats);
                fprintf('Comparison plot saved: %d files\n', numel(saved_paths));
                for j = 1:numel(saved_paths)
                    fprintf('  - %s\n', saved_paths{j});
                end
            catch ME
                fprintf('Failed to save comparison plot: %s\n', ME.message);
            end
        else
            fprintf('Figure saving disabled. To save, set config.ui_controls.enable_fig_save = true\n');
        end
        
        fprintf('✓ Comparison plot generated successfully\n');
        
    catch ME
        fprintf('Error generating comparison plot: %s\n', ME.message);
        fprintf('Stack trace:\n');
        disp(ME.stack);
    end
    
    fprintf('\n====================================================\n');
    fprintf(' Import Mode Complete\n');
    fprintf(' Comparison directory: %s\n', comp_dir);
    fprintf(' Datasets compared: %d\n', n_datasets);
    fprintf('====================================================\n');
    return;
end

% ========== NEW SIMULATION MODE ==========
fprintf('\n====================================================\n');
fprintf(' New Simulation Mode\n');
fprintf('====================================================\n');

% --- 2.6) Create output directory structure ---
% Determine run type based on batch count
if config.batch.batch_count == 1
    run_type = 'single';
else
    run_type = 'batch';
end

% Create timestamped output structure
output_paths = output_manager(config, run_type);

% Update config to use new output directories
config.io.outdir = output_paths.run_dir;
config.io.data_dir = output_paths.data_dir;
config.io.figures_dir = output_paths.figures_dir;
config.io.single_viz_dir = output_paths.single_viz_dir;

% Track output files for metadata
output_files = struct();
output_files.figures = {};

% Track runtime statistics
run_stats = struct();
run_stats.start_time = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
run_start_tic = tic;

% --- 3) Batch seeds ---
[seeds, seeds_csv] = get_batch_seeds(config);
fprintf('Seed file: %s\n', seeds_csv);
output_files.seeds_csv = seeds_csv;

% --- 4) Batch execution ---
% Check if dual-system comparison mode is enabled
if getfield_or(config, {'ui_controls','dual_system_comparison'}, false)
    fprintf('\n====================================================\n');
    fprintf(' Dual-System Comparison Mode Enabled\n');
    fprintf('====================================================\n');

    % Run dual-system comparison
    [bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

    % ✅ FIX: Save BOTH system results separately
    fprintf('\n--- Saving Dual-System Batch Results ---\n');

    % Save bulk system results
    report_basename_bulk = 'batch_results_bulk';
    bulk_csv = write_report_csv(bulk_data.batch_table, config.io.data_dir, report_basename_bulk);
    fprintf('Bulk system results: %s\n', bulk_csv);

    % Save MSE system results
    report_basename_mse = 'batch_results_mse';
    mse_csv = write_report_csv(mse_data.batch_table, config.io.data_dir, report_basename_mse);
    fprintf('MSE system results: %s\n', mse_csv);
    
    % Track output files
    output_files.batch_results = {bulk_csv, mse_csv};
    
    % Save time-series data if enabled
    if getfield_or(config, {'io','save_timeseries'}, true)
        fprintf('\n--- Saving Time-Series Data ---\n');
        bulk_ts_csv = save_timeseries(bulk_data.time_axis, bulk_data.product_curves, ...
                                      config.io.data_dir, 'timeseries_products_bulk');
        mse_ts_csv = save_timeseries(mse_data.time_axis, mse_data.product_curves, ...
                                     config.io.data_dir, 'timeseries_products_mse');
        output_files.timeseries = {bulk_ts_csv, mse_ts_csv};
    end

    % Use bulk or MSE batch table based on original mode (for legacy compatibility)
    if strcmpi(config.simulation_params.simulation_mode, 'bulk')
        batch_table = bulk_data.batch_table;
    else
        batch_table = mse_data.batch_table;
    end

    % Store comparison data for visualization
    config.dual_comparison_data.bulk = bulk_data;
    config.dual_comparison_data.mse = mse_data;

else
    % Standard single-mode execution
    batch_table = run_batches(config, seeds);
end

% --- 5) Write report ---
report_basename = getfield_or(config, {'batch','report_basename'}, 'batch_results');
report_csv = write_report_csv(batch_table, config.io.data_dir, report_basename);
output_files.batch_results = report_csv;


% --- Additional visualization and image saving integration ---
% Only run single-run visualization for single runs (batch_count == 1)
% For batch runs, skip single-run visualization (use statistical plots instead)
if getfield_or(config, {'ui_controls','visualize_enabled'}, false) && config.batch.batch_count == 1
    % Single run visualization
    viz_outdir = config.io.figures_dir;
    
    viz_seed = seeds(1);
    fprintf('Visualization enabled: Single run visualization for Seed=%d\n', viz_seed);
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
            saved_paths = save_figures(figs_all, config.io.figures_dir, base_name, formats); % [save_figures()](modules/io/save_figures.m:1)
            fprintf('Number of saved image files: %d\n', numel(saved_paths));
            output_files.figures = [output_files.figures; saved_paths(:)];
        catch ME
            fprintf('Failed to save images: %s\n', ME.message);
        end
    end

    % Generate snapshot animation (if enabled)
    if getfield_or(config, {'ui_controls','enable_animation'}, false)
        try
            fprintf('\n--- Generating Snapshot Animation ---\n');
            % Temporarily update config.io.outdir for animation
            old_outdir = config.io.outdir;
            config.io.outdir = config.io.figures_dir;  % Always save to figures dir
            video_path = animate_snapshots(results_viz, config); % [animate_snapshots()](modules/viz/animate_snapshots.m:1)
            config.io.outdir = old_outdir;
            if ~isempty(video_path)
                fprintf('Animation saved: %s\n', video_path);
                output_files.figures = [output_files.figures; {video_path}];
            end
        catch ME
            fprintf('animate_snapshots warning: %s\n', ME.message);
        end
    end
end

% --- Dual-System Comparison Plot (Independent of visualize_enabled) ---
% This is a Monte Carlo statistical visualization and should generate
% regardless of single-run visualization settings
if isfield(config, 'dual_comparison_data') && ~isempty(config.dual_comparison_data)
    try
        fprintf('\n====================================================\n');
        fprintf(' Generating Dual-System Comparison Plot\n');
        fprintf('====================================================\n');
        f_dual = plot_dual_system_comparison(config.dual_comparison_data.bulk, ...
                                       config.dual_comparison_data.mse, ...
                                       config);

        % Save dual-system comparison plot
        if getfield_or(config, {'ui_controls','enable_fig_save'}, false) && ishghandle(f_dual)
            formats = {'fig','png','pdf'};
            base_name = sprintf('dual_comparison_enzymes_%d', config.particle_params.num_enzymes);
            try
                saved_paths = save_figures(f_dual, config.io.figures_dir, base_name, formats);
                fprintf('Dual-system comparison plot saved: %d files\n', numel(saved_paths));
                output_files.figures = [output_files.figures; saved_paths(:)];
            catch ME
                fprintf('Failed to save dual-system comparison plot: %s\n', ME.message);
            end
        end
        fprintf('Dual-system comparison plot generated successfully\n');
    catch ME
        fprintf('plot_dual_system_comparison warning: %s\n', ME.message);
    end

    % ✅ NEW: Generate additional statistical plots for dual-system comparison
    fprintf('\n====================================================\n');
    fprintf(' Generating Advanced Statistical Plots\n');
    fprintf('====================================================\n');

    figs_stats = gobjects(0,1);

    % 1. Batch distribution comparison
    try
        fprintf('Creating batch distribution comparison plot...\n');
        f_dist = plot_batch_distribution(config.dual_comparison_data.bulk, ...
                                        config.dual_comparison_data.mse, ...
                                        config); % [plot_batch_distribution()](modules/viz/plot_batch_distribution.m:1)
        if ishghandle(f_dist), figs_stats(end+1,1) = f_dist; end
    catch ME
        fprintf('plot_batch_distribution warning: %s\n', ME.message);
    end

    % 2. Enhancement factor evolution
    try
        fprintf('Creating enhancement factor evolution plot...\n');
        f_ef = plot_enhancement_factor(config.dual_comparison_data.bulk, ...
                                      config.dual_comparison_data.mse, ...
                                      config); % [plot_enhancement_factor()](modules/viz/plot_enhancement_factor.m:1)
        if ishghandle(f_ef), figs_stats(end+1,1) = f_ef; end
    catch ME
        fprintf('plot_enhancement_factor warning: %s\n', ME.message);
    end

    % 3. MC convergence analysis (Bulk)
    try
        fprintf('Creating Monte Carlo convergence analysis (Bulk)...\n');
        f_mc_bulk = plot_mc_convergence(bulk_data.batch_table, config, 'Bulk'); % [plot_mc_convergence()](modules/viz/plot_mc_convergence.m:1)
        if ishghandle(f_mc_bulk), figs_stats(end+1,1) = f_mc_bulk; end
    catch ME
        fprintf('plot_mc_convergence (Bulk) warning: %s\n', ME.message);
    end

    % 4. MC convergence analysis (MSE)
    try
        fprintf('Creating Monte Carlo convergence analysis (MSE)...\n');
        f_mc_mse = plot_mc_convergence(mse_data.batch_table, config, 'MSE'); % [plot_mc_convergence()](modules/viz/plot_mc_convergence.m:1)
        if ishghandle(f_mc_mse), figs_stats(end+1,1) = f_mc_mse; end
    catch ME
        fprintf('plot_mc_convergence (MSE) warning: %s\n', ME.message);
    end

    % 5. Batch timeseries heatmap (Bulk)
    try
        fprintf('Creating batch timeseries heatmap (Bulk)...\n');
        f_hm_bulk = plot_batch_timeseries_heatmap(bulk_data, config, 'Bulk'); % [plot_batch_timeseries_heatmap()](modules/viz/plot_batch_timeseries_heatmap.m:1)
        if ishghandle(f_hm_bulk), figs_stats(end+1,1) = f_hm_bulk; end
    catch ME
        fprintf('plot_batch_timeseries_heatmap (Bulk) warning: %s\n', ME.message);
    end

    % 6. Batch timeseries heatmap (MSE)
    try
        fprintf('Creating batch timeseries heatmap (MSE)...\n');
        f_hm_mse = plot_batch_timeseries_heatmap(mse_data, config, 'MSE'); % [plot_batch_timeseries_heatmap()](modules/viz/plot_batch_timeseries_heatmap.m:1)
        if ishghandle(f_hm_mse), figs_stats(end+1,1) = f_hm_mse; end
    catch ME
        fprintf('plot_batch_timeseries_heatmap (MSE) warning: %s\n', ME.message);
    end

    % Save statistical plots
    if getfield_or(config, {'ui_controls','enable_fig_save'}, false) && ~isempty(figs_stats)
        formats = {'fig','png','pdf'};
        base_name = sprintf('stats_enzymes_%d', config.particle_params.num_enzymes);
        try
            saved_paths = save_figures(figs_stats, config.io.figures_dir, base_name, formats);
            fprintf('Statistical plots saved: %d files\n', numel(saved_paths));
            output_files.figures = [output_files.figures; saved_paths(:)];
        catch ME
            fprintf('Failed to save statistical plots: %s\n', ME.message);
        end
    end

    fprintf('Advanced statistical plots generation complete\n');
    fprintf('====================================================\n');
end

% --- Write metadata ---
if getfield_or(config, {'io','write_metadata'}, true)
    run_stats.end_time = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
    run_stats.duration_seconds = toc(run_start_tic);
    run_stats.n_batches_completed = height(batch_table);
    
    try
        metadata_path = write_metadata(config, output_paths, output_files, run_stats);
        fprintf('\nRun metadata written: %s\n', metadata_path);
    catch ME
        fprintf('Warning: Failed to write metadata: %s\n', ME.message);
    end
end

% --- Summary output ---
fprintf('\n================= Execution Complete =================\n');
fprintf('Run directory: %s\n', output_paths.run_dir);
fprintf('Report file: %s\n', report_csv);
if isfile(seeds_csv)
    fprintf('Seed record: %s\n', seeds_csv);
end
fprintf('Batch count: %d | Mode: %s | Visualization switch: %s\n', ...
    height(batch_table), config.simulation_params.simulation_mode, tf(config.ui_controls.visualize_enabled));
fprintf('Runtime: %.1f seconds\n', run_stats.duration_seconds);

% --- Monte Carlo confidence interval statistics (based on batch products_final) ---
% ✅ FIX: Generate separate statistics for dual-system comparison
if isfield(config, 'dual_comparison_data') && ~isempty(config.dual_comparison_data)
    fprintf('\n--- Dual-System Monte Carlo Statistics ---\n');
    % Bulk system statistics
    try
        write_mc_stats(bulk_data.batch_table, config.io.data_dir, 'mc_summary_bulk.csv', 'Bulk');
    catch ME
        fprintf('Bulk MC statistics error: %s\n', ME.message);
    end
    % MSE system statistics
    try
        write_mc_stats(mse_data.batch_table, config.io.data_dir, 'mc_summary_mse.csv', 'MSE');
    catch ME
        fprintf('MSE MC statistics error: %s\n', ME.message);
    end
else
    % Standard single-mode statistics
    try
        write_mc_stats(batch_table, config.io.data_dir, 'mc_summary.csv', '');
    catch ME
        fprintf('Monte Carlo statistics error: %s\n', ME.message);
    end
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

function write_mc_stats(batch_table, outdir, filename, system_label)
% WRITE_MC_STATS Write Monte Carlo confidence interval statistics to CSV
% Inputs:
%   - batch_table: table with products_final column
%   - outdir: output directory
%   - filename: output CSV filename
%   - system_label: optional label ('Bulk', 'MSE', or '')
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
        % Print statistics
        if ~isempty(system_label)
            prefix = sprintf('[%s] ', system_label);
        else
            prefix = '';
        end
        fprintf(['%sMonte Carlo statistics (products_final): Valid batches=%d/%d | Mean=%.3f | Std=%.3f | ' ...
                 '95%%CI=[%.3f, %.3f] (%s)\n'], prefix, n_eff, n_total, mu, sd, ci_lower, ci_upper, dist_name);
        % Write summary CSV
        summary_tbl = table(n_total, n_eff, mu, sd, se, ci_lower, ci_upper, 0.95, string(dist_name), ...
            'VariableNames', {'n_total','n_valid','mean','std','se','ci_lower','ci_upper','ci_level','dist'});
        mc_csv = fullfile(outdir, filename);
        writetable(summary_tbl, mc_csv);
        fprintf('%sMC confidence intervals written: %s\n', prefix, mc_csv);
    else
        fprintf('%sMonte Carlo statistics: No valid products_final, skipping confidence interval calculation.\n', prefix);
    end
catch ME
    rethrow(ME);
end
end
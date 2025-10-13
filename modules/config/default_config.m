function config = default_config()
% DEFAULT_CONFIG Default configuration for 2D Enzyme Cascade Simulation
% Baseline source: [refactored_2d_model.m](../../refactored_2d_model.m)
% Output structure:
%   - simulation_params, particle_params, geometry_params, inhibition_params
%   - plotting_controls, plot_colors, analysis_switches, shell_dynamics
%   - font_settings, ui_controls, batch, io
% Description:
%   - This configuration maintains consistency with existing code parameters, with new additions for batch and RNG strategies, visualization switches, etc.
%   - Future interactive modules and batch processing modules will be extended based on this configuration

% -------------------------------------------------------------------------
% A. Physical System and Time Settings
% -------------------------------------------------------------------------
config.simulation_params.box_size = 500;                % nm
config.simulation_params.total_time = 100;              % s
config.simulation_params.time_step = 0.1;               % s
config.simulation_params.use_accurate_probability = true; % true: P=1-exp(-k*dt)
config.simulation_params.simulation_mode = 'MSE';   % 'MSE' or 'bulk'
% Auto-adapt time step to meet accuracy constraints (enabled by default)
config.simulation_params.enable_auto_dt = true;      % auto adjust dt before run
config.simulation_params.auto_dt.target_k_fraction = 0.05;   % ensure k_max*dt <= this
config.simulation_params.auto_dt.target_sigma_fraction = 0.3; % sigma <= this * min(scale)
config.simulation_params.auto_dt.target_sigma_abs_nm = 1.0;   % and sigma <= this (nm)

% -------------------------------------------------------------------------
% B. Particle and Molecular Properties
% -------------------------------------------------------------------------
config.particle_params.num_enzymes = 400;               % Total GOx+HRP count
config.particle_params.num_substrate = 3000;
config.particle_params.diff_coeff_bulk = 1000;          % nm^2/s
config.particle_params.diff_coeff_film = 10;            % nm^2/s
config.particle_params.k_cat_GOx = 100;                 % 1/s
config.particle_params.k_cat_HRP = 100;                 % 1/s
config.particle_params.gox_hrp_split = 0.5;             % GOx fraction (0-1), existing script uses 50/50

% -------------------------------------------------------------------------
% C. Geometric Dimension Settings
% -------------------------------------------------------------------------
config.geometry_params.particle_radius = 20;            % nm
config.geometry_params.film_thickness = 5;              % nm
config.geometry_params.radius_GOx = 2;                  % nm
config.geometry_params.radius_HRP = 2;                  % nm
config.geometry_params.radius_substrate = 1;            % nm

% -------------------------------------------------------------------------
% D. Crowding Inhibition Parameters
% -------------------------------------------------------------------------
config.inhibition_params.R_inhibit = 10;                % nm
config.inhibition_params.n_sat = 5;
config.inhibition_params.I_max = 0.8;                   % (0-1)

% -------------------------------------------------------------------------
% E. Simulation and Visualization Controls
% -------------------------------------------------------------------------
config.plotting_controls.force_cpu_mode = false;
config.plotting_controls.progress_report_interval = 250;
config.plotting_controls.data_recording_interval = 25;
config.plotting_controls.snapshot_times = [0, 50, 100];
% Box plot y-limits padding policy (for batch distribution plots)
config.plotting_controls.boxplot_y_pad_frac = 0.05;   % fraction of data range (top & bottom)
config.plotting_controls.boxplot_y_pad_min  = 1;      % absolute min padding (units)
config.plotting_controls.boxplot_y_pad_max  = 200;    % absolute max padding (units)

% -------------------------------------------------------------------------
% F. Professional Plotting Color Controls
% -------------------------------------------------------------------------
config.plot_colors.GOx = [0.8500, 0.3250, 0.0980];      % Deep Orange
config.plot_colors.HRP = [0.4940, 0.1840, 0.5560];      % Magenta/Purple
config.plot_colors.Product = [0.4660, 0.6740, 0.1880];  % Vivid Green
config.plot_colors.Particle = [0.5, 0.5, 0.5];          % Neutral Gray
config.plot_colors.TracerColormap = 'lines';

% -------------------------------------------------------------------------
% G. Advanced Data Recording and Analysis Options
% -------------------------------------------------------------------------
config.analysis_switches.enable_reaction_mapping = true;
config.analysis_switches.enable_particle_tracing = true;
config.analysis_switches.num_tracers_to_follow = 5;
config.analysis_switches.enable_reaction_rate_plot = true;
config.analysis_switches.enable_shell_dynamics_plot = true;
config.analysis_switches.enable_product_fitting_plot = false;
config.analysis_switches.enable_rate_fitting_plot = true;

% -------------------------------------------------------------------------
% H. Layered Dynamic Evolution Plot Controls
% -------------------------------------------------------------------------
config.shell_dynamics.num_shells = 4;
config.shell_dynamics.shell_width = 40;                 % nm

% -------------------------------------------------------------------------
% I. Global Font Controls
% -------------------------------------------------------------------------
config.font_settings.global_font_name = 'Arial';
config.font_settings.title_font_size = 14;
config.font_settings.label_font_size = 12;
config.font_settings.legend_font_size = 10;
config.font_settings.axis_font_size = 10;

% -------------------------------------------------------------------------
% J. UI Controls and Themes
% -------------------------------------------------------------------------
config.ui_controls.visualize_enabled = false;           % Batch processing defaults to visualization off
config.ui_controls.enable_fig_save = false;             % Default no image saving (can be decided by main control)
config.ui_controls.theme = 'light';                     % Theme placeholder: 'light' | 'dark'
config.ui_controls.dual_system_comparison = false;      % Dual-system comparison mode (bulk vs MSE)
config.ui_controls.enable_animation = false;            % Snapshot animation generation (requires snapshots)

% -------------------------------------------------------------------------
% K. Compute/Acceleration Options
% -------------------------------------------------------------------------
% Neighbor search backend: 'auto' | 'pdist2' | 'rangesearch' | 'gpu'
config.compute.neighbor_backend = 'auto';
% GPU compute for neighbor search: 'off' | 'on' | 'auto'
config.compute.use_gpu = 'off';

% -------------------------------------------------------------------------
% L. Batch and Random Number Strategies
% -------------------------------------------------------------------------
% seed_mode: 'fixed' | 'per_batch_random' | 'manual_list' | 'incremental'
config.batch.batch_count = 1;
config.batch.seed_mode = 'fixed';
config.batch.fixed_seed = 1234;                         % Fixed seed
config.batch.seed_base = 1000;                          % Base for incremental mode
config.batch.seed_list = [];                            % Manual seed list for manual_list mode
config.batch.use_gpu = 'auto';                          % 'auto' | 'on' | 'off'
config.batch.use_parfor = true;                         % Auto-enable parallel for better performance
config.batch.num_workers = 'auto';                      % Always auto-detect CPU cores (cores - 1)
config.batch.report_basename = 'batch_results';         % Report file prefix

% -------------------------------------------------------------------------
% M. IO Settings
% -------------------------------------------------------------------------
% Convention: out directory located under project root 'out/' (main sets absolute path)
config.io.outdir = 'out';
config.io.output_structure = 'timestamped';             % 'timestamped' | 'legacy'
config.io.save_timeseries = true;                       % Save time-series product data
config.io.write_metadata = true;                        % Write run metadata JSON

% Metadata
config.meta.version = 'v0.1-skeleton';
config.meta.created_by = 'default_config()';

end

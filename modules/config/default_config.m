function config = default_config()
% DEFAULT_CONFIG 2D酶级联模拟的默认配置
% 基线来源: [refactored_2d_model.m](../../refactored_2d_model.m)
% 输出结构:
%   - simulation_params, particle_params, geometry_params, inhibition_params
%   - plotting_controls, plot_colors, analysis_switches, shell_dynamics
%   - font_settings, ui_controls, batch, io
% 说明:
%   - 该配置与现有代码参数保持一致，并新增批次与RNG策略、可视化开关等选项
%   - 后续交互模块与批处理模块将基于此配置进行扩展

% -------------------------------------------------------------------------
% A. 物理系统与时间设置
% -------------------------------------------------------------------------
config.simulation_params.box_size = 500;                % nm
config.simulation_params.total_time = 100;              % s
config.simulation_params.time_step = 0.1;               % s
config.simulation_params.use_accurate_probability = true; % true: P=1-exp(-k*dt)
config.simulation_params.simulation_mode = 'MSE';   % 'MSE' 或 'bulk'

% -------------------------------------------------------------------------
% B. 粒子与分子属性
% -------------------------------------------------------------------------
config.particle_params.num_enzymes = 400;               % GOx+HRP 总数
config.particle_params.num_substrate = 3000;
config.particle_params.diff_coeff_bulk = 1000;          % nm^2/s
config.particle_params.diff_coeff_film = 10;            % nm^2/s
config.particle_params.k_cat_GOx = 100;                 % 1/s
config.particle_params.k_cat_HRP = 100;                 % 1/s
config.particle_params.gox_hrp_split = 0.5;             % GOx占比(0-1), 现有脚本为 50/50

% -------------------------------------------------------------------------
% C. 几何尺寸设置
% -------------------------------------------------------------------------
config.geometry_params.particle_radius = 20;            % nm
config.geometry_params.film_thickness = 5;              % nm
config.geometry_params.radius_GOx = 2;                  % nm
config.geometry_params.radius_HRP = 2;                  % nm
config.geometry_params.radius_substrate = 1;            % nm

% -------------------------------------------------------------------------
% D. 拥挤抑制参数
% -------------------------------------------------------------------------
config.inhibition_params.R_inhibit = 10;                % nm
config.inhibition_params.n_sat = 5;
config.inhibition_params.I_max = 0.8;                   % (0-1)

% -------------------------------------------------------------------------
% E. 模拟与可视化控制
% -------------------------------------------------------------------------
config.plotting_controls.force_cpu_mode = false;
config.plotting_controls.progress_report_interval = 250;
config.plotting_controls.data_recording_interval = 25;
config.plotting_controls.snapshot_times = [0, 50, 100];

% -------------------------------------------------------------------------
% F. 专业绘图颜色控制
% -------------------------------------------------------------------------
config.plot_colors.GOx = [0.8500, 0.3250, 0.0980];      % Deep Orange
config.plot_colors.HRP = [0.4940, 0.1840, 0.5560];      % Magenta/Purple
config.plot_colors.Product = [0.4660, 0.6740, 0.1880];  % Vivid Green
config.plot_colors.Particle = [0.5, 0.5, 0.5];          % Neutral Gray
config.plot_colors.TracerColormap = 'lines';

% -------------------------------------------------------------------------
% G. 高级数据记录与分析选项
% -------------------------------------------------------------------------
config.analysis_switches.enable_reaction_mapping = true;
config.analysis_switches.enable_particle_tracing = true;
config.analysis_switches.num_tracers_to_follow = 5;
config.analysis_switches.enable_reaction_rate_plot = true;
config.analysis_switches.enable_shell_dynamics_plot = true;
config.analysis_switches.enable_product_fitting_plot = false;
config.analysis_switches.enable_rate_fitting_plot = true;

% -------------------------------------------------------------------------
% H. 分层动态演化图控制
% -------------------------------------------------------------------------
config.shell_dynamics.num_shells = 4;
config.shell_dynamics.shell_width = 40;                 % nm

% -------------------------------------------------------------------------
% I. 全局字体控制
% -------------------------------------------------------------------------
config.font_settings.global_font_name = 'Arial';
config.font_settings.title_font_size = 14;
config.font_settings.label_font_size = 12;
config.font_settings.legend_font_size = 10;
config.font_settings.axis_font_size = 10;

% -------------------------------------------------------------------------
% J. UI 控制与主题
% -------------------------------------------------------------------------
config.ui_controls.visualize_enabled = false;           % 批处理默认关闭可视化
config.ui_controls.enable_fig_save = false;             % 默认不保存图像(可由主控决定)
config.ui_controls.theme = 'light';                     % 主题预留: 'light' | 'dark'

% -------------------------------------------------------------------------
% K. 批次与随机数策略
% -------------------------------------------------------------------------
% seed_mode: 'fixed' | 'per_batch_random' | 'manual_list' | 'incremental'
config.batch.batch_count = 1;
config.batch.seed_mode = 'fixed';
config.batch.fixed_seed = 1234;                         % 固定种子
config.batch.seed_base = 1000;                          % incremental 的基准
config.batch.seed_list = [];                            % manual_list 时手工种子列表
config.batch.use_gpu = 'auto';                          % 'auto' | 'on' | 'off'
config.batch.use_parfor = false;                        % 先默认关闭并行, 后续可开启
config.batch.report_basename = 'batch_results';         % 报告文件前缀

% -------------------------------------------------------------------------
% L. IO 设置
% -------------------------------------------------------------------------
% 约定 out 目录位于工程 2D/out 下；主控脚本可重写此路径
config.io.outdir = fullfile('2D', 'out');

% 元信息
config.meta.version = 'v0.1-skeleton';
config.meta.created_by = 'default_config()';

end
function main_2d_pipeline()
% MAIN_2D_PIPELINE 2D 酶级联模拟 主控入口
% 流程:
%   1) 加载默认配置 [default_config()](modules/config/default_config.m:1)
%   2) 交互式输入覆盖 [interactive_config()](modules/config/interactive_config.m:1)
%   3) 生成批次种子 [get_batch_seeds()](modules/seed_utils/get_batch_seeds.m:1) → 写出 seeds.csv
%   4) 批次运行 [run_batches()](modules/batch/run_batches.m:1)
%   5) 写出报告 [write_report_csv()](modules/io/write_report_csv.m:1) → batch_results.csv
%
% 说明:
%   - 当前版本默认串行运行，可视化由交互开关控制；后续可扩展 parfor 与GPU细化
%   - 各子模块将逐步从 [refactored_2d_model.m](refactored_2d_model.m) 拆分迁移至 modules 下

clc;
fprintf('====================================================\n');
fprintf(' 2D 主控流水线启动 main_2d_pipeline\n');
fprintf('====================================================\n');

% --- 统一加入模块路径 ---
here = fileparts(mfilename('fullpath'));
modules_dir = fullfile(here, 'modules');
if exist(modules_dir, 'dir')
    addpath(genpath(modules_dir));
else
    warning('未找到模块目录: %s', modules_dir);
end

% --- 1) 默认配置 ---
config = default_config();

% 将 outdir 规范为相对本脚本目录，保证跨机器可运行
config.io.outdir = fullfile(here, 'out');
if ~exist(config.io.outdir, 'dir')
    mkdir(config.io.outdir);
end

% --- 2) 交互式覆盖配置 ---
config = interactive_config(config);

% --- 3) 批次种子 ---
[seeds, seeds_csv] = get_batch_seeds(config);
fprintf('种子文件: %s\n', seeds_csv);

% --- 4) 批次运行 ---
batch_table = run_batches(config, seeds);

% --- 5) 写出报告 ---
report_basename = getfield_or(config, {'batch','report_basename'}, 'batch_results');
report_csv = write_report_csv(batch_table, config.io.outdir, report_basename);


% --- 额外可视化与图像保存集成 ---
if getfield_or(config, {'ui_controls','visualize_enabled'}, false)
    viz_seed = seeds(1);
    fprintf('开启可视化: 使用第一批种子 Seed=%d 执行一次单次模拟以生成图像...\n', viz_seed);
    % 为确保轨迹图一定生成，这里对可视化单次模拟的配置强制开启示踪追踪
    viz_config = config;
    if ~isfield(viz_config, 'ui_controls'), viz_config.ui_controls = struct(); end
    viz_config.ui_controls.visualize_enabled = true; % 强制可视化On
    if ~isfield(viz_config, 'analysis_switches'), viz_config.analysis_switches = struct(); end
    viz_config.analysis_switches.enable_particle_tracing = true; % 强制开启轨迹追踪
    if ~isfield(viz_config.analysis_switches, 'num_tracers_to_follow') || viz_config.analysis_switches.num_tracers_to_follow < 1
        viz_config.analysis_switches.num_tracers_to_follow = 5; % 最少跟踪1-5条
    end
    fprintf('可视化单次模拟：已强制启用示踪轨迹 (num_tracers_to_follow=%d)\n', viz_config.analysis_switches.num_tracers_to_follow);
    results_viz = simulate_once(viz_config, viz_seed); % [simulate_once()](modules/sim_core/simulate_once.m:1)

    figs_all = gobjects(0,1);
    % 产物曲线
    try
        f = plot_product_curve(results_viz, config); % [plot_product_curve()](modules/viz/plot_product_curve.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_product_curve 警告: %s\n', ME.message);
    end
    % 速率分析
    try
        f = plot_reaction_rate_analysis(results_viz, config); % [plot_reaction_rate_analysis()](modules/viz/plot_reaction_rate_analysis.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end;
    catch ME
        fprintf('plot_reaction_rate_analysis 警告: %s\n', ME.message);
    end
    % 快照
    try
        fs = plot_snapshot(results_viz, config); % [plot_snapshot()](modules/viz/plot_snapshot.m:1)
        if ~isempty(fs)
            fs = fs(isgraphics(fs));
            figs_all = [figs_all; fs(:)]; 
        end
    catch ME
        fprintf('plot_snapshot 警告: %s\n', ME.message);
    end
    % 事件图
    try
        f = plot_event_map(results_viz, config); % [plot_event_map()](modules/viz/plot_event_map.m:1)
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_event_map 警告: %s\n', ME.message);
    end

    % 轨迹
    try
        if isfield(results_viz, 'tracer_paths') && ~isempty(results_viz.tracer_paths)
            fs = plot_tracers(results_viz, config); % [plot_tracers()](modules/viz/plot_tracers.m:1)
            if ~isempty(fs)
                fs = fs(isgraphics(fs)); 
                figs_all = [figs_all; fs(:)];
            end
        end
    catch ME
        fprintf('plot_tracers 警告: %s\n', ME.message);
    end

    % 壳层动力学
    try
        f = plot_shell_dynamics(results_viz, config); % [plot_shell_dynamics()](modules/viz/plot_shell_dynamics.m:1).
        if ishghandle(f), figs_all(end+1,1) = f; end
    catch ME
        fprintf('plot_shell_dynamics 警告: %s\n', ME.message);
    end

    % 保存图像
    if getfield_or(config, {'ui_controls','enable_fig_save'}, false)
        formats = {'fig','png','pdf'};
        base_name = sprintf('viz_seed_%d', viz_seed);
        try
            saved_paths = save_figures(figs_all, config.io.outdir, base_name, formats); % [save_figures()](modules/io/save_figures.m:1)
            fprintf('已保存图像文件数: %d\n', numel(saved_paths));
        catch ME
            fprintf('保存图像失败: %s\n', ME.message);
        end
    end
end

% --- 摘要打印 ---
fprintf('\n================= 运行完成 =================\n');
fprintf('报告文件: %s\n', report_csv);
if isfile(seeds_csv)
    fprintf('种子记录: %s\n', seeds_csv);
end
fprintf('批次数: %d | 模式: %s | 可视化开关: %s\n', ...
    height(batch_table), config.simulation_params.simulation_mode, tf(config.ui_controls.visualize_enabled));

% --- MC 置信区间统计（基于批次 products_final） ---
try
    pf = batch_table.products_final;
    valid_mask = isfinite(pf);
    n_total = height(batch_table);
    n_eff = sum(valid_mask);
    if n_eff >= 1
        pf_valid = pf(valid_mask);
        % 使用样本标准差 (n-1)
        mu = mean(pf_valid);
        sd = std(pf_valid, 0);
        se = sd / sqrt(n_eff);
        if n_eff >= 2 
            if exist('tinv', 'file') == 2
                tcrit = tinv(0.975, n_eff - 1);
                dist_name = 't';
            else
                tcrit = 1.96;  % 正态近似
                dist_name = 'normal';
            end
            ci_lower = mu - tcrit * se;
            ci_upper = mu + tcrit * se;
        else
            ci_lower = NaN; ci_upper = NaN; dist_name = 'NA';
        end
        fprintf(['蒙特卡洛统计 (products_final): 有效批次=%d/%d | 均值=%.3f | 标准差=%.3f | ' ...
                 '95%%CI=[%.3f, %.3f] (%s)\n'], n_eff, n_total, mu, sd, ci_lower, ci_upper, dist_name);
        % 写出摘要 CSV
        summary_tbl = table(n_total, n_eff, mu, sd, se, ci_lower, ci_upper, 0.95, string(dist_name), ...
            'VariableNames', {'n_total','n_valid','mean','std','se','ci_lower','ci_upper','ci_level','dist'});
        mc_csv = fullfile(config.io.outdir, 'mc_summary.csv');
        try
            writetable(summary_tbl, mc_csv);
            fprintf('MC 置信区间已写出: %s\n', mc_csv);
        catch ME
            fprintf('写出 mc_summary.csv 失败: %s\n', ME.message);
        end
    else
        fprintf('蒙特卡洛统计: 无有效 products_final，跳过置信区间计算。\n');
    end
catch ME
    fprintf('蒙特卡洛统计异常: %s\n', ME.message);
end
fprintf('====================================================\n');
end

% ----------------- 工具函数 ---------------
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
function fig = plot_shell_dynamics(results, config)
% PLOT_SHELL_DYNAMICS 绘制径向壳层内底物数量的时间演化
% 用法:
%   fig = plot_shell_dynamics(results, config)
% 依赖:
%   - 美学规范: [viz_style()](./viz_style.m:1)
% 输入:
%   - results: [simulate_once()](../sim_core/simulate_once.m:1) 输出
%              需包含 results.shell_counts_over_time [R x N] 与 results.shell_edges [1 x (N+1)]
%   - config:  [default_config()](../config/default_config.m:1)
%
% 行为:
%   - 横轴为 t = (1:R) * dt * data_recording_interval
%   - 纵轴为每个壳层的底物计数
%   - 图例标注每个壳层的半径范围

counts = getfield_fallback(results, 'shell_counts_over_time', []);
edges  = getfield_fallback(results, 'shell_edges', []);

% 回退: 无分层数据
if isempty(counts) || isempty(edges) || size(counts,2) ~= numel(edges)-1
    fig = figure('Name', 'Shell Population Dynamics', 'Color', 'w', 'Position', [750, 750, 700, 500]);
    ax = axes(fig); 
    viz_style(ax, config.font_settings, getfield_or(config, {'ui_controls','theme'}, 'light'), config.plot_colors); % [viz_style()](./viz_style.m:1)
    text(0.5, 0.5, 'No shell dynamics data available', 'HorizontalAlignment', 'center', 'Parent', ax);
    axis(ax, 'off');
    return;
end

% 时间轴
dt = getfield_or(results, {'meta','dt'}, getfield_or(config, {'simulation_params','time_step'}, 0.1));
interval = getfield_or(config, {'plotting_controls','data_recording_interval'}, 25);
R = size(counts, 1);
t = (1:R)' * dt * interval;

% 创建图
fig = figure('Name', 'Shell Population Dynamics', 'Color', 'w', 'Position', [750, 750, 700, 500]);
ax = axes(fig); hold(ax, 'on');
viz_style(ax, config.font_settings, getfield_or(config, {'ui_controls','theme'}, 'light'), config.plot_colors); % [viz_style()](./viz_style.m:1)

% 颜色
co = lines(size(counts,2));

% 绘制
legend_labels = cell(size(counts,2), 1);
for i = 1:size(counts,2)
    plot(ax, t, counts(:, i), 'LineWidth', 2, 'Color', co(i,:));
    legend_labels{i} = sprintf('Shell: %.0f-%.0f nm', edges(i), edges(i+1));
end

xlabel(ax, 'Time (s)');
ylabel(ax, 'Number of Substrates in Shell');
title(ax, 'Substrate Count Evolution in Radial Shells');
legend(ax, legend_labels, 'Location', 'northeast');
grid(ax, 'on');
xlim(ax, [0, max(t)]);

hold(ax, 'off');

end

% ---------------- 工具 ----------------
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

function v = getfield_fallback(s, name, default)
v = default;
try
    if isstruct(s) && isfield(s, name)
        v = s.(name);
    end
catch
    v = default;
end
end
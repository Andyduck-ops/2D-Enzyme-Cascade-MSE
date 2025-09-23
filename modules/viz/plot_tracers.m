function figs = plot_tracers(results, config)
% PLOT_TRACERS 绘制示踪粒子轨迹
% 用法:
%   figs = plot_tracers(results, config)
% 依赖:
%   - 美学规范: [viz_style()](./viz_style.m:1)
% 输入:
%   - results: [simulate_once()](../sim_core/simulate_once.m:1) 的输出
%              需包含 results.tracer_paths {N x 1}，每个单元为 [T_i x 2] 轨迹
%   - config:  全局配置 [default_config()](../config/default_config.m:1)
%
% 行为:
%   - 将所有示踪轨迹绘制在同一张图上
%   - MSE 模式(兼容 surface)叠加中心颗粒轮廓
%   - 若无轨迹数据则友好提示并返回空句柄数组

% 读取必要配置
L = getfield_or(config, {'simulation_params','box_size'}, 500);
mode = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE');
font_settings = config.font_settings;
plot_colors   = config.plot_colors;
theme         = getfield_or(config, {'ui_controls','theme'}, 'light');

paths = {};
if isfield(results, 'tracer_paths')
    paths = results.tracer_paths;
end

if isempty(paths)
    figs = gobjects(0);
    warning('plot_tracers: 无示踪轨迹数据可绘制。');
    return;
end

% 颜色表: 优先使用配置中的 TracerColormap
try 
    cmap_name = plot_colors.TracerColormap;
catch 
    cmap_name = 'lines';
end
try
    cmap = feval(cmap_name, numel(paths));
catch
    cmap = lines(numel(paths));

end

% 创建图
figs = gobjects(1,1);
figs(1) = figure('Name', 'Particle Tracers', 'Color', 'w', 'Position', [1400, 650, 700, 500]);
ax = axes(figs(1)); hold(ax, 'on');
viz_style(ax, font_settings, theme, plot_colors); % [viz_style()](./viz_style.m:1)

% 绘制轨迹
for i = 1:numel(paths)
    P = paths{i};
    if isempty(P) || size(P,2) ~= 2, continue; end 
    if size(P,1) >= 2
        plot(ax, P(:,1), P(:,2), 'LineWidth', 1.5, 'Color', cmap(i,:), ...
            'DisplayName', sprintf('Tracer %d', i));
        plot(ax, P(:,1), P(:,2), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10, ...
            'Color', cmap(i,:), 'HandleVisibility', 'off');
    else
        scatter(ax, P(1,1), P(1,2), 36, cmap(i,:), 'filled', ...
            'DisplayName', sprintf('Tracer %d', i));
    end
end

% MSE 模式叠加中心颗粒（兼容 surface）
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
    pr = getfield_or(config, {'geometry_params','particle_radius'}, 20);
    th = linspace(0, 2*pi, 200);
    pc = [L/2, L/2];
    xp = pc(1) + pr * cos(th);
    yp = pc(2) + pr * sin(th);
    plot(ax, xp, yp, '--', 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Inorganic Particle');
end

axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
xlim(ax, [0 L]); ylim(ax, [0 L]);
title(ax, sprintf('Single Molecule Trajectories (%s mode)', mode));
xlabel(ax, 'X (nm)'); ylabel(ax, 'Y (nm)');
legend(ax, 'Location', 'northeastoutside', 'NumColumns', 1);

hold(ax, 'off');

end

% 读取字段或默认值
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
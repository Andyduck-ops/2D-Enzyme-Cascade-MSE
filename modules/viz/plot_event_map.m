function fig = plot_event_map(results, config)
% PLOT_EVENT_MAP 绘制反应事件空间分布图
% 用法:
%   fig = plot_event_map(results, config)
% 依赖:
%   - 美学规范: [viz_style()](./viz_style.m:1)
% 输入:
%   - results: [simulate_once()](../sim_core/simulate_once.m:1) 的输出
%              优先使用: results.reaction_coords_gox, results.reaction_coords_hrp
%              回退: 若二者为空, 尝试使用最后一帧 snapshots 的 Product 数据
%   - config:  全局配置 [default_config()](../config/default_config.m:1)

mode = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE');
L    = getfield_or(config, {'simulation_params','box_size'}, 500);
font_settings = config.font_settings;
plot_colors   = config.plot_colors;
theme         = getfield_or(config, {'ui_controls','theme'}, 'light');

% 事件坐标
rc_gox = getfield_fallback(results, 'reaction_coords_gox', []);
rc_hrp = getfield_fallback(results, 'reaction_coords_hrp', []);

% 回退: 使用最后一帧快照的 Product 分布
if isempty(rc_gox) && isempty(rc_hrp)
    if isfield(results, 'snapshots') && ~isempty(results.snapshots)
        last = results.snapshots(end, :);
        prod_pos = last{1,3};
        if ~isempty(prod_pos)
            rc_hrp = prod_pos; % 用产品位置作为事件近似
        end
    end
end

fig = figure('Name', 'Reaction Event Map', 'Color', 'w', 'Position', [1400, 100, 600, 500]);
ax = axes(fig); hold(ax, 'on');
viz_style(ax, font_settings, theme, plot_colors); % [viz_style()](./viz_style.m:1)

% MSE 模式叠加薄膜边界（兼容 surface）
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
     pr  = getfield_or(config, {'geometry_params','particle_radius'}, 20);
     ft  = getfield_or(config, {'geometry_params','film_thickness'}, 5);
     film_r = pr + ft;
     pc = [L/2, L/2];
     th = linspace(0, 2*pi, 200);
     xf = pc(1) + film_r * cos(th);
     yf = pc(2) + film_r * sin(th);
     plot(ax, xf, yf, '--', 'Color', plot_colors.Particle, 'LineWidth', 2, 'DisplayName', 'Enzyme Film');
end

% 绘制事件
has_any = false;
if ~isempty(rc_gox)
    scatter(ax, rc_gox(:,1), rc_gox(:,2), 24, plot_colors.GOx, 'filled', 'DisplayName', 'GOx Reactions');
    has_any = true;
end
if ~isempty(rc_hrp)
    scatter(ax, rc_hrp(:,1), rc_hrp(:,2), 24, plot_colors.HRP, 'filled', 'DisplayName', 'HRP Reactions');
    has_any = true;
end

axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
xlim(ax, [0 L]); ylim(ax, [0 L]);
title(ax, sprintf('Spatial Map of Reaction Events (%s mode)', mode));
xlabel(ax, 'X (nm)'); ylabel(ax, 'Y (nm)');
if has_any
    legend(ax, 'Location', 'northeast');
else
    text(0.5, 0.5, 'No reaction event data. Showing nothing.', 'HorizontalAlignment', 'center', 'Parent', ax);
end
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
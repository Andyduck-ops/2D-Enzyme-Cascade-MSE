function fig = plot_product_curve(results, config)
% PLOT_PRODUCT_CURVE 绘制产物生成曲线
% 用法:
%   fig = plot_product_curve(results, config)
% 依赖:
%   - 美学规范: [viz_style()](./viz_style.m:1)
% 输入:
%   - results: [simulate_once()](../sim_core/simulate_once.m:1) 的输出
%   - config:  全局配置 [default_config()](../config/default_config.m:1)
%
% 回退策略:
%   - 若 results.product_curve 为空, 尝试由 reaction_rate_hrp 积分得到
%   - 若仍为空, 则直接绘制 products_final 的水平线作为占位

time_axis = getfield_or(results, 'time_axis', []);
product_curve = getfield_or(results, 'product_curve', []);
rate_hrp = getfield_or(results, 'reaction_rate_hrp', []);

if isempty(product_curve)
    if ~isempty(rate_hrp) && ~isempty(time_axis)
        dt = median(diff(time_axis));
        product_curve = cumsum(rate_hrp) * dt;
    elseif ~isempty(time_axis)
        product_curve = zeros(size(time_axis));

    end
end

% 创建图
fig = figure('Name', 'Product Curve', 'Color', 'w', 'Position', [100, 500, 600, 400]);
ax = axes(fig); hold(ax, 'on');

% 应用美学
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
viz_style(ax, config.font_settings, viz_theme, config.plot_colors); % [viz_style()](./viz_style.m:1)

% 绘图
if ~isempty(time_axis) && ~isempty(product_curve)
    plot(ax, time_axis, product_curve, 'LineWidth', 2, 'Color', config.plot_colors.Product);
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Number of Products');
    title(ax, 'Product Generation Kinetics');
    grid(ax, 'on');
else
    % 占位: 无时间信息, 仅显示最终产物数
    y = getfield_or(results, 'products_final', NaN);
    if ~isnan(y)
        bar(ax, 1, y, 'FaceColor', config.plot_colors.Product);
        xlim(ax, [0 2]); set(ax, 'XTick', 1, 'XTickLabel', {'Final'});
        ylabel(ax, 'Number of Products');
        title(ax, 'Final Product Count (No time axis available)');
        grid(ax, 'on');
    else
        text(0.5, 0.5, 'No product data', 'HorizontalAlignment', 'center', 'Parent', ax);
        axis(ax, 'off');
    end
end

hold(ax, 'off');

end
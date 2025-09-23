function fig = plot_product_curve(results, config)
% PLOT_PRODUCT_CURVE Plot cumulative product counts over time.
% Usage:
%   fig = plot_product_curve(results, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
% Inputs:
%   - results: output struct from simulate_once() (../sim_core/simulate_once.m:1)
%   - config: configuration struct from default_config()/interactive_config()
%
% Post-processing:
%   - If results.product_curve is empty, integrate reaction_rate_hrp when available.
%   - Otherwise use products_final as a horizontal placeholder.

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

% Create figure
fig = figure('Name', 'Product Curve', 'Color', 'w', 'Position', [100, 500, 600, 400]);
ax = axes(fig); hold(ax, 'on');

% Apply visualization theme
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
viz_style(ax, config.font_settings, viz_theme, config.plot_colors); % [viz_style()](./viz_style.m:1)

% Plot curve
if ~isempty(time_axis) && ~isempty(product_curve)
    plot(ax, time_axis, product_curve, 'LineWidth', 2, 'Color', config.plot_colors.Product);
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Number of Products');
    title(ax, 'Product Generation Kinetics');
    grid(ax, 'on');
else
    % Placeholder: no curve data, show final count only
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

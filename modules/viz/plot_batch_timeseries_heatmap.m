function fig = plot_batch_timeseries_heatmap(data, config, system_label)
% PLOT_BATCH_TIMESERIES_HEATMAP Timeseries heatmap of all batch product curves
% Usage:
%   fig = plot_batch_timeseries_heatmap(data, config)
%   fig = plot_batch_timeseries_heatmap(data, config, system_label)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
%   - getfield_or() (../utils/getfield_or.m:1)
% Inputs:
%   - data: struct with fields
%       .time_axis: [n_steps x 1] time points (s)
%       .product_curves: [n_steps x n_batches] product counts matrix
%   - config: configuration struct
%   - system_label: optional string ('Bulk', 'MSE', or '')
%
% Output:
%   - fig: figure handle with timeseries heatmap visualization
%
% Features:
%   - 2D heatmap: time (x-axis) vs batch index (y-axis), color intensity = product count
%   - NOT a particle trajectory plot - visualizes product evolution across batches
%   - Overlaid mean trajectory reference line (white dashed)
%   - Anomalous batch annotations (>2σ deviation from mean)
%   - Color scale optimized for visual clarity (parula colormap)

arguments
    data struct
    config struct
    system_label char = ''
end

% Extract data
time_axis = getfield_or(data, 'time_axis', []);
product_curves = getfield_or(data, 'product_curves', []);

if isempty(time_axis) || isempty(product_curves)
    warning('plot_batch_timeseries_heatmap: Missing time_axis or product_curves');
    fig = [];
    return;
end

[n_steps, n_batches] = size(product_curves);

% Calculate statistics for anomaly detection
mean_curve = mean(product_curves, 2);
std_curve = std(product_curves, 0, 2);

% Identify anomalous batches (those with final products > 2σ from mean)
final_products = product_curves(end, :);
final_mean = mean(final_products);
final_std = std(final_products, 0);
threshold = 2.0;
anomalous_batches = find(abs(final_products - final_mean) > threshold * final_std);

% Create figure
if ~isempty(system_label)
    fig_name = sprintf('Batch Timeseries Heatmap (%s)', system_label);
else
    fig_name = 'Batch Timeseries Heatmap';
end

fig = figure('Name', fig_name, ...
             'Color', 'w', ...
             'Position', [100, 100, 1000, 600]);
ax = axes(fig);
hold(ax, 'on');

% Get theme settings
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
font_settings = config.font_settings;

% Plot heatmap
imagesc(ax, time_axis, 1:n_batches, product_curves');
colormap(ax, 'parula');
c = colorbar(ax);
c.Label.String = 'Product Count';
c.Label.FontSize = font_settings.label_font_size;

% Overlay mean trajectory as reference line
% Scale mean_curve to batch index space for visualization
mean_trajectory_y = interp1(linspace(min(mean_curve), max(mean_curve), n_batches), ...
                            1:n_batches, mean_curve, 'linear', 'extrap');
plot(ax, time_axis, mean_trajectory_y, 'w--', ...
     'LineWidth', 2.5, 'DisplayName', 'Mean Trajectory');

% Mark anomalous batches
if ~isempty(anomalous_batches)
    for i = 1:numel(anomalous_batches)
        batch_idx = anomalous_batches(i);
        scatter(ax, time_axis(end), batch_idx, 100, 'r', 'filled', ...
                'MarkerEdgeColor', 'w', 'LineWidth', 1.5);
        text(ax, time_axis(end) * 0.95, batch_idx, sprintf('B%d', batch_idx), ...
             'Color', 'w', 'FontSize', 8, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'right');
    end
end

% Labels and title
xlabel(ax, 'Time (s)', 'FontSize', font_settings.label_font_size);
ylabel(ax, 'Batch Index', 'FontSize', font_settings.label_font_size);

if ~isempty(system_label)
    title(ax, sprintf('Batch Timeseries Heatmap - %s System (n=%d)', system_label, n_batches), ...
          'FontSize', font_settings.title_font_size);
else
    title(ax, sprintf('Batch Timeseries Heatmap (n=%d batches)', n_batches), ...
          'FontSize', font_settings.title_font_size);
end

% Apply theme (partially, as heatmap overrides some settings)
ax.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
ax.FontSize = getfield_or(font_settings, 'axis_font_size', 10);
ax.LineWidth = 1.0;
box(ax, 'on');

% Theme-specific adjustments
switch lower(viz_theme)
    case 'light'
        fig.Color = 'w';
        ax.Color = 'w';
    case 'dark'
        fig.Color = [0.1 0.1 0.12];
        ax.Color = [0.1 0.1 0.12];
end

% Add legend if anomalous batches exist
if ~isempty(anomalous_batches)
    lgd = legend(ax, {'Mean Trajectory'}, 'Location', 'northwest');
    lgd.FontSize = font_settings.legend_font_size;
    lgd.TextColor = 'w';
    lgd.Color = [0 0 0 0.5];
end

% Add annotation with statistics
annotation_str = sprintf(['Total batches: %d\n' ...
                         'Anomalous (>2σ): %d\n' ...
                         'Mean final: %.1f\n' ...
                         'Std final: %.1f'], ...
                         n_batches, numel(anomalous_batches), ...
                         final_mean, final_std);

annotation(fig, 'textbox', [0.02, 0.75, 0.12, 0.15], ...
           'String', annotation_str, ...
           'FontSize', 9, ...
           'BackgroundColor', 'w', ...
           'EdgeColor', 'k', ...
           'LineWidth', 1);

hold(ax, 'off');

end
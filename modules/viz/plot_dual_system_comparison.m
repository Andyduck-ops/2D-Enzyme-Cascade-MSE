function fig = plot_dual_system_comparison(bulk_data, mse_data, config)
% PLOT_DUAL_SYSTEM_COMPARISON Plot bulk vs MSE product curves with mean±S.D.
% Usage:
%   fig = plot_dual_system_comparison(bulk_data, mse_data, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
%   - getfield_or() (../utils/getfield_or.m:1)
% Inputs:
%   - bulk_data: struct with fields
%       .time_axis: [n_steps x 1] time points (s)
%       .product_curves: [n_steps x n_batches] product counts matrix
%       .enzyme_count: scalar, number of enzymes used
%   - mse_data: struct with same fields as bulk_data
%   - config: configuration struct from default_config()/interactive_config()
%
% Output:
%   - fig: figure handle with dual-system comparison plot
%
% Features:
%   - Plots mean product curves for both systems
%   - Displays ±S.D. error bands (shaded regions)
%   - Configurable enzyme quantity parameter
%   - Professional styling with viz_style()
%   - Legend showing system types and statistics

% Validate inputs
if ~isstruct(bulk_data) || ~isstruct(mse_data)
    error('plot_dual_system_comparison: bulk_data and mse_data must be structs');
end

% Extract bulk data
bulk_time = getfield_or(bulk_data, 'time_axis', []);
bulk_curves = getfield_or(bulk_data, 'product_curves', []);
bulk_enzyme_count = getfield_or(bulk_data, 'enzyme_count', NaN);

% Extract MSE data
mse_time = getfield_or(mse_data, 'time_axis', []);
mse_curves = getfield_or(mse_data, 'product_curves', []);
mse_enzyme_count = getfield_or(mse_data, 'enzyme_count', NaN);

% Validate data availability
if isempty(bulk_time) || isempty(bulk_curves)
    error('plot_dual_system_comparison: bulk_data missing time_axis or product_curves');
end
if isempty(mse_time) || isempty(mse_curves)
    error('plot_dual_system_comparison: mse_data missing time_axis or product_curves');
end

% Calculate statistics: mean and standard deviation
bulk_mean = mean(bulk_curves, 2);
bulk_std = std(bulk_curves, 0, 2);
mse_mean = mean(mse_curves, 2);
mse_std = std(mse_curves, 0, 2);

% Calculate final statistics for legend
bulk_final_mean = mean(bulk_curves(end, :));
bulk_final_std = std(bulk_curves(end, :), 0);
mse_final_mean = mean(mse_curves(end, :));
mse_final_std = std(mse_curves(end, :), 0);

% Create figure
fig = figure('Name', 'Dual System Comparison (Bulk vs MSE)', ...
             'Color', 'w', ...
             'Position', [100, 100, 900, 600]);
ax = axes(fig);
hold(ax, 'on');

% Apply visualization theme
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
viz_style(ax, config.font_settings, viz_theme, config.plot_colors);

% Define colors for bulk and MSE
color_bulk = [0.2, 0.4, 0.8];  % Blue for bulk
color_mse = [0.8, 0.2, 0.2];   % Red for MSE

% Plot bulk system: shaded error band + mean line
fill_bulk = [bulk_time; flipud(bulk_time)];
fill_y_bulk = [bulk_mean - bulk_std; flipud(bulk_mean + bulk_std)];
h_bulk_shade = fill(ax, fill_bulk, fill_y_bulk, color_bulk, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', '');

% Plot MSE system: shaded error band + mean line
fill_mse = [mse_time; flipud(mse_time)];
fill_y_mse = [mse_mean - mse_std; flipud(mse_mean + mse_std)];
h_mse_shade = fill(ax, fill_mse, fill_y_mse, color_mse, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', '');

% Plot mean curves
h_bulk = plot(ax, bulk_time, bulk_mean, '-', ...
    'LineWidth', 2.5, ...
    'Color', color_bulk, ...
    'DisplayName', sprintf('Bulk (mean=%.1f±%.1f)', bulk_final_mean, bulk_final_std));

h_mse = plot(ax, mse_time, mse_mean, '-', ...
    'LineWidth', 2.5, ...
    'Color', color_mse, ...
    'DisplayName', sprintf('MSE (mean=%.1f±%.1f)', mse_final_mean, mse_final_std));

% Labels and title
xlabel(ax, 'Time (s)', 'FontSize', config.font_settings.label_font_size);
ylabel(ax, 'Number of Products', 'FontSize', config.font_settings.label_font_size);

% Title with enzyme count information
if ~isnan(bulk_enzyme_count) && bulk_enzyme_count == mse_enzyme_count
    title(ax, sprintf('Dual System Comparison (Enzyme Count: %d)', bulk_enzyme_count), ...
          'FontSize', config.font_settings.title_font_size);
else
    title(ax, 'Dual System Comparison: Bulk vs MSE', ...
          'FontSize', config.font_settings.title_font_size);
end

% Legend
lgd = legend(ax, [h_bulk, h_mse], 'Location', 'northwest');
lgd.FontSize = config.font_settings.legend_font_size;
lgd.Box = 'on';

% Grid
grid(ax, 'on');
ax.GridLineStyle = ':';
ax.GridAlpha = 0.3;

hold(ax, 'off');

end
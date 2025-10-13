function fig = plot_batch_distribution(bulk_data, mse_data, config)
% PLOT_BATCH_DISTRIBUTION Distribution comparison of bulk vs MSE batch results
% Usage:
%   fig = plot_batch_distribution(bulk_data, mse_data, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
%   - getfield_or() (../utils/getfield_or.m:1)
% Inputs:
%   - bulk_data: struct with .batch_table field
%   - mse_data: struct with .batch_table field
%   - config: configuration struct from default_config()/interactive_config()
%
% Output:
%   - fig: figure handle with box plot and overlaid histograms
%
% Features:
%   - Side-by-side box plots showing distribution statistics
%   - Overlaid semi-transparent histograms
%   - Statistical significance annotations
%   - Violin-plot-like visualization

arguments
    bulk_data struct
    mse_data struct
    config struct
end

% Extract products_final from batch tables
bulk_pf = bulk_data.batch_table.products_final;
mse_pf = mse_data.batch_table.products_final;

% Filter valid values
bulk_valid = bulk_pf(isfinite(bulk_pf));
mse_valid = mse_pf(isfinite(mse_pf));

if isempty(bulk_valid) || isempty(mse_valid)
    warning('plot_batch_distribution: No valid data for distribution comparison');
    fig = [];
    return;
end

% Create figure with two subplots
fig = figure('Name', 'Batch Distribution Comparison', ...
             'Color', 'w', ...
             'Position', [100, 100, 1000, 500]);

% Get theme settings
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
font_settings = config.font_settings;

% Define colors
color_bulk = [0.2, 0.4, 0.8];
color_mse = [0.8, 0.2, 0.2];

% --- Subplot 1: Box Plot Comparison ---
ax1 = subplot(1, 2, 1);
hold(ax1, 'on');

% Prepare data for boxplot
data_combined = [bulk_valid; mse_valid];
group_labels = [repmat({'Bulk'}, numel(bulk_valid), 1); ...
                repmat({'MSE'}, numel(mse_valid), 1)];

% Create box plot
boxplot(ax1, data_combined, group_labels, ...
        'Colors', [color_bulk; color_mse], ...
        'Symbol', 'o', ...
        'Widths', 0.5);

% Overlay individual data points with jitter
x_bulk = ones(size(bulk_valid)) + 0.15 * (rand(size(bulk_valid)) - 0.5);
x_mse = 2 * ones(size(mse_valid)) + 0.15 * (rand(size(mse_valid)) - 0.5);

scatter(ax1, x_bulk, bulk_valid, 20, color_bulk, 'filled', ...
        'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0);
scatter(ax1, x_mse, mse_valid, 20, color_mse, 'filled', ...
        'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0);

ylabel(ax1, 'Final Products', 'FontSize', font_settings.label_font_size);
title(ax1, 'Distribution Statistics', 'FontSize', font_settings.title_font_size);
viz_style(ax1, font_settings, viz_theme, config.plot_colors);
grid(ax1, 'on');
% Ensure some horizontal margin and rotate tick labels to avoid overlap when many groups
try
    % Infer number of groups from categorical labels
    cats = unique(string(group_labels));
    n_groups = numel(cats);
    xlim(ax1, [0.5, n_groups + 0.5]);
catch
    xlim(ax1, [0.5, 2.5]);
end
try, xtickangle(ax1, 20); catch, end
ax1.TickLabelInterpreter = 'none';

% Expand y-limits to avoid visual crowding at top/bottom (boxes/outliers stacking)
all_vals = data_combined(isfinite(data_combined));
if ~isempty(all_vals)
    yr = [min(all_vals), max(all_vals)];
    dr = max(yr(2) - yr(1), eps);
    pad_frac = getfield_or(config, {'plotting_controls','boxplot_y_pad_frac'}, 0.05);
    pad_min  = getfield_or(config, {'plotting_controls','boxplot_y_pad_min'}, 1);
    pad_max  = getfield_or(config, {'plotting_controls','boxplot_y_pad_max'}, 200);
    pad = min(pad_max, max(pad_min, pad_frac * dr));
    new_ylim = [max(0, yr(1) - pad), yr(2) + pad];
    try, ylim(ax1, new_ylim); catch, end
end
hold(ax1, 'off');

% --- Subplot 2: Overlaid Histogram ---
ax2 = subplot(1, 2, 2);
hold(ax2, 'on');

% Determine histogram bins
all_data = [bulk_valid; mse_valid];
n_bins = min(30, max(10, round(sqrt(numel(all_data)))));
edges = linspace(min(all_data), max(all_data), n_bins);

% Plot histograms with transparency
histogram(ax2, bulk_valid, edges, ...
          'FaceColor', color_bulk, ...
          'FaceAlpha', 0.5, ...
          'EdgeColor', 'none', ...
          'Normalization', 'probability', ...
          'DisplayName', sprintf('Bulk (n=%d)', numel(bulk_valid)));

histogram(ax2, mse_valid, edges, ...
          'FaceColor', color_mse, ...
          'FaceAlpha', 0.5, ...
          'EdgeColor', 'none', ...
          'Normalization', 'probability', ...
          'DisplayName', sprintf('MSE (n=%d)', numel(mse_valid)));

% Add mean lines
bulk_mean = mean(bulk_valid);
mse_mean = mean(mse_valid);
yl = ylim(ax2);

plot(ax2, [bulk_mean, bulk_mean], yl, '--', ...
     'Color', color_bulk, 'LineWidth', 2, 'DisplayName', '');
plot(ax2, [mse_mean, mse_mean], yl, '--', ...
     'Color', color_mse, 'LineWidth', 2, 'DisplayName', '');

xlabel(ax2, 'Final Products', 'FontSize', font_settings.label_font_size);
ylabel(ax2, 'Probability', 'FontSize', font_settings.label_font_size);
title(ax2, 'Distribution Overlay', 'FontSize', font_settings.title_font_size);

% Legend
lgd = legend(ax2, 'Location', 'best');
lgd.FontSize = font_settings.legend_font_size;

viz_style(ax2, font_settings, viz_theme, config.plot_colors);
hold(ax2, 'off');

% Overall title with enhancement factor
enhancement_factor = mse_mean / max(bulk_mean, 1);
sgtitle(fig, sprintf('Batch Distribution Comparison (Enhancement: %.2fx)', enhancement_factor), ...
        'FontSize', font_settings.title_font_size + 2, 'FontWeight', 'bold');

% Statistical test annotation (if available)
try
    [~, p_value] = ttest2(bulk_valid, mse_valid);
    annotation(fig, 'textbox', [0.4, 0.02, 0.2, 0.05], ...
               'String', sprintf('t-test p-value: %.4f', p_value), ...
               'HorizontalAlignment', 'center', ...
               'FontSize', 10, ...
               'EdgeColor', 'none');
catch
    % ttest2 not available in older MATLAB versions
end

end

function fig = plot_enhancement_factor(bulk_data, mse_data, config)
% PLOT_ENHANCEMENT_FACTOR Enhancement factor evolution over time
% Usage:
%   fig = plot_enhancement_factor(bulk_data, mse_data, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
%   - getfield_or() (../utils/getfield_or.m:1)
% Inputs:
%   - bulk_data: struct with fields
%       .time_axis: [n_steps x 1] time points (s)
%       .product_curves: [n_steps x n_batches] product counts matrix
%   - mse_data: struct with same fields as bulk_data
%   - config: configuration struct
%
% Output:
%   - fig: figure handle showing enhancement factor dynamics
%
% Features:
%   - Mean enhancement factor: EF(t) = mean(MSE(t)) / mean(Bulk(t))
%   - 95% confidence interval shaded region
%   - Per-batch final enhancement factors (scatter)
%   - Time-dependent enhancement visualization

arguments
    bulk_data struct
    mse_data struct
    config struct
end

% Extract data
bulk_time = getfield_or(bulk_data, 'time_axis', []);
bulk_curves = getfield_or(bulk_data, 'product_curves', []);
mse_time = getfield_or(mse_data, 'time_axis', []);
mse_curves = getfield_or(mse_data, 'product_curves', []);

if isempty(bulk_time) || isempty(mse_time)
    warning('plot_enhancement_factor: Missing time_axis data');
    fig = [];
    return;
end

% Calculate mean curves
bulk_mean = mean(bulk_curves, 2);
mse_mean = mean(mse_curves, 2);

% Calculate enhancement factor (avoid division by zero)
enhancement_factor = zeros(size(bulk_mean));
for t = 1:numel(bulk_mean)
    if bulk_mean(t) > 0
        enhancement_factor(t) = mse_mean(t) / bulk_mean(t);
    else
        enhancement_factor(t) = NaN;
    end
end

% Calculate per-batch final enhancement factors
bulk_final = bulk_curves(end, :);
mse_final = mse_curves(end, :);
ef_final_per_batch = mse_final ./ max(bulk_final, 1);  % Avoid division by zero

% Calculate confidence intervals for enhancement factor
n_steps = numel(bulk_time);
n_batches = size(bulk_curves, 2);
ef_upper = zeros(n_steps, 1);
ef_lower = zeros(n_steps, 1);

for t = 1:n_steps
    % Bootstrap-style CI estimation
    ef_samples = mse_curves(t, :) ./ max(bulk_curves(t, :), 1);
    ef_samples = ef_samples(isfinite(ef_samples));

    if numel(ef_samples) >= 2
        ef_mean_t = mean(ef_samples);
        ef_std_t = std(ef_samples, 0);
        se_t = ef_std_t / sqrt(numel(ef_samples));

        if exist('tinv', 'file') == 2
            tcrit = tinv(0.975, numel(ef_samples) - 1);
        else
            tcrit = 1.96;
        end

        ef_upper(t) = ef_mean_t + tcrit * se_t;
        ef_lower(t) = ef_mean_t - tcrit * se_t;
    else
        ef_upper(t) = NaN;
        ef_lower(t) = NaN;
    end
end

% Create figure
fig = figure('Name', 'Enhancement Factor Evolution', ...
             'Color', 'w', ...
             'Position', [100, 100, 1000, 600]);
ax = axes(fig);
hold(ax, 'on');

% Get theme settings
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
font_settings = config.font_settings;

% Define color
color_ef = [0.8, 0.3, 0.3];
color_ci = [0.8, 0.5, 0.5];

% Plot confidence interval band
valid_mask = isfinite(ef_upper) & isfinite(ef_lower) & isfinite(enhancement_factor);
if any(valid_mask)
    time_valid = bulk_time(valid_mask);
    ef_valid = enhancement_factor(valid_mask);
    ef_upper_valid = ef_upper(valid_mask);
    ef_lower_valid = ef_lower(valid_mask);

    fill_x = [time_valid; flipud(time_valid)];
    fill_y = [ef_upper_valid; flipud(ef_lower_valid)];

    fill(ax, fill_x, fill_y, color_ci, ...
         'FaceAlpha', 0.25, ...
         'EdgeColor', 'none', ...
         'DisplayName', '95% CI');
end

% Plot mean enhancement factor curve
plot(ax, bulk_time, enhancement_factor, '-', ...
     'LineWidth', 3, ...
     'Color', color_ef, ...
     'DisplayName', 'Mean Enhancement Factor');

% Add reference line at EF = 1 (no enhancement)
yline(ax, 1, '--k', 'No Enhancement', ...
      'LineWidth', 1.5, 'Alpha', 0.6, 'FontSize', 10);

% Scatter plot: per-batch final enhancement factors
final_time = bulk_time(end);
scatter(ax, final_time * ones(size(ef_final_per_batch)), ef_final_per_batch, ...
        40, color_ef, 'filled', 'MarkerFaceAlpha', 0.4, ...
        'DisplayName', 'Per-Batch Final EF');

% Labels and title
xlabel(ax, 'Time (s)', 'FontSize', font_settings.label_font_size);
ylabel(ax, 'Enhancement Factor (MSE / Bulk)', 'FontSize', font_settings.label_font_size);

% Calculate final enhancement statistics
ef_final_mean = mean(ef_final_per_batch(isfinite(ef_final_per_batch)));
ef_final_std = std(ef_final_per_batch(isfinite(ef_final_per_batch)), 0);

title(ax, sprintf('Enhancement Factor Evolution (Final: %.2f±%.2f)', ...
                  ef_final_mean, ef_final_std), ...
      'FontSize', font_settings.title_font_size);

% Legend
lgd = legend(ax, 'Location', 'best');
lgd.FontSize = font_settings.legend_font_size;

% Apply theme
viz_style(ax, font_settings, viz_theme, config.plot_colors);
grid(ax, 'on');
hold(ax, 'off');

% Add annotation box with key statistics
annotation_str = sprintf(['Final EF: %.2f ± %.2f\n' ...
                         'Max EF: %.2f\n' ...
                         'Batches: %d'], ...
                         ef_final_mean, ef_final_std, ...
                         max(ef_final_per_batch(isfinite(ef_final_per_batch))), ...
                         n_batches);

annotation(fig, 'textbox', [0.15, 0.75, 0.15, 0.15], ...
           'String', annotation_str, ...
           'FontSize', 10, ...
           'BackgroundColor', 'w', ...
           'EdgeColor', 'k', ...
           'LineWidth', 1);

end
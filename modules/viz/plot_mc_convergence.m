function fig = plot_mc_convergence(batch_table, config, system_label)
% PLOT_MC_CONVERGENCE Monte Carlo convergence analysis visualization
% Usage:
%   fig = plot_mc_convergence(batch_table, config)
%   fig = plot_mc_convergence(batch_table, config, system_label)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
%   - getfield_or() (../utils/getfield_or.m:1)
% Inputs:
%   - batch_table: table with products_final column from run_batches()
%   - config: configuration struct from default_config()/interactive_config()
%   - system_label: optional string ('Bulk', 'MSE', or '')
%
% Output:
%   - fig: figure handle with 3 subplots showing convergence analysis
%
% Features:
%   - Cumulative mean convergence curve
%   - Cumulative standard deviation evolution
%   - 95% confidence interval width reduction
%   - Answers "How many batches are needed for stable results?"

arguments
    batch_table table
    config struct
    system_label char = ''
end

% Extract products_final and filter valid values
pf = batch_table.products_final;
valid_mask = isfinite(pf);
pf_valid = pf(valid_mask);
n_total = numel(pf_valid);

if n_total < 2
    warning('plot_mc_convergence: Need at least 2 valid batches for convergence analysis');
    fig = [];
    return;
end

% Calculate cumulative statistics
cum_mean = zeros(n_total, 1);
cum_std = zeros(n_total, 1);
cum_ci_width = zeros(n_total, 1);

for n = 1:n_total
    data_subset = pf_valid(1:n);
    cum_mean(n) = mean(data_subset);
    cum_std(n) = std(data_subset, 0);

    % Calculate 95% CI width
    if n >= 2
        se = cum_std(n) / sqrt(n);
        if exist('tinv', 'file') == 2
            tcrit = tinv(0.975, n - 1);
        else
            tcrit = 1.96;  % Normal approximation
        end
        cum_ci_width(n) = 2 * tcrit * se;
    else
        cum_ci_width(n) = NaN;
    end
end

batch_indices = (1:n_total)';

% Create figure with 3 subplots
if ~isempty(system_label)
    fig_name = sprintf('MC Convergence Analysis (%s)', system_label);
else
    fig_name = 'Monte Carlo Convergence Analysis';
end

fig = figure('Name', fig_name, ...
             'Color', 'w', ...
             'Position', [100, 100, 1200, 400]);

% Get theme settings
viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light');
font_settings = config.font_settings;

% Color scheme
color_main = [0.2, 0.6, 0.8];
color_ci = [0.8, 0.4, 0.2];

% --- Subplot 1: Cumulative Mean ---
ax1 = subplot(1, 3, 1);
hold(ax1, 'on');
plot(ax1, batch_indices, cum_mean, '-', 'LineWidth', 2, 'Color', color_main);
% Reference line: final mean
yline(ax1, cum_mean(end), '--', 'Final Mean', ...
      'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], 'Alpha', 0.7);
xlabel(ax1, 'Number of Batches', 'FontSize', font_settings.label_font_size);
ylabel(ax1, 'Cumulative Mean', 'FontSize', font_settings.label_font_size);
title(ax1, 'Mean Convergence', 'FontSize', font_settings.title_font_size);
viz_style(ax1, font_settings, viz_theme, config.plot_colors);
hold(ax1, 'off');

% --- Subplot 2: Cumulative Standard Deviation ---
ax2 = subplot(1, 3, 2);
hold(ax2, 'on');
plot(ax2, batch_indices, cum_std, '-', 'LineWidth', 2, 'Color', color_main);
% Reference line: final std
yline(ax2, cum_std(end), '--', 'Final Std', ...
      'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], 'Alpha', 0.7);
xlabel(ax2, 'Number of Batches', 'FontSize', font_settings.label_font_size);
ylabel(ax2, 'Cumulative Std. Dev.', 'FontSize', font_settings.label_font_size);
title(ax2, 'Variance Stabilization', 'FontSize', font_settings.title_font_size);
viz_style(ax2, font_settings, viz_theme, config.plot_colors);
hold(ax2, 'off');

% --- Subplot 3: CI Width Evolution ---
ax3 = subplot(1, 3, 3);
hold(ax3, 'on');
plot(ax3, batch_indices, cum_ci_width, '-', 'LineWidth', 2, 'Color', color_ci);
xlabel(ax3, 'Number of Batches', 'FontSize', font_settings.label_font_size);
ylabel(ax3, '95% CI Width', 'FontSize', font_settings.label_font_size);
title(ax3, 'Estimation Precision', 'FontSize', font_settings.title_font_size);
viz_style(ax3, font_settings, viz_theme, config.plot_colors);
hold(ax3, 'off');

% Add overall title
if ~isempty(system_label)
    sgtitle(fig, sprintf('Monte Carlo Convergence Analysis - %s System', system_label), ...
            'FontSize', font_settings.title_font_size + 2, 'FontWeight', 'bold');
else
    sgtitle(fig, 'Monte Carlo Convergence Analysis', ...
            'FontSize', font_settings.title_font_size + 2, 'FontWeight', 'bold');
end

end
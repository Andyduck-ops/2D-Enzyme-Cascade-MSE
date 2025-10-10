function fig = plot_multi_comparison(datasets, config)
% PLOT_MULTI_COMPARISON Multi-dataset comparison visualization
% Usage:
%   fig = plot_multi_comparison(datasets)
%   fig = plot_multi_comparison(datasets, config)
%
% Inputs:
%   - datasets: struct array with fields:
%       .time_axis: [n_steps x 1] time points
%       .product_curves: [n_steps x n_batches] product matrix
%       .label: display label for legend
%       .metadata: (optional) run metadata
%   - config: (optional) configuration struct for styling
%
% Output:
%   - fig: figure handle
%
% Description:
%   Creates publication-quality comparison plot of multiple datasets.
%   Features:
%     - Mean ± S.D. curves with shaded error bands
%     - Predefined color scheme (6+ colors)
%     - Line style cycling when colors run out
%     - Interactive legend (click to show/hide)
%     - Formatted legend with timestamp, mode, parameters, and statistics
%
% Example:
%   datasets(1).time_axis = t1;
%   datasets(1).product_curves = curves1;
%   datasets(1).label = '[10/10 14:30] bulk enz=400 sub=3000';
%   fig = plot_multi_comparison(datasets);

if nargin < 2
    config = struct();
end

n_datasets = numel(datasets);

if n_datasets == 0
    error('plot_multi_comparison: datasets array is empty');
end

% ========== Predefined Color Scheme ==========
% Professional color palette (colorblind-friendly)
colors = [
    0.8500, 0.3250, 0.0980;  % Orange
    0.0000, 0.4470, 0.7410;  % Blue
    0.4660, 0.6740, 0.1880;  % Green
    0.4940, 0.1840, 0.5560;  % Purple
    0.9290, 0.6940, 0.1250;  % Yellow
    0.6350, 0.0780, 0.1840;  % Dark Red
    0.3010, 0.7450, 0.9330;  % Cyan
    0.8500, 0.3250, 0.5980;  % Pink
];

% Line styles for cycling
line_styles = {'-', '--', '-.', ':'};

% ========== Create Figure ==========
fig = figure('Position', [100, 100, 1000, 600]);
hold on;
grid on;
box on;

% ========== Plot Each Dataset ==========
legend_entries = cell(n_datasets, 1);
plot_handles = gobjects(n_datasets, 1);

for i = 1:n_datasets
    dataset = datasets(i);
    
    % Validate dataset
    if ~isfield(dataset, 'time_axis') || ~isfield(dataset, 'product_curves')
        warning('Dataset %d missing required fields, skipping', i);
        continue;
    end
    
    time_axis = dataset.time_axis(:);
    product_curves = dataset.product_curves;
    
    % Calculate statistics
    mean_curve = mean(product_curves, 2);
    std_curve = std(product_curves, 0, 2);
    
    % Select color and line style
    color_idx = mod(i-1, size(colors, 1)) + 1;
    style_idx = floor((i-1) / size(colors, 1)) + 1;
    style_idx = mod(style_idx-1, numel(line_styles)) + 1;
    
    color = colors(color_idx, :);
    line_style = line_styles{style_idx};
    
    % Plot shaded error band (mean ± std)
    fill([time_axis; flipud(time_axis)], ...
         [mean_curve + std_curve; flipud(mean_curve - std_curve)], ...
         color, 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
         'HandleVisibility', 'off');
    
    % Plot mean curve
    h = plot(time_axis, mean_curve, 'LineWidth', 2, ...
             'Color', color, 'LineStyle', line_style);
    plot_handles(i) = h;
    
    % Build legend entry
    if isfield(dataset, 'label') && ~isempty(dataset.label)
        base_label = dataset.label;
    else
        base_label = sprintf('Dataset %d', i);
    end
    
    % Add statistics to legend
    final_mean = mean_curve(end);
    final_std = std_curve(end);
    legend_entries{i} = sprintf('%s (%.1f±%.1f)', base_label, final_mean, final_std);
end

% ========== Formatting ==========
xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Product Count', 'FontSize', 12, 'FontWeight', 'bold');
title('Multi-Dataset Comparison', 'FontSize', 14, 'FontWeight', 'bold');

% Apply styling from config if available
if isfield(config, 'font_settings')
    if isfield(config.font_settings, 'global_font_name')
        set(gca, 'FontName', config.font_settings.global_font_name);
    end
    if isfield(config.font_settings, 'axis_font_size')
        set(gca, 'FontSize', config.font_settings.axis_font_size);
    end
end

% ========== Interactive Legend ==========
% Create legend with click-to-toggle functionality
leg = legend(plot_handles, legend_entries, ...
             'Location', 'northwest', ...
             'FontSize', 10, ...
             'Interpreter', 'none');

% Enable interactive legend (MATLAB R2018a+)
try
    % Set up ItemHitFcn for interactive toggling
    set(leg, 'ItemHitFcn', @(src, event) toggle_visibility(event));
catch
    % Older MATLAB versions don't support ItemHitFcn
end

hold off;

fprintf('Multi-dataset comparison plot created with %d datasets\n', n_datasets);

end

% ========== Helper Functions ==========
function toggle_visibility(event)
% TOGGLE_VISIBILITY Toggle line visibility when legend item is clicked

try
    % Get the line object associated with the clicked legend item
    line_obj = event.Peer;
    
    % Toggle visibility
    if strcmp(line_obj.Visible, 'on')
        line_obj.Visible = 'off';
        % Make legend entry gray
        event.Peer.Color = [0.5, 0.5, 0.5];
    else
        line_obj.Visible = 'on';
        % Restore original color (stored in UserData)
        if isfield(line_obj.UserData, 'OriginalColor')
            line_obj.Color = line_obj.UserData.OriginalColor;
        end
    end
catch ME
    % Silently fail if toggle doesn't work
    warning('Legend toggle failed: %s', ME.message);
end
end

function fig = plot_shell_dynamics(results, config)
% PLOT_SHELL_DYNAMICS Plot shell occupancy dynamics over time.
% Usage:
%   fig = plot_shell_dynamics(results, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
% Inputs:
%   - results: output from simulate_once() (../sim_core/simulate_once.m:1)
%              expects results.shell_counts_over_time [R x N] and results.shell_edges [1 x (N+1)]
%   - config: configuration struct from default_config()/interactive_config()
%
% Details:
%   - Time axis: t = (1:R) * dt * data_recording_interval
%   - Values: particle counts within each shell
%   - Plot annotates each shell boundary radius range

counts = getfield_fallback(results, 'shell_counts_over_time', []);
edges  = getfield_fallback(results, 'shell_edges', []);

% Guard clause: nothing to plot
if isempty(counts) || isempty(edges) || size(counts,2) ~= numel(edges)-1
    fig = figure('Name', 'Shell Population Dynamics', 'Color', 'w', 'Position', [750, 750, 700, 500]);
    ax = axes(fig); 
    viz_style(ax, config.font_settings, getfield_or(config, {'ui_controls','theme'}, 'light'), config.plot_colors); % [viz_style()](./viz_style.m:1)
    text(0.5, 0.5, 'No shell dynamics data available', 'HorizontalAlignment', 'center', 'Parent', ax);
    axis(ax, 'off');
    return;
end

% Time axis
dt = getfield_or(results, {'meta','dt'}, getfield_or(config, {'simulation_params','time_step'}, 0.1));
interval = getfield_or(config, {'plotting_controls','data_recording_interval'}, 25);
R = size(counts, 1);
t = (1:R)' * dt * interval;

% Create figure
fig = figure('Name', 'Shell Population Dynamics', 'Color', 'w', 'Position', [750, 750, 700, 500]);
ax = axes(fig); hold(ax, 'on');
viz_style(ax, config.font_settings, getfield_or(config, {'ui_controls','theme'}, 'light'), config.plot_colors); % [viz_style()](./viz_style.m:1)

% Colormap
co = lines(size(counts,2));

% Labels
legend_labels = cell(size(counts,2), 1);
for i = 1:size(counts,2)
    plot(ax, t, counts(:, i), 'LineWidth', 2, 'Color', co(i,:));
    legend_labels{i} = sprintf('Shell: %.0f-%.0f nm', edges(i), edges(i+1));
end

xlabel(ax, 'Time (s)');
ylabel(ax, 'Number of Substrates in Shell');
title(ax, 'Substrate Count Evolution in Radial Shells');
legend(ax, legend_labels, 'Location', 'northeast');
grid(ax, 'on');
xlim(ax, [0, max(t)]);

hold(ax, 'off');

end

% ---------------- Utilities ----------------
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

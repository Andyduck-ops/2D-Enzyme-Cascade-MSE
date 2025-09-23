function figs = plot_tracers(results, config)
% PLOT_TRACERS Visualize tracer particle trajectories.
% Usage:
%   figs = plot_tracers(results, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
% Inputs:
%   - results: simulate_once() output (../sim_core/simulate_once.m:1)
%              expects results.tracer_paths {N x 1} with [T_i x 2] positions
%   - config: configuration struct from default_config()/interactive_config()
% Output:
%   - figs: array of figure handles (empty when no tracers)
%
% Behavior:
%   - Plots each trajectory in shared axes with unique color.
%   - MSE/surface modes overlay the inorganic particle boundary.
%   - Missing paths trigger a friendly warning.

% Extract key configuration values
L = getfield_or(config, {'simulation_params','box_size'}, 500);
mode = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE');
font_settings = config.font_settings;
plot_colors   = config.plot_colors;
theme         = getfield_or(config, {'ui_controls','theme'}, 'light');

paths = {};
if isfield(results, 'tracer_paths')
    paths = results.tracer_paths;
end

if isempty(paths)
    figs = gobjects(0);
    warning('plot_tracers: no tracer path data available.');
    return;
end

% Build colormap (fall back to default lines map)
try 
    cmap_name = plot_colors.TracerColormap;
catch 
    cmap_name = 'lines';
end
try
    cmap = feval(cmap_name, numel(paths));
catch
    cmap = lines(numel(paths));
end

% Create figure
figs = gobjects(1,1);
figs(1) = figure('Name', 'Particle Tracers', 'Color', 'w', 'Position', [1400, 650, 700, 500]);
ax = axes(figs(1)); hold(ax, 'on');
viz_style(ax, font_settings, theme, plot_colors); % [viz_style()](./viz_style.m:1)

% Plot trajectories
for i = 1:numel(paths)
    P = paths{i};
    if isempty(P) || size(P,2) ~= 2, continue; end 
    if size(P,1) >= 2
        plot(ax, P(:,1), P(:,2), 'LineWidth', 1.5, 'Color', cmap(i,:), ...
            'DisplayName', sprintf('Tracer %d', i));
        plot(ax, P(:,1), P(:,2), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10, ...
            'Color', cmap(i,:), 'HandleVisibility', 'off');
    else
        scatter(ax, P(1,1), P(1,2), 36, cmap(i,:), 'filled', ...
            'DisplayName', sprintf('Tracer %d', i));
    end
end

% MSE mode overlays the inorganic particle boundary
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
    pr = getfield_or(config, {'geometry_params','particle_radius'}, 20);
    th = linspace(0, 2*pi, 200);
    pc = [L/2, L/2];
    xp = pc(1) + pr * cos(th);
    yp = pc(2) + pr * sin(th);
    plot(ax, xp, yp, '--', 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Inorganic Particle');
end

axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
xlim(ax, [0 L]); ylim(ax, [0 L]);
title(ax, sprintf('Single Molecule Trajectories (%s mode)', mode));
xlabel(ax, 'X (nm)'); ylabel(ax, 'Y (nm)');
legend(ax, 'Location', 'northeastoutside', 'NumColumns', 1);

hold(ax, 'off');

end

% Helper: nested field lookup
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

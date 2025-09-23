function figs = plot_snapshot(results, config)
% PLOT_SNAPSHOT Plot selected 2D simulation snapshots.
% Usage:
%   figs = plot_snapshot(results, config)
% Inputs:
%   - results: simulate_once() output with results.snapshots {K x 3} (../sim_core/simulate_once.m:1)
%             snapshots{i,1}=GOx, {i,2}=HRP, {i,3}=Products
%   - config: configuration struct from default_config()/interactive_config()
% Behavior:
%   - Generates one figure per snapshot with GOx/HRP/Product scatter points using plot_colors.
%   - In surface mode, draws inorganic particle and film boundaries.
% Output:
%   - figs: array of figure handles for successfully rendered snapshots.

snapshots = [];
if isfield(results, 'snapshots')
    snapshots = results.snapshots;
end
if isempty(snapshots)
    figs = gobjects(0);
    warning('plot_snapshot: no snapshot data available.');
    return;
end

% Extract key settings
L = getfield_or(config, {'simulation_params','box_size'}, 500);
mode = getfield_or(config, {'simulation_params','simulation_mode'}, 'surface');
font_settings = config.font_settings;
plot_colors   = config.plot_colors;
theme         = getfield_or(config, {'ui_controls','theme'}, 'light');

% Determine snapshot labels (fall back to index labels)
snapshot_times = getfield_or(config, {'plotting_controls','snapshot_times'}, []);
K = size(snapshots, 1);
if numel(snapshot_times) < K
    % Ensure labels cover all snapshots
    t_labels = arrayfun(@(i) sprintf('t #%d', i), 1:K, 'UniformOutput', false);
else
    t_labels = arrayfun(@(x) sprintf('t = %.2f s', x), snapshot_times(1:K), 'UniformOutput', false);
end

% Draw particle and film boundaries when in surface mode
particle_center = [L/2, L/2];
pr  = getfield_or(config, {'geometry_params','particle_radius'}, 20);
ft  = getfield_or(config, {'geometry_params','film_thickness'}, 5);
film_boundary = pr + ft;

theta = linspace(0, 2*pi, 200);
x_particle = particle_center(1) + pr * cos(theta);
y_particle = particle_center(2) + pr * sin(theta);
x_film = particle_center(1) + film_boundary * cos(theta);
y_film = particle_center(2) + film_boundary * sin(theta);

figs = gobjects(K,1);
for i = 1:K
    figs(i) = figure('Name', sprintf('2D Snapshot %d', i), 'Color', 'w', 'Position', [750, 100, 700, 600]);
    ax = axes(figs(i)); hold(ax, 'on');
    viz_style(ax, font_settings, theme, plot_colors); % [viz_style()](./viz_style.m:1)

    % Plot GOx / HRP / Product scatter layers
    labels = {'GOx','HRP','Product'};
    colors = {plot_colors.GOx, plot_colors.HRP, plot_colors.Product};
    for j = 1:3
        pos = snapshots{i, j};
        if ~isempty(pos)
            scatter(ax, pos(:,1), pos(:,2), 20, 'filled', ...
                'MarkerFaceColor', colors{j}, 'MarkerEdgeColor', 'none', ...
                'DisplayName', labels{j});
        end
    end

    % Surface mode overlays
    if strcmpi(mode, 'surface')
        plot(ax, x_particle, y_particle, '--', 'Color', plot_colors.Particle, 'LineWidth', 2, 'DisplayName', 'Inorganic Particle');
        plot(ax, x_film, y_film, ':', 'Color', [0 0 0], 'LineWidth', 1, 'DisplayName', 'Film Boundary');
    end

    axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
    xlim(ax, [0 L]); ylim(ax, [0 L]);
    title(ax, sprintf('2D Particle Distribution (%s) - %s', mode, t_labels{i}));
    xlabel(ax, 'X (nm)'); ylabel(ax, 'Y (nm)');
    legend(ax, 'Location', 'northeastoutside');

    hold(ax, 'off');
end

end

% Helper: safe nested field lookup
function v = getfield_or(s, key, default)
v = default;
try
    if ischar(key)
        if isstruct(s) && isfield(s, key), v = s.(key); end
        return;
    end
    for i = 1:numel(key)
        k = key{i};
        if isstruct(s) && isfield(s, k)
            s = s.(k);
        else
            return;
        end
    end
    v = s;
catch
    v = default;
end
end

function fig = plot_event_map(results, config)
% PLOT_EVENT_MAP Plot the spatial distribution of reaction events.
% Usage:
%   fig = plot_event_map(results, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
% Inputs:
%   - results: output struct from simulate_once() (../sim_core/simulate_once.m:1)
%               consumes results.reaction_coords_gox and results.reaction_coords_hrp
%               fallback: if empty, use the final snapshot product positions
%   - config: global configuration struct (default_config()/interactive_config())

mode = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE');
L    = getfield_or(config, {'simulation_params','box_size'}, 500);
font_settings = config.font_settings;
plot_colors   = config.plot_colors;
theme         = getfield_or(config, {'ui_controls','theme'}, 'light');

% Reaction event coordinates
rc_gox = getfield_fallback(results, 'reaction_coords_gox', []);
rc_hrp = getfield_fallback(results, 'reaction_coords_hrp', []);

% Fallback: try the last snapshot for product positions when events are empty
if isempty(rc_gox) && isempty(rc_hrp)
    if isfield(results, 'snapshots') && ~isempty(results.snapshots)
        last = results.snapshots(end, :);
        prod_pos = last{1,3};
        if ~isempty(prod_pos)
            % Treat product coordinates as surrogate events
            rc_hrp = prod_pos;
        end
    end
end

fig = figure('Name', 'Reaction Event Map', 'Color', 'w', 'Position', [1400, 100, 600, 500]);
ax = axes(fig); hold(ax, 'on');
viz_style(ax, font_settings, theme, plot_colors); % [viz_style()](./viz_style.m:1)

% Draw enzyme film boundary for MSE/surface modes
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
     pr  = getfield_or(config, {'geometry_params','particle_radius'}, 20);
     ft  = getfield_or(config, {'geometry_params','film_thickness'}, 5);
     film_r = pr + ft;
     pc = [L/2, L/2];
     th = linspace(0, 2*pi, 200);
     xf = pc(1) + film_r * cos(th);
     yf = pc(2) + film_r * sin(th);
     plot(ax, xf, yf, '--', 'Color', plot_colors.Particle, 'LineWidth', 2, 'DisplayName', 'Enzyme Film');
end

% Plot events
has_any = false;
if ~isempty(rc_gox)
    scatter(ax, rc_gox(:,1), rc_gox(:,2), 24, plot_colors.GOx, 'filled', ...
        'MarkerFaceAlpha', 0.45, 'DisplayName', 'GOx Reactions');
    has_any = true;
end
if ~isempty(rc_hrp)
    scatter(ax, rc_hrp(:,1), rc_hrp(:,2), 24, plot_colors.HRP, 'filled', ...
        'MarkerFaceAlpha', 0.45, 'DisplayName', 'HRP Reactions');
    has_any = true;
end

axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
xlim(ax, [0 L]); ylim(ax, [0 L]);
title(ax, sprintf('Spatial Map of Reaction Events (%s mode)', mode));
xlabel(ax, 'X (nm)'); ylabel(ax, 'Y (nm)');
if has_any
    lgd = legend(ax, 'Location', 'northeast');
    if isfield(font_settings, 'legend_font_size')
        lgd.FontSize = font_settings.legend_font_size;
    end
else
    text(0.5, 0.5, 'No reaction event data. Showing nothing.', 'HorizontalAlignment', 'center', 'Parent', ax);
end
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

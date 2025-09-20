function viz_style(ax, font_settings, theme, plot_colors)
% VIZ_STYLE Unified visualization aesthetic settings
% Usage:
%   viz_style(ax, font_settings, theme)
%   viz_style(ax, font_settings, theme, plot_colors)
%
% Parameters:
%   - ax            Target axes handle
%   - font_settings Structure with fields from [default_config()](../config/default_config.m:1):
%       .global_font_name, .title_font_size, .label_font_size, .legend_font_size, .axis_font_size
%   - theme         'light' | 'dark'
%   - plot_colors   (optional) Structure with same plot_colors fields as [default_config()](../config/default_config.m:1)
%                    Will be used to set ColorOrder and some default colors
%
% Reference source for aesthetic suggestions: [Reference_notes.txt](../../Reference_notes.txt:329)

arguments
    ax (1,1) matlab.graphics.axis.Axes
    font_settings struct
    theme char {mustBeMember(theme, {'light','dark'})}
    plot_colors struct = struct()
end

% ---------------- Font and Basic Appearance ----------------
ax.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
ax.FontSize = getfield_or(font_settings, 'axis_font_size', 10);
ax.LineWidth = 1.0;
box(ax, 'on');
axis(ax, 'tight');
grid(ax, 'on');
ax.GridLineStyle = ':';
ax.GridAlpha = 0.5;

% ---------------- Theme ----------------
switch lower(theme)
    case 'light'
        bg_color = 'w';
        fg_color = 'k';
        grid_color = [0.2 0.2 0.2];
    case 'dark'
        bg_color = [0.1 0.1 0.12];
        fg_color = [0.92 0.92 0.95];
        grid_color = [0.65 0.65 0.7];
end
fig = ancestor(ax, 'figure');
if ~isempty(fig)
    fig.Color = bg_color;
end
ax.Color = bg_color;
ax.XColor = fg_color;
ax.YColor = fg_color;
ax.GridColor = grid_color;

% ---------------- Color Order and Colormap ----------------
% According to reference file, default colormap uses 'parula' for better perceptual uniformity
try
    colormap(ax, 'parula');
catch
    % Backward compatibility for older versions
end

% Set ColorOrder (prioritize using GOx/HRP/Product from passed plot_colors)
co = [];
if isfield(plot_colors, 'GOx'),      co(end+1,:) = plot_colors.GOx; end %#ok<AGROW>
if isfield(plot_colors, 'HRP'),      co(end+1,:) = plot_colors.HRP; end %#ok<AGROW>
if isfield(plot_colors, 'Product'),  co(end+1,:) = plot_colors.Product; end %#ok<AGROW>
if size(co,1) >= 1
    ax.ColorOrder = co;
end

% ---------------- Title/Label Font Sizes ----------------
% Note: Font sizes are applied only when title()/xlabel()/ylabel() are called later
% Here we provide a convenience function for unified settings
apply_title_label_legend(ax, font_settings);

    % Uniformly set title/label/legend font sizes
    function apply_title_label_legend(ax, font_settings)
        ttl = get(ax, 'Title');
        if isgraphics(ttl)
            ttl.FontSize = getfield_or(font_settings, 'title_font_size', 14);
            ttl.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
            ttl.Color    = ax.XColor;
        end

        xl = get(ax, 'XLabel');
        if isgraphics(xl)
            xl.FontSize = getfield_or(font_settings, 'label_font_size', 12);
            xl.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
            xl.Color    = ax.XColor;
        end

        yl = get(ax, 'YLabel');
        if isgraphics(yl)
            yl.FontSize = getfield_or(font_settings, 'label_font_size', 12);
            yl.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
            yl.Color    = ax.YColor;
        end

        % Legend font size can be set when creating legend:
        %   lgd = legend(ax, ...); lgd.FontSize = font_settings.legend_font_size;
    end

    % Read field or default value
    function v = getfield_or(s, key, default)
        v = default;
        try
            if isstruct(s) && isfield(s, key)
                v = s.(key);
            end
        catch
            v = default;
        end
    end

end
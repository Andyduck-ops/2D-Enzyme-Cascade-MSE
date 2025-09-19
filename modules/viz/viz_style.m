function viz_style(ax, font_settings, theme, plot_colors)
% VIZ_STYLE 统一的可视化美学设置
% 用法:
%   viz_style(ax, font_settings, theme)
%   viz_style(ax, font_settings, theme, plot_colors)
%
% 参数:
%   - ax            目标坐标区句柄
%   - font_settings 结构体, 字段同 [default_config()](../config/default_config.m:1):
%       .global_font_name, .title_font_size, .label_font_size, .legend_font_size, .axis_font_size
%   - theme         'light' | 'dark'
%   - plot_colors   (可选) 结构体, 字段同 [default_config()](../config/default_config.m:1) 的 plot_colors
%                    将用于设置 ColorOrder 和部分默认色
%
% 参考美学建议来源: [一些参考.txt](../../一些参考.txt:329)

arguments
    ax (1,1) matlab.graphics.axis.Axes
    font_settings struct
    theme char {mustBeMember(theme, {'light','dark'})}
    plot_colors struct = struct()
end

% ---------------- 字体与基础外观 ----------------
ax.FontName = getfield_or(font_settings, 'global_font_name', 'Arial');
ax.FontSize = getfield_or(font_settings, 'axis_font_size', 10);
ax.LineWidth = 1.0;
box(ax, 'on');
axis(ax, 'tight');
grid(ax, 'on');
ax.GridLineStyle = ':';
ax.GridAlpha = 0.5;

% ---------------- 主题 ----------------
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

% ---------------- 颜色序列与colormap ----------------
% 按参考文件建议, 默认 colormap 使用 'parula' 更具感知均匀性
try
    colormap(ax, 'parula');
catch
    % 低版本容错
end

% 设置 ColorOrder (优先使用传入的 plot_colors 中 GOx/HRP/Product)
co = [];
if isfield(plot_colors, 'GOx'),      co(end+1,:) = plot_colors.GOx; end %#ok<AGROW>
if isfield(plot_colors, 'HRP'),      co(end+1,:) = plot_colors.HRP; end %#ok<AGROW>
if isfield(plot_colors, 'Product'),  co(end+1,:) = plot_colors.Product; end %#ok<AGROW>
if size(co,1) >= 1
    ax.ColorOrder = co;
end

% ---------------- 标题/标签字号 ----------------
% 注意: 仅当后续调用 title()/xlabel()/ylabel() 时, 再应用字号
% 这里提供一个便捷函数用于统一设置
apply_title_label_legend(ax, font_settings);

    % 统一设置标题/标签/图例字号
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

        % 图例字号可在创建图例时设置:
        %   lgd = legend(ax, ...); lgd.FontSize = font_settings.legend_font_size;
    end

    % 读取字段或默认值
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
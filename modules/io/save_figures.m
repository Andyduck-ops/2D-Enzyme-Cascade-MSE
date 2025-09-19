function paths = save_figures(fig_handles, outdir, base_name, formats)
% SAVE_FIGURES 批量保存图像到指定目录，支持 fig/png/pdf
% 用法:
%   paths = save_figures(fig_handles, outdir, base_name, formats)
% 参数:
%   - fig_handles: 图句柄数组或元胞，可混合; 非有效图句柄将被跳过
%   - outdir: 输出目录（不存在会自动创建）
%   - base_name: 基础文件名，例如 'viz_seed_1234'
%   - formats: 字符串元胞数组，默认 {'fig','png','pdf'}
% 返回:
%   - paths: 已保存文件的完整路径字符串数组
%
% 依赖:
%   - 主控管线: [main_2d_pipeline()](../../main_2d_pipeline.m:1)
%   - 报表输出: [write_report_csv()](./write_report_csv.m:1)
%
% 说明:
%   - 优先使用 exportgraphics 保存 png/pdf；如果不可用，则回退 print/saveas
%   - 文件名包含序号与图名(清洗后的 Name)，以便多图场景有可读性
%   - 默认保存格式: fig + png + pdf（与用户要求一致）

if nargin < 4 || isempty(formats)
    formats = {'fig','png','pdf'};
end

if ~iscell(formats)
    error('formats 必须是元胞数组，例如 {''fig'',''png'',''pdf''}');
end

% 统一成数组
if iscell(fig_handles)
    figs = [fig_handles{:}];
else
    figs = fig_handles;
end
% 过滤有效图
valid = [];
for i = 1:numel(figs)
    if ishghandle(figs(i)) && strcmp(get(figs(i), 'Type'), 'figure')
        valid(end+1) = i; %#ok<AGROW>
    end
end
figs = figs(valid);

% 确保输出目录
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

paths = strings(0,1);

% 保存函数能力检查
has_export = exist('exportgraphics', 'file') == 2;

for idx = 1:numel(figs)
    fh = figs(idx);
    % 生成文件名: base + idx + safeName
    nm = get(fh, 'Name');
    if isempty(nm), nm = sprintf('Figure%d', double(fh)); end
    safe = regexprep(nm, '[^\w\-]+', '_');
    fname_base = sprintf('%s_%02d_%s', base_name, idx, safe);
    ax = local_best_axes(fh);

    % 遍历格式
    for f = 1:numel(formats)
        fmt = lower(strtrim(formats{f}));
        switch fmt
            case 'fig'
                fpath = fullfile(outdir, sprintf('%s.fig', fname_base));
                try
                    savefig(fh, fpath);
                catch ME
                    warning('保存 FIG 失败: %s', ME.message);
                    continue;
                end
            case 'png'
                fpath = fullfile(outdir, sprintf('%s.png', fname_base));
                try
                    if has_export
                        exportgraphics(ax, fpath, 'Resolution', 300);
                    else
                        print(fh, fpath, '-dpng', '-r300');
                    end
                catch ME
                    warning('保存 PNG 失败: %s', ME.message);
                    continue;
                end
            case 'pdf'
                fpath = fullfile(outdir, sprintf('%s.pdf', fname_base));
                try
                    if has_export
                        exportgraphics(ax, fpath, 'ContentType', 'vector');
                    else
                        print(fh, fpath, '-dpdf', '-bestfit');
                    end
                catch ME
                    warning('保存 PDF 失败: %s', ME.message);
                    continue;
                end
            otherwise
                warning('未支持的格式: %s，已跳过。', fmt);
                continue;
        end
        paths(end+1,1) = string(fpath); %#ok<AGROW>
    end
end

% 去重
paths = unique(paths, 'stable');

% 控制台摘要
if ~isempty(paths)
    fprintf('图像已保存至目录: %s\n', outdir);
else
    fprintf('无图像保存，可能没有有效图句柄或格式不支持。\n');
end

end

% 选择一个合适的坐标区用于 exportgraphics/print
function ax = local_best_axes(fig)
axs = findall(fig, 'Type', 'axes');
if isempty(axs)
    % 如果没有axes，创建一个空axes避免导出失败
    ax = axes('Parent', fig);
else
    % 选择最后创建的一个
    ax = axs(1);
end
end
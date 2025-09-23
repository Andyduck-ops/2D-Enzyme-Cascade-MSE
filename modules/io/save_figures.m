function paths = save_figures(fig_handles, outdir, base_name, formats)
% SAVE_FIGURES Save figure handles to an output directory (supports fig/png/pdf).
% Usage:
%   paths = save_figures(fig_handles, outdir, base_name, formats)
% Inputs:
%   - fig_handles: array or cell array of figure handles; invalid entries are ignored.
%   - outdir: output directory path (created automatically if missing).
%   - base_name: filename prefix such as 'viz_seed_1234'.
%   - formats: cell array of strings; default is {'fig','png','pdf'}.
% Output:
%   - paths: string array of saved file paths.
%
% See also:
%   - main_2d_pipeline() (../../main_2d_pipeline.m:1)
%   - write_report_csv() (./write_report_csv.m:1)
%
% Notes:
%   - Prefer exportgraphics for png/pdf when available; fall back to print/saveas otherwise.
%   - Filenames include the figure Name to keep saved outputs readable.
%   - Default formats: fig, png, pdf; users may override as needed.

if nargin < 4 || isempty(formats)
    formats = {'fig','png','pdf'};
end

if ~iscell(formats)
    error('formats must be a cell array such as {''fig'',''png'',''pdf''}.');
end

% Normalize input to a flat array of figure handles
if iscell(fig_handles)
    figs = [fig_handles{:}];
else
    figs = fig_handles;
end
% Keep only valid figure handles
valid = [];
for i = 1:numel(figs)
    if ishghandle(figs(i)) && strcmp(get(figs(i), 'Type'), 'figure')
        valid(end+1) = i; %#ok<AGROW>
    end
end
figs = figs(valid);

% Ensure the output directory exists
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

paths = strings(0,1);

% Detect exportgraphics availability
has_export = exist('exportgraphics', 'file') == 2;

for idx = 1:numel(figs)
    fh = figs(idx);
    % Build filename from base, index, and sanitized figure name
    nm = get(fh, 'Name');
    if isempty(nm), nm = sprintf('Figure%d', double(fh)); end
    safe = regexprep(nm, '[^\w\-]+', '_');
    fname_base = sprintf('%s_%02d_%s', base_name, idx, safe);
    ax = local_best_axes(fh);

    % Export in each requested format
    for f = 1:numel(formats)
        fmt = lower(strtrim(formats{f}));
        switch fmt
            case 'fig'
                fpath = fullfile(outdir, sprintf('%s.fig', fname_base));
                try
                    savefig(fh, fpath);
                catch ME
                    warning('Failed to save FIG: %s', ME.message);
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
                    warning('Failed to save PNG: %s', ME.message);
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
                    warning('Failed to save PDF: %s', ME.message);
                    continue;
                end
            otherwise
                warning('Unsupported format: %s, skipping.', fmt);
                continue;
        end
        paths(end+1,1) = string(fpath); %#ok<AGROW>
    end
end

% Remove duplicates
paths = unique(paths, 'stable');

% Console summary
if ~isempty(paths)
    fprintf('Figures saved to: %s\n', outdir);
else
    fprintf('No figures saved; ensure handles are valid and formats are supported.\n');
end

end

% Select a representative axes for exportgraphics/print
function ax = local_best_axes(fig)
axs = findall(fig, 'Type', 'axes');
if isempty(axs)
    % No axes found; create an axes to avoid export failure
    ax = axes('Parent', fig);
else
    % Use the first axes by default
    ax = axs(1);
end
end

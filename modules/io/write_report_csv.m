function csv_path = write_report_csv(batch_table, outdir, basename)
% WRITE_REPORT_CSV 将批次结果表写出为CSV文件
% 用法:
%   csv_path = write_report_csv(batch_table, outdir)
%   csv_path = write_report_csv(batch_table, outdir, basename)
%
% 输入:
%   - batch_table  table, 通常来源于 [run_batches()](../batch/run_batches.m:1)
%   - outdir       输出目录, 通常来自 [default_config()](../config/default_config.m:1)
%   - basename     文件基本名(可选), 默认 'batch_results'
%
% 输出:
%   - csv_path     实际写出的 CSV 文件路径
%
% CSV 列推荐:
%   batch_index, seed, products_final, mode, num_enzymes, gox_count, hrp_count, num_substrate, dt, total_time

if nargin < 3 || isempty(basename)
    basename = 'batch_results';
end

if ~istable(batch_table)
    error('write_report_csv: 输入 batch_table 必须是 table。');
end

if ~exist(outdir, 'dir')
    try
        mkdir(outdir);
    catch ME
        error('无法创建输出目录 %s: %s', outdir, ME.message);
    end
end

csv_path = fullfile(outdir, sprintf('%s.csv', basename));

% 使用 writetable 写出
try
    writetable(batch_table, csv_path);
catch ME
    % 若低版本MATLAB或权限问题导致失败, 退回 fopen/fprintf
    warning('writetable 失败(%s), 使用手动写CSV。', ME.message);
    fid = fopen(csv_path, 'w');
    if fid == -1
        error('无法写入 CSV: %s', csv_path);
    end
    % 写表头
    headers = batch_table.Properties.VariableNames;
    for k = 1:numel(headers)
        if k > 1, fprintf(fid, ','); end
        fprintf(fid, '%s', headers{k});
    end
    fprintf(fid, '\n');
    % 写数据
    for i = 1:height(batch_table)
        for k = 1:numel(headers)
            if k > 1, fprintf(fid, ','); end
            val = batch_table{i, k};
            % 简单格式化: 数字/字符串/字符
            if isnumeric(val)
                fprintf(fid, '%g', val);
            elseif isstring(val) || ischar(val)
                fprintf(fid, '%s', string(val));
            else
                % 其他类型转为字符串
                fprintf(fid, '%s', char(string(val)));
            end
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

fprintf('批次结果已写出: %s\n', csv_path);

end
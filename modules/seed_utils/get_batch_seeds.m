function [seeds, csv_path] = get_batch_seeds(config)
% GET_BATCH_SEEDS 依据配置生成每批运行的随机数种子并写出 CSV
% 依赖配置来源: [default_config()](../config/default_config.m:1), [interactive_config()](../config/interactive_config.m:1)
% 输出:
%   - seeds    [batch_count x 1] 数组
%   - csv_path 写出的 CSV 路径 (用于存档/报告)
%
% 支持模式:
%   - fixed:            所有批次使用同一个 fixed_seed
%   - per_batch_random: 每批随机生成一个种子 (不可复现, 除非外部先行 rng 固定)
%   - manual_list:      使用用户提供的 seed_list (若长度不足则循环使用)
%   - incremental:      从 seed_base 开始, 对每批 +1 递增
%
% CSV 列:
%   batch_index, seed

% ---- 读取必要配置 ----
count = getfield_or(config, {'batch','batch_count'}, 1);
mode  = getfield_or(config, {'batch','seed_mode'}, 'fixed');

% ---- 生成 seeds ----
switch lower(mode)
    case 'fixed'
        fixed_seed = getfield_or(config, {'batch','fixed_seed'}, 1234);
        seeds = repmat(fixed_seed, count, 1);

    case 'per_batch_random'
        % 注意: 若希望复现实验, 应在外部先设置 rng(seed, 'twister')
        % 范围选择 1..2^31-1 与 MATLAB rng 兼容
        seeds = randi([1, 2^31-1], count, 1);

    case 'manual_list'
        list = getfield_or(config, {'batch','seed_list'}, []);
        if isempty(list)
            warning('manual_list 模式未提供 seed_list, 回退为 per_batch_random。');
            seeds = randi([1, 2^31-1], count, 1);
        else
            list = list(:);
            if numel(list) >= count
                seeds = list(1:count);
            else
                % 长度不足时循环使用
                reps = ceil(count / numel(list));
                seeds = repmat(list, reps, 1);
                seeds = seeds(1:count);
                fprintf('manual_list 长度不足(%d < %d), 已循环使用以补足批次数。\n', numel(list), count);
            end
        end

    case 'incremental'
        base = getfield_or(config, {'batch','seed_base'}, 1000);
        seeds = (base + (0:count-1))';
        
    otherwise
        warning('未知 seed_mode=%s, 回退为 fixed(1234)。', mode);
        seeds = repmat(1234, count, 1);
end

% ---- 写出 CSV ----
outdir = getfield_or(config, {'io','outdir'}, fullfile('2D','out'));
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
csv_path = fullfile(outdir, 'seeds.csv');

fid = fopen(csv_path, 'w');
if fid == -1
    warning('无法写入 %s, 跳过CSV输出。', csv_path);
else
    fprintf(fid, 'batch_index,seed\n');
    for i = 1:numel(seeds)
        fprintf(fid, '%d,%d\n', i, seeds(i));
    end
    fclose(fid);
end

% ---- 汇总打印 ----
fprintf('已生成批次种子: 模式=%s, 批次=%d, 写出=%s\n', mode, count, csv_path);

    function v = getfield_or(s, path, default)
        % 从嵌套结构获取字段, 不存在则返回默认值
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

end
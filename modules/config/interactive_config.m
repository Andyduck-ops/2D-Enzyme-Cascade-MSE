function config = interactive_config(config)
% INTERACTIVE_CONFIG 交互式采集模拟配置
% 用法:
%   cfg = interactive_config();                % 基于 [default_config()](./default_config.m) 的默认值进行交互
%   cfg = interactive_config(existing_config); % 在传入配置基础上微调
%
% 交互项覆盖:
%   - 粒子规模: 总酶数(num_enzymes), GOx占比(gox_hrp_split), 底物数(num_substrate)
%   - 模式: surface/bulk
%   - 可视化开关: visualize_enabled
%   - 批次与RNG: batch_count, seed_mode(fixed/per_batch_random/manual_list/incremental),
%                fixed_seed/seed_base/seed_list, use_gpu, use_parfor
%
% 注意:
%   - 本函数仅写入决策与参数, 后续 [get_batch_seeds()](../seed_utils/get_batch_seeds.m) 将实际生成批次种子
%   - 可视化美学与绘图由 [viz_style()](../viz/viz_style.m) 与各 plot_* 函数负责
%
% 参考基线: [refactored_2d_model.m](../../refactored_2d_model.m)

if nargin < 1 || isempty(config)
    config = default_config();
end

fprintf('====================================================\n');
fprintf(' 2D 模拟交互式配置\n');
fprintf(' (回车=使用默认值，输入数值或选项以覆盖)\n');
fprintf('====================================================\n');

% -----------------------------
% 基本规模设置
% -----------------------------
% 总酶数
def_num_enz = config.particle_params.num_enzymes;
val = input(sprintf('1) 总酶数量 num_enzymes [默认=%d]: ', def_num_enz));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val > 0
    config.particle_params.num_enzymes = round(val);
end

% GOx占比
def_ratio = config.particle_params.gox_hrp_split;
val = input(sprintf('2) GOx占比 gox_hrp_split (0-1) [默认=%.2f]: ', def_ratio));
if ~isempty(val) && isnumeric(val) && isfinite(val)
    config.particle_params.gox_hrp_split = max(0, min(1, val));
end

% 底物数量
def_num_sub = config.particle_params.num_substrate;
val = input(sprintf('3) 底物数量 num_substrate [默认=%d]: ', def_num_sub));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val >= 0
    config.particle_params.num_substrate = round(val);
end

% -----------------------------
% 模式与可视化
% -----------------------------
% 模式
def_mode = config.simulation_params.simulation_mode;
val = input(sprintf('4) 模式 simulation_mode [MSE/bulk] [默认=%s]: ', def_mode), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    % 兼容：将 surface 等价映射为 MSE
    if any(strcmp(v, {'mse','surface','bulk'}))
        if strcmp(v,'surface'), v = 'mse'; end
        config.simulation_params.simulation_mode = v;
    else
        fprintf('   无效输入, 保持默认: %s\n', def_mode);
    end
end

% 可视化开关
def_vis = config.ui_controls.visualize_enabled;
val = input(sprintf('5) 是否开启可视化 visualize_enabled [y/n] [默认=%s]: ', tf(def_vis)), 's');
if ~isempty(val)
    config.ui_controls.visualize_enabled = is_yes(val);
end

% -----------------------------
% 批次与随机数策略
% -----------------------------
% 批次数
def_batches = config.batch.batch_count;
val = input(sprintf('6) 批次数 batch_count [默认=%d]: ', def_batches));
if ~isempty(val) && isnumeric(val) && isfinite(val) && val > 0
    config.batch.batch_count = round(val);
end

% RNG 模式
def_seed_mode = config.batch.seed_mode;
val = input(sprintf(['7) 种子模式 seed_mode [fixed/per_batch_random/manual_list/incremental]\n' ...
                     '   [默认=%s]: '], def_seed_mode), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    if any(strcmp(v, {'fixed','per_batch_random','manual_list','incremental'}))
        config.batch.seed_mode = v;
    else
        fprintf('   无效输入, 保持默认: %s\n', def_seed_mode);
    end
end

% 按模式补充参数
switch config.batch.seed_mode
    case 'fixed'
        def_seed = config.batch.fixed_seed;
        val = input(sprintf('   - 固定种子 fixed_seed [默认=%d]: ', def_seed));
        if ~isempty(val) && isnumeric(val) && isfinite(val)
            config.batch.fixed_seed = round(val);
        end
    case 'incremental'
        def_base = config.batch.seed_base;
        val = input(sprintf('   - 增量种子基准 seed_base [默认=%d]: ', def_base));
        if ~isempty(val) && isnumeric(val) && isfinite(val)
            config.batch.seed_base = round(val);
        end
    case 'manual_list'
        val = input('   - 手工种子列表 seed_list (例如: 101,202,303): ', 's');
        if ~isempty(val)
            nums = parse_list_to_int(val);
            if ~isempty(nums)
                config.batch.seed_list = nums(:).';
                if numel(nums) < config.batch.batch_count
                    fprintf('   警告: 列表长度小于批次数(%d), 后续模块将按需截断/循环使用。\n', config.batch.batch_count);
                end
            else
                fprintf('   未解析到有效整数列表, 保持默认空列表。\n');
            end
        end
    case 'per_batch_random'
        % 不需要额外参数; 由 get_batch_seeds() 使用随机策略生成
end

% GPU 策略
def_gpu = config.batch.use_gpu;
val = input(sprintf('8) GPU 策略 use_gpu [auto/on/off] [默认=%s]: ', def_gpu), 's');
if ~isempty(val)
    v = lower(strtrim(val));
    if any(strcmp(v, {'auto','on','off'}))
        config.batch.use_gpu = v;
    else
        fprintf('   无效输入, 保持默认: %s\n', def_gpu);
    end
end

% parfor
def_pf = config.batch.use_parfor;
val = input(sprintf('9) 是否开启并行 parfor [y/n] [默认=%s]: ', tf(def_pf)), 's');
if ~isempty(val)
    config.batch.use_parfor = is_yes(val);
end

% -----------------------------
% 计算派生: GOx/HRP 数量(可选存放)
% -----------------------------
N = config.particle_params.num_enzymes;
r = config.particle_params.gox_hrp_split;
gox_count = round(N * r);
hrp_count = N - gox_count;
config.particle_params.gox_count = gox_count;
config.particle_params.hrp_count = hrp_count;

% -----------------------------
% 汇总打印
% -----------------------------
fprintf('\n--------------- 配置摘要 ---------------\n');
fprintf('模式: %s | 盒子: L=%g nm | T=%gs, dt=%gs\n', ...
    config.simulation_params.simulation_mode, ...
    config.simulation_params.box_size, ...
    config.simulation_params.total_time, ...
    config.simulation_params.time_step);
fprintf('酶: 总数=%d (GOx=%d, HRP=%d, 占比=%.2f), 底物=%d\n', ...
    N, gox_count, hrp_count, r, config.particle_params.num_substrate);
fprintf('批次: %d | 种子模式: %s\n', config.batch.batch_count, config.batch.seed_mode);
switch config.batch.seed_mode
    case 'fixed'
        fprintf('  fixed_seed=%d\n', config.batch.fixed_seed);
    case 'incremental'
        fprintf('  seed_base=%d\n', config.batch.seed_base);
    case 'manual_list'
        fprintf('  seed_list=[%s]\n', join_ints(config.batch.seed_list));
    case 'per_batch_random'
        fprintf('  per-batch 将自动随机生成种子\n');
end
fprintf('GPU: %s | parfor: %s | 可视化: %s\n', ...
    upper(config.batch.use_gpu), tf(config.batch.use_parfor), tf(config.ui_controls.visualize_enabled));
fprintf('输出目录: %s\n', config.io.outdir);
fprintf('----------------------------------------\n');

end

% -----------------------------
% 工具函数
% -----------------------------
function t = tf(b)
    if b, t = 'y'; else, t = 'n'; end
end

function b = is_yes(s)
    s = lower(strtrim(s));
    b = any(strcmp(s, {'y','yes','1','true','t'}));
end

function nums = parse_list_to_int(str)
    % 将 "1, 2, 3" -> [1 2 3]
    parts = regexp(str, '[,\s]+', 'split');
    nums = [];
    for i = 1:numel(parts)
        if isempty(parts{i}), continue; end
        v = str2double(parts{i});
        if ~isnan(v) && isfinite(v)
            nums(end+1) = round(v); %#ok<AGROW>
        end
    end
    nums = unique(nums, 'stable');
end

function s = join_ints(v)
    if isempty(v), s = ''; return; end
    s = sprintf('%d,', v(:));
    s = s(1:end-1);
end
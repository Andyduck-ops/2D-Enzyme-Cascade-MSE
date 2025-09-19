function mode_used = setup_rng(seed, use_gpu)
% SETUP_RNG 使用指定种子初始化CPU/GPU随机数生成器，保证可复现
% 用法:
%   mode_used = setup_rng(seed, use_gpu)
% 输入:
%   - seed    数值型整数随机种子
%   - use_gpu 'auto' | 'on' | 'off'，默认 'auto'
% 输出:
%   - mode_used 'cpu' | 'gpu' 表示最终使用的随机数设备
%
% 约定:
%   - CPU 使用 rng(seed, 'twister') 以获得稳定的跨版本可复现性
%   - GPU 使用 gpurng(seed, 'Threefry') 以支持子流与并行一致性
%   - 'auto' 模式: 若可用GPU则同时设定GPU RNG, 失败则回退CPU
%
% 参考: [default_config()](../config/default_config.m:1)

if nargin < 2 || isempty(use_gpu)
    use_gpu = 'auto';
end

% 始终先设置 CPU RNG，保证rand/randn 等可复现
rng(seed, 'twister');
mode_used = 'cpu';

% 选择是否设置 GPU RNG
switch lower(use_gpu)
    case 'off'
        % 仅CPU
        return;
    case 'on'
        if gpu_available()
            if try_set_gpurng(seed)
                mode_used = 'gpu';
            else
                warning('启用GPU RNG失败，回退CPU RNG。');
            end
        else
            warning('GPU不可用，回退CPU RNG。');
        end
    case 'auto'
        if gpu_available()
            if try_set_gpurng(seed)
                mode_used = 'gpu';
            else
                % 回退CPU已设置
                warning('自动模式: 设置GPU RNG失败，继续使用CPU RNG。');
            end
        else
            % CPU已设置
        end
    otherwise
        warning('未知 use_gpu=%s，回退CPU RNG。', use_gpu);
end

fprintf('RNG 初始化完成: seed=%d, mode=%s\n', seed, mode_used);

end

% ----------------- 内部工具函数 -----------------
function yes = gpu_available()
yes = false;
try
    yes = (gpuDeviceCount > 0);
catch
    yes = false;
end
end

function ok = try_set_gpurng(seed)
ok = false;
try
    gpurng(seed, 'Threefry');
    ok = true;
catch ME
    warning('gpurng 设定失败: %s', ME.message);
    ok = false;
end
end
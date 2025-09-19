function batch_table = run_batches(config, seeds)
% RUN_BATCHES 串行执行多批次模拟，记录每批的种子与关键结果
% 用法:
%   T = run_batches(config, seeds)
% 输入:
%   - config  由 [default_config()](../config/default_config.m:1) 与 [interactive_config()](../config/interactive_config.m:1) 生成
%   - seeds   [batch_count x 1] 批次种子，可由 [get_batch_seeds()](../seed_utils/get_batch_seeds.m:1) 生成
% 输出:
%   - batch_table  table，包含每批的 seed、products_final 与核心元数据

batch_count = numel(seeds);
if batch_count < 1
    error('run_batches: 输入 seeds 为空。');
end

% 预分配结果容器
seed_col          = zeros(batch_count,1);
prod_col          = nan(batch_count,1);
mode_col          = strings(batch_count,1);
enz_col           = zeros(batch_count,1);
gox_col           = zeros(batch_count,1);
hrp_col           = zeros(batch_count,1);
substrate_col     = zeros(batch_count,1);
dt_col            = zeros(batch_count,1);
total_time_col    = zeros(batch_count,1);

% 读取部分静态配置
sim_mode    = config.simulation_params.simulation_mode;
N_total     = config.particle_params.num_enzymes;
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count')
    gox_n = config.particle_params.gox_count;
    hrp_n = config.particle_params.hrp_count;
else
    r = config.particle_params.gox_hrp_split;
    gox_n = round(N_total * r);
    hrp_n = N_total - gox_n;
end
num_sub     = config.particle_params.num_substrate;
dt          = config.simulation_params.time_step;
T_total     = config.simulation_params.total_time;

fprintf('开始批次运行: %d 批\n', batch_count);
for b = 1:batch_count
    s = seeds(b);
    % 初始化RNG
    setup_rng(s, getfield_or(config, {'batch','use_gpu'}, 'auto')); % [setup_rng()](../rng/setup_rng.m:1)    
    
    % 单批运行
    results = simulate_once(config, s); % [simulate_once()](../sim_core/simulate_once.m:1)
    
    % 结果与元数据记录
    seed_col(b)       = s;
    prod_col(b)       = getfield_or(results, {'products_final'}, NaN);
    mode_col(b)       = string(sim_mode);
    enz_col(b)        = N_total;
    gox_col(b)        = gox_n;
    hrp_col(b)        = hrp_n;
    substrate_col(b)  = num_sub;
    dt_col(b)         = dt;
    total_time_col(b) = T_total;
    
    fprintf('  批 %d/%d | Seed=%d | Products=%g | Mode=%s\n', ...
        b, batch_count, s, prod_col(b), sim_mode);
end

% 汇总为表
batch_table = table(...
    (1:batch_count).', seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, ...
    substrate_col, dt_col, total_time_col, ...
    'VariableNames', {'batch_index','seed','products_final','mode','num_enzymes','gox_count','hrp_count','num_substrate','dt','total_time'} ...
);

    function v = getfield_or(s, path, default)
        v = default;
        try
            for k = 1:numel(path)
                key = path{k};
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
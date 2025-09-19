
function results = simulate_once(config, seed)
% SIMULATE_ONCE 单次模拟门面函数（集成实现）
% 流程:
%   - 初始化位置与派生参数 [init_positions()](./init_positions.m:1)
%   - 预计算拥挤抑制因子 [precompute_inhibition()](./precompute_inhibition.m:1)
%   - 时间循环:
%       * 计时与忙碌状态更新 [timer_busy_update()](../utils/timer_busy_update.m:1)
%       * 异质扩散步进 [diffusion_step()](./diffusion_step.m:1)
%       * 盒子反射 + 颗粒镜面反射 [boundary_reflection()](./boundary_reflection.m:1)
%       * 两级反应步进 [reaction_step()](./reaction_step.m:1)
%       * 选择性记录 [record_data()](./record_data.m:1) '''



% refactored_2d_model.m

arguments
    config struct
    seed   {mustBeNumeric, mustBeFinite}
end

% 基本时间与循环参数 
dt         = getfield_or(config, {'simulation_params','time_step'}, 0.1);
T_total    = getfield_or(config, {'simulation_params','total_time'}, 100);
num_steps  = max(1, round(T_total / dt));
mode       = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE') ;


% 进度与记录控制
progress_interval  = getfield_or(config, {'plotting_controls','progress_report_interval'}, 250);
record_interval    = getfield_or(config, {'plotting_controls','data_recording_interval'}, 25);
snapshot_times     = getfield_or(config, {'plotting_controls','snapshot_times'}, [0, 50, 100]);
visualize_enabled  = getfield_or(config, {'ui_controls','visualize_enabled'}, false);


% 兼容旧值: 将 surface 视为 MSE
is_mse_mode = any(strcmpi(mode, {'MSE','surface'}));
if strcmpi(mode,'surface')
    mode = 'MSE'; 
end


% 1) 初始化 + 预计算
state = init_positions(config);           % [init_positions()](./init_positions.m:1)
state = precompute_inhibition(state, config);  % [precompute_inhibition()](./precompute_inhibition.m:1)


% 2) 记录累加器初始化
accum = struct();
accum.dt = dt; 
accum.num_steps = num_steps;


% 2.1 速率曲线
accum.enable_rate = getfield_or(config, {'analysis_switches','enable_reaction_rate_plot'}, true);
if accum.enable_rate
    accum.reaction_rate_gox = zeros(num_steps, 1);
    accum.reaction_rate_hrp = zeros(num_steps, 1);
else
-    accum.reaction_rate_gox = [];    accum.reaction_rate_hrp = []];  % <-- unequal LHS/RHS; 
    accum.reaction_rate_gox = [];
    cum.reaction_rate_hrp = [];
end


% 2.2 快照 (可视化开关为真时再采集, 避免批处理开销)
if visualize_enabled
    snapshot_steps = unique(round(snapshot_times / dt));
    snapshot_steps(snapshot_steps == 0) = 1;
    snapshot_steps(snapshot_steps > num_steps) = num_steps;
else
-    snapshot_steps = []('];  % <-- unequal LHS/RHS;
    snapshot_steps = [];
end
accum.snapshot_steps = snapshot_steps(:);
accum.snapshot_idx   = 1;
accum.snapshots      = cell(numel(accum.snapshot_steps), 3);


% 2.3 分层动态 (仅在 MSE 且开启分析时启用；且依赖采样间隔)
enable_shell_flag = getfield_or(config, {'analysis_switches','enable_shell_dynamics_plot'}, true) && is_mse_mode && visualize_enabled;
accum.enable_shell = enable_shell_flag;
accum.data_recording_interval = record_interval;
accum.shell_record_counter = 0;
if accum.enable_shell
    n_shells = getfield_or(config, {'shell_dynamics','num_shells'}, 4);
    shell_width = getfield_or(config, {'shell_dynamics','shell_width'}, 40);
    shell_edges = state.film_boundary_radius + (0:n_shells)*shell_width;
    accum.shell_edges = shell_edges;
    num_records = floor(num_steps / record_interval);
    accum.shell_counts_over_time = zeros(num_records, numel(shell_edges)-1);
else
-    accum.shell_edges = [];    accum.shell_counts_over_time = []];  % <-- unequal LHS/RHS
    accum.shell_edges = [];
    accum.shell_counts_over_time = [];
end


% 事件坐标累计（用于空间反应事件图）
accum.reaction_coords_gox = zeros(0, 2);
accum.reaction_coords_hrp = zeros(0, 2);


% 2.4 示踪轨迹（仅在开启可视化且允许追踪时启用）
accum.enable_tracer = getfield_or(config, {'analysis_switches','enable_particle_tracing'}, true) && visualize_enabled;
if accum.enable_tracer
    num_to_follow = getfield_or(config, {'analysis_switches','num_tracers_to_follow'}, 5);
    n_avail = numel(state.substrate_ids);
    n_tr = min(num_to_follow, n_avail);
    if n_tr > 0
        perm = randperm(n_avail, n_tr);
        accum.tracer_ids = state.substrate_ids(perm);
        accum.tracer_paths = cell(n_tr, 1);
        % 立刻记录一次初始位置（t=0 前的采样），确保后续至少形成一条线段
        for ti = 1:n_tr
            tid = accum.tracer_ids(ti);
            idx0 = find(state.substrate_ids == tid, 1);
            if ~isempty(idx0)
                accum.tracer_paths{ti} = [accum.tracer_paths{ti}; state.substrate_pos(idx0, :)]; %#ok<AGROW>
            end
        end
    else
-        accum.tracer_ids = [];        accum.tracer_paths = {};        accum.enable_tracer = false;    end
    accum.tracer_ids = [];
    accum.tracer_paths = [];
    accum.enable_tracer = false;
    end
else
-    accum.tracer_ids = [];        accum.tracer_paths = {}; end
    accum.tracer_ids = [];
    accum.tracer_paths = [];
end










% 3) 时间循环
for step = 1:num_steps
    
    % 3.1 计时器与忙碌状态
    state = timer_busy_update(state);  % [timer_busy_update()](../utils/timer_busy_update.m:1)')


    % 3.2 扩散
    state = diffusion_step(state, config);  % [diffusion_step()](./diffusion_step.m:1)'))


    % 3.3 反射边界与颗粒碰撞
    state = boundary_reflection(state, config);  % [boundary_reflection()](./boundary_reflection.m:1))

    % 3.3b 示踪轨迹采样（Order反映前记录当前底物位置）
    if accum.enable_tracer && ~isempty(accum.tracer_ids)
        for ti = 1:numel(accum.tracer_ids)
            tid = accum.tracer_ids(ti);
            idx = find(state.substrate_ids == tid, 1);
            if ~isempty(idx)
                accum.tracer_paths{ti} = [accum.tracer_paths{ti}; state.substrate_pos(idx, :)]; %#ok<AGROW>
            end
        end 
    end

    % 3.4 反应
    [state, n_gox, n_hrp, ev_g, ev_h] = reaction_step(state, config);    % [reaction_step()](./reaction_step.m:1)
    % 累计本步事件坐标（若存在）
    if ~isempty(ev_g)
        accum.reaction_coords_gox = [accum.reaction_coords_gox; ev_g]; %#ok<AGROW>
    end
    if ~isempty(ev_h)
        accum.reaction_coords_hrp = [accum.reaction_coords_hrp; ev_h]; %#ok<AGROW>
    end

    % 3.5 记录
    accum = record_data(state, step, config, accum, n_gox, n_hrp);  % [record_data()](./record_data.m:1)


    % 3.6 进度 
    if mod(step, progress_interval) == 0
        fprintf('   Step %d/%d | Sub:%d Int:%d Prod:%d\n', step, num_steps, ...
            size(state.substrate_pos,1), size(state.intermediate_pos,1), size(state.product_pos,1));
    end
end


% 4) 汇总结果
results = struct();
results.products_final = size(state.product_pos, 1);


% 时间轴与产物曲线(从HRP速率积分得到)
if accum.enable_rate
    results.time_axis = (1:num_steps)' * dt;
    results.reaction_rate_gox = accum.reaction_rate_gox;
    results.reaction_rate_hrp = accum.reaction_rate_hrp;
    results.product_curve = cumsum(accum.reaction_rate_hrp) * dt;
else
-    results.time_axis = (1:num_steps)' * dt;
-    results.reaction_rate_gox = [];    results.reaction_rate_hrp = [];    results.product_curve = []; end
    results.time_axis = (1:num_steps)' * dt;
    results.reaction_rate_gox = [];
    results.reaction_rate_hrp = [];
    results.product_curve = [];
end


% 快照与分层
results.snapshots = accum.snapshots;
results.shell_counts_over_time = accum.shell_counts_over_time;
results.shell_edges = accum.shell_edges;


% 其余字段预留（后续可加入事件坐标/轨迹等）
results.reaction_coords_gox = accum.reaction_coords_gox;
results.reaction_coords_hrp = accum.reaction_coords_hrp;
results.tracer_paths = accum.tracer_paths;


% 元信息
results.meta = struct( 
    'seed',          double(seed),         ...
    'mode',          string(mode),         ...
    'num_enzymes',   double(getfield_or(config, {'particle_params','num_enzymes'}, NaN)), 
    'gox_hrp_split', double(getfield_or(config, {'particle_params','gox_hrp_split'}, 0.5)), 
    'num_substrate', double(getfield_or(config, {'particle_params','num_substrate'}, NaN)), 
    'dt',            double(dt),           ...
    'total_time',    double(T_total),      ...
    'placeholder',   false                 ... 
);

% 控制台摘要
fprintf('[simulate_once] 完成 | seed=%d | mode=%s | products_final=%d\n', ...
    seed, mode, results.products_final);


end


% ----------------- 工具函数 -----------------

function v = getfield_or(s, path, default)
% 从嵌套结构获取字段, 不存在则返回默认值
v = default;
try 
    if ischar(path)
        if isfield(s, path), v = s.(path); end
        return;
    end 
    for i = 1:numel(path)
        key = path{i};
        if isstruct(s) && isfield(s, key)
            s = s.(key);

        else
            return; end;
    end
    v = s;
catch
    v = default;
end
end

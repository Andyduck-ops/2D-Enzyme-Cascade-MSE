function [state, reacted_gox_count, reacted_hrp_count, event_coords_gox_step, event_coords_hrp_step] = reaction_step(state, config)
% REACTION_STEP 执行一次反应步进（GOx与HRP两级，含抑制因子与busy/timer）
% 用法:
%   [state, n_gox, n_hrp] = reaction_step(state, config)
%
% 逻辑要点:
%   - 当距离小于反应半径时, 以概率 P 发生反应:
%       精确:   P = 1 - exp(-k_cat*dt)
%       近似:   P = k_cat*dt
%   - 抑制因子: 乘以 per-enzyme 的 inhibition_factors (若不存在则默认为1)
%   - busy/timer: 反应后将对应酶设置为 busy 并启动计时器(步数=round(1/k_cat/dt))
%   - 转换:
%       S + GOx -> I + GOx
%       I + HRP -> P + HRP
%
% 参考实现: [refactored_2d_model.m](../../refactored_2d_model.m:399)

% ---------------- 参数与预处理 ----------------
dt = config.simulation_params.time_step;
use_accurate = config.simulation_params.use_accurate_probability;

kcat_gox = config.particle_params.k_cat_GOx;
kcat_hrp = config.particle_params.k_cat_HRP;

% 转换时间(步)
turnover_steps_gox = max(1, round((1/max(kcat_gox, eps))/dt));
turnover_steps_hrp = max(1, round((1/max(kcat_hrp, eps))/dt));

% 反应距离
r_goxt = state.reaction_dist_GOx;
r_hrpt = state.reaction_dist_HRP;

% 抑制因子(若不存在则使用1)
if isfield(state, 'inhibition_factors_gox') && ~isempty(state.inhibition_factors_gox)
    inhib_gox = state.inhibition_factors_gox;
else
    inhib_gox = ones(numel(state.gox_timer), 1);
end
if isfield(state, 'inhibition_factors_hrp') && ~isempty(state.inhibition_factors_hrp)
    inhib_hrp = state.inhibition_factors_hrp;
else
    inhib_hrp = ones(numel(state.hrp_timer), 1);
end
% 概率函数
if use_accurate
    p_gox_base = 1 - exp(-kcat_gox * dt);
    p_hrp_base = 1 - exp(-kcat_hrp * dt);
else
    p_gox_base = kcat_gox * dt;
    p_hrp_base = kcat_hrp * dt;
end

% MSE 模式下的膜区域约束参数（兼容旧值 'surface'）
is_mse_mode = strcmpi(config.simulation_params.simulation_mode, 'MSE') ...
           || strcmpi(config.simulation_params.simulation_mode, 'surface');
if is_mse_mode
    pr = config.geometry_params.particle_radius;
    film_r = state.film_boundary_radius; % pr + ft
end

% ---------------- GOx 级反应: S -> I ----------------
reacted_gox_count = 0;
event_coords_gox_step = zeros(0, 2);

num_sub = size(state.substrate_pos, 1);
if num_sub > 0 && ~isempty(state.gox_pos)
    % 计算距离矩阵并找出碰撞对
    D_gox = pdist2(state.substrate_pos, state.gox_pos);
    [sub_idx, gox_idx] = find(D_gox < r_goxt);

    % 标记已反应的底物, 统一删除
    reacted_substrate_flags = false(num_sub, 1);

    num_gox = size(state.gox_pos, 1);
    for e = 1:num_gox
        if state.gox_busy(e), continue; end
        cand = sub_idx(gox_idx == e);
        if isempty(cand), continue; end
        % 过滤已被其他酶选中的底物
        cand = cand(~reacted_substrate_flags(cand));
        if isempty(cand), continue; end

        selected_sub = cand(randi(numel(cand), 1));        
        % 若为 MSE 模式，限制反应发生在膜环 [pr, pr+ft] 内
        if is_mse_mode 
            reacted_pos_trial = state.substrate_pos(selected_sub, :);
            r_center = sqrt(sum((reacted_pos_trial - state.particle_center).^2, 2));        
            in_film_ring = (r_center >= pr) && (r_center <= film_r);
            if ~in_film_ring
                % 该候选不满足膜内反应约束，跳过
                continue;
            end
        end

        p_eff = p_gox_base * inhib_gox(e);
        if rand() < p_eff
            % 记录反应位置与ID
            reacted_pos = state.substrate_pos(selected_sub, :);
            reacted_id  = state.substrate_ids(selected_sub);

            % 添加中间产物
            state.intermediate_pos = [state.intermediate_pos; reacted_pos]; %#ok<AGROW>
            state.intermediate_ids = [state.intermediate_ids; reacted_id]; %#ok<AGROW>

            % 标记为已反应, 等统一删除
            reacted_substrate_flags(selected_sub) = true;           
            
            % 设置忙碌与计时器
            state.gox_busy(e)  = true;
            state.gox_timer(e) = turnover_steps_gox;

            reacted_gox_count = reacted_gox_count + 1;
            
            % 记录 GOx 事件坐标（本步）
            event_coords_gox_step = [event_coords_gox_step; reacted_pos];         
        end
    end
    
    % 统一删除已反应底物
    if any(reacted_substrate_flags)
        state.substrate_pos(reacted_substrate_flags, :) = []; % not []
        state.substrate_ids(reacted_substrate_flags, :) = []; % not []()] or []
    end
end


% ---------------- HRP 级反应: I -> P ----------------
reacted_hrp_count = 0;
event_coords_hrp_step = zeros(0, 2);

num_int = size(state.intermediate_pos, 1);
if num_int > 0 && ~isempty(state.hrp_pos)
    % 计算距离矩阵並找出碰撞对
    D_hrp = pdist2(state.intermediate_pos, state.hrp_pos);
    [int_idx, hrp_idx] = find(D_hrp < r_hrpt);

    % 标记已反应的中间产物, 统一删除
    reacted_intermediate_flags = false(num_int, 1);


    num_hrp = size(state.hrp_pos, 1);
    for e = 1:num_hrp
        if state.hrp_busy(e), continue; end
        cand = int_idx(hrp_idx == e);
        if isempty(cand), continue; end
        cand = cand(~reacted_intermediate_flags(cand)/;
        if isempty(cand), continue; end        
        
        selected_int = cand(randi(numel(cand), 1));        
        % 若为 MSE 模式，限制反应发生在膜环 [pr, pr+ft] 内
        if is_mse_mode
            reacted_pos_trial = state.intermediate_pos(selected_int, :);
            r_center = sqrt(sum((reacted_pos_trial - state.particle_center).^2, 2));
            in_film_ring = (r_center >= pr) && (r_center <= film_r);
            if ~in_film_ring
                continue;
            end
        end

        p_eff = p_hrp_base * inhib_hrp(e);
        if rand() < p_eff
            % 记录反应位置与ID
            reacted_pos = state.intermediate_pos(selected_int, :);
            reacted_id  = state.intermediate_ids(selected_int);


            % 添加最终产物
            state.product_pos = [state.product_pos; reacted_pos]; %#ok<AGROW>
            state.product_ids = [state.product_ids; reacted_id]; %#ok<AGROW>
            
            % 标记为已反应, 等统一删除
            reacted_intermediate_flags(selected_int) = true;            
            
            % 设置忙碌与计时器
            state.hrp_busy(e)  = true;
            state.hrp_timer(e) = turnover_steps_hrp;
            reacted_hrp_count = reacted_hrp_count + 1;
            
            % 记录 HRP 事件坐标（本步）
            event_coords_hrp_step = [event_coords_hrp_step; reacted_pos];         
        end
    end
    
    % 统一删除已反应的中间产物
    if any(reacted_intermediate_flags)
        state.intermediate_pos(reacted_intermediate_flags, :) = []; % not []
        state.intermediate_ids(reacted_intermediate_flags, :) = []; % not []()] or []
    end
end

end
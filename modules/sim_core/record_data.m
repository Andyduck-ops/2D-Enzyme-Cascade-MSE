function accum = record_data(state, step, config, accum, reacted_gox_count, reacted_hrp_count)
% RECORD_DATA 在时间步内记录所需数据(速率/快照/分层统计)
% 用法:
%   accum = record_data(state, step, config, accum, reacted_gox_count, reacted_hrp_count)
%
% 输入:
%   - state: 当前系统状态(包含粒子位置等)
%   - step:  当前步数(1-based)
%   - config: 配置(开关/图像/分层等)
%   - accum: 累加器结构(需在simulate_once中初始化)
%   - reacted_gox_count, reacted_hrp_count: 本步两类反应计数
%
% 输出:
%   - accum: 更新后的累加器
%
% 初始化约定(由simulate_once设置):
%   accum.num_steps, accum.dt
%   accum.enable_rate (bool)
%     accum.reaction_rate_gox [num_steps x 1], accum.reaction_rate_hrp [num_steps x 1]
%   accum.snapshot_steps [k x 1], accum.snapshot_idx, accum.snapshots {k x 3}
%   accum.enable_shell (bool & surface only)
%     accum.shell_edges [1 x (n+1)], accum.shell_counts_over_time [num_records x n]
%     accum.data_recording_interval, accum.shell_record_counter

dt = accum.dt;

% 1) 瞬时反应速率
if accum.enable_rate
    accum.reaction_rate_gox(step,1) = reacted_gox_count / dt;
    accum.reaction_rate_hrp(step,1) = reacted_hrp_count / dt;
end

% 2) 选择性快照
if accum.snapshot_idx <= numel(accum.snapshot_steps)
    if step == accum.snapshot_steps(accum.snapshot_idx)
        % 按原脚本存 GOx/HRP/Product
        k = accum.snapshot_idx;
        accum.snapshots{k,1} = state.gox_pos;
        accum.snapshots{k,2} = state.hrp_pos;
        accum.snapshots{k,3} = state.product_pos;
        accum.snapshot_idx = accum.snapshot_idx + 1;
    end
end

% 3) 分层动态统计（仅在启用且表面模式）
if accum.enable_shell && ~isempty(state.substrate_pos)
    if mod(step, accum.data_recording_interval) == 0
        accum.shell_record_counter = accum.shell_record_counter + 1;
        if accum.shell_record_counter <= size(accum.shell_counts_over_time,1)
            dist_from_center = sqrt(sum((state.substrate_pos - state.particle_center).^2, 2));
            accum.shell_counts_over_time(accum.shell_record_counter, :) = histcounts(dist_from_center, accum.shell_edges);
        end
    end
end

end
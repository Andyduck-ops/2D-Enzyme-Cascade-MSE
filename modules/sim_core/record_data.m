function accum = record_data(state, step, config, accum, reacted_gox_count, reacted_hrp_count)
% RECORD_DATA Record required data within time step (rates/snapshots/shell statistics)
% Usage:
%   accum = record_data(state, step, config, accum, reacted_gox_count, reacted_hrp_count)
%
% Inputs:
%   - state: Current system state (including particle positions, etc.)
%   - step:  Current step number (1-based)
%   - config: Configuration (switches/images/shells, etc.)
%   - accum: Accumulator structure (must be initialized in simulate_once)
%   - reacted_gox_count, reacted_hrp_count: Reaction counts for this step
%
% Output:
%   - accum: Updated accumulator
%
% Initialization convention (set by simulate_once):
%   accum.num_steps, accum.dt
%   accum.enable_rate (bool)
%     accum.reaction_rate_gox [num_steps x 1], accum.reaction_rate_hrp [num_steps x 1]
%   accum.snapshot_steps [k x 1], accum.snapshot_idx, accum.snapshots {k x 3}
%   accum.enable_shell (bool & surface only)
%     accum.shell_edges [1 x (n+1)], accum.shell_counts_over_time [num_records x n]
%     accum.data_recording_interval, accum.shell_record_counter

dt = accum.dt;

% 1) Instantaneous reaction rates
if accum.enable_rate
    accum.reaction_rate_gox(step,1) = reacted_gox_count / dt;
    accum.reaction_rate_hrp(step,1) = reacted_hrp_count / dt;
end

% 2) Selective snapshots
if accum.snapshot_idx <= numel(accum.snapshot_steps)
    if step == accum.snapshot_steps(accum.snapshot_idx)
        % Store GOx/HRP/Product as in original script
        k = accum.snapshot_idx;
        accum.snapshots{k,1} = state.gox_pos;
        accum.snapshots{k,2} = state.hrp_pos;
        accum.snapshots{k,3} = state.product_pos;
        accum.snapshot_idx = accum.snapshot_idx + 1;
    end
end

% 3) Shell dynamics statistics (only when enabled and in surface mode)
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
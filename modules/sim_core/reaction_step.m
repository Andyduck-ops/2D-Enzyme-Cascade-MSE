function [state, reacted_gox_count, reacted_hrp_count, event_coords_gox_step, event_coords_hrp_step] = reaction_step(state, config)
% REACTION_STEP Execute one reaction step (two-stage GOx and HRP with inhibition and busy/timer)
% Usage:
%   [state, n_gox, n_hrp] = reaction_step(state, config)
%
% Logic points:
%   - When distance is less than reaction radius, reaction occurs with probability P:
%       Exact:   P = 1 - exp(-k_cat*dt)
%       Approx:  P = k_cat*dt
%   - Inhibition factor: Multiply by per-enzyme inhibition_factors (default to 1 if not exists)
%   - busy/timer: Set enzyme to busy and start timer after reaction (steps=round(1/k_cat/dt))
%   - Reactions:
%       S + GOx -> I + GOx
%       I + HRP -> P + HRP
%
% Reference implementation: [refactored_2d_model.m](../../refactored_2d_model.m:399)

% ---------------- Parameters and Preprocessing ----------------
dt = config.simulation_params.time_step;
use_accurate = config.simulation_params.use_accurate_probability;

kcat_gox = config.particle_params.k_cat_GOx;
kcat_hrp = config.particle_params.k_cat_HRP;

% Turnover time (continuous seconds)
turnover_time_gox = 1 / max(kcat_gox, eps);
turnover_time_hrp = 1 / max(kcat_hrp, eps);

% Reaction distances
r_goxt = state.reaction_dist_GOx;
r_hrpt = state.reaction_dist_HRP;

% Inhibition factors (use 1 if not exists)
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
% Probability functions
if use_accurate
    p_gox_base = 1 - exp(-kcat_gox * dt);
    p_hrp_base = 1 - exp(-kcat_hrp * dt);
else
    % Safe linear approximation with clamping
    p_gox_base = min(max(kcat_gox * dt, 0), 1);
    p_hrp_base = min(max(kcat_hrp * dt, 0), 1);
end

% Membrane region constraint parameters for MSE mode (compatible with legacy value 'surface')
is_mse_mode = strcmpi(config.simulation_params.simulation_mode, 'MSE') ...
           || strcmpi(config.simulation_params.simulation_mode, 'surface');
if is_mse_mode
    pr = config.geometry_params.particle_radius;
    film_r = state.film_boundary_radius; % pr + ft
end

% ---------------- GOx Level Reaction: S -> I ----------------
reacted_gox_count = 0;
event_coords_gox_step = zeros(0, 2);

num_sub = size(state.substrate_pos, 1);
if num_sub > 0 && ~isempty(state.gox_pos)
    % Neighbor search (backend can be CPU/GPU/rangesearch)
    backend = getfield_or(config, {'compute','neighbor_backend'}, 'auto');
    use_gpu_compute = getfield_or(config, {'compute','use_gpu'}, 'off');
    [sub_idx, gox_idx] = neighbor_search(state.substrate_pos, state.gox_pos, r_goxt, backend, use_gpu_compute);

    % Mark reacted substrates for unified deletion
    reacted_substrate_flags = false(num_sub, 1);

    num_gox = size(state.gox_pos, 1);
    % Randomize enzyme processing order to avoid selection bias
    gox_order = randperm(num_gox);
    for idx = 1:num_gox
        e = gox_order(idx);
        if state.gox_busy(e), continue; end
        cand = sub_idx(gox_idx == e);
        if isempty(cand), continue; end
        % Filter substrates already selected by other enzymes
        cand = cand(~reacted_substrate_flags(cand));
        if isempty(cand), continue; end

        selected_sub = cand(randi(numel(cand), 1));
        % If MSE mode, restrict reaction to membrane ring [pr, pr+ft]
        if is_mse_mode 
            reacted_pos_trial = state.substrate_pos(selected_sub, :);
            r_center = sqrt(sum((reacted_pos_trial - state.particle_center).^2, 2));        
            in_film_ring = (r_center >= pr) && (r_center <= film_r);
            if ~in_film_ring
                % Candidate does not satisfy membrane reaction constraint, skip
                continue;
            end
        end

        p_eff = p_gox_base * inhib_gox(e);
        if rand() < p_eff
            % Record reaction position and ID
            reacted_pos = state.substrate_pos(selected_sub, :);
            reacted_id  = state.substrate_ids(selected_sub);

            % Add intermediate product
            state.intermediate_pos = [state.intermediate_pos; reacted_pos]; %#ok<AGROW>
            state.intermediate_ids = [state.intermediate_ids; reacted_id]; %#ok<AGROW>

            % Mark as reacted, wait for unified deletion
            reacted_substrate_flags(selected_sub) = true;           
            
            % Set busy and timer
            state.gox_busy(e)  = true;
            state.gox_timer(e) = turnover_time_gox;  % seconds (continuous timer)

            reacted_gox_count = reacted_gox_count + 1;
            
            % Record GOx event coordinates (this step)
            event_coords_gox_step = [event_coords_gox_step; reacted_pos];         
        end
    end
    
    % Unified deletion of reacted substrates
    if any(reacted_substrate_flags)
        state.substrate_pos(reacted_substrate_flags, :) = []; % not []
        state.substrate_ids(reacted_substrate_flags, :) = []; % not []()] or []
    end
end


% ---------------- HRP Level Reaction: I -> P ----------------
reacted_hrp_count = 0;
event_coords_hrp_step = zeros(0, 2);

num_int = size(state.intermediate_pos, 1);
if num_int > 0 && ~isempty(state.hrp_pos)
    % Neighbor search (backend can be CPU/GPU/rangesearch)
    backend = getfield_or(config, {'compute','neighbor_backend'}, 'auto');
    use_gpu_compute = getfield_or(config, {'compute','use_gpu'}, 'off');
    [int_idx, hrp_idx] = neighbor_search(state.intermediate_pos, state.hrp_pos, r_hrpt, backend, use_gpu_compute);

    % Mark reacted intermediates for unified deletion
    reacted_intermediate_flags = false(num_int, 1);


    num_hrp = size(state.hrp_pos, 1);
    % Randomize enzyme processing order to avoid selection bias
    hrp_order = randperm(num_hrp);
    for idx = 1:num_hrp
        e = hrp_order(idx);
        if state.hrp_busy(e), continue; end
        cand = int_idx(hrp_idx == e);
        if isempty(cand), continue; end
        cand = cand(~reacted_intermediate_flags(cand));
        if isempty(cand), continue; end        
        
        selected_int = cand(randi(numel(cand), 1));
        % If MSE mode, restrict reaction to membrane ring [pr, pr+ft]
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
            % Record reaction position and ID
            reacted_pos = state.intermediate_pos(selected_int, :);
            reacted_id  = state.intermediate_ids(selected_int);


            % Add final product
            state.product_pos = [state.product_pos; reacted_pos]; %#ok<AGROW>
            state.product_ids = [state.product_ids; reacted_id]; %#ok<AGROW>
            
            % Mark as reacted, wait for unified deletion
            reacted_intermediate_flags(selected_int) = true;            
            
            % Set busy and timer
            state.hrp_busy(e)  = true;
            state.hrp_timer(e) = turnover_time_hrp;  % seconds (continuous timer)
            reacted_hrp_count = reacted_hrp_count + 1;
            
            % Record HRP event coordinates (this step)
            event_coords_hrp_step = [event_coords_hrp_step; reacted_pos];         
        end
    end
    
    % Unified deletion of reacted intermediates
    if any(reacted_intermediate_flags)
        state.intermediate_pos(reacted_intermediate_flags, :) = []; % not []
        state.intermediate_ids(reacted_intermediate_flags, :) = []; % not []()] or []
    end
end

end


function results = simulate_once(config, seed)
% SIMULATE_ONCE Single simulation facade function (integrated implementation)
% Workflow:
%   - Initialize positions and derived parameters [init_positions()](./init_positions.m:1)
%   - Precompute crowding inhibition factors [precompute_inhibition()](./precompute_inhibition.m:1)
%   - Time loop:
%       * Timer and busy state update [timer_busy_update()](../utils/timer_busy_update.m:1)
%       * Heterogeneous diffusion step [diffusion_step()](./diffusion_step.m:1)
%       * Box reflection + particle specular reflection [boundary_reflection()](./boundary_reflection.m:1)
%       * Two-stage reaction step [reaction_step()](./reaction_step.m:1)
%       * Selective recording [record_data()](./record_data.m:1)



% refactored_2d_model.m

arguments
    config struct
    seed   {mustBeNumeric, mustBeFinite}
end

% Basic time and loop parameters 
dt         = getfield_or(config, {'simulation_params','time_step'}, 0.1);
T_total    = getfield_or(config, {'simulation_params','total_time'}, 100);
num_steps  = max(1, round(T_total / dt));
mode       = getfield_or(config, {'simulation_params','simulation_mode'}, 'MSE') ;


% Progress and recording controls
progress_interval  = getfield_or(config, {'plotting_controls','progress_report_interval'}, 250);
record_interval    = getfield_or(config, {'plotting_controls','data_recording_interval'}, 25);
snapshot_times     = getfield_or(config, {'plotting_controls','snapshot_times'}, [0, 50, 100]);
visualize_enabled  = getfield_or(config, {'ui_controls','visualize_enabled'}, false);


% Legacy compatibility: treat surface as MSE
is_mse_mode = any(strcmpi(mode, {'MSE','surface'}));
if strcmpi(mode,'surface')
    mode = 'MSE'; 
end


% 1) Initialization + precomputation
state = init_positions(config);           % [init_positions()](./init_positions.m:1)
state = precompute_inhibition(state, config);  % [precompute_inhibition()](./precompute_inhibition.m:1)


% 2) Recording accumulator initialization
accum = struct();
accum.dt = dt; 
accum.num_steps = num_steps;


% 2.1 Rate curves
accum.enable_rate = getfield_or(config, {'analysis_switches','enable_reaction_rate_plot'}, true);
if accum.enable_rate
    accum.reaction_rate_gox = zeros(num_steps, 1);
    accum.reaction_rate_hrp = zeros(num_steps, 1);
else
 
    accum.reaction_rate_gox = [];
    accum.reaction_rate_hrp = [];
end


% 2.2 Snapshots (collect only when visualization is enabled to avoid batch processing overhead)
if visualize_enabled
    snapshot_steps = unique(round(snapshot_times / dt));
    snapshot_steps(snapshot_steps == 0) = 1;
    snapshot_steps(snapshot_steps > num_steps) = num_steps;
else
    snapshot_steps = [];
end
accum.snapshot_steps = snapshot_steps(:);
accum.snapshot_idx   = 1;
accum.snapshots      = cell(numel(accum.snapshot_steps), 3);


% 2.3 Layered dynamics (only enabled in MSE mode with analysis enabled; depends on sampling interval)
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
    accum.shell_edges = [];
    accum.shell_counts_over_time = [];
end


% Event coordinate accumulation (for spatial reaction event maps)
accum.reaction_coords_gox = zeros(0, 2);
accum.reaction_coords_hrp = zeros(0, 2);


% 2.4 Tracer trajectories (only enabled when visualization is on and tracing is allowed)
accum.enable_tracer = getfield_or(config, {'analysis_switches','enable_particle_tracing'}, true) && visualize_enabled;
if accum.enable_tracer
    num_to_follow = getfield_or(config, {'analysis_switches','num_tracers_to_follow'}, 5);
    n_avail = numel(state.substrate_ids);
    n_tr = min(num_to_follow, n_avail);
    if n_tr > 0
        perm = randperm(n_avail, n_tr);
        accum.tracer_ids = state.substrate_ids(perm);
        accum.tracer_paths = cell(n_tr, 1);
        % Immediately record initial positions (sampling before t=0) to ensure at least one line segment is formed
        for ti = 1:n_tr
            tid = accum.tracer_ids(ti);
            idx0 = find(state.substrate_ids == tid, 1);
            if ~isempty(idx0)
                accum.tracer_paths{ti} = [accum.tracer_paths{ti}; state.substrate_pos(idx0, :)]; %#ok<AGROW>
            end
        end
    else
    accum.tracer_ids = [];
    accum.tracer_paths = [];
    accum.enable_tracer = false;
    end
else
    accum.tracer_ids = [];
    accum.tracer_paths = [];
end










% 3) Time loop
for step = 1:num_steps
    
    % 3.1 Timers and busy states
    state = timer_busy_update(state);  % [timer_busy_update()](../utils/timer_busy_update.m:1)')


    % 3.2 Diffusion
    state = diffusion_step(state, config);  % [diffusion_step()](./diffusion_step.m:1)'))


    % 3.3 Reflective boundaries and particle collisions
    state = boundary_reflection(state, config);  % [boundary_reflection()](./boundary_reflection.m:1))

    % 3.3b Tracer trajectory sampling (record current substrate positions before order reflection)
    if accum.enable_tracer && ~isempty(accum.tracer_ids)
        for ti = 1:numel(accum.tracer_ids)
            tid = accum.tracer_ids(ti);
            idx = find(state.substrate_ids == tid, 1);
            if ~isempty(idx)
                accum.tracer_paths{ti} = [accum.tracer_paths{ti}; state.substrate_pos(idx, :)]; %#ok<AGROW>
            end
        end 
    end

    % 3.4 Reactions
    [state, n_gox, n_hrp, ev_g, ev_h] = reaction_step(state, config);    % [reaction_step()](./reaction_step.m:1)
    % Accumulate event coordinates for this step (if any)
    if ~isempty(ev_g)
        accum.reaction_coords_gox = [accum.reaction_coords_gox; ev_g]; %#ok<AGROW>
    end
    if ~isempty(ev_h)
        accum.reaction_coords_hrp = [accum.reaction_coords_hrp; ev_h]; %#ok<AGROW>
    end

    % 3.5 Recording
    accum = record_data(state, step, config, accum, n_gox, n_hrp);  % [record_data()](./record_data.m:1)


    % 3.6 Progress 
    if mod(step, progress_interval) == 0
        fprintf('   Step %d/%d | Sub:%d Int:%d Prod:%d\n', step, num_steps, ...
            size(state.substrate_pos,1), size(state.intermediate_pos,1), size(state.product_pos,1));
    end
end


% 4) Compile results
results = struct();
results.products_final = size(state.product_pos, 1);


% Time axis and product curves (derived from HRP rate integration)
if accum.enable_rate
    results.time_axis = (1:num_steps)' * dt;
    results.reaction_rate_gox = accum.reaction_rate_gox;
    results.reaction_rate_hrp = accum.reaction_rate_hrp;
    results.product_curve = cumsum(accum.reaction_rate_hrp) * dt;
else
    results.time_axis = (1:num_steps)' * dt;
    results.reaction_rate_gox = [];
    results.reaction_rate_hrp = [];
    results.product_curve = [];
end


% Snapshots and layering
results.snapshots = accum.snapshots;
results.shell_counts_over_time = accum.shell_counts_over_time;
results.shell_edges = accum.shell_edges;


% Other fields reserved (can add event coordinates/trajectories etc. later)
results.reaction_coords_gox = accum.reaction_coords_gox;
results.reaction_coords_hrp = accum.reaction_coords_hrp;
results.tracer_paths = accum.tracer_paths;


% Metadata
meta = struct();
meta.seed = double(seed);
meta.mode = char(mode);
meta.num_enzymes = double(getfield_or(config, {'particle_params','num_enzymes'}, NaN));
meta.gox_hrp_split = double(getfield_or(config, {'particle_params','gox_hrp_split'}, 0.5));
meta.num_substrate = double(getfield_or(config, {'particle_params','num_substrate'}, NaN));
meta.dt = double(dt);
meta.total_time = double(T_total);
meta.placeholder = false;
results.meta = meta;

% Console summary
fprintf('[simulate_once] Complete | seed=%d | mode=%s | products_final=%d\n', ...
    seed, mode, results.products_final);


end


% ----------------- Utility Functions -----------------

function v = getfield_or(s, path, default)
% Get field from nested structure, return default value if not exists
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

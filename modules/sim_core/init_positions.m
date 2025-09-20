function state = init_positions(config)
% INIT_POSITIONS Initialize initial state of 2D system based on configuration
% Usage:
%   state = init_positions(config)
% Depends on default parameters: [default_config()](../config/default_config.m:1)
% Reference implementation points from: [refactored_2d_model.m](../../refactored_2d_model.m:137)
%
% Output state key fields:
%   - Constants and derived: particle_center, film_boundary_radius
%   - Reaction radii: reaction_dist_GOx, reaction_dist_HRP, radius_intermediate
%   - Enzymes: enzyme_pos(Nx2), enzyme_type(Nx1; 1=GOx,2=HRP), gox_pos, hrp_pos, gox_indices, hrp_indices
%   - Substrate/intermediate/product positions: substrate_pos(Mx2), intermediate_pos(0x2), product_pos(0x2)
%   - ID: substrate_ids, intermediate_ids, product_ids
%   - Timing and state: gox_busy, gox_timer, hrp_busy, hrp_timer

% ---------------- Basic Parameters ----------------
L   = config.simulation_params.box_size;                      % Box length nm
dt  = config.simulation_params.time_step; %#ok<NASGU>
mode = config.simulation_params.simulation_mode;              % 'MSE'|'bulk' (compatible with legacy 'surface')

% Particle/enzyme and geometry
N_total = config.particle_params.num_enzymes;
num_sub = config.particle_params.num_substrate;

pr   = config.geometry_params.particle_radius;
ft   = config.geometry_params.film_thickness;
rGOx = config.geometry_params.radius_GOx;
rHRP = config.geometry_params.radius_HRP;
rSub = config.geometry_params.radius_substrate;

% Reaction radii and derived values
state.particle_center = [L/2, L/2];
state.film_boundary_radius = pr + ft;
state.radius_intermediate = rSub; % Consistent with original code
state.reaction_dist_GOx = rGOx + rSub;
state.reaction_dist_HRP = rHRP + state.radius_intermediate;

% Validity check (consistent with original script)
assert(state.film_boundary_radius < L/2, 'Error: Particle+film exceeds half box length!');

% ---------------- Enzyme Types and Quantities ----------------
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count') 
    gox_n = config.particle_params.gox_count;
    hrp_n = config.particle_params.hrp_count;
else
    ratio = config.particle_params.gox_hrp_split;
    gox_n = round(N_total * ratio);
    hrp_n = N_total - gox_n;
end
enzyme_type = [ones(gox_n,1); 2*ones(hrp_n,1)];

% ---------------- Enzyme Position Initialization ----------------
enzyme_pos = zeros(N_total, 2);
switch lower(mode)
    case {'mse','surface'}    % Uniform distribution within [pr, pr+ft] annulus (MSE mode; compatible with legacy 'surface')
        theta = 2*pi*rand(N_total,1);
        rad   = pr + ft*rand(N_total,1);
        enzyme_pos(:,1) = state.particle_center(1) + rad.*cos(theta);
        enzyme_pos(:,2) = state.particle_center(2) + rad.*sin(theta);
    case 'bulk'
        % Uniform distribution within box [0,L]x[0,L]
        enzyme_pos = L * rand(N_total, 2);
    otherwise
        error('Unknown simulation_mode=%s (expected ''MSE'' or ''bulk'')', mode);
end

gox_indices = find(enzyme_type==1);
hrp_indices = find(enzyme_type==2);
gox_pos = enzyme_pos(gox_indices,:);
hrp_pos = enzyme_pos(hrp_indices,:);

% ---------------- Substrate Initialization ----------------
substrate_pos = []; needed = num_sub; while needed > 0
    candidates = L * rand(ceil(needed*1.5), 2);
    if any(strcmpi(mode, {'MSE','surface'})) 
        dist_from_center = sqrt(sum((candidates - state.particle_center).^2, 2));
        valid = candidates(dist_from_center > state.film_boundary_radius, :);
    else
        valid = candidates;
    end
    substrate_pos = [substrate_pos; valid]; %#ok<AGROW>
    needed = num_sub - size(substrate_pos, 1);
end
substrate_pos = substrate_pos(1:num_sub, :);


% ---------------- Product/Intermediate Product and IDs ----------------
intermediate_pos = zeros(0,2);
product_pos = zeros(0,2);

substrate_ids = (1:size(substrate_pos,1))'; intermediate_ids = zeros(0,1); product_ids = zeros(0,1); % In addition to providing positions directly, IDs are needed to index positions in final result segments ((substrate_pos(i,:)+enzyme_pos(j,:))/2) (this way calculations only occur once during initial product generation, reducing redundant computation, and some products may require multiple position calculations). Also facilitates using "for idx=1:N_sub" to replace original "for i=1:size(substrate_pos,1)", while size(substrate_ids,1)==size(substrate_pos,1) provides some reasonableness guarantee.

% ---------------- Enzyme Busy State and Timing ----------------
gox_busy  = false(gox_n, 1);
hrp_busy  = false(hrp_n, 1);
gox_timer = zeros(gox_n, 1);
hrp_timer = zeros(hrp_n, 1);

% ---------------- Assemble state ----------------
state.enzyme_pos   = enzyme_pos;
state.enzyme_type  = enzyme_type;
state.gox_pos      = gox_pos;
state.hrp_pos      = hrp_pos;
state.gox_indices  = gox_indices;
state.hrp_indices  = hrp_indices;

state.substrate_pos     = substrate_pos;
state.intermediate_pos  = intermediate_pos;
state.product_pos       = product_pos;

state.substrate_ids     = substrate_ids;
state.intermediate_ids  = intermediate_ids;
state.product_ids       = product_ids;

state.gox_busy   = gox_busy;
state.hrp_busy   = hrp_busy;
state.gox_timer  = gox_timer;
state.hrp_timer  = hrp_timer;

% Metadata (optional)
state.meta = struct( ...
    'mode', mode, ...
    'L', L, ...
    'N_total', N_total, ...
    'gox_n', gox_n, ...
    'hrp_n', hrp_n, ...
    'num_sub', num_sub ...
);

end
function state = boundary_reflection(state, config)
% BOUNDARY_REFLECTION Specular reflection handling for boundary and central particle collisions
% Usage:
%   state = boundary_reflection(state, config)
%
% Implementation:
%   1) Box perimeter reflection boundary: x<0 -> -x, x>L -> 2L-x (same for y)
%   2) MSE mode (compatible with legacy surface): When penetrating central particle (r = particle_radius), push particles back along normal vector to
%      r = particle_radius + eps buffer radius (avoid numerical oscillation)
%
% Reference original script:
%   - Box reflection: [refactored_2d_model.m](../../refactored_2d_model.m:314)
%   - Particle specular reflection: [refactored_2d_model.m](../../refactored_2d_model.m:326)

L   = config.simulation_params.box_size;
mode = config.simulation_params.simulation_mode;

% 1) Box reflection boundary (unified processing for three particle types)
state.substrate_pos    = reflect_to_box(state.substrate_pos, L);
state.intermediate_pos = reflect_to_box(state.intermediate_pos, L);
state.product_pos      = reflect_to_box(state.product_pos, L);

% 2) MSE mode particle collision handling (compatible with 'surface' input)
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
     pr = config.geometry_params.particle_radius;
     % Stability parameters (consistent with original script approach)
     min_distance   = 1e-6;
     target_distance = pr + 0.1;

     % Process three particle types sequentially
     state.substrate_pos    = reflect_from_particle(state.substrate_pos, state.particle_center, pr, target_distance, min_distance);
     state.intermediate_pos = reflect_from_particle(state.intermediate_pos, state.particle_center, pr, target_distance, min_distance);
     state.product_pos      = reflect_from_particle(state.product_pos, state.particle_center, pr, target_distance, min_distance);
 end

end

% ----------------- Utility Functions -----------------
function P = reflect_to_box(P, L)
% Box reflection boundary
if isempty(P), return; end
% Reflection for values less than 0
mask = P < 0;
P(mask) = -P(mask);
% Reflection for values greater than L
mask = P > L;
P(mask) = 2*L - P(mask);
end

function P = reflect_from_particle(P, center, pr, target_r, min_r)
% MSE mode: Central particle collision specular reflection (compatible with surface)
if isempty(P), return; end
dist = sqrt(sum((P - center).^2, 2));
collided = dist < pr;
if ~any(collided), return; end

vec = P(collided, :) - center;      % Vector pointing to particle
d   = dist(collided);

% For points too close to center, use random direction instead of normalized unit normal to avoid numerical instability
too_close = d < min_r;
normals = zeros(size(vec));
if any(too_close)
    n_too = sum(too_close);
    theta = 2*pi*rand(n_too, 1);
    normals(too_close, :) = [cos(theta), sin(theta)];
end
if any(~too_close)
    normals(~too_close, :) = vec(~too_close, :) ./ d(~too_close);
end

% Push position back to target_r
P(collided, :) = center + target_r * normals;
end
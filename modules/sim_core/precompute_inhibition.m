function state = precompute_inhibition(state, config)
% PRECOMPUTE_INHIBITION Calculate enzyme crowding inhibition factors and write to state
% Usage:
%   state = precompute_inhibition(state, config)
%
% Input:
%   - state.enzyme_pos [N x 2]
%   - state.enzyme_type [N x 1] (1=GOx, 2=HRP) optional (not dependent)
%   - state.gox_indices / state.hrp_indices
%   - config.inhibition_params: R_inhibit, n_sat, I_max
%
% Output: Write to state
%   - state.inhibition_factors_per_enzyme [N x 1]
%   - state.inhibition_factors_gox [num_gox x 1]
%   - state.inhibition_factors_hrp [num_hrp x 1]
%
% Reference: [refactored_2d_model.m](../../refactored_2d_model.m:185)

% Parameter reading
R_inhibit = config.inhibition_params.R_inhibit;
n_sat     = config.inhibition_params.n_sat;
I_max     = config.inhibition_params.I_max;

pos = state.enzyme_pos;
N = size(pos, 1);
if N == 0
    state.inhibition_factors_per_enzyme = zeros(0,1);
    state.inhibition_factors_gox = zeros(0,1);
    state.inhibition_factors_hrp = zeros(0,1);
    return;
end

% Calculate pairwise distances and count neighbors (excluding self)
% Consistent with reference implementation: n_nearby(i) = sum_j 1{ 0 < dist(i,j) < R_inhibit }
D = pdist2(pos, pos);
% Ignore self
D(1:N+1:end) = inf;
n_nearby = sum(D < R_inhibit, 2);

% Inhibition function: I = 1 - I_max * min(n_nearby/n_sat, 1)
inhibition_factors = 1 - I_max * min(n_nearby ./ max(n_sat, eps), 1);

% Write back to state (with GOx/HRP slicing)
state.inhibition_factors_per_enzyme = inhibition_factors;

if isfield(state, 'gox_indices') && ~isempty(state.gox_indices)
    state.inhibition_factors_gox = inhibition_factors(state.gox_indices);
else
    % Compatible with no-index scenario
    state.inhibition_factors_gox = [];
end

if isfield(state, 'hrp_indices') && ~isempty(state.hrp_indices)
    state.inhibition_factors_hrp = inhibition_factors(state.hrp_indices);
else
    state.inhibition_factors_hrp = [];
end

% Console summary
fprintf('[precompute_inhibition] Inhibition factor range: %.3f - %.3f\n', min(inhibition_factors), max(inhibition_factors));

end
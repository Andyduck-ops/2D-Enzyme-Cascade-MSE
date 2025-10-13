function [filtered_pos, filtered_ids, valid_mask] = roi_filter(pos, ids, particle_center, pr, film_r, r_react)
% ROI_FILTER Filter particles within MSE annulus reaction zone
%
% Usage:
%   [filtered_pos, filtered_ids, valid_mask] = roi_filter(pos, ids, particle_center, pr, film_r, r_react)
%
% Inputs:
%   pos: [N x 2] particle positions
%   ids: [N x 1] particle IDs
%   particle_center: [1 x 2] center coordinates
%   pr: particle radius (nm)
%   film_r: film boundary radius = pr + film_thickness (nm)
%   r_react: reaction radius (nm)
%
% Outputs:
%   filtered_pos: [M x 2] subset of positions within ROI
%   filtered_ids: [M x 1] subset of IDs within ROI
%   valid_mask: [N x 1] logical mask for original arrays
%
% ROI Definition:
%   Reaction zone: pr - r_react <= r_center <= film_r + r_react
%   This captures all particles that could potentially react with enzymes in the film
%
% Algorithm:
%   1. Compute distance from particle center (vectorized)
%   2. Apply annulus constraint
%   3. Return filtered subset and mask

% Handle empty input
if isempty(pos)
    filtered_pos = zeros(0, 2);
    filtered_ids = zeros(0, 1);
    valid_mask = false(0, 1);
    return;
end

% Compute distance from particle center (vectorized)
r_center = sqrt(sum((pos - particle_center).^2, 2));

% Apply ROI constraint: particles within reaction zone of film annulus
r_min = pr - r_react;
r_max = film_r + r_react;
valid_mask = (r_center >= r_min) & (r_center <= r_max);

% Extract filtered subset
filtered_pos = pos(valid_mask, :);
filtered_ids = ids(valid_mask);

end

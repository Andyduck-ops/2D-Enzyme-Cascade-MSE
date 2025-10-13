function [i_idx, j_idx] = neighbor_celllist(A, B, r, box_size, cell_list_B)
% NEIGHBOR_CELLLIST Grid-based spatial hashing for neighbor search
%
% Usage:
%   [i_idx, j_idx] = neighbor_celllist(A, B, r, box_size, cell_list_B)
%
% Inputs:
%   A: [NA x 2] query positions
%   B: [NB x 2] reference positions
%   r: scalar search radius
%   box_size: scalar domain size
%   cell_list_B: (optional) pre-built cell list for B
%
% Outputs:
%   i_idx: [M x 1] indices into A
%   j_idx: [M x 1] indices into B
%
% Algorithm:
%   1. Build cell list for B if not provided
%   2. For each point in A:
%      a. Find its cell (ix, iy)
%      b. Check 9 neighboring cells (3x3 grid)
%      c. Test distances only within these cells
%
% Performance:
%   O(NA × avg_particles_per_cell) vs O(NA × NB) for brute force

% Handle empty inputs
if isempty(A) || isempty(B)
    i_idx = zeros(0, 1);
    j_idx = zeros(0, 1);
    return;
end

% Build cell list if not provided
if nargin < 5 || isempty(cell_list_B)
    cell_size = r;  % Use search radius as cell size
    cell_list_B = build_cell_list(B, box_size, cell_size);
end

% Extract cell list parameters
nx = cell_list_B.grid_dim(1);
ny = cell_list_B.grid_dim(2);
cell_size = cell_list_B.cell_size;
buckets = cell_list_B.buckets;

% Preallocate output (estimate)
i_idx = zeros(size(A, 1) * 10, 1);  % Rough estimate
j_idx = zeros(size(A, 1) * 10, 1);
count = 0;

% For each query point in A
for i = 1:size(A, 1)
    % Find cell for this query point
    ix = floor(A(i, 1) / cell_size) + 1;
    iy = floor(A(i, 2) / cell_size) + 1;
    
    % Clamp to grid
    ix = max(min(ix, nx), 1);
    iy = max(min(iy, ny), 1);
    
    % Check 9 neighboring cells (3x3 grid)
    for dx = -1:1
        for dy = -1:1
            cx = ix + dx;
            cy = iy + dy;
            
            % Skip if out of bounds
            if cx < 1 || cx > nx || cy < 1 || cy > ny
                continue;
            end
            
            % Get particles in this cell
            cell_particles = buckets{cx, cy};
            if isempty(cell_particles)
                continue;
            end
            
            % Test distances
            for j = cell_particles'
                dist = sqrt(sum((A(i, :) - B(j, :)).^2));
                if dist < r
                    count = count + 1;
                    % Grow arrays if needed
                    if count > length(i_idx)
                        i_idx = [i_idx; zeros(size(A, 1) * 10, 1)]; %#ok<AGROW>
                        j_idx = [j_idx; zeros(size(A, 1) * 10, 1)]; %#ok<AGROW>
                    end
                    i_idx(count) = i;
                    j_idx(count) = j;
                end
            end
        end
    end
end

% Trim to actual size
i_idx = i_idx(1:count);
j_idx = j_idx(1:count);

end

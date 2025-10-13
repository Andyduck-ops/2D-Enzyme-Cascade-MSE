function cell_list = build_cell_list(pos, box_size, cell_size)
% BUILD_CELL_LIST Create spatial grid structure for fast neighbor search
%
% Usage:
%   cell_list = build_cell_list(pos, box_size, cell_size)
%
% Inputs:
%   pos: [N x 2] particle positions
%   box_size: scalar, domain size (assumes square box)
%   cell_size: scalar, cell edge length
%
% Output:
%   cell_list: struct with fields
%     - grid_dim: [nx, ny] number of cells per dimension
%     - cell_size: scalar cell edge length
%     - assignments: [N x 2] cell indices for each particle
%     - buckets: {nx x ny} cell array of particle indices
%
% Algorithm:
%   1. Divide domain into grid of cells
%   2. Assign each particle to its cell: floor(pos / cell_size) + 1
%   3. Store particle indices in corresponding bucket

% Handle empty input
if isempty(pos)
    cell_list = struct('grid_dim', [0 0], 'cell_size', cell_size, ...
                       'assignments', zeros(0, 2), 'buckets', {cell(0, 0)});
    return;
end

% Calculate grid dimensions
nx = ceil(box_size / cell_size);
ny = nx;  % Square grid

% Assign particles to cells (1-indexed)
cell_indices = floor(pos / cell_size) + 1;

% Clamp to grid boundaries
cell_indices = max(cell_indices, 1);
cell_indices = min(cell_indices, nx);

% Build buckets
buckets = cell(nx, ny);
for i = 1:size(pos, 1)
    ix = cell_indices(i, 1);
    iy = cell_indices(i, 2);
    buckets{ix, iy} = [buckets{ix, iy}; i];
end

% Assemble output
cell_list = struct(...
    'grid_dim', [nx ny], ...
    'cell_size', cell_size, ...
    'assignments', cell_indices, ...
    'buckets', {buckets} ...
);

end

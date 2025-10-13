function [i_idx, j_idx, searcher_out] = neighbor_kdtree(A, B, r, searcher_B)
% NEIGHBOR_KDTREE KD-tree based neighbor search with optional caching
%
% Usage:
%   [i_idx, j_idx, searcher] = neighbor_kdtree(A, B, r, searcher_B)
%
% Inputs:
%   A: [NA x 2] query positions
%   B: [NB x 2] reference positions (enzyme positions)
%   r: scalar search radius
%   searcher_B: (optional) cached KDTreeSearcher for B
%
% Outputs:
%   i_idx: [M x 1] indices into A
%   j_idx: [M x 1] indices into B
%   searcher_out: KDTreeSearcher object for B (for caching)
%
% Algorithm:
%   If searcher_B provided, use cached searcher
%   Otherwise, build new KDTreeSearcher(B)
%   Use rangesearch(searcher, A, r) for efficient neighbor query
%
% Requirements: Statistics and Machine Learning Toolbox

% Handle empty inputs
if isempty(A) || isempty(B)
    i_idx = zeros(0, 1);
    j_idx = zeros(0, 1);
    searcher_out = [];
    return;
end

% Build or use cached searcher
if nargin < 4 || isempty(searcher_B)
    % Build new searcher
    searcher_out = KDTreeSearcher(B);
else
    % Use cached searcher
    searcher_out = searcher_B;
end

% Perform range search
[idxC, ~] = rangesearch(searcher_out, A, r);

% Flatten cell array to index vectors
na = size(A, 1);
counts = cellfun(@numel, idxC(:));
total = sum(counts);

i_idx = zeros(total, 1);
j_idx = zeros(total, 1);

pos = 1;
for i = 1:na
    js = idxC{i};
    n = numel(js);
    if n == 0
        continue;
    end
    i_idx(pos:pos+n-1) = i;
    j_idx(pos:pos+n-1) = js(:);
    pos = pos + n;
end

% Trim unused preallocated space
if pos <= total
    i_idx(pos:end) = [];
    j_idx(pos:end) = [];
end

end

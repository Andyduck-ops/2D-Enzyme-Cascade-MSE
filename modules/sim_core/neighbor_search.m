function [i_idx, j_idx] = neighbor_search(A, B, r, backend, use_gpu)
% NEIGHBOR_SEARCH Find pair indices (i,j) where distance(A(i,:), B(j,:)) < r
% Usage:
%   [i_idx, j_idx] = neighbor_search(A, B, r, backend, use_gpu)
% Inputs:
%   - A [NA x d], B [NB x d]
%   - r scalar radius
%   - backend: 'auto' | 'pdist2' | 'rangesearch' | 'gpu'
%   - use_gpu: 'off' | 'on' | 'auto'
% Output:
%   - i_idx, j_idx: column vectors of indices into A and B

if nargin < 4 || isempty(backend), backend = 'auto'; end
if nargin < 5 || isempty(use_gpu), use_gpu = 'off'; end

% Decide backend
if strcmpi(backend, 'auto')
    if (strcmpi(use_gpu,'on') || strcmpi(use_gpu,'auto')) && gpu_is_available()
        chosen = 'gpu';
    elseif exist('rangesearch','file') == 2
        chosen = 'rangesearch';
    else
        chosen = 'pdist2';
    end
else
    chosen = lower(string(backend));
end

switch char(chosen)
    case 'gpu'
        [i_idx, j_idx] = neighbor_gpu(A, B, r);
    case 'rangesearch'
        [i_idx, j_idx] = neighbor_rangesearch(A, B, r);
    otherwise % 'pdist2'
        [i_idx, j_idx] = neighbor_pdist2(A, B, r);
end

end

% ----------------- Backends -----------------
function [i_idx, j_idx] = neighbor_pdist2(A, B, r)
if isempty(A) || isempty(B)
    i_idx = zeros(0,1); j_idx = zeros(0,1); return; end
D = pdist2(A, B);
[i_idx, j_idx] = find(D < r);
end

function [i_idx, j_idx] = neighbor_rangesearch(A, B, r)
if isempty(A) || isempty(B)
    i_idx = zeros(0,1); j_idx = zeros(0,1); return; end
% Query neighbors in B for each point in A
[idxC, ~] = rangesearch(B, A, r);
% Flatten cell arrays into index vectors
na = size(A,1);
counts = cellfun(@numel, idxC(:));
total = sum(counts);
i_idx = zeros(total,1);
j_idx = zeros(total,1);
pos = 1;
for i = 1:na
    js = idxC{i};
    n = numel(js);
    if n == 0, continue; end
    i_idx(pos:pos+n-1) = i;
    j_idx(pos:pos+n-1) = js(:);
    pos = pos + n;
end
if pos <= total
    i_idx(pos:end) = [];
    j_idx(pos:end) = [];
end
end

function [i_idx, j_idx] = neighbor_gpu(A, B, r)
% GPU brute-force with distance^2 using matrix multiplication
try
    if isempty(A) || isempty(B)
        i_idx = zeros(0,1); j_idx = zeros(0,1); return; end
    Ag = gpuArray(single(A));
    Bg = gpuArray(single(B));
    A2 = sum(Ag.^2, 2);            % [NA x 1]
    B2 = sum(Bg.^2, 2);            % [NB x 1]
    % dist^2 = |A|^2 + |B|^2 - 2 A*B'
    dist2 = A2 + B2' - 2*(Ag*Bg'); % [NA x NB]
    mask = dist2 < (single(r)^2);
    [ii, jj] = find(mask);
    i_idx = gather(ii);
    j_idx = gather(jj);
catch ME
    warning('neighbor_gpu failed (%s); falling back to CPU pdist2', ME.message);
    [i_idx, j_idx] = neighbor_pdist2(A, B, r);
end
end

% ----------------- GPU helper -----------------
function yes = gpu_is_available()
yes = false;
try
    yes = (gpuDeviceCount > 0);
catch
    yes = false;
end
end


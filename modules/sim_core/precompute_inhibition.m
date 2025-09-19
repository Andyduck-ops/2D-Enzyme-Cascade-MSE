function state = precompute_inhibition(state, config)
% PRECOMPUTE_INHIBITION 计算酶的拥挤抑制因子并写入state
% 用法:
%   state = precompute_inhibition(state, config)
%
% 输入:
%   - state.enzyme_pos [N x 2]
%   - state.enzyme_type [N x 1] (1=GOx, 2=HRP) 可选（不依赖）
%   - state.gox_indices / state.hrp_indices
%   - config.inhibition_params: R_inhibit, n_sat, I_max
%
% 输出: 向 state 写入
%   - state.inhibition_factors_per_enzyme [N x 1]
%   - state.inhibition_factors_gox [num_gox x 1]
%   - state.inhibition_factors_hrp [num_hrp x 1]
%
% 参考: [refactored_2d_model.m](../../refactored_2d_model.m:185)

% 参数读取
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

% 计算成对距离并统计邻居数量（不包含自身）
% 与参考实现一致: n_nearby(i) = sum_j 1{ 0 < dist(i,j) < R_inhibit }
D = pdist2(pos, pos);
% 忽略自身
D(1:N+1:end) = inf;
n_nearby = sum(D < R_inhibit, 2);

% 抑制函数: I = 1 - I_max * min(n_nearby/n_sat, 1)
inhibition_factors = 1 - I_max * min(n_nearby ./ max(n_sat, eps), 1);

% 写回到 state（同时按 GOx/HRP 切片）
state.inhibition_factors_per_enzyme = inhibition_factors;

if isfield(state, 'gox_indices') && ~isempty(state.gox_indices)
    state.inhibition_factors_gox = inhibition_factors(state.gox_indices);
else
    % 兼容无索引场景
    state.inhibition_factors_gox = [];
end

if isfield(state, 'hrp_indices') && ~isempty(state.hrp_indices)
    state.inhibition_factors_hrp = inhibition_factors(state.hrp_indices);
else
    state.inhibition_factors_hrp = [];
end

% 控制台摘要
fprintf('[precompute_inhibition] 抑制因子范围: %.3f - %.3f\n', min(inhibition_factors), max(inhibition_factors));

end
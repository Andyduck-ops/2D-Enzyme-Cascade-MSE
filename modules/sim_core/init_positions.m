function state = init_positions(config)
% INIT_POSITIONS 基于配置初始化2D系统的初始状态
% 用法:
%   state = init_positions(config)
% 依赖默认参数: [default_config()](../config/default_config.m:1)
% 参考实现要点来自: [refactored_2d_model.m](../../refactored_2d_model.m:137)
%
% 输出 state 关键字段:
%   - 常量与派生: particle_center, film_boundary_radius
%   - 反应半径:   reaction_dist_GOx, reaction_dist_HRP, radius_intermediate
%   - 酶: enzyme_pos(Nx2), enzyme_type(Nx1; 1=GOx,2=HRP), gox_pos, hrp_pos, gox_indices, hrp_indices
%   - 底物/中间/产物位置: substrate_pos(Mx2), intermediate_pos(0x2), product_pos(0x2)
%   - ID: substrate_ids, intermediate_ids, product_ids
%   - 计时与状态: gox_busy, gox_timer, hrp_busy, hrp_timer

% ---------------- 基础参数 ----------------
L   = config.simulation_params.box_size;                      % 盒子长度 nm
dt  = config.simulation_params.time_step; %#ok<NASGU>
mode = config.simulation_params.simulation_mode;              % 'MSE'|'bulk' (兼容旧'surface')

% 粒子/酶与几何
N_total = config.particle_params.num_enzymes;
num_sub = config.particle_params.num_substrate;

pr   = config.geometry_params.particle_radius;
ft   = config.geometry_params.film_thickness;
rGOx = config.geometry_params.radius_GOx;
rHRP = config.geometry_params.radius_HRP;
rSub = config.geometry_params.radius_substrate;

% 反应半径与派生
state.particle_center = [L/2, L/2];
state.film_boundary_radius = pr + ft;
state.radius_intermediate = rSub; % 与原代码一致
state.reaction_dist_GOx = rGOx + rSub;
state.reaction_dist_HRP = rHRP + state.radius_intermediate;

% 合法性检查 (与原脚本一致)
assert(state.film_boundary_radius < L/2, 'Error: Particle+film 超过盒子半边长!');

% ---------------- 酶类型与数量 ----------------
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count') 
    gox_n = config.particle_params.gox_count;
    hrp_n = config.particle_params.hrp_count;
else
    ratio = config.particle_params.gox_hrp_split;
    gox_n = round(N_total * ratio);
    hrp_n = N_total - gox_n;
end
enzyme_type = [ones(gox_n,1); 2*ones(hrp_n,1)];

% ---------------- 酶位置初始化 ----------------
enzyme_pos = zeros(N_total, 2);
switch lower(mode)
    case {'mse','surface'}    % 在 [pr, pr+ft] 圆环内均匀分布 (MSE 模式；兼容旧'surface')
        theta = 2*pi*rand(N_total,1);
        rad   = pr + ft*rand(N_total,1);
        enzyme_pos(:,1) = state.particle_center(1) + rad.*cos(theta);
        enzyme_pos(:,2) = state.particle_center(2) + rad.*sin(theta);
    case 'bulk'
        % 在盒子 [0,L]x[0,L] 内均匀分布
        enzyme_pos = L * rand(N_total, 2);
    otherwise
        error('未知 simulation_mode=%s (期望 ''MSE'' 或 ''bulk'')', mode);
end

gox_indices = find(enzyme_type==1);
hrp_indices = find(enzyme_type==2);
gox_pos = enzyme_pos(gox_indices,:);
hrp_pos = enzyme_pos(hrp_indices,:);

% ---------------- 底物初始化 ----------------
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


% ---------------- 产物/中间产物与ID ----------------
intermediate_pos = zeros(0,2);
product_pos = zeros(0,2);

substrate_ids = (1:size(substrate_pos,1))'; intermediate_ids = zeros(0,1); product_ids = zeros(0,1); % 除直接给出位置外，还需要给出ID，用于索引最终结果段中的位置 ((substrate_pos(i,:)+enzyme_pos(j,:))/2) (这样才能只在产物初始生成时计算一次，减少冗余计算量，且部分产物可能需要多次计算位置)。同时方便用一个"for idx=1:N_sub"来替代原来"for i=1:size(substrate_pos,1)" (不写:43; 原写:46)，同时size(substrate_ids,1)==size(substrate_pos,1) 也提供了一定合理性保证。

% ---------------- 酶忙碌状态与计时 ----------------
gox_busy  = false(gox_n, 1);
hrp_busy  = false(hrp_n, 1);
gox_timer = zeros(gox_n, 1);
hrp_timer = zeros(hrp_n, 1);

% ---------------- 组装state ----------------
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

% 元信息（非必需）
state.meta = struct( ...
    'mode', mode, ...
    'L', L, ...
    'N_total', N_total, ...
    'gox_n', gox_n, ...
    'hrp_n', hrp_n, ...
    'num_sub', num_sub ...
);

end
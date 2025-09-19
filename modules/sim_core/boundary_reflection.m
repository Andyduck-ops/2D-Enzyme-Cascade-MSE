function state = boundary_reflection(state, config)
% BOUNDARY_REFLECTION 边界与中心颗粒碰撞的镜面反射处理
% 用法:
%   state = boundary_reflection(state, config)
%
% 实现内容:
%   1) 盒子四周反射边界: x<0 -> -x, x>L -> 2L-x (y 同理)
%   2) MSE模式(兼容旧 surface): 与中心颗粒(r = particle_radius)发生侵入时, 将粒子沿法向量推回到
%      r = particle_radius + eps 的缓冲半径 (避免数值震荡)
%
% 参考原脚本:
%   - 盒子反射: [refactored_2d_model.m](../../refactored_2d_model.m:314)
%   - 颗粒镜面反射: [refactored_2d_model.m](../../refactored_2d_model.m:326)

L   = config.simulation_params.box_size;
mode = config.simulation_params.simulation_mode;

% 1) 盒子反射边界 (三类粒子统一处理)
state.substrate_pos    = reflect_to_box(state.substrate_pos, L);
state.intermediate_pos = reflect_to_box(state.intermediate_pos, L);
state.product_pos      = reflect_to_box(state.product_pos, L);

% 2) MSE 模式颗粒碰撞处理（兼容 'surface' 输入）
is_mse = any(strcmpi(mode, {'MSE','surface'}));
if is_mse
     pr = config.geometry_params.particle_radius;
     % 稳定参数 (与原脚本一致思想)
     min_distance   = 1e-6;
     target_distance = pr + 0.1;

     % 对三类粒子依次处理
     state.substrate_pos    = reflect_from_particle(state.substrate_pos, state.particle_center, pr, target_distance, min_distance);
     state.intermediate_pos = reflect_from_particle(state.intermediate_pos, state.particle_center, pr, target_distance, min_distance);
     state.product_pos      = reflect_from_particle(state.product_pos, state.particle_center, pr, target_distance, min_distance);
 end

end

% ----------------- 工具函数 -----------------
function P = reflect_to_box(P, L)
% 盒子反射边界
if isempty(P), return; end
% 小于0的反射
mask = P < 0;
P(mask) = -P(mask);
% 大于L的反射
mask = P > L;
P(mask) = 2*L - P(mask);
end

function P = reflect_from_particle(P, center, pr, target_r, min_r)
% MSE模式: 中心颗粒碰撞镜面反射（兼容 surface）
if isempty(P), return; end
dist = sqrt(sum((P - center).^2, 2));
collided = dist < pr;
if ~any(collided), return; end

vec = P(collided, :) - center;      % 指向粒子的向量
d   = dist(collided);

% 对过近于中心的点，采用随机方向代替单位法向的归一化，避免数值不稳定
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

% 将位置推回到 target_r
P(collided, :) = center + target_r * normals;
end
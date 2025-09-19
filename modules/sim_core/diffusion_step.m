function state = diffusion_step(state, config)
% DIFFUSION_STEP 进行一次2D布朗扩散步进（异质扩散）
% 用法:
%   state = diffusion_step(state, config)
%
% 逻辑:
%   - MSE: 薄膜内半径<=film_boundary_radius使用 D_film，否则使用 D_bulk（兼容旧 surface）
%   - bulk:    统一使用 D_bulk
%   - 分别对 substrate/intermediate/product 三类粒子进行更新
 
dt     = config.simulation_params.time_step;
mode   = config.simulation_params.simulation_mode;
D_bulk = config.particle_params.diff_coeff_bulk;
D_film = config.particle_params.diff_coeff_film;
 
% 兼容旧值: 将 'surface' 视为 'MSE'
is_mse = any(strcmpi(mode, {'MSE','surface'}));

% 工具函数: 应用异质扩散到某一类粒子
    function P = step_species(P)
        if isempty(P), return; end
        if is_mse
            % 位置依赖扩散系数: 薄膜内/外
            dist = sqrt(sum((P - state.particle_center).^2, 2));
            in_film = dist <= state.film_boundary_radius;
            D = D_bulk * ones(size(P,1), 1);
            D(in_film) = D_film;
        else
            % 统一 D_bulk
            D = D_bulk * ones(size(P,1), 1);
        end
        % 布朗运动步进
        P = P + sqrt(2*D*dt) .* randn(size(P));
    end

% 三类粒子依次更新
state.substrate_pos    = step_species(state.substrate_pos);
state.intermediate_pos = step_species(state.intermediate_pos);
state.product_pos      = step_species(state.product_pos);







end
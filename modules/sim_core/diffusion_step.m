function state = diffusion_step(state, config)
% DIFFUSION_STEP Perform one 2D Brownian diffusion step (heterogeneous diffusion)
% Usage:
%   state = diffusion_step(state, config)
%
% Logic:
%   - MSE: Within film radius<=film_boundary_radius uses D_film, otherwise uses D_bulk (compatible with legacy surface)
%   - bulk: Uniformly uses D_bulk
%   - Updates substrate/intermediate/product three particle types separately
 
dt     = config.simulation_params.time_step;
mode   = config.simulation_params.simulation_mode;
D_bulk = config.particle_params.diff_coeff_bulk;
D_film = config.particle_params.diff_coeff_film;
 
% Legacy compatibility: treat 'surface' as 'MSE'
is_mse = any(strcmpi(mode, {'MSE','surface'}));

% Utility function: apply heterogeneous diffusion to a particle species
    function P = step_species(P)
        if isempty(P), return; end
        if is_mse
            % Position-dependent diffusion coefficient: inside/outside film
            dist = sqrt(sum((P - state.particle_center).^2, 2));
            in_film = dist <= state.film_boundary_radius;
            D = D_bulk * ones(size(P,1), 1);
            D(in_film) = D_film;
        else
            % Uniform D_bulk
            D = D_bulk * ones(size(P,1), 1);
        end
        % Brownian motion step
        P = P + sqrt(2*D*dt) .* randn(size(P));
    end

% Update three particle types sequentially
state.substrate_pos    = step_species(state.substrate_pos);
state.intermediate_pos = step_species(state.intermediate_pos);
state.product_pos      = step_species(state.product_pos);







end
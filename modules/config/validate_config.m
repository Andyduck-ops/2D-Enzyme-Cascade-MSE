function config = validate_config(config)
% VALIDATE_CONFIG Check configuration consistency and adjust for dependencies
%
% Usage:
%   config = validate_config(config)
%
% Checks:
%   1. Toolbox dependencies (Statistics, Parallel, GPU)
%   2. Reaction probability with stride
%   3. Verlet parameters consistency
%   4. Cell size parameters
%
% Adjustments:
%   - Fallback neighbor backend if dependencies missing
%   - Warnings for suboptimal parameter combinations

% -------------------------------------------------------------------------
% Check Toolbox Dependencies
% -------------------------------------------------------------------------
has_stats = license('test', 'Statistics_Toolbox') && exist('KDTreeSearcher', 'class') == 8;
has_parallel = license('test', 'Distrib_Computing_Toolbox');
has_gpu = gpuDeviceCount > 0;

% Adjust neighbor backend based on availability
if strcmpi(config.compute.neighbor_backend, 'auto')
    if has_stats
        config.compute.neighbor_backend = 'rangesearch';
    elseif has_gpu && (strcmpi(config.compute.use_gpu, 'on') || strcmpi(config.compute.use_gpu, 'auto'))
        config.compute.neighbor_backend = 'gpu';
        warning('validate_config:no_stats', ...
            'Statistics Toolbox not available, using GPU backend');
    else
        config.compute.neighbor_backend = 'pdist2';
        warning('validate_config:no_stats_no_gpu', ...
            'Statistics Toolbox and GPU not available, using pdist2 (slower)');
    end
elseif strcmpi(config.compute.neighbor_backend, 'rangesearch') || strcmpi(config.compute.neighbor_backend, 'kdtree')
    if ~has_stats
        warning('validate_config:rangesearch_unavailable', ...
            'rangesearch/kdtree requested but Statistics Toolbox not available');
        if has_gpu
            config.compute.neighbor_backend = 'gpu';
            warning('validate_config:fallback_gpu', 'Falling back to GPU backend');
        else
            config.compute.neighbor_backend = 'pdist2';
            warning('validate_config:fallback_pdist2', 'Falling back to pdist2');
        end
    end
end

% Adjust parallel settings
if config.batch.use_parfor && ~has_parallel
    warning('validate_config:no_parallel', ...
        'Parallel Computing Toolbox not available, disabling parfor');
    config.batch.use_parfor = false;
end

% -------------------------------------------------------------------------
% Validate Reaction Check Stride
% -------------------------------------------------------------------------
m = config.reaction_check_stride;
dt = config.simulation_params.time_step;
k_max = max(config.particle_params.k_cat_GOx, config.particle_params.k_cat_HRP);

% Check reaction probability
p_max = 1 - exp(-k_max * m * dt);
if p_max > 0.2
    warning('validate_config:high_probability', ...
        'Reaction probability %.3f > 0.2 with stride=%d. Consider reducing stride or dt.', ...
        p_max, m);
end

% -------------------------------------------------------------------------
% Validate Verlet Parameters
% -------------------------------------------------------------------------
if isfield(config, 'neighbor')
    r_react = max(config.geometry_params.radius_GOx + config.geometry_params.radius_substrate, ...
                  config.geometry_params.radius_HRP + config.geometry_params.radius_substrate);
    
    % Check r_skin range
    if config.neighbor.r_skin_nm < 0.3 * r_react || config.neighbor.r_skin_nm > 2.0 * r_react
        warning('validate_config:r_skin_range', ...
            'r_skin_nm=%.2f is outside recommended range [%.2f, %.2f]', ...
            config.neighbor.r_skin_nm, 0.5*r_react, 1.0*r_react);
    end
    
    % Check max_drift vs r_skin
    if config.neighbor.max_drift_nm > config.neighbor.r_skin_nm
        warning('validate_config:max_drift_large', ...
            'max_drift_nm > r_skin_nm may cause missed neighbors. Recommended: max_drift <= r_skin/2');
    end
end

end

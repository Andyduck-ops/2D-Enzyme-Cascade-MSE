function [config, dt_info] = auto_adjust_dt(config)
% AUTO_ADJUST_DT Reduce dt until basic accuracy constraints are met.
% Usage:
%   [config, dt_info] = auto_adjust_dt(config)
%
% Constraints (all must hold):
%   - k_max * dt <= target_k_fraction
%   - sigma = sqrt(2*D_bulk*dt) <= min(target_sigma_abs_nm, target_sigma_fraction * min_scale)
% where min_scale = min([rGOx+rSub, rHRP+rSub, film_thickness]).

dt0 = getfield_or(config, {'simulation_params','time_step'}, NaN);
if ~getfield_or(config, {'simulation_params','enable_auto_dt'}, false) || ~isfinite(dt0) || dt0 <= 0
    dt_info = struct('enabled', false, 'initial_dt', dt0, 'final_dt', dt0, 'history', dt0);
    return;
end

% Read parameters
k_g = getfield_or(config, {'particle_params','k_cat_GOx'}, NaN);
k_h = getfield_or(config, {'particle_params','k_cat_HRP'}, NaN);
D_b = getfield_or(config, {'particle_params','diff_coeff_bulk'}, NaN);
rGOx = getfield_or(config, {'geometry_params','radius_GOx'}, NaN);
rHRP = getfield_or(config, {'geometry_params','radius_HRP'}, NaN);
rSub = getfield_or(config, {'geometry_params','radius_substrate'}, NaN);
film = getfield_or(config, {'geometry_params','film_thickness'}, NaN);

tk = getfield_or(config, {'simulation_params','auto_dt','target_k_fraction'}, 0.05);
ts = getfield_or(config, {'simulation_params','auto_dt','target_sigma_fraction'}, 0.3);
ts_abs = getfield_or(config, {'simulation_params','auto_dt','target_sigma_abs_nm'}, 1.0);

if any(~isfinite([k_g,k_h,D_b,rGOx,rHRP,rSub,film]))
    dt_info = struct('enabled', true, 'initial_dt', dt0, 'final_dt', dt0, 'history', dt0, 'note', 'insufficient parameters');
    return;
end

kmax = max(k_g, k_h);
min_scale = min([rGOx + rSub, rHRP + rSub, film]);
sigma_target = min(ts_abs, ts * max(min_scale, eps));

dt = dt0;
hist = dt;
max_iter = 32;
iter = 0;
while true
    iter = iter + 1;
    k_ok = (kmax * dt) <= tk;
    sigma = sqrt(2 * D_b * dt);
    s_ok = sigma <= sigma_target;
    if k_ok && s_ok
        break;
    end
    % Reduce dt by half each time to avoid overshoot; ensures monotonic approach
    dt = dt / 2;
    hist(end+1) = dt; %#ok<AGROW>
    if iter >= max_iter
        break;
    end
end

% Apply new dt
config.simulation_params.time_step = dt;

% Report
dt_info = struct();
dt_info.enabled = true;
dt_info.initial_dt = dt0;
dt_info.final_dt = dt;
dt_info.history = hist(:).';
dt_info.kmax = kmax;
dt_info.D_bulk = D_b;
dt_info.min_scale = min_scale;
dt_info.target_k_fraction = tk;
dt_info.target_sigma_fraction = ts;
dt_info.target_sigma_abs_nm = ts_abs;
dt_info.sigma_final = sqrt(2*D_b*dt);
dt_info.kdt_final = kmax * dt;

% Store in config.meta for metadata writer
if ~isfield(config, 'meta') || ~isstruct(config.meta)
    config.meta = struct();
end
config.meta.dt_auto = dt_info;

end

% ----------------- Utility -----------------
function v = getfield_or(s, path, default)
    v = default;
    try
        for k = 1:numel(path)
            key = path{k};
            if isstruct(s) && isfield(s, key)
                s = s.(key);
            else
                return;
            end
        end
        v = s;
    catch
        v = default;
    end
end


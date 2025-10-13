function config_sanity_checks(config)
% CONFIG_SANITY_CHECKS Print warnings if dt and kinetics/diffusion scales are inconsistent.
% Usage:
%   config_sanity_checks(config)
%
% Checks:
%   - Reaction scale: k_max*dt should be small (recommend <= 0.05, warn above 0.2)
%   - Diffusion scale: sigma = sqrt(2*D_bulk*dt) should be well below reaction radii/film thickness

dt = getfield_or(config, {'simulation_params','time_step'}, NaN);
k_g = getfield_or(config, {'particle_params','k_cat_GOx'}, NaN);
k_h = getfield_or(config, {'particle_params','k_cat_HRP'}, NaN);
D_b = getfield_or(config, {'particle_params','diff_coeff_bulk'}, NaN);

rGOx = getfield_or(config, {'geometry_params','radius_GOx'}, NaN);
rHRP = getfield_or(config, {'geometry_params','radius_HRP'}, NaN);
rSub = getfield_or(config, {'geometry_params','radius_substrate'}, NaN);
film = getfield_or(config, {'geometry_params','film_thickness'}, NaN);

if any(~isfinite([dt,k_g,k_h,D_b,rGOx,rHRP,rSub,film]))
    fprintf('[config_sanity_checks] Skipped (incomplete parameters)\n');
    return;
end

kmax = max(k_g, k_h);
kdt  = kmax * dt;
if kdt > 0.2
    fprintf('[config_sanity_checks] Warning: k_max*dt=%.3g is large; consider dt <= %.3g\n', kdt, 0.05/max(kmax, eps));
end

sigma = sqrt(2*D_b*dt);
r_react_min = min([rGOx + rSub, rHRP + rSub, film]);
if isfinite(r_react_min) && r_react_min > 0 && sigma > 0.5 * r_react_min
    fprintf('[config_sanity_checks] Warning: diffusion step sigma=%.3g nm is large vs min scale %.3g nm\n', sigma, r_react_min);
end

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


function mode_used = setup_rng(seed, use_gpu)
% SETUP_RNG Initialize CPU/GPU random number generators with a fixed seed for reproducibility.
% Usage:
%   mode_used = setup_rng(seed, use_gpu)
%
% Inputs:
%   - seed    numeric scalar seed value
%   - use_gpu 'auto' | 'on' | 'off'; defaults to 'auto'
%
% Output:
%   - mode_used  'cpu' or 'gpu' indicating the device RNG that was configured
%
% Notes:
%   - CPU RNG uses rng(seed, 'twister') for stable reproducibility.
%   - GPU RNG uses gpurng(seed, 'Threefry') when available.
%   - In 'auto' mode the GPU RNG is attempted first; failures fall back to CPU RNG.
%
% Reference: default_config() (../config/default_config.m:1)

if nargin < 2 || isempty(use_gpu)
    use_gpu = 'auto';
end

% Always seed the CPU RNG to keep rand/randn deterministic
rng(seed, 'twister');
mode_used = 'cpu';

% Optionally configure GPU RNG
switch lower(use_gpu)
    case 'off'
        return;
    case 'on'
        if gpu_available()
            if try_set_gpurng(seed)
                mode_used = 'gpu';
            else
                warning('Failed to configure GPU RNG; continuing with CPU RNG.');
            end
        else
            warning('GPU not available; using CPU RNG.');
        end
    case 'auto'
        if gpu_available()
            if try_set_gpurng(seed)
                mode_used = 'gpu';
            else
                warning('Auto mode: GPU RNG setup failed; falling back to CPU RNG.');
            end
        end
    otherwise
        warning('Unknown use_gpu option: %s. Using CPU RNG.', use_gpu);
end

fprintf('RNG initialized: seed=%d, mode=%s\n', seed, mode_used);

end

% ----------------- Helper functions -----------------
function yes = gpu_available()
yes = false;
try
    yes = (gpuDeviceCount > 0);
catch
    yes = false;
end
end

function ok = try_set_gpurng(seed)
ok = false;
try
    gpurng(seed, 'Threefry');
    ok = true;
catch ME
    warning('gpurng setup failed: %s', ME.message);
    ok = false;
end
end

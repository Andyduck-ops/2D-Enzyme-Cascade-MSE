function pool_config = auto_configure_parallel(config)
% AUTO_CONFIGURE_PARALLEL Automatically configure parallel pool based on CPU cores
% Usage:
%   pool_config = auto_configure_parallel(config)
% Input:
%   - config  simulation configuration struct
% Output:
%   - pool_config  struct with fields:
%       .use_parfor      logical, whether to use parallel execution
%       .num_workers     number of workers to use
%       .pool            parallel pool object (if created)
%
% This function detects the number of CPU cores and automatically configures
% the parallel pool for optimal performance.

pool_config = struct();
pool_config.use_parfor = false;
pool_config.num_workers = 0;
pool_config.pool = [];

% Check if parallel execution is requested
use_parfor = getfield_or(config, {'batch','use_parfor'}, false);
if ~use_parfor
    fprintf('Parallel execution disabled in config\n');
    return;
end

% Detect number of CPU cores
try
    % Get number of physical cores
    num_cores = feature('numcores');
    fprintf('Detected %d CPU cores\n', num_cores);
    
    % Check user-specified worker count
    user_workers = getfield_or(config, {'batch','num_workers'}, 'auto');
    
    if ischar(user_workers) && strcmpi(user_workers, 'auto')
        % Auto mode: use all cores minus 1 (leave one for system)
        optimal_workers = max(1, num_cores - 1);
        fprintf('Auto mode: using %d workers (leaving 1 core for system)\n', optimal_workers);
    elseif isnumeric(user_workers) && user_workers > 0
        % User specified a number
        optimal_workers = min(user_workers, num_cores);
        if user_workers > num_cores
            fprintf('Warning: requested %d workers but only %d cores available\n', ...
                user_workers, num_cores);
        end
        fprintf('Using %d workers as specified\n', optimal_workers);
    else
        % Invalid setting, use default
        optimal_workers = max(1, num_cores - 1);
        fprintf('Invalid num_workers setting, using auto: %d workers\n', optimal_workers);
    end
    
    % Check if parallel pool already exists
    pool = gcp('nocreate');
    if isempty(pool)
        % Create new pool with optimal worker count
        fprintf('Starting parallel pool with %d workers...\n', optimal_workers);
        pool = parpool(optimal_workers);
        fprintf('Parallel pool started successfully\n');
    else
        % Pool exists, check if it has the right number of workers
        if pool.NumWorkers ~= optimal_workers
            fprintf('Existing pool has %d workers, restarting with %d workers...\n', ...
                pool.NumWorkers, optimal_workers);
            delete(pool);
            pool = parpool(optimal_workers);
            fprintf('Parallel pool restarted successfully\n');
        else
            fprintf('Using existing parallel pool with %d workers\n', pool.NumWorkers);
        end
    end
    
    pool_config.use_parfor = true;
    pool_config.num_workers = pool.NumWorkers;
    pool_config.pool = pool;
    
catch ME
    warning('Failed to configure parallel pool: %s', ME.message);
    fprintf('Falling back to serial execution\n');
    pool_config.use_parfor = false;
end

    function v = getfield_or(s, path, default)
        % Inline helper to read nested struct fields with a default fallback
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

end

function [seeds, csv_path] = get_batch_seeds(config)
% GET_BATCH_SEEDS Generate per-batch random seeds and persist them to a CSV file.
% Configuration sources: default_config() (../config/default_config.m:1), interactive_config() (../config/interactive_config.m:1)
%
% Outputs:
%   - seeds    [batch_count x 1] column vector of seeds
%   - csv_path path to the written seeds.csv file (for logging/sharing)
%
% Supported modes:
%   - fixed:            use the provided fixed_seed for every batch
%   - per_batch_random: draw a fresh random seed for each batch (10000-999999)
%   - manual_list:      use a user supplied seed_list (repeats if shorter than batch_count)
%   - incremental:      start from seed_base and increment by 1 per batch
%
% CSV schema:
%   batch_index, seed

SEED_MIN = 10000;
SEED_MAX = 999999;

% ---- Read configuration ----
count = getfield_or(config, {'batch','batch_count'}, 1);
mode  = getfield_or(config, {'batch','seed_mode'}, 'fixed');

% ---- Generate seeds ----
switch lower(mode)
    case 'fixed'
        fixed_seed = getfield_or(config, {'batch','fixed_seed'}, 1234);
        seeds = repmat(fixed_seed, count, 1);

    case 'per_batch_random'
        seeds = randi([SEED_MIN, SEED_MAX], count, 1);

    case 'manual_list'
        list = getfield_or(config, {'batch','seed_list'}, []);
        if isempty(list)
            warning('manual_list mode missing seed_list; falling back to per_batch_random.');
            seeds = randi([SEED_MIN, SEED_MAX], count, 1);
        else
            list = list(:);
            if numel(list) >= count
                seeds = list(1:count);
            else
                reps = ceil(count / numel(list));
                seeds = repmat(list, reps, 1);
                seeds = seeds(1:count);
                fprintf('manual_list shorter than batch_count (%d < %d); repeating seeds as needed.\n', numel(list), count);
            end
        end

    case 'incremental'
        base = getfield_or(config, {'batch','seed_base'}, SEED_MIN);
        if base < SEED_MIN
            warning('incremental mode base (%d) adjusted up to %d to maintain 5-6 digit seeds.', base, SEED_MIN);
            base = SEED_MIN;
        end
        seeds = (base + (0:count-1))';

    otherwise
        warning('Unknown seed_mode=%s; defaulting to fixed seed 1234.', mode);
        seeds = repmat(1234, count, 1);
end

% ---- Write CSV ----
outdir = getfield_or(config, {'io','outdir'}, fullfile('2D','out'));
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
csv_path = fullfile(outdir, 'seeds.csv');

fid = fopen(csv_path, 'w');
if fid == -1
    warning('Unable to write %s; skipping CSV export.', csv_path);
else
    fprintf(fid, 'batch_index,seed\n');
    for i = 1:numel(seeds)
        fprintf(fid, '%d,%d\n', i, seeds(i));
    end
    fclose(fid);
end

% ---- Console output ----
fprintf('Generated batch seeds: mode=%s, count=%d, written=%s\n', mode, count, csv_path);

    function v = getfield_or(s, path, default)
        % Helper to read nested struct fields with a default fallback
        v = default;
        try
            for i = 1:numel(path)
                key = path{i};
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

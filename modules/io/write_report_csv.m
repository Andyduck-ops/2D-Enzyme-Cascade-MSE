function csv_path = write_report_csv(batch_table, outdir, basename)
% WRITE_REPORT_CSV Write batch results to a CSV file.
% Usage:
%   csv_path = write_report_csv(batch_table, outdir)
%   csv_path = write_report_csv(batch_table, outdir, basename)
%
% Inputs:
%   - batch_table  table produced by run_batches()
%   - outdir       output directory, e.g., from default_config()
%   - basename     optional file basename (default 'batch_results')
%
% Output:
%   - csv_path     absolute path of the CSV file that was written
%
% CSV column order:
%   batch_index, seed, products_final, mode, num_enzymes, gox_count, hrp_count, num_substrate, dt, total_time

if nargin < 3 || isempty(basename)
    basename = 'batch_results';
end

if ~istable(batch_table)
    error('write_report_csv: batch_table must be a table.');
end

if ~exist(outdir, 'dir')
    try
        mkdir(outdir);
    catch ME
        error('Unable to create output directory %s: %s', outdir, ME.message);
    end
end

csv_path = fullfile(outdir, sprintf('%s.csv', basename));

try
    writetable(batch_table, csv_path);
catch ME
    % Older MATLAB versions or permissions can block writetable; fall back to manual CSV writing
    warning('writetable failed (%s); falling back to manual CSV write.', ME.message);
    fid = fopen(csv_path, 'w');
    if fid == -1
        error('Unable to open CSV for writing: %s', csv_path);
    end

    headers = batch_table.Properties.VariableNames;
    for k = 1:numel(headers)
        if k > 1, fprintf(fid, ','); end
        fprintf(fid, '%s', headers{k});
    end
    fprintf(fid, '\n');

    for i = 1:height(batch_table)
        for k = 1:numel(headers)
            if k > 1, fprintf(fid, ','); end
            val = batch_table{i, k};
            if isnumeric(val)
                fprintf(fid, '%g', val);
            elseif isstring(val) || ischar(val)
                fprintf(fid, '%s', string(val));
            else
                fprintf(fid, '%s', char(string(val)));
            end
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

fprintf('Batch results written to: %s\n', csv_path);

end

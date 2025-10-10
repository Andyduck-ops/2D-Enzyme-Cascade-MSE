function csv_path = save_timeseries(time_axis, product_curves, outdir, basename)
% SAVE_TIMESERIES Save time-series product data to CSV file
% Usage:
%   csv_path = save_timeseries(time_axis, product_curves, outdir)
%   csv_path = save_timeseries(time_axis, product_curves, outdir, basename)
%
% Inputs:
%   - time_axis: [n_steps x 1] time points (s)
%   - product_curves: [n_steps x n_batches] product matrix
%   - outdir: output directory path
%   - basename: optional file basename (default 'timeseries_products')
%
% Output:
%   - csv_path: absolute path of the CSV file that was written
%
% CSV Format:
%   time,batch_1,batch_2,batch_3,...
%   0.0,0.0,0.0,0.0,...
%   0.1,1.2,1.1,1.3,...
%   ...
%
% Description:
%   Efficiently writes time-series data to CSV format using writetable.
%   The first column is time, followed by columns for each batch.

if nargin < 4 || isempty(basename)
    basename = 'timeseries_products';
end

% Validate inputs
if isempty(time_axis) || isempty(product_curves)
    error('save_timeseries: time_axis and product_curves must not be empty');
end

% Ensure time_axis is column vector
time_axis = time_axis(:);
n_steps = numel(time_axis);

% Validate product_curves dimensions
[n_rows, n_batches] = size(product_curves);
if n_rows ~= n_steps
    error('save_timeseries: product_curves rows (%d) must match time_axis length (%d)', ...
          n_rows, n_steps);
end

% Create output directory if it doesn't exist
if ~exist(outdir, 'dir')
    try
        mkdir(outdir);
    catch ME
        error('Unable to create output directory %s: %s', outdir, ME.message);
    end
end

% ========== Build Table ==========
% Start with time column
data_table = table(time_axis, 'VariableNames', {'time'});

% Add batch columns
for b = 1:n_batches
    col_name = sprintf('batch_%d', b);
    data_table.(col_name) = product_curves(:, b);
end

% ========== Write CSV ==========
csv_path = fullfile(outdir, sprintf('%s.csv', basename));

try
    writetable(data_table, csv_path);
    fprintf('Time-series data saved: %s (%d steps x %d batches)\n', ...
            csv_path, n_steps, n_batches);
catch ME
    % Fallback to manual CSV writing for older MATLAB versions
    warning('writetable failed (%s); falling back to manual CSV write.', ME.message);
    
    fid = fopen(csv_path, 'w');
    if fid == -1
        error('Unable to open CSV for writing: %s', csv_path);
    end
    
    % Write header
    fprintf(fid, 'time');
    for b = 1:n_batches
        fprintf(fid, ',batch_%d', b);
    end
    fprintf(fid, '\n');
    
    % Write data rows
    for i = 1:n_steps
        fprintf(fid, '%.6f', time_axis(i));
        for b = 1:n_batches
            fprintf(fid, ',%.6f', product_curves(i, b));
        end
        fprintf(fid, '\n');
    end
    
    fclose(fid);
    fprintf('Time-series data saved (manual): %s (%d steps x %d batches)\n', ...
            csv_path, n_steps, n_batches);
end

end

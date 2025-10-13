function [seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col] = ...
    record_batch_result(b, seed, results, batch_config, seed_col, prod_col, mode_col, enz_col, gox_col, hrp_col, substrate_col, dt_col, total_time_col)
% RECORD_BATCH_RESULT Record results from a single batch execution
%
% Usage:
%   [seed_col, prod_col, ...] = record_batch_result(b, seed, results, batch_config, seed_col, prod_col, ...)
%
% Inputs:
%   b: batch index
%   seed: random seed used
%   results: simulation results struct
%   batch_config: batch configuration struct from extract_batch_config
%   seed_col, prod_col, ...: existing column arrays
%
% Outputs:
%   Updated column arrays with batch b results

% Record seed
seed_col(b) = seed;

% Record products
if isfield(results, 'products_final')
    prod_col(b) = results.products_final;
else
    prod_col(b) = NaN;
end

% Record configuration
mode_col(b) = string(batch_config.sim_mode);
enz_col(b) = batch_config.N_total;
gox_col(b) = batch_config.gox_n;
hrp_col(b) = batch_config.hrp_n;
substrate_col(b) = batch_config.num_sub;
dt_col(b) = batch_config.dt;
total_time_col(b) = batch_config.T_total;

end

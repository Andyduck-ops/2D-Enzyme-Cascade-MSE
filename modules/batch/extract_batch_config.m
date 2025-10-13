function batch_config = extract_batch_config(config)
% EXTRACT_BATCH_CONFIG Extract common batch configuration parameters
%
% Usage:
%   batch_config = extract_batch_config(config)
%
% Input:
%   config: configuration struct
%
% Output:
%   batch_config: struct with extracted parameters
%     .sim_mode: simulation mode ('MSE' or 'bulk')
%     .N_total: total number of enzymes
%     .gox_n: number of GOx enzymes
%     .hrp_n: number of HRP enzymes
%     .num_sub: number of substrate molecules
%     .dt: time step
%     .T_total: total simulation time
%     .use_gpu_mode: GPU mode setting

batch_config = struct();

% Simulation mode
batch_config.sim_mode = config.simulation_params.simulation_mode;

% Enzyme counts
batch_config.N_total = config.particle_params.num_enzymes;
if isfield(config.particle_params, 'gox_count') && isfield(config.particle_params, 'hrp_count')
    batch_config.gox_n = config.particle_params.gox_count;
    batch_config.hrp_n = config.particle_params.hrp_count;
else
    r = config.particle_params.gox_hrp_split;
    batch_config.gox_n = round(batch_config.N_total * r);
    batch_config.hrp_n = batch_config.N_total - batch_config.gox_n;
end

% Substrate count
batch_config.num_sub = config.particle_params.num_substrate;

% Time parameters
batch_config.dt = config.simulation_params.time_step;
batch_config.T_total = config.simulation_params.total_time;

% GPU mode
batch_config.use_gpu_mode = 'auto';
if isfield(config, 'batch') && isfield(config.batch, 'use_gpu')
    batch_config.use_gpu_mode = config.batch.use_gpu;
end

end

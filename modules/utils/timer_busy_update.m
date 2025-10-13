function state = timer_busy_update(state)
% TIMER_BUSY_UPDATE Decrement enzyme timers and synchronize busy states (continuous time)
% Usage:
%   state = timer_busy_update(state)
%
% Behavior (updated to continuous time):
%   - If state.dt is available, treat timers as remaining time (seconds):
%       gox_timer = max(gox_timer - dt, 0); gox_busy = (gox_timer > 0)
%       hrp_timer = max(hrp_timer - dt, 0); hrp_busy = (hrp_timer > 0)
%   - Backward compatible: if state.dt missing, fallback to old step-based decrement by 1.
%
% Reference: [refactored_2d_model.m](../../refactored_2d_model.m:241)

% Determine decrement step
if isfield(state, 'dt') && ~isempty(state.dt) && isfinite(state.dt) && state.dt > 0
    dec = state.dt;   % continuous-time decrement (seconds)
else
    dec = 1;          % fallback: step-based (legacy)
end

% GOx
if isfield(state, 'gox_timer') && ~isempty(state.gox_timer)
    state.gox_timer = max(state.gox_timer - dec, 0);
    state.gox_busy  = state.gox_timer > 0;
end

% HRP
if isfield(state, 'hrp_timer') && ~isempty(state.hrp_timer)
    state.hrp_timer = max(state.hrp_timer - dec, 0);
    state.hrp_busy  = state.hrp_timer > 0;
end

end

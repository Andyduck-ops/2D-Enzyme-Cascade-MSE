function state = timer_busy_update(state)
% TIMER_BUSY_UPDATE Decrement enzyme timers and synchronize busy states
% Usage:
%   state = timer_busy_update(state)
%
% Behavior:
%   - gox_timer = max(gox_timer - 1, 0); gox_busy = (gox_timer > 0)
%   - hrp_timer = max(hrp_timer - 1, 0); hrp_busy = (hrp_timer > 0)
%
% Reference: [refactored_2d_model.m](../../refactored_2d_model.m:241)

% GOx
if isfield(state, 'gox_timer') && ~isempty(state.gox_timer)
    state.gox_timer = max(state.gox_timer - 1, 0);
    state.gox_busy  = state.gox_timer > 0;
end

% HRP
if isfield(state, 'hrp_timer') && ~isempty(state.hrp_timer)
    state.hrp_timer = max(state.hrp_timer - 1, 0);
    state.hrp_busy  = state.hrp_timer > 0;
end

end
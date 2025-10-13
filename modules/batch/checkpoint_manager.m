function checkpoint_manager(action, checkpoint_file, data)
% CHECKPOINT_MANAGER Manage checkpoints for long batch runs
%
% Usage:
%   checkpoint_manager('save', checkpoint_file, data)
%   data = checkpoint_manager('load', checkpoint_file)
%   checkpoint_manager('delete', checkpoint_file)
%   exists = checkpoint_manager('exists', checkpoint_file)
%
% Checkpoint data structure:
%   - completed_batches: [N x 1] indices of completed batches
%   - results: partial batch_table
%   - config: configuration used
%   - timestamp: when checkpoint was saved

switch lower(action)
    case 'save'
        % Save checkpoint
        if nargin < 3
            error('checkpoint_manager: data required for save action');
        end
        data.checkpoint_timestamp = datetime('now');
        save(checkpoint_file, 'data', '-v7.3');
        
    case 'load'
        % Load checkpoint
        if exist(checkpoint_file, 'file')
            loaded = load(checkpoint_file);
            data = loaded.data;
        else
            data = [];
        end
        
    case 'delete'
        % Delete checkpoint
        if exist(checkpoint_file, 'file')
            delete(checkpoint_file);
        end
        
    case 'exists'
        % Check if checkpoint exists
        data = exist(checkpoint_file, 'file') == 2;
        
    otherwise
        error('checkpoint_manager: unknown action %s', action);
end

end

function v = getfield_or(s, path, default)
% GETFIELD_OR Get nested struct field with default fallback
%
% Usage:
%   value = getfield_or(struct, 'field', default)
%   value = getfield_or(struct, {'nested','field'}, default)
%
% Inputs:
%   s: struct to query
%   path: field name (string) or cell array of nested field names
%   default: default value if field doesn't exist
%
% Output:
%   v: field value if exists, otherwise default
%
% Examples:
%   config.io.outdir = 'out';
%   getfield_or(config, {'io','outdir'}, 'default')  % returns 'out'
%   getfield_or(config, {'io','missing'}, 'default') % returns 'default'

v = default;
try
    % Handle single string path
    if ischar(path) || isstring(path)
        if isstruct(s) && isfield(s, char(path))
            v = s.(char(path));
        end
        return;
    end
    
    % Handle cell array path (nested fields)
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

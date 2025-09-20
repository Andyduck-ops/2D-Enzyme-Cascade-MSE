function v = getfield_or(s, key, default)
% GETFIELD_OR Get field or nested field from structure, return default if not exists
% Usage:
%   v = getfield_or(s, 'field', default)
%   v = getfield_or(s, {'a','b','c'}, default)

v = default;
try
    % Single field name
    if ischar(key) || (isstring(key) && isscalar(key))
        k = char(key);
        if isstruct(s) && isfield(s, k)
            v = s.(k);
        end
        return;
    end

    % Nested path: cell string array
    for i = 1:numel(key)
        k = key{i};
        if isstring(k), k = char(k); end
        if isstruct(s) && isfield(s, k)
            s = s.(k);
        else
            v = default;
            return;
        end
    end
    v = s;
catch
    v = default;
end
end
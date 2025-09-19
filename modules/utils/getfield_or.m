function v = getfield_or(s, key, default)
% GETFIELD_OR 从结构体获取字段或嵌套字段, 不存在则返回默认值
% 用法:
%   v = getfield_or(s, 'field', default)
%   v = getfield_or(s, {'a','b','c'}, default)

v = default;
try
    % 单字段名
    if ischar(key) || (isstring(key) && isscalar(key))
        k = char(key);
        if isstruct(s) && isfield(s, k)
            v = s.(k);
        end
        return;
    end

    % 嵌套路径: 元胞字符串数组
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
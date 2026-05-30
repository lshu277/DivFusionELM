function s = set_default_field(s, fieldName, defaultValue)
%SET_DEFAULT_FIELD Set a default field value if it is missing or empty.

if ~isfield(s, fieldName) || isempty(s.(fieldName))
    s.(fieldName) = defaultValue;
end

end

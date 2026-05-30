function baseStruct = merge_structs(baseStruct, overrideStruct)
%MERGE_STRUCTS Recursively merge user-defined settings into default settings.
%
%   baseStruct = merge_structs(baseStruct, overrideStruct) overwrites fields
%   in baseStruct with fields from overrideStruct. Nested structures are
%   merged recursively.

if nargin < 2 || isempty(overrideStruct)
    return;
end

fieldNames = fieldnames(overrideStruct);
for i = 1:numel(fieldNames)
    name = fieldNames{i};
    if isstruct(overrideStruct.(name)) && isfield(baseStruct, name) && isstruct(baseStruct.(name))
        baseStruct.(name) = merge_structs(baseStruct.(name), overrideStruct.(name));
    else
        baseStruct.(name) = overrideStruct.(name);
    end
end

end

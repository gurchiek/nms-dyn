function child = inherit(parent,child,fields)

% returns child structure which is same as input child structure except
% that all fieldnames specified in fields (input cell array) will be 
% updated in child corresponding to their value in parent. if fields (input
% cell array) is empty then all fields in parent are given to the child. 
% If child has fields that the parent does not have then it keeps them.

if nargin == 2; fields = {}; end
if isempty(fields); fields = fieldnames(parent); end
for k = 1:length(fields); if isfield(parent,fields{k}); child.(fields{k}) = parent.(fields{k}); end; end

end
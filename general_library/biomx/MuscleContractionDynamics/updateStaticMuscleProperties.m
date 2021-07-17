function muscle = updateStaticMuscleProperties(muscle,properties,muscleNames)

% INPUTS
% muscle - nms muscle struct
% properties - struct with fields and values to give to each muscle
%               specified in muscleNames within the muscle struct
% muscleNames - cell array of muscle names to update, if empty or not given
% then all muscles updated

if nargin == 2; muscleNames = {}; end
if isempty(muscleNames); muscleNames = fieldnames(muscle); end

for m = 1:length(muscleNames)
    
    muscle.(muscleNames{m}) = inherit(properties,muscle.(muscleNames{m}));

end
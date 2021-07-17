function model = updateMuscleGroupings(model)

% muscle groupings are specified in model.muscleGroup.(groupType).(groupName) = {'muscle1','muscle2',...}
% each muscle also has a property which specifies what groups it belongs to model.muscle.muscle1.(groupType) = groupName
% groupType is different ways of grouping muscles, e.g. activationGroup,
% structuralGroup, functionalGroup, etc.
% this function updates the groupName for each groupType for each muscle
% specified in model.muscleGroup

% for each grouping type
grouping = fieldnames(model.muscleGroup);
for g = 1:length(grouping)
    
    % for each group
    group = fieldnames(model.muscleGroup.(grouping{g}));
    for k = 1:length(group)
        
        % for each muscle in the group
        muscles = model.muscleGroup.(grouping{g}).(group{k});
        for m = 1:length(muscles)
            
            % update within that muscle
            model.muscle.(muscles{m}).(grouping{g}) = group{k};
            
        end
        
    end
    
end

end
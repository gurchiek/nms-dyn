function [model,options] = updateOptimizedParameters(model,x,options)

% muscles
msc = options.muscles;

% is table (bayesopt)? if not then array (simulanneal)
tbl = istable(x);
if tbl
    tblVarNames = x.Properties.VariableNames;
end

% for each variable
n = length(options.optimizableParameters);
for i = 1:n
    
    % get value
    if tbl
        value = x.(tblVarNames{i});
    else
        value = x(i);
    end
    options.optimizableParameters(i).value = value;
    
    % details
    group1 = options.optimizableParameters(i).majorGroup;
    group2 = options.optimizableParameters(i).minorGroup;
    scalar = options.optimizableParameters(i).isScalar;
    fxn = options.optimizableParameters(i).isFunction;
    name = options.optimizableParameters(i).name;
    
    % for each muscle in group
    gmsc = options.muscleGroup.(group1).(group2);
    for m = 1:length(gmsc)
        
        % if muscle included in optimization
        if any(strcmp(gmsc{m},msc))
            
            % update
            if scalar
                model.muscle.(gmsc{m}).(name) = model.muscle.(gmsc{m}).(name) * value;
            elseif fxn
                model.muscle.(gmsc{m}).(name) = str2func(char(value));
            else
                model.muscle.(gmsc{m}).(name) = value;
            end
            
        end
        
    end
    
end
function options = mtuParameterSet_l2(options,init)

% 2 length params: optimal fiber length and tendon slack length

% results can be output from bayes ot

% name
options.parameterSetName = 'l2';

% structural group
structgrp = fieldnames(options.muscleGroup.structuralGroup);
i = 1;

% optimal fiber length scalar
for g = 1:length(structgrp)
    options.optimizableParameters(i).majorGroup = 'structuralGroup';
    options.optimizableParameters(i).minorGroup = structgrp{g};
    options.optimizableParameters(i).name = 'optimalFiberLength';
    options.optimizableParameters(i).isScalar = true;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [0.9 1.1];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

% tendon slack length scalar
for g = 1:length(structgrp)
    options.optimizableParameters(i).majorGroup = 'structuralGroup';
    options.optimizableParameters(i).minorGroup = structgrp{g};
    options.optimizableParameters(i).name = 'tendonSlackLength';
    options.optimizableParameters(i).isScalar = true;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [0.9 1.1];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

function options = mtuParameterSet_s1a4(options)

% naming format is:
%   majorGroup_minorGroup_variableName_scalar
% if variableName is a real number to be scaled by the optimizable variable
% or is:
%   majorGroup_minorGroup_variableName
% if variableName is to be replaced by the optimizable variable directly

% 1 strength param, 4 activation params, only function is nonlinearity (not
% optimizing dynamics)

% name
options.parameterSetName = 's1a4';

% strength and activation groups
strgrp = fieldnames(options.muscleGroup.strengthGroup);
actgrp = fieldnames(options.muscleGroup.activationGroup);
i = 1;

% maxForce scalar
for g = 1:length(strgrp)
    options.optimizableParameters(i).majorGroup = 'strengthGroup';
    options.optimizableParameters(i).minorGroup = strgrp{g};
    options.optimizableParameters(i).name = 'maxForce';
    options.optimizableParameters(i).isScalar = true;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [0.5 2.0];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

% activation time constant
for g = 1:length(actgrp)
    options.optimizableParameters(i).majorGroup = 'activationGroup';
    options.optimizableParameters(i).minorGroup = actgrp{g};
    options.optimizableParameters(i).name = 'activationTimeConstant';
    options.optimizableParameters(i).isScalar = false;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [0.01 0.06];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

% activationDeactivationRatio
for g = 1:length(actgrp)
    options.optimizableParameters(i).majorGroup = 'activationGroup';
    options.optimizableParameters(i).minorGroup = actgrp{g};
    options.optimizableParameters(i).name = 'activationDeactivationRatio';
    options.optimizableParameters(i).isScalar = false;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [0.25 1.0];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

% activation nonlinearity function
for g = 1:length(actgrp)
    options.optimizableParameters(i).majorGroup = 'activationGroup';
    options.optimizableParameters(i).minorGroup = actgrp{g};
    options.optimizableParameters(i).name = 'activationNonlinearityFunction';
    options.optimizableParameters(i).isScalar = false;
    options.optimizableParameters(i).isFunction = true;
    options.optimizableParameters(i).range = {'actnonlinAexp','actnonlinAc','actnonlinA'};
    options.optimizableParameters(i).type = 'categorical';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

% activation nonlinearity shape factor Aexp
for g = 1:length(actgrp)
    options.optimizableParameters(i).majorGroup = 'activationGroup';
    options.optimizableParameters(i).minorGroup = actgrp{g};
    options.optimizableParameters(i).name = 'activationNonlinearityShapeAexp';
    options.optimizableParameters(i).isScalar = false;
    options.optimizableParameters(i).isFunction = false;
    options.optimizableParameters(i).range = [-3 -1e-6];
    options.optimizableParameters(i).type = 'real';
    options.optimizableParameters(i).transform = 'none';
    options.optimizableParameters(i).abbreviation = ['v' num2str(i)];
    i = i + 1;
end

end
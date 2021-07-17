function [model,trial,evaluation,results,model0,options] = fminconModel(model,trial,options)

global mdl0 trl0 opt iter
iter = 0;

mdl0 = model;
trl0 = trial;
opt = options;

nvars = length(options.optimizableParameters);
x0 = zeros(nvars,1);
lb = x0;
ub = x0;
for v = 1:nvars
    x0(v) = options.optimizableParameters(v).value;
    lb(v) = options.optimizableParameters(v).range(1);
    ub(v) = options.optimizableParameters(v).range(2);
end

% simulated annealing
[x,fval,exitflag,output] = fmincon(@objectiveFunction,x0,[],[],[],[],lb,ub);
results.fval = fval;
results.exitflag = exitflag;
results.output = output;

% save old model
model0 = mdl0;
[model,options] = updateOptimizedParameters(model0,x,options);
evaluation = evaluateMuscleContractionSimulation(model,trial,options);

end

%% objective function

function obj = objectiveFunction(x)

global mdl0 trl0 opt eval

% update params
mdl = updateOptimizedParameters(mdl0,x,opt);

% evaluate
eval = evaluateMuscleContractionSimulation(mdl,trl0,opt);

% objective is average perf. metric across all trials/dof
obj = mean([eval.(opt.objectivePerformanceMetric)]);

end
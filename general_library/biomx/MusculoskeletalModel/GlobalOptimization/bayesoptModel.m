function [model,results,trial,evaluation,model0,options] = bayesoptModel(model,trial,options)

global mdl0 trl0 opt iter
iter = 0;

mdl0 = model;
trl0 = trial;
opt = options;

% for each variable
n = length(options.optimizableParameters);
x(1:n) = optimizableVariable;
for v = 1:n
    
    % convert to optimizable variable for bayesopt
    x(v) = optimizableVariable(options.optimizableParameters(v).abbreviation,...
                               options.optimizableParameters(v).range,...
                               'Type',options.optimizableParameters(v).type,...
                               'Transform',options.optimizableParameters(v).transform);
    
end

warning('off', 'MATLAB:table:ModifiedVarnamesLengthMax');

% bayesian optimization
results = bayesopt(@objectiveFunction,x,'IsObjectiveDeterministic',true,...
                                        'AcquisitionFunctionName',options.AcquisitionFunctionName,...
                                        'ExplorationRatio',options.ExplorationRatio(1),...
                                        'GPActiveSetSize',options.GPActiveSetSize,...
                                        'MaxObjectiveEvaluations',options.MaxObjectiveEvaluations(1),...
                                        'NumSeedPoints',options.NumSeedPoints,...
                                        'PlotFcn',{@printTorqueError},... % plotPrintTorqueError or printTorqueError or plotTorqueError
                                        'Verbose',0);

% multiple loops?
if length(options.ExplorationRatio) > 1
    if length(options.ExplorationRatio) ~= length(options.MaxObjectiveEvaluations)
        warning('User input multiple ExplorationRatio but this must be accompanied by equally as many MaxObjectiveEvaluations. Returning results from only the first ExplorationRatio.')
    else
        
        for k = 2:length(options.ExplorationRatio)

            results = resume(results,'ExplorationRatio',options.ExplorationRatio(k),'MaxObjectiveEvaluations',options.MaxObjectiveEvaluations(k));

        end
        
    end
end

% save old model
model0 = mdl0;
[model,options] = updateOptimizedParameters(model0,results.XAtMinObjective,options);

if nargout > 2
    [evaluation,trial] = evaluateMuscleContractionSimulation(model,trial,options);
end

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

%% plotting function

% plots torque errors associated with minimum objective and prints results
function stop = plotPrintTorqueError(results,state)

global eval iter opt

persistent h minobj minerror legendcell

colors = {'k','r','b','g','c','m'};

stop = false;
if iter == 0
    h = figure;
    minerror = struct();
    legendcell = cell(1,2*size(opt.dof,1));
    for k = 1:size(opt.dof,1)
        minerror(k).joint = opt.dof{k,1};
        minerror(k).dof = opt.dof{k,2};
        minerror(k).mae = [];
        minerror(k).rmse = [];
        legendcell{2*k-1} = [minerror(k).joint '-' minerror(k).dof '-' 'mae'];
        legendcell{2*k} = [minerror(k).joint '-' minerror(k).dof '-' 'rmse'];
    end
    minobj = inf;
    iter = iter + 1;
    fprintf('\n');
else
    if strcmp(state,'iteration')
        figure(h)
        if minobj > results.MinObjective
            minobj = results.MinObjective;
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).mae]);
                minerror(k).rmse(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).rmse]);
            end
        else
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = minerror(k).mae(end);
                minerror(k).rmse(end+1) = minerror(k).rmse(end);
            end
        end
        
        hold off
        plot(1:numel(minerror(1).mae),minerror(1).mae,colors{1})
        hold on
        plot(1:numel(minerror(1).mae),minerror(1).rmse,colors{1},'LineStyle','--')
        for k = 2:length(minerror)
            plot(1:numel(minerror(k).mae),minerror(k).mae,colors{k})
            plot(1:numel(minerror(k).mae),minerror(k).rmse,colors{k},'LineStyle','--')
        end
        ylabel('Torque Error (Nm)')
        xlabel('Iteration Number')
        title('EMG-driven Torque Estimation Performance')
        legend(legendcell)
        drawnow
        
        
        fprintf('Iteration: %d, Curr Objective: %6.3f, Min Objective: %6.3f (',iter,results.ObjectiveTrace(end),minobj)
        for k = 1:length(minerror)
            fprintf('%s-%s: %5.2f mae (%5.2f rmse), ',minerror(k).joint,minerror(k).dof,minerror(k).mae(end),minerror(k).rmse(end))
        end
        fprintf('\b\b)\n')
        iter = iter + 1;
    end
end

end

%% plotting function

% plots torque errors associated with minimum objective
function stop = plotTorqueError(results,state)

global eval iter opt

persistent h minobj minerror legendcell

colors = {'k','r','b','g','c','m'};

stop = false;
if iter == 0
    h = figure;
    minerror = struct();
    legendcell = cell(1,2*size(opt.dof,1));
    for k = 1:size(opt.dof,1)
        minerror(k).joint = opt.dof{k,1};
        minerror(k).dof = opt.dof{k,2};
        minerror(k).mae = [];
        minerror(k).rmse = [];
        legendcell{2*k-1} = [minerror(k).joint '-' minerror(k).dof '-' 'mae'];
        legendcell{2*k} = [minerror(k).joint '-' minerror(k).dof '-' 'rmse'];
    end
    minobj = inf;
    iter = iter + 1;
    fprintf('\n');
else
    if strcmp(state,'iteration')
        figure(h)
        if minobj > results.MinObjective
            minobj = results.MinObjective;
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).mae]);
                minerror(k).rmse(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).rmse]);
            end
        else
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = minerror(k).mae(end);
                minerror(k).rmse(end+1) = minerror(k).rmse(end);
            end
        end
        
        hold off
        plot(1:numel(minerror(1).mae),minerror(1).mae,colors{1})
        hold on
        plot(1:numel(minerror(1).mae),minerror(1).rmse,colors{1},'LineStyle','--')
        for k = 2:length(minerror)
            plot(1:numel(minerror(k).mae),minerror(k).mae,colors{k})
            plot(1:numel(minerror(k).mae),minerror(k).rmse,colors{k},'LineStyle','--')
        end
        ylabel('Torque Error (Nm)')
        xlabel('Iteration Number')
        title('EMG-driven Torque Estimation Performance')
        legend(legendcell)
        drawnow
        iter = iter + 1;
    end
end

end


%% plotting function

% prints torque errors associated with minimum objective
function stop = printTorqueError(results,state)

global eval iter opt

persistent minobj minerror 

stop = false;
if iter == 0
    minerror = struct();
    for k = 1:size(opt.dof,1)
        minerror(k).joint = opt.dof{k,1};
        minerror(k).dof = opt.dof{k,2};
        minerror(k).mae = [];
        minerror(k).rmse = [];
    end
    minobj = inf;
    iter = iter + 1;
    fprintf('\n');
else
    if strcmp(state,'iteration')
        if minobj > results.MinObjective
            minobj = results.MinObjective;
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).mae]);
                minerror(k).rmse(end+1) = mean([eval(strcmp({eval.joint},minerror(k).joint) & strcmp({eval.dof},minerror(k).dof)).rmse]);
            end
        else
            for k = 1:length(minerror)
                minerror(k).mae(end+1) = minerror(k).mae(end);
                minerror(k).rmse(end+1) = minerror(k).rmse(end);
            end
        end
        
        
        fprintf('Iteration: %d, Curr Objective: %6.3f, Min Objective: %6.3f (',iter,results.ObjectiveTrace(end),minobj)
        for k = 1:length(minerror)
            fprintf('%s-%s: %5.2f mae (%5.2f rmse), ',minerror(k).joint,minerror(k).dof,minerror(k).mae(end),minerror(k).rmse(end))
        end
        fprintf('\b\b)\n')
        iter = iter + 1;
    end
end

end
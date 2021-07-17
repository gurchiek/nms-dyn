%% SCRIPT 4 (option 1): global optimization of hill model parameters

% mtu parameter optimization using bayesopt
% calibration trials are walk_1 - walk_7
% stance phase only
% knee flexiom moment
% all muscles
% objective function is the mean square error normalized by variance
% parameter set s1a5
%   -maxForce: scales max force
%   -activationDynamics: function
%   -activationNonlinearity: function
%   -activationNonlinearityShapeFactor: parameter in act nonlinearity fxn
%   -activationTimeConstant: act dynamics parameter
%   -activationDeactivationRatio: act dynamics parameter

close all
clear
clc

% subject ID
subid = 'S0040';

% load calibrated model
load(replace(cd,'s4_mtu_parameter_identification',['nmsdyn_' subid '.mat']))

% update any muscle properties prior to optimization here
% e.g. set solver type to implicitIntegration or use algebraic (rigid tendon)
model.muscle = updateStaticMuscleProperties(model.muscle,struct('solverType','implicitIntegration'));

% parameter set
mtuOptimizationOptions = struct();
mtuOptimizationOptions.muscleGroup = model.muscleGroup;
mtuOptimizationOptions = mtuParameterSet_s1a5(mtuOptimizationOptions);

% bayesopt settings
mtuOptimizationOptions.NumSeedPoints = 4 * numel(mtuOptimizationOptions.optimizableParameters);
mtuOptimizationOptions.GPActiveSetSize = 300;
mtuOptimizationOptions.ExplorationRatio = 0.5; % can do array of multiple to fine tune (e.g. [0.5 0.4 0.3]
mtuOptimizationOptions.MaxObjectiveEvaluations = numel(mtuOptimizationOptions.optimizableParameters)^2;
mtuOptimizationOptions.AcquisitionFunctionName = 'expected-improvement-plus';

% trials, muscles, dof, objective
mtuOptimizationOptions.trials = {'walk_1','walk_2','walk_3','walk_4','walk_5','walk_6','walk_7'};
mtuOptimizationOptions.dof = {'right_knee','flexion'};
mtuOptimizationOptions.objectivePerformanceMetric = 'nmse_var'; % mean square error normalized by variance, this must be a metric returned in the evaluation struct of evaluateMuscleContractionSimulation
mtuOptimizationOptions.muscles = fieldnames(model.muscle); % all muscles

% contraction dynamics simulation options: analysis name (analysis
% containing mtu kinematics and muscle exctitations) and simulation time
% options
simulationOptions.analysisName = 'constrained';
simtimename = 'simulationTimeFullOMC';
for t = 1:length(mtuOptimizationOptions.trials)
    
    % name of time arrays for kinematics and excitations
    kintimename = trial.(mtuOptimizationOptions.trials{t}).(simulationOptions.analysisName).kinematicsTimeName; % associated with kinematics variables including mtu.length/velocity and muscle.momentArm
    exctimename = trial.(mtuOptimizationOptions.trials{t}).(simulationOptions.analysisName).excitationTimeName; % associated with muscle.excitation time-series
    
    % create simulation time array: force plate contact only (stance phase)
    kinTime = trial.(mtuOptimizationOptions.trials{t}).(kintimename);
    trial.(mtuOptimizationOptions.trials{t}).(simtimename) = kinTime(trial.(mtuOptimizationOptions.trials{t}).(simulationOptions.analysisName).events.footContact:trial.(mtuOptimizationOptions.trials{t}).(simulationOptions.analysisName).events.footOff);
    
    % create muscleContractionDynamics time struct
    time.mtuKinematics = trial.(mtuOptimizationOptions.trials{t}).(kintimename);
    time.excitation = trial.(mtuOptimizationOptions.trials{t}).(exctimename);
    time.simulation = trial.(mtuOptimizationOptions.trials{t}).(simtimename);
    
    % also include time array for inverse dynamics for comparing ID torque
    % during same time interval, this is needed for
    % evaluateMuscleContractionSimulation in bayesoptModel
    dyntimename = trial.(mtuOptimizationOptions.trials{t}).(simulationOptions.analysisName).dynamicsTimeName; 
    time.dynamics = trial.(mtuOptimizationOptions.trials{t}).(dyntimename);
    
    % store in options
    simulationOptions.trial.(mtuOptimizationOptions.trials{t}).time = time;
    
end

% store simulation options
mtuOptimizationOptions.simulationOptions = simulationOptions;

% save old model
% since some optimizableParameters scale the original model values, if ever
% want to continue tuning, then will need access to the original model
originalModel = model;

% optimize
[model,results,~,~,~,mutOptimizationOptions] = bayesoptModel(model,trial,mtuOptimizationOptions);

% store calibration details
model.mtuParameterOptimization(1).script = fullfile(cd,'optimize_mtu_parameters_s1a5.m');
model.mtuParameterOptimization(1).date = datetime;
model.mtuParameterOptimization(1).optimizationOptions = mtuOptimizationOptions;
model.mtuParameterOptimization(1).results = results;
model.mtuParameterOptimization(1).originalModel = originalModel;

beep

%% save

ok = questdlg('Save (will overwrite any existing)?','Save','Yes','No','Yes');
if ~isempty(ok)
    if ok(1) == 'Y'
        clearvars -except model session trial
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep

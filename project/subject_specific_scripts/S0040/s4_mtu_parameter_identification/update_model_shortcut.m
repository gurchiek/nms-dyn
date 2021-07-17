%% SCRIPT 4 (option 2): update model using optimized hill parameters

% optimal hill model parameters can be optimized using the
% optimize_mtu_parameters_s1a5 script. However, this can take a long time.
% The parameters for subject S0040 have already been optimized using the
% script. Run update_model_shortcut to update the model with the optimized
% parameters

close all
clear
clc

% subject ID
subid = 'S0040';

% load calibrated model
load(replace(cd,'s4_mtu_parameter_identification',['nmsdyn_' subid '.mat']))

% load the results from the optimization
load('S0040_hill_model_parameter_optimization.mat')

% update and save
model = updateOptimizedParameters(model,bayesoptResults.XAtMinObjective,mtuOptimizationOptions);
clearvars -except model session trial
save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))

beep
%% SCRIPT 2: inverse dynamics
% must have already run script 1
% this script computes inverse kinematics and dynamics using optical motion
% capture and force plate data

close all
clear
clc

% subject ID
subid = 'S0040';

% inverse dynamics is based on constrained inverse kinematics
% set the name for this analysis here
conAnalysisName = 'constrained';

% the constrained inverse kinematics is initialized with an unconstrained
% estimate, set name for this analysis here
uncAnalysisName = 'unconstrained';

% load calibrated model
load(replace(cd,'s2_inverse_dynamics',['nmsdyn_' subid '.mat']))

%%

% analyze movement
trialNames = fieldnames(trial);
for t = 1:length(trialNames)
    
    fprintf('\n')
    trial.(trialNames{t}) = analyzeMovement(model,trial.(trialNames{t}),session,conAnalysisName,uncAnalysisName);

    % get muscle excitations
    trial.(trialNames{t}) = getMuscleExcitations(model,trial.(trialNames{t}),conAnalysisName);
    
    % store name of time arrays
    trial.(trialNames{t}).(conAnalysisName).kinematicsTimeName = 'markerTime';
    trial.(trialNames{t}).(conAnalysisName).dynamicsTimeName = 'markerTime'; 
    trial.(trialNames{t}).(conAnalysisName).excitationTimeName = 'sensorTime';
    
end

beep

%% save

ok = questdlg('Save (will overwrite any existing)?','Save','Yes','No','Yes');
if ~isempty(ok)
    if ok(1) == 'Y'
        clearvars -except model session trial
        session.inverse_dynamics_date = datetime;
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep

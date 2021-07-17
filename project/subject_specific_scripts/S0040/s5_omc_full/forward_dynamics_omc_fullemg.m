%% SCRIPT 5: simulate muscle contraction using full set of emg and OMC
% simulates muscle contraction
% stance phase only: force plate foot contact to foot off
% all muscles
% knee flexion moment computed
% kinematics: optical motion capture
% emg set: full
% analysis name: omcfull

% changes are made to the following:
%   trial.(trialName).(simtimename): time array corresponding to this simulation
%   trial.(trialName).(analysisName): analysis corresponding to this simulation

close all
clear
clc

% subject ID
subid = 'S0040';

% analysis names
anl = 'omcfull';
kinematicsAnalysis = 'constrained';

% name given to simulation time array
simtimename = 'simulationTimeFullOMC';

% load calibrated model
load(replace(cd,'s5_omc_full',['nmsdyn_' subid '.mat']))

%% simulation

trialNames = fieldnames(trial);
for t = 1:length(trialNames)
    
    fprintf('-Trial %d/%d\n',t,length(trialNames))
    
    % get time array names
    kintimename = trial.(trialNames{t}).(kinematicsAnalysis).kinematicsTimeName; % associated with kinematics variables including mtu.length/velocity and muscle.momentArm
    exctimename = trial.(trialNames{t}).(kinematicsAnalysis).excitationTimeName; % associated with muscle.excitation time-series
    
    % create simulation time array: force plate contact only
    kinTime = trial.(trialNames{t}).(kintimename);
    trial.(trialNames{t}).(simtimename) = kinTime(trial.(trialNames{t}).(kinematicsAnalysis).events.footContact:trial.(trialNames{t}).(kinematicsAnalysis).events.footOff);
    
    % simulate muscle contraction dynamics
    time.mtuKinematics = trial.(trialNames{t}).(kintimename);
    time.excitation = trial.(trialNames{t}).(exctimename);
    time.simulation = trial.(trialNames{t}).(simtimename);
    trial.(trialNames{t}).(anl).body.muscle = muscleContractionDynamics(model,trial.(trialNames{t}).(kinematicsAnalysis).body.muscle,fieldnames(model.muscle),time);
    
    % sum to get total torque for knee and ankle flexion
    dof = {'right_knee','flexion'};
    trial.(trialNames{t}).(anl).body = sumMuscleTorques(trial.(trialNames{t}).(anl).body,fieldnames(model.muscle),dof);
    
    % store time array names
    trial.(trialNames{t}).(anl).time = time;
    trial.(trialNames{t}).(anl).kinematicsTimeName = kintimename;
    trial.(trialNames{t}).(anl).excitationTimeName = exctimename;
    trial.(trialNames{t}).(anl).simulationTimeName = simtimename;
    
end

beep

%% save

ok = questdlg('Save (will overwrite any existing)?','Save','Yes','No','Yes');
if ~isempty(ok)
    if ok(1) == 'Y'
        clearvars -except model session trial
        session.forward_dynamics_marker_fullemg_date = datetime;
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep

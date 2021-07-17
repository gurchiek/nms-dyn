%% SCRIPT 6: simulate muscle contraction using a three muscle subset of EMG, GP synergy model, and IMC
% simulates muscle contraction
% stance phase only: force plate foot contact to foot off
% all muscles
% knee flexion moment
% kinematics: imu
% emg set: subset (full set informed by synergp model)
% analysis name: imcgp

% changes are made to the following:
%   trial.(trialName).(simtimename): time array corresponding to this simulation
%   trial.(trialName).(analysisName): analysis corresponding to this simulation

close all
clear
clc

% subject ID
subid = 'S0040';

% analysis names
anl = 'imcgp';
kinematicsAnalysis = 'imc';

% name given to simulation time array
simtimename = 'simulationTimeSynergpIMU';

% gpml
ok = questdlg('You should have downloaded the GPML toolbox (see README). When prompted, choose the folder containing the GPML code.','GPML Path','OK','OK');
if isempty(ok)
    error('script terminated');
else
    addpath(uigetdir);
end
startup;

% load synergy model
load('synergpSession_S0040_15-Feb-2021.mat')
syngp = session;
clear session

% load calibrated model
load(replace(cd,fullfile('s6_imc_gp'),['nmsdyn_' subid '.mat']))

% this pipeline works by replacing the measured emg data in
% trial.emg with the syergp model estimtes and then assigning the
% excitation values to each muscle in
% trial.(anlaysisName).muscle.excitation
% so in order to keep the true measured emgs in the input trial struct we
% will first copy it to trial0 and then trial0 will be manipulated
% throughout after which trial0.emdSynergpOMC will be copied to
% trial.emdSynergpOMC and the latter will have all analysis driven by the
% synergp model emg estimates and OMC kinematics but the trial.emg will be
% the original measured values
trial0 = trial;

% unpack
gpModel = syngp.model(1).gpModel;
X = syngp.model(1).trainingSet.X;
Y = syngp.model(1).trainingSet.Y;
inputStructure = syngp.model(1).inputStructure;
inmsc = inputStructure.predictorMuscles;
outmsc = {syngp.model(1).subject.muscle.name};
sf = inputStructure.samplingFrequency;
winsamp = round(sf/1000 * inputStructure.windowSize_ms);
relsamp = round(sf/1000 * inputStructure.windowRelativeOutputTime_ms);

% trials to evaluate
trialNames = fieldnames(trial);
for t = 1:length(trialNames)
    
    fprintf('-Trial %d/%d\n',t,length(trialNames))

    % indices of specified window
    ndata = length(trial0.(trialNames{t}).emg.locations.(inmsc{1}).elec.data);
    
    % indices in actual EMG that will be predicted for
    outputIndices = winsamp - relsamp:ndata - relsamp;

    % how many observations will there be
    nobs = ndata - winsamp + 1;

    % for each observation
    Xstar = zeros(nobs,winsamp * length(inmsc));
    for iobs = 1:nobs

        % get indices of input window
        window = iobs:iobs + winsamp - 1;

        % get index of output sample
        outsamp = window(end) - relsamp;

        % for each predictor muscle
        for m = 1:length(inmsc)

            % get input muscle data
            Xstar(iobs,winsamp*(m-1)+1:winsamp*m) = trial0.(trialNames{t}).emg.locations.(inmsc{m}).elec.data(window);

        end
        
    end
    
    % for each output muscle
    fprintf('     -estimating unmeasured muscle excitations\n')
    for m = 1:length(outmsc)
        
        % gp model
        hyp = syngp.model(1).subject.muscle(m).optimization(end).hyperparameters;
        
        % estimate
        emg_est = gp(hyp,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,X,Y(:,m),Xstar)';
        
        % actual emg
        emg_true = trial0.(trialNames{t}).emg.locations.(outmsc{m}).elec.data(outputIndices);
        
        % evaluate
        trial0.(trialNames{t}).(anl).synergpEvaluation(m).muscle = outmsc{m};
        trial0.(trialNames{t}).(anl).synergpEvaluation(m).rmse = rms(emg_est-emg_true);
        trial0.(trialNames{t}).(anl).synergpEvaluation(m).mae = mean(abs(emg_est-emg_true));
        trial0.(trialNames{t}).(anl).synergpEvaluation(m).correlation = corr(emg_true',emg_est');
        
        % store data
        trial0.(trialNames{t}).emg.locations.(outmsc{m}).elec.data(outputIndices) = emg_est;
        trial0.(trialNames{t}).emg.locations.(outmsc{m}).elec.data(1:outputIndices(1)) = hyp.mean; % output time falls within middle of input window so cant estimate for the first half input window, instead use gp model mean
        trial0.(trialNames{t}).emg.locations.(outmsc{m}).elec.data(outputIndices(end):end) = hyp.mean; % output time falls within middle of input window so cant estimate for the last half input window, instead use gp model mean
        
    end

    % get muscle excitations
    trial0.(trialNames{t}) = getMuscleExcitations(model,trial0.(trialNames{t}),kinematicsAnalysis);
    
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
    fprintf('     -simulating contraction dynamics\n')
    trial0.(trialNames{t}).(anl).body.muscle = muscleContractionDynamics(model,trial0.(trialNames{t}).(kinematicsAnalysis).body.muscle,fieldnames(model.muscle),time);
    
    % sum to get total torque for knee and ankle flexion
    dof = {'right_knee','flexion'};
    trial0.(trialNames{t}).(anl).body = sumMuscleTorques(trial0.(trialNames{t}).(anl).body,fieldnames(model.muscle),dof);
    
    % store in trial
    trial.(trialNames{t}).(anl) = trial0.(trialNames{t}).(anl);
    
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
        session.forward_dynamics_imu_synergp_3muscle_date = datetime;
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep
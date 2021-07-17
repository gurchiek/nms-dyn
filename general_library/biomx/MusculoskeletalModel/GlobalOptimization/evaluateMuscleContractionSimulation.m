function [evaluation,trial] = evaluateMuscleContractionSimulation(model,trial,options)

% options: 
%   trials: cell array of trial names
%   simulationOptions.analysisName: analysis containing mtu kinematics and muscle excitations in trial.(trialName).(analysisName).body
%   simulationOptions.(trialName).time: time struct input to muscleContractionDynamics; one for each trial in options.trials
%   muscles: cell array of muscle names
%   dof: cell array of dofs, see sumMuscleTorques function

% for each trial
trialNames = options.trials;
evaluation(length(trialNames)) = struct();
anl = options.simulationOptions.analysisName;
i = 1;
for t = 1:length(trialNames)
    
    % simulate contraction dynamics
    trial.(trialNames{t}).(anl).body.muscle = muscleContractionDynamics(model,trial.(trialNames{t}).(anl).body.muscle,options.muscles,options.simulationOptions.trial.(trialNames{t}).time);
    
    % sum muscle torques
    trial.(trialNames{t}).(anl).body = sumMuscleTorques(trial.(trialNames{t}).(anl).body,options.muscles,options.dof);
    
    % for each degree of freedom
    for d = 1:size(options.dof,1)
        
        % eval details
        evaluation(i).trialName = trialNames{t};
        evaluation(i).joint = options.dof{d,1};
        evaluation(i).dof = options.dof{d,2};
        
        % get inverse dynamics torque
        trq = trial.(trialNames{t}).(anl).body.joint.(options.dof{d,1}).(options.dof{d,2}).torque;
        
        % get ID torque for corresponding simulation time array (ID time is
        % same as mtu kinematics time)
        trq = interp1(options.simulationOptions.trial.(trialNames{t}).time.dynamics,trq,options.simulationOptions.trial.(trialNames{t}).time.simulation,'pchip');
        
        % get emdtorque (synchronized with time.simulation)
        etrq = trial.(trialNames{t}).(anl).body.joint.(options.dof{d,1}).(options.dof{d,2}).emdtorque;
        
        % store
        evaluation(i).torque = trq;
        evaluation(i).emdtorque = etrq;
        
        % characterize error
        err = trq - etrq;
        mse = mean(err.^2);
        rmse = sqrt(mse);
        mae = mean(abs(err));
        sd = std(trq);
        rng = max(trq) - min(trq);
        vr = var(trq);
        
        evaluation(i).mse = mse;
        evaluation(i).nmse_var = mse / vr;
        
        evaluation(i).rmse = rmse;
        evaluation(i).nrmse_sd = rmse / sd;
        evaluation(i).nrmse_range = rmse / rng;
        
        evaluation(i).mae =  mae;
        evaluation(i).nmae_sd = mae / sd;
        evaluation(i).nmae_range = mae / rng;
        
        evaluation(i).correlation = corr(etrq',trq');
        evaluation(i).vaf = 1 - sum(err.^2) / sum(trq.^2);
        
        i = i + 1;
        
    end
    
end

end
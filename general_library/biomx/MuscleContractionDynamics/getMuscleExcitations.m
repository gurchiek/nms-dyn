function trial = getMuscleExcitations(model,trial,analysisName)

% loops through all muscles and assigns to each muscle's excitation state
% the average emg envelope for all emg sensors associated to this muscle
% (in muscle.(muscleName).emg.names  = {'muscle1','muscle2'}). Thus, the
% emg data need already be imported for this trial and processed (ie
% excitations computed).

% INPUTS
% model - nms model struct
% trial - nms trial.(trialName) struct
% analysisName - analysis name within which is muscle struct wherein
% excitations are moved

% for each muscle
mnames = fieldnames(model.muscle);
n = length(trial.sensorTime);
for m = 1:length(mnames)
    
    % get excitation data
    enames = model.muscle.(mnames{m}).emg.names;
    nm = length(enames);
    exc = zeros(1,n);
    for e = 1:nm
        exc = exc + 1/nm * trial.emg.locations.(enames{e}).elec.data;
    end
    trial.(analysisName).body.muscle.(mnames{m}).excitation = exc;
    
end
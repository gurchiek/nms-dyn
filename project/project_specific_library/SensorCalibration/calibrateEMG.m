function [model,session] = calibrateEMG(model,session,options)

% reads in all emg data for all calibration trials, computes amplitudes
% (excitations), then normalizes by the maximum across all trials (muscle
% specific)

% unpack import options
dataImport = session.dataImport;

% import calibration data
importOptions = dataImport.emg.options;
importOptions.trialNames = options.trialNames;
importOptions.locations = options.locations;
importOptions.renameTrials = options.renameTrials;
importOptions.resample = options.resample;
fprintf('-importing emg data\n')
data = dataImport.emg.importer(importOptions);

%% PROCESS
        
% for each emg location
trialNames = fieldnames(data.trials);
locations = fieldnames(data.trials.(trialNames{1}).locations);
for m = 1:length(locations)

    % keep track of largest emg value for normalization later
    normalization_constant.value = 0;
    normalization_constant.trial = '';

    % for each trial
    for t = 1:length(trialNames)

        % get sampling frequency
        sf = data.trials.(trialNames{t}).locations.(locations{m}).elec.samplingFrequency;

        % get amplitudes
        e = data.trials.(trialNames{t}).locations.(locations{m}).elec.data;
        e = options.processor(e,sf,options.processorOptions);

        % normalization constant
        if max(e) > normalization_constant.value
            normalization_constant.value = max(e); 
            normalization_constant.trial = trialNames{t};
        end

        % store processed data (excitations)
        data.trials.(trialNames{t}).locations.(locations{m}).elec.data = e;

    end

    % for each trial
    if ~isempty(normalization_constant.trial)
        for t = 1:length(trialNames)

            if isfield(data.trials.(trialNames{t}).locations.(locations{m}),'elec')

                % normalize
                data.trials.(trialNames{t}).locations.(locations{m}).elec.data = data.trials.(trialNames{t}).locations.(locations{m}).elec.data / normalization_constant.value;

                % store
                data.trials.(trialNames{t}).locations.(locations{m}).elec.normalization_constant = normalization_constant;

                % downsample?
                if isfield(options,'downsample')

                    if options.downsample > 0

                        old_time = data.trials.(trialNames{t}).locations.(locations{m}).elec.time;
                        new_time = old_time(1):1/options.downsample:old_time(end);
                        data.trials.(trialNames{t}).locations.(locations{m}).elec.samplingFrequency = options.downsample;
                        data.trials.(trialNames{t}).locations.(locations{m}).elec.time = new_time;
                        data.trials.(trialNames{t}).locations.(locations{m}).elec.postProcessor_samplingFrequency = options.downsample;
                        data.trials.(trialNames{t}).locations.(locations{m}).elec.data = interp1(old_time,data.trials.(trialNames{t}).locations.(locations{m}).elec.data,new_time,'pchip');

                    end

                end
                
                % save in session trial data or model calibration data
                if isfield(session.trial,trialNames{t})
                    session.trial.(trialNames{t}).emg = data.trials.(trialNames{t});
                else
                    model.calibrationData.trials.(trialNames{t}).emg = data.trials.(trialNames{t});
                end
                
            end
            
        end
        
    end

end

end
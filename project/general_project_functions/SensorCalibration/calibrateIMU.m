function [model,session] = calibrateIMU(model,session,options)

% calibrates and time-synchronizes IMU data. Time synchronization assumes
% certain project structure (is less general purpose)

% uses static trial to compute:
%   (1) direction of gravity in accelerometer frame: model.accelerometer.(accelName).meanMagnitude
%   (2) standard deviation of accelerometer magnitude: model.accelerometer.(accelName).magnitudeStandardDeviation
%   (3) average accelerometer magnitude (for normalization): model.accelerometer.(accelName).meanMagnitude
%   (4) gyro bias: model.gyroscope.(gyroName).bias
%   (5) axis specific gyro standard deviation: model.gyroscope.(gyroName).standardDeviation
%   (6) standard deviation of gyroscope magnitude: model.gyroscope.(gyroName).magnitudeStandardDeviation

% for all trials in session, data is imported from apdm, accelerometer, and
% gyroscope, (emg data should be already stored and processed for each
% trial)
% all mc10 (accel, gyro, emg) data are time synchronized with apdm data
% (digital synchronization using xcorr and apdm/mc10 shank gyro signals)

% all sensor data correspond with the time array
% session.trial.(trialName).sensorTime which is synchronized with APDM
% timestamps. APDM is synchronized with vicon (same trigger)

dataImport = session.dataImport;

% import accel calibration data
importOptions = dataImport.accel.options;
importOptions.trialNames = options.trialName;
importOptions.renameTrials = options.renameTrial;
importOptions.resample = options.resample;
fprintf('-importing accel data\n')
acc = dataImport.accel.importer(importOptions);
accsf = importOptions.resample;

% import gyro calibration data
importOptions = dataImport.gyro.options;
importOptions.trialNames = options.trialName;
importOptions.renameTrials = options.renameTrial;
importOptions.resample = options.resample;
fprintf('-importing gyro data\n')
gyro = dataImport.gyro.importer(importOptions);
gyrosf = importOptions.resample;

% handle multiple static trials (use latest)
readtrials = fieldnames(gyro.trials);
staticind = find(contains(readtrials,'static')); % indices of trialnames with static in name
if isempty(staticind)
    error('No static trials.')
elseif length(staticind) > 1
    statictrials = readtrials(staticind); % all trialnames with static in name
    staticnum = zeros(1,length(staticind));
    for k = 1:length(staticind)
        staticnum(k) = str2double(replace(statictrials{k},'static_','')); % get number associated with trialname (e.g., static_1, static_2, ...)
    end
    [~,ilateststatic] = max(staticnum); % get number of latest
    
    % replace name of latest with static
    gyro.trials.static = gyro.trials.(statictrials{ilateststatic});
    acc.trials.static = acc.trials.(statictrials{ilateststatic});
    
    % remove others
    gyro.trials = rmfield(gyro.trials,statictrials);
    acc.trials = rmfield(acc.trials,statictrials);
    
end

% nsamples for static
nstill = round(options.resample * options.nStillSeconds);

% initialize
gloc = fieldnames(gyro.trials.static.locations);
aloc = fieldnames(acc.trials.static.locations);
data = zeros(3*(length(gloc)+length(aloc)),size(acc.trials.static.locations.(aloc{1}).accel.data,2));

% get static data
i = 1:3;
for l = 1:length(gloc)
    
    data(i,:) = gyro.trials.static.locations.(gloc{l}).gyro.data;
    i = i(end)+1:i(end)+3;
    
end
for l = 1:length(aloc)
    
    data(i,:) = acc.trials.static.locations.(aloc{l}).accel.data;
    i = i(end)+1:i(end)+3;
    
end

% get static indices
istill = staticndx(data,nstill);

% for each gyro location
for l = 1:length(gloc)
    
    % calibration params
    model.gyroscope.(gloc{l}).bias = mean(gyro.trials.static.locations.(gloc{l}).gyro.data(:,istill(1):istill(2)),2);
    model.gyroscope.(gloc{l}).standardDeviation = std(gyro.trials.static.locations.(gloc{l}).gyro.data(:,istill(1):istill(2)),0,2);
    model.gyroscope.(gloc{l}).magnitudeStandardDeviation = std(vecnorm(gyro.trials.static.locations.(gloc{l}).gyro.data(:,istill(1):istill(2)),2));
    
end

% for each accel location
for l = 1:length(aloc)
    
    % calibration params
    model.accelerometer.(aloc{l}).meanMagnitude = mean(vecnorm(acc.trials.static.locations.(aloc{l}).accel.data(:,istill(1):istill(2))));
    model.accelerometer.(aloc{l}).magnitudeStandardDeviation = std(vecnorm(acc.trials.static.locations.(aloc{l}).accel.data(:,istill(1):istill(2)),2));
    model.accelerometer.(aloc{l}).meanDirection = normc(mean(acc.trials.static.locations.(aloc{l}).accel.data(:,istill(1):istill(2)),2));
    
end

%% if ever going to separate true IMU cal that requires only static trial data, separation point is here, this section syncs with APDM (assumes certain project structure, etc.)

% import apdm movement data
importOptions = dataImport.apdm.options;
fprintf('-importing apdm data\n')
apdm = dataImport.apdm.importer(importOptions);
apdmsf = importOptions.resample;

% for each trial
trialNames = fieldnames(apdm.trials);
for t = 1:length(trialNames)
    
    % synchronize with mc10 with apdm using shank gyro
    s1 = bwfilt(vecnorm(apdm.trials.(trialNames{t}).locations.right_shank.gyro.data),3,apdmsf,'low',4);
    s2 = bwfilt(vecnorm(gyro.trials.(trialNames{t}).locations.distal_lateral_shank_right.gyro.data),3,gyrosf,'low',4);
    n1 = 2^floor(log2(length(s1)));
    s1 = s1(1:n1);
    n2 = 2^floor(log2(length(s2)));
    s2 = s2(1:n2);
    if n1 > n2
        s1 = s1(1:n2);
    elseif n2 > n1
        s2 = s2(1:n1);
    end
    
    % get delay
    [crosscorr,delay] = xcorr(s2,s1);
    [~,imaxcrosscorr] = max(crosscorr);
    delay = delay(imaxcrosscorr)/100;
    if abs(delay) > 1.0
        plot(s1)
        hold on
        plot(s2)
        error('delay larger than one second, double check synchronization')
    end
    
    % get shank time array
    session.trial.(trialNames{t}).sensorDelay = delay;
    sensorTime = gyro.trials.(trialNames{t}).locations.distal_lateral_shank_right.gyro.time;
    
    % for each acc location
    for l = 1:length(aloc)
        
        % store data with shank gyro time array
        old_time = acc.trials.(trialNames{t}).locations.(aloc{l}).accel.time;
        old_data = acc.trials.(trialNames{t}).locations.(aloc{l}).accel.data;
        session.trial.(trialNames{t}).accelerometer.locations.(aloc{l}).accel.data = interp1(old_time,old_data',sensorTime','pchip')';
        
    end
    
    % for each gyro location
    for l = 1:length(gloc)
        
        % store data with shank gyro time array
        old_time = gyro.trials.(trialNames{t}).locations.(gloc{l}).gyro.time;
        old_data = gyro.trials.(trialNames{t}).locations.(gloc{l}).gyro.data;
        session.trial.(trialNames{t}).gyroscope.locations.(gloc{l}).gyro.data = interp1(old_time,old_data',sensorTime','pchip')';
        
    end
    
    % for each emg location
    eloc = fieldnames(session.trial.(trialNames{t}).emg.locations);
    for l = 1:length(eloc)
        
        % store data with shank gyro time array
        old_time = session.trial.(trialNames{t}).emg.locations.(eloc{l}).elec.time;
        old_data = session.trial.(trialNames{t}).emg.locations.(eloc{l}).elec.data;
        session.trial.(trialNames{t}).emg.locations.(eloc{l}).elec.data = interp1(old_time,old_data',sensorTime','pchip')';
        session.trial.(trialNames{t}).emg.locations.(eloc{l}).elec = rmfield(session.trial.(trialNames{t}).emg.locations.(eloc{l}).elec,'time');
        
    end
    
    % store synchronized sensor time
    sensorTime = sensorTime - sensorTime(1) - delay;
    session.trial.(trialNames{t}).sensorTime = sensorTime;
    
%     % to check, uncomment this
%     plot(sensorTime,bwfilt(vecnorm(gyro.trials.(trialNames{t}).locations.distal_lateral_shank_right.gyro.data),3,gyrosf,'low',4))
%     hold on
%     apdmtime = apdm.trials.(trialNames{t}).locations.right_shank.gyro.time;
%     apdmtime = apdmtime - apdmtime(1);
%     plot(apdmtime,bwfilt(vecnorm(apdm.trials.(trialNames{t}).locations.right_shank.gyro.data),3,apdmsf,'low',4))


end


end
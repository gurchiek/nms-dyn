function [ data ] = importMC10x(importOptions)
%Reed Gurchiek, 2019, reed.gurchiek@uvm.edu
%   imports MC10 data from directory after data has been exported using
%   exportMC10
%
%   all imported data are synced and resampled to a uniform grid at a 
%   sampling frequency dependent on the resample option (see INPUTS). If
%   two datapoints have the same timestamp, then the first datapoint is
%   kept and the other removed
%
%---------------------------INPUTS-----------------------------------------
%
%   importOptions:

%       (1) dataDirectory:
%               -string specifying data directory, should contain only 
%                   annotations.csv file and EXPORTED .csv files from
%                   exportMC10
%
%       (2) trialNames (default: allTrials):
%           -cell with names of trials (activities) to import 
%           -these correspond to csv file names as per x.x.trialname.x.csv
%           -if importing all data assigned a trial name then 'allTrials'
%           -if importing all data from recording then 'allData'
%               -this includes 'interval' data
%               -data from all trials in this case will be concatenated 
%                as a single trial called 'all'
%           -use *trialName* to import all trials whose trial name contains
%               trialName
%               -e.g. to import t_1 and t_2 one could use:
%                   -importOptions.trialNames = {'t_1','t_2'}
%                               OR
%                   -importOptions.trialNames = 't*';
%
%               -e.g. to import walk_fast and walk_slow one could use
%                   -importOptions.trialNames = {'walk_slow','walk_fast'}
%                               OR
%                   -importOptions.trialNames = 'walk*';
%               
%               -e.g. to import all trials that have walk in the name use
%                   -importOptions.trialNames = '*walk*'
%
%       (3) locationNames (default: all):
%           -cell with names of sensor locations.  
%           -if all then 'all'
%
%       (4) sensorNames (default: all):
%           -cell with sensor names to keep.  
%           -if all then 'all'
%           -acceptable sensor names:
%               (1) 'accel'
%               (2) 'gyro'
%               (3) 'elec'
%
%       (5) resample (default: mc10):
%           -if 'high' then resamples all data to highest sf of all sensors
%           -if 'low' then resamples all data to lowest sf of all sensors
%           -if x then resamples all data to x
%           -if 'mean' then resamples to each sensor's mean frequency
%           -if 'mc10' then resamples to user-set sf in mc10 study
%                   -e.g. if mean sf is 34 Hz, then resamples to 31.25 Hz
%           -if 'mc10high' then resamples to the highest sf set by user in
%               mc10 study design across all sensors
%                   -e.g. if mean emg sf = 501.3 Hz and mean acc sf = 30 Hz,
%                   then all emg and acc data resampled to 500 Hz
%           -if 'mc10low' then resamples to the lowest sf set by user in
%               mc10 study design across all sensors
%           -if resample = 0, then data are not resampled nor synced
%           
%       (6-8) resampleAccel, resampleGyro, resampleElec:
%           -use this to resample individual sensors to specific sf
%           -for this use either x, 'mean', or 'mc10'
%
%       (9) storeSameTrials (default: appendField):
%           -if 'appendName' then multiple trials of same activity will have
%               the trial number appended 
%                   -e.g. trial.walk_01.start, trial.walk_02.start, etc.
%           -if 'appendField' then multiple trials of same activity will be 
%               added as an additional field element
%                   -e.g. trial.walk(1).start, trial.walk(2).start, etc.
%           -if 'first' then only the first activity of this type is
%               imported
%           -if 'last' then only the last activity of this type is imported
%
%       (10) renameTrials (default: 'none')
%           -if 'none' then renames no trials
%           -if cell then should be an n x 2 cell with first column
%               containing the oldNames which will be changed to the
%               newNames in the second column.
%                   -e.g. to change trial_1 to newTrial use:
%                       importOptions.renameTrials = {'trial_1','newTrial'}
%               -can also use wild cards to replace certain parts of trial
%               names
%                   -e.g. to change walk_fast and walk_slow to w_fast and
%                       w_slow use:
%                       importOptions.renameTrials = {'*walk','w'}
%                           -note: this would replace 'walk' with 'w' in
%                           ALL trials that contains 'walk' in the name
%
%       (10) reportStatus (default: 0):
%           -flag to update (1) or not (0) status of import to command
%            window
%
%       (11) renameLocations (default: 'none')
%           -if 'none' then renames no locations
%           -if cell then should be an n x 2 cell with first column
%               containing the oldNames which will be changed to the
%               newNames in the second column.
%                   -e.g. to change loc_1 to newloc use:
%                       importOptions.renameLocations = {'loc_1','newloc'}
%
% 	-example: to make the accelerometer resample to the mean acc sf, the
%           gyro resample to 100 Hz, and emg resample to the sf set by user
%           in mc10 study, for the left/right rectus femoris, all trials, 
%           and report import status then set:
%   
%   importOptions.trialNames = 'allTrials';
%   importOptions.sensorLocations = {'rectus_femoris_right','rectus_femoris_left'}
%   importOptions.sensorNames = 'all';
%   importOptions.resampleAccel = 'mean';
%   importOptions.resampleGyro = 100;
%   importOptions.resampleElec = 'mc10';
%   importOptions.reportStatus = 1;
%
%   data = importMC10(importOptions);
%
%--------------------------OUTPUTS-----------------------------------------
%
%   data:
%       -output struct organized as follows:
%
%           data.
%                directory
%                trials.
%                       trialName.
%                                 start_timestamp
%                                 end_timestamp
%                                 locations.
%                                           locationName.
%                                                        sensorName.
%                                                                   time
%                                                                   data
%                                                                   samplingFrequency
%
%--------------------------------------------------------------------------
%% importMC10x

% set option defaults
sense = {'accel' 'gyro' 'elec'};
option = ...
    struct('dataDirectory','',...
           'trialNames','allTrials',...
           'locationNames','all',...
           'sensorNames','all',...
           'storeSameTrials','appendField',...
           'resampleAccel','mc10',...
           'resampleGyro','mc10',...
           'resampleElec','mc10',...
           'renameTrials','none',...
           'renameLocations','none',...
           'reportStatus',0);

% initialize flags
resampleFlag = 1;
renameTrialsFlag = 0;

% update if given
if nargin > 0
    
    % correct potential naming errors: dataDirectory
    potential_fields = {'dataDirectory','dir','path','directory','folder'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.dataDirectory = importOptions.(potential_fields{ifield(1)}); end

    % correct potential naming errors: sensorNames
    potential_fields = {'sensorNames','sensors','sensor','sensorName'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.sensorNames = importOptions.(potential_fields{ifield(1)}); end

    % correct potential naming errors: locationNames
    potential_fields = {'locationNames','sensorLocations','locations','location','locationName','sensorLocation','muscles','muscleNames','muscle','muscleName','segment','segments','segmentName','segmentNames'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.locationNames = importOptions.(potential_fields{ifield(1)}); end

    % correct potential naming errors: storeSameTrials
    potential_fields = {'storeSameTrials','storeSameActivities','sameActivites','sameTrials','importSameTrials','importSameActivities'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.storeSameTrials = importOptions.(potential_fields{ifield(1)}); end

    % correct potential naming errors: trialNames
    potential_fields = {'trialNames','activityNames','activities','trials','activity','trial'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.trialNames = importOptions.(potential_fields{ifield(1)}); end

    % correct potential naming errors: reportStatus
    potential_fields = {'reportStatus','report','status'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.reportStatus = importOptions.(potential_fields{ifield(1)}); end
    
    % correct potential naming errors: renameTrials
    potential_fields = {'renameTrials','renameTrial','renameActivity','renameActivities'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.renameTrials = importOptions.(potential_fields{ifield(1)}); end
    
    % correct potential naming errors: renameLocations
    potential_fields = {'renameLocations','renameLocation','renameMuscle','renameMuscles','renameSegment','renameSegments'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.renameLocations = importOptions.(potential_fields{ifield(1)}); end

    % update sensor specific resample option if global resample given
    if isfield(importOptions,'resample')
        
        % set resampleFlag if user requesting no resample
        if isa(importOptions.resample,'double')
            if importOptions.resample == 0
                resampleFlag = 0;
            end
        elseif isa(importOptions.resample,'logical')
            if importOptions.resample == false
                resampleFlag = 0;
            end
        end
        
        % get resample request if applicable
        if resampleFlag
            for s = 1:3
                option.(['resample' cap(sense{s})]) = importOptions.resample;
            end
        end

    else

        % correct potential naming errors: resampleAccel
        potential_fields = {'resampleAccel','resample_Accel','resampleACC','resample_accel','resample_acc','resample_Acc'};
        has_field = isfield(importOptions,potential_fields);
        ifield = find(has_field);
        if any(has_field); option.resampleAccel = importOptions.(potential_fields{ifield(1)}); end

        % correct potential naming errors: resampleGyro
        potential_fields = {'resampleGyro','resample_Gyro','resampleGYRO','resample_gyro','resample','resample_Gyro'};
        has_field = isfield(importOptions,potential_fields);
        ifield = find(has_field);
        if any(has_field); option.resampleGyro = importOptions.(potential_fields{ifield(1)}); end

        % correct potential naming errors: resampleElec
        potential_fields = {'resampleElec','resample_Elec','resampleEMG','resampleECG','resample_elec','resample_EMG','resample_emg','resampleECG','resample_ecg','resample_ECG'};
        has_field = isfield(importOptions,potential_fields);
        ifield = find(has_field);
        if any(has_field); option.resampleElec = importOptions.(potential_fields{ifield(1)}); end
    end
end

% get data directory
if isempty(option.dataDirectory)
    ok = questdlg('Select MC10 directory containing exported .csv sensor data files','Data Directory','OK',{'OK'});
    if isempty(ok)
        error('Importing Terminated')
    else
        option.dataDirectory = uigetdir;
        if option.dataDirectory == 0
            error('Importing Terminated')
        end
    end
end

% intialize data struct
data.directory = option.dataDirectory;

%% HANDLE 'all' NAMING OPTIONS

% SENSOR NAMES
if isa(option.sensorNames,'char')
    
    % if contains 'all' then make cell with all names
    if contains(option.sensorNames,'all','IgnoreCase',true)
        option.sensorNames = {'accel','elec','gyro'};
        
    % otherwise make requested sensor a cell element
    elseif any(strcmpi(option.sensorNames,{'acc','accel','accelerometer'}))
        option.sensorNames = {'accel'};
    elseif any(strcmpi(option.sensorNames,{'gyro','gyroscope'}))
        option.sensorNames = {'gyro'};
    elseif any(strcmpi(option.sensorNames,{'imu','inertial','inertial_sensor','inertialSensor','inertialMeasurementUnit','IMU'}))
        option.sensorNames = {'accel','gyro'};
    elseif any(strcmpi(option.sensorNames,{'elec','emg','ecg','ekg','electromyography','semg','EMG','sEMG'}))
        option.sensorNames = {'elec'};
    else
        error('Unrecognized user requested sensorName')
    end
end

% LOCATION NAMES
if isa(option.locationNames,'char')
    
    % if contains 'all' then make cell with all names
    if contains(option.locationNames,'all','IgnoreCase',true)
        
        % get file names
        option.locationNames = dir(fullfile(data.directory,'f*.*.*.*.*.csv'));
        option.locationNames = {option.locationNames.name};
        
        % for each file name
        for n = 1:numel(option.locationNames)
            
            % get location name
            period = strfind(option.locationNames{n},'.');
            option.locationNames{n} = option.locationNames{n}(period(3)+1:period(4)-1);
            
        end
        
        % keep unique
        option.locationNames = unique(option.locationNames);
        
    % otherwise make requested location a cell element
    else
        
        option.locationNames = {option.locationNames};
        
    end
    
end

% TRIAL NAMES
if isa(option.trialNames,'char')
    
    % if string given, but not 'all'
    if ~contains(option.trialNames,'all')
        
        % then assume a single trial requested, change to a cell element
        option.trialNames = {option.trialNames};
        
    % otherwise if all trials
    elseif strcmp(option.trialNames,'allTrials') || strcmp(option.trialNames,'all')
        
        % get named trial file names
        option.trialNames = dir(fullfile(data.directory,'f*.a*.*.*.*.csv'));
        option.trialNames = {option.trialNames.name};
        
        % for each trial name
        for tn = 1:numel(option.trialNames)
            
            % keep only trial name
            period = strfind(option.trialNames{tn},'.');
            option.trialNames{tn} = option.trialNames{tn}(period(2)+1:period(3)-1);
            
        end
        
        % keep unique, change to cell to handle in 'if cell' block next
        option.trialNames = unique(option.trialNames);
        
    % otherwise if all data to reconstruct
    elseif strcmp(option.trialNames,'allData')
        
        % do nothing, leave as 'allData', this will be handled in IMPORT
        
    else
        error('If requesting importing all data, please specify ''allData'' or ''allTrials''. See INPUTS for details.')
    end
    
end

%% HANDLE RENAMING TRIALS OPTION

% if is a character array
if isa(option.renameTrials,'char')
    
    % if not none
    if ~strcmpi(option.renameTrials,'none')
        
        % then throw error, at least two strings needed
        error('User set renameTrials option to ''%s''. If renaming desired then trials to rename and what to change name too must be specified. See INPUTS.',option.renameTrials)
        
    end
    
% if a logical
elseif isa(option.renameTrials,'logical')
    
    % then will only accept false for 'none'
    if option.renameTrials == false
        renameTrialsFlag = 0;
    else
        error('User set renameTrials option to logical true. If renaming desired then trials to rename must be specified. See INPUTS.')
    end
    
% if a double
elseif isa(option.renameTrials,'double')
    
    % then will only accept 0 for 'none'
    if option.renameTrials == 0
        renameTrialsFlag = 0;
    else
        error('User set renameTrials option to 1. If renaming desired then trials to rename must be specified. See INPUTS.')
    end
    
% otherwise must be a cell
elseif isa(option.renameTrials,'cell')
    renameTrialsFlag = 1;
else
    error('Unrecognized input for importOptions.renameTrials.')
end

%% HANDLE RENAMING LOCATIONS OPTION

% if is a character array
if isa(option.renameLocations,'char')
    
    % if not none
    if ~strcmpi(option.renameLocations,'none')
        
        % then throw error, at least two strings needed
        error('User set renameLocations option to ''%s''. If renaming desired then locations to rename and what to change name too must be specified. See INPUTS.',option.renameLocations)
        
    else
        renameLocationsFlag = 0;
    end
    
% if a logical
elseif isa(option.renameLocations,'logical')
    
    % then will only accept false for 'none'
    if option.renameLocations == false
        renameLocationsFlag = 0;
    else
        error('User set renameLocations option to logical true. If renaming desired then locations to rename must be specified. See INPUTS.')
    end
    
% if a double
elseif isa(option.renameLocations,'double')
    
    % then will only accept 0 for 'none'
    if option.renameLocations == 0
        renameLocationsFlag = 0;
    else
        error('User set renameLocations option to 1. If renaming desired then locations to rename must be specified. See INPUTS.')
    end
    
% otherwise must be a cell
elseif isa(option.renameLocations,'cell')
    renameLocationsFlag = 1;
else
    error('Unrecognized input for importOptions.renameLocations.')
end

%%  INITIALIZE TRIALS

% if only some trials requested for import
if isa(option.trialNames,'cell')
    
    % for each user requested trial name
    for t = 1:length(option.trialNames)
        
        % get all files with this trial name (may have wild cards)
        trialNames = dir(fullfile(data.directory,['f*.a*.' option.trialNames{t} '.*.*.csv']));
        
        % warn user if empty
        if isempty(trialNames)
            fprintf('-WARNING: user requested to import trial ''%s'', but there were no associated file names.\n',option.trialNames{t})
            
        % continue if not empty
        else
            
            % remove leading f*.a*. and trailing .(location).(sensor).csv
            trialNames = {trialNames.name};
            for n = 1:length(trialNames)
                period = strfind(trialNames{n},'.');
                trialNames{n} = trialNames{n}(period(2)+1:period(3)-1);
            end
            
            % keep unique names (would be more than one only because of wildcard)
            trialNames = unique(trialNames);
            
            % for each unique trial name
            for u = 1:length(trialNames)
                
                % check to see if renaming this trial name
                store_as_this = trialNames{u};
                if renameTrialsFlag
                    
                    % for each trial to rename
                    for r = 1:size(option.renameTrials,1)
                        
                        % if replacing just a portion
                        if option.renameTrials{r,1}(1) == '*'
                            
                            % replace
                            replace_this = option.renameTrials{r,1}(2:end);
                            with_this = option.renameTrials{r,2};
                            store_as_this = replace(store_as_this, replace_this, with_this);
                            
                        % otherwise replacing everything    
                        else
                            
                            % if matches
                            if strcmp(option.renameTrials{r,1},store_as_this)
                                
                                % then change name and exit
                                store_as_this = option.renameTrials{r,2};
                                break;
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                % get associated leading file name f*.a*.*
                % might be more than one if multiple trials have same name
                leading_file_names = dir(fullfile(data.directory,['f*.a*.' trialNames{u} '.*.*.csv']));
                leading_file_names = {leading_file_names.name};
                for f = 1:length(leading_file_names)
                    period = strfind(leading_file_names{f},'.');
                    leading_file_names{f} = leading_file_names{f}(1:period(3)-1);
                end
                
                % keep unique leading file names, might be more than one if
                % data for this trial instance exists for more than one
                % sensor location and/or sensor type
                leading_file_names = unique(leading_file_names);
                
                % if only one exists
                if length(leading_file_names) == 1
                    
                    % initialize in data.trials struct
                    data.trials.(store_as_this).leading_file_name = leading_file_names{1};
                    
                % otherwise if more than one
                else
                    
                    % then get file numbers: f(file_number).*.*.*.*.csv
                    file_numbers = zeros(1,length(leading_file_names));
                    for f = 1:length(file_numbers)
                        period = strfind(leading_file_names{f},'.');
                        file_numbers(f) = str2double(leading_file_names{f}(2:period(1)-1));
                    end
                    
                    % sort by file number
                    [~,sorted_indices] = sort(file_numbers,'ascend');
                    leading_file_names = leading_file_names(sorted_indices);
                    
                    % handle according to storeSameTrials option
                    
                    % if keeping first trial
                    if strcmpi(option.storeSameTrials,'first')
                        data.trials.(store_as_this).leading_file_name = leading_file_names{1};
                        
                    % if keeping last trial
                    elseif strcmpi(option.storeSameTrials,'last')
                        data.trials.(store_as_this).leading_file_name = leading_file_names{end};
                        
                    % otherwise, storing multiple
                    else
                        
                        % for each
                        for n = 1:length(leading_file_names)
                            
                            % if appending field
                            if strcmpi(option.storeSameTrials,'appendField')
                                data.trials.(store_as_this)(n).leading_file_name = leading_file_names{n};
                                
                            % otherwise appending trial name
                            else
                                data.trials.([store_as_this '_' num2str(n)]).leading_file_name = leading_file_names{n};
                            end
                        end
                    end
                end
            end
        end
    end
end


%% IMPORT

% keep track of highest and lowest sampling frequencies
highest_samplingFrequency = 0;
lowest_samplingFrequency = inf;

% allowable MC10 sampling frequencies
mc10f = 15.625*2.^[0 1 2 3 4 5 6];

% if specific trials
if isa(option.trialNames,'cell')
    
    % for each trial
    trialNames = fieldnames(data.trials);
    for t = 1:length(trialNames)
        
        % for each field
        for f = 1:length(data.trials.(trialNames{t}))
            
            % keep track of earliest and latest time stamp
            start_timestamp = 0;
            end_timestamp = inf;

            % for each location
            for l = 1:length(option.locationNames)

                % for each sensor
                for s = 1:length(option.sensorNames)

                    % if file exists
                    file_name = fullfile(data.directory,[data.trials.(trialNames{t})(f).leading_file_name '.' option.locationNames{l} '.' option.sensorNames{s} '.csv']);
                    if isfile(file_name)
                        
                        % import
                        d = readmatrix(file_name,'NumHeaderLines',1);
                        
                        % make sure time stamps unique
                        [time,iunique] = unique(d(:,1));
                        
                        % store
                        dataScalar = 1;
                        if strcmpi(option.sensorNames{s},'gyro'); dataScalar = pi/180; end
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).time = time';
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).data = d(iunique,2:end)' * dataScalar;
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency = 1./mean(diff(time));
                        
                        % update start/end timestamp
                        if time(1) > start_timestamp; start_timestamp = time(1); end
                        if time(end) < end_timestamp; end_timestamp = time(end); end
                        
                        % update fastest/slowest sampling frquency
                        if data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency > highest_samplingFrequency
                            highest_samplingFrequency = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                        end
                        if data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency < lowest_samplingFrequency
                            lowest_samplingFrequency = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                        end
                        
                    % otherwise, if doesn't exist
                    else
                        
                        % warn user
                        fprintf('-WARNING: file name ''%s'' does not exist. Aborting import for this data set.\n',file_name);
                        
                    end
                    
                end
                
            end
            
            % save start/end timestamps
            data.trials.(trialNames{t})(f).start_timestamp = start_timestamp;
            data.trials.(trialNames{t})(f).end_timestamp = end_timestamp;
            
        end
        
    end
 
% if not a cell, then importing all data
else
    
    % get unique leading file names
    leading_file_names = dir(fullfile(data.directory,'f*.*.*.*.*.csv'));
    leading_file_names = {leading_file_names.name};
    for f = 1:length(leading_file_names)
        period = strfind(leading_file_names{f},'.');
        leading_file_names{f} = leading_file_names{f}(1:period(3)-1);
    end
    leading_file_names = unique(leading_file_names);
    
    % sort chronologically
    file_number = zeros(1,length(leading_file_names));
    for f = 1:length(leading_file_names)
        period = strfind(leading_file_names{f},'.');
        file_number(f) = str2double(leading_file_names{f}(2:period(1)-1));
    end
    [~,isort] = sort(file_number,'ascend');
    leading_file_names = leading_file_names(isort);
        
            
    % keep track of earliest and latest time stamp
    start_timestamp = 0;
    end_timestamp = inf;
    
    % for each location
    for l = 1:length(option.locationNames)
        
        % for each sensor
        abort_import = 0;
        for s = 1:length(option.sensorNames)
            
            % initialize time/data array
            time = [];
            raw_data = [];
            
            % for each file
            for f = 1:length(leading_file_names)
                
                % if exists
                file_name = fullfile(data.directory,[leading_file_names{f} '.' option.locationNames{l} '.' option.sensorNames{s} '.csv']);
                if isfile(file_name)
                        
                    % import
                    d = readmatrix(file_name,'NumHeaderLines',1);

                    % make sure time stamps unique
                    [interval_time,iunique] = unique(d(:,1));

                    % store
                    time = horzcat(time,interval_time');
                    raw_data = horzcat(raw_data,d(iunique,2:end)');

                % otherwise, if doesn't exist
                else

                    % warn user
                    fprintf('-WARNING: sensor ''%s'' for location ''%s'' does not contain leading file name ''%s''. Aborting import for this sensor/location.\n',....
                        option.sensorNames{s},option.locationNames{l},leading_file_names{f});
                    
                    % throw abort flag
                    abort_import = 1;
                    break;

                end
                
            end
                
            % if not aborting
            if ~abort_import

                % save
                data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).time = time;
                data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).data = raw_data;
                data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency = 1./mean(diff(time));
                data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).samplingFrequency = 1./mean(diff(time));

                % update start/end timestamp
                if time(1) > start_timestamp; start_timestamp = time(1); end
                if time(end) < end_timestamp; end_timestamp = time(end); end

                % update fastest/slowest sampling frquency
                if data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency > highest_samplingFrequency
                    highest_samplingFrequency = data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                end
                if data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency < lowest_samplingFrequency
                    lowest_samplingFrequency = data.trials.allData.locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                end

            end
            
        end
        
    end
    
    % save start/end timestamps
    data.trials.allData.start_timestamp = start_timestamp;
    data.trials.allData.end_timestamp = end_timestamp;
    
end

% get highest/lowest mc10 sampling frequencies
[~,index] = min(abs(mc10f - highest_samplingFrequency));
highest_mc10_samplingFrequency = mc10f(index);
[~,index] = min(abs(mc10f - lowest_samplingFrequency));
lowest_mc10_samplingFrequency = mc10f(index);

%% SYNC & RESAMPLE

% if resampling
if resampleFlag
    
    
    % for each trial name
    trialNames = fieldnames(data.trials);
    for t = 1:length(trialNames)
        
        % for each trial with that name
        for f = 1:numel(data.trials.(trialNames{t}))
            
            % for each location
            for l = 1:length(option.locationNames)
                
                % for each sensor
                sensors = fieldnames(data.trials.(trialNames{t})(f).locations.(option.locationNames{l}));
                for s = 1:length(sensors)
                    
                    % get new sampling frequency
                    new_sf = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).original_samplingFrequency;
                    
                    % if accel
                    if sensors{s}(1) == 'a'
                        
                        % if character array
                        if isa(option.resampleAccel,'char')
                            if strcmp(option.resampleAccel,'high')
                                new_sf = highest_samplingFrequency;
                            elseif strcmp(option.resampleAccel,'low')
                                new_sf = lowest_samplingFrequency;
                            elseif strcmp(option.resampleAccel,'mc10high')
                                new_sf = highest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleAccel,'mc10low')
                                new_sf = lowest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleAccel,'mc10')
                                [~,index] = min(abs(mc10f - new_sf));
                                new_sf = mc10f(index);
                            end
                                
                        % otherwise must be double
                        elseif isa(option.resampleAccel,'double')
                            new_sf = option.resampleAccel;
                            
                        % otherwise error
                        else
                            error('resampleAccel or resample option should only be a character array or double.')
                        end
                        
                    % if gyro
                    elseif sensors{s}(1) == 'g'
                        
                        % if character array
                        if isa(option.resampleGyro,'char')
                            if strcmp(option.resampleGyro,'high')
                                new_sf = highest_samplingFrequency;
                            elseif strcmp(option.resampleGyro,'low')
                                new_sf = lowest_samplingFrequency;
                            elseif strcmp(option.resampleGyro,'mc10high')
                                new_sf = highest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleGyro,'mc10low')
                                new_sf = lowest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleGyro,'mc10')
                                [~,index] = min(abs(mc10f - new_sf));
                                new_sf = mc10f(index);
                            end
                                
                        % otherwise must be double
                        elseif isa(option.resampleGyro,'double')
                            new_sf = option.resampleGyro;
                            
                        % otherwise error
                        else
                            error('resampleAccel or resample option should only be a character array or double.')
                        end
                        
                    % if emg
                    elseif sensors{s}(1) == 'e'
                        
                        % if character array
                        if isa(option.resampleElec,'char')
                            if strcmp(option.resampleElec,'high')
                                new_sf = highest_samplingFrequency;
                            elseif strcmp(option.resampleElec,'low')
                                new_sf = lowest_samplingFrequency;
                            elseif strcmp(option.resampleElec,'mc10high')
                                new_sf = highest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleElec,'mc10low')
                                new_sf = lowest_mc10_samplingFrequency;
                            elseif strcmp(option.resampleElec,'mc10')
                                [~,index] = min(abs(mc10f - new_sf));
                                new_sf = mc10f(index);
                            end
                                
                        % otherwise must be double
                        elseif isa(option.resampleElec,'double')
                            new_sf = option.resampleElec;
                            
                        % otherwise error
                        else
                            error('resampleAccel or resample option should only be a character array or double.')
                        end
                        
                    end
                            
                    % save new sampling frequency
                    data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).samplingFrequency = new_sf;
                    data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).postImporter_samplingFrequency = new_sf;
                    
                    % original time array
                    time0 = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).time;
                    
                    % new time array
                    data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).time = data.trials.(trialNames{t})(f).start_timestamp:1/new_sf:data.trials.(trialNames{t})(f).end_timestamp;
                    
                    % resample
                    data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).data = interp1(time0,...
                                                                                                         data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).data',...
                                                                                                         data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).time','pchip')';
                                                                                                     
                end
                
            end
            
        end
        
    end
    
end

%% RENAME LOCATIONS

% if renaming
if renameLocationsFlag
    
    % for each trial name
    trialNames = fieldnames(data.trials);
    for t = 1:length(trialNames)
        
        % for each location
        locations = fieldnames(data.trials.(trialNames{t}).locations);
        for l = 1:length(locations)
            
            % if renaming
            ichange = strcmp(locations{l},option.renameLocations(:,1));
            if any(ichange)
                
                % save location data
                temp = data.trials.(trialNames{t}).locations.(locations{l});
                
                % remove old and update with new name
                data.trials.(trialNames{t}).locations = rmfield(data.trials.(trialNames{t}).locations,locations{l});
                data.trials.(trialNames{t}).locations.(option.renameLocations{ichange,2}) = temp;
                
            end
            
        end
        
    end
    
end


end

function [ str ] = cap(str)
str(1) = upper(str(1));
end
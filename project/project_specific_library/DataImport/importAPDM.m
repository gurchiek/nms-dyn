function [ data ] = importAPDM(importOptions)
%Reed Gurchiek, 2020, reed.gurchiek@uvm.edu
%   imports APDM data from .h5 files in monitorData directory
%
%   all imported data are synced and resampled to a uniform grid at a 
%   sampling frequency dependent on the resample option (see INPUTS). If
%   two datapoints have the same timestamp, then the first datapoint is
%   kept and the other removed
%
%---------------------------INPUTS-----------------------------------------
%
%   importOptions:
%
%       (1) dataDirectory:
%               -char array specifying data directory containing .h5 files
%
%       (2) trialNames (default: allTrials):
%           -cell with names of trials (activities) to import 
%           -these correspond to .h5 files containing trialnames in the
%                filename (e.g. filename = *trialname.h5
%           -if importing all data assigned a trial name then 'allTrials'
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
%               (3) 'mag'
%               (4) 'baro'
%               (5) 'temp'
%               (6) 'quaternion'
%
%       (5) resample (default: mean):
%           -if 'high' then resamples all data to highest sf of all sensors
%           -if 'low' then resamples all data to lowest sf of all sensors
%           -if x then resamples all data to x
%           -if 'mean' then resamples to each sensor's mean frequency
%           -if resample = 0, then data are not resampled nor synced
%
%       (6) storeSameTrials (default: appendName):
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
%       (7) renameTrials (default: 'none')
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
%       (8) reportStatus (default: 0):
%           -flag to update (1) or not (0) status of import to command
%            window
%
%       (9) renameLocations (default: 'none')
%           -if 'none' then renames no locations
%           -if cell then should be an n x 2 cell with first column
%               containing the oldNames which will be changed to the
%               newNames in the second column.
%                   -e.g. to change loc_1 to newloc use:
%                       importOptions.renameLocations = {'loc_1','newloc'}
%
%       (10) gravitationalAcceleration (default: 9.81)
%               -acceleration data will be divided by this number to
%                   convert to g's
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
%                                 apdmAnnotations
%                                 locations.
%                                           locationName.
%                                                        sensorName.
%                                                                   time
%                                                                   data
%                                                                   samplingFrequency
%
%--------------------------------------------------------------------------
%% importAPDM

% set option defaults
sense = {'accel' 'gyro' 'mag' 'baro' 'temp' 'quaternion'};
apdmSensorNames = {'Accelerometer','Gyroscope','Magnetometer','Barometer','Temperature','Orientation'};
option = ...
    struct('dataDirectory','',...
           'trialNames','allTrials',...
           'locationNames','all',...
           'sensorNames','all',...
           'storeSameTrials','appendName',...
           'resample','mean',...
           'renameTrials','none',...
           'renameLocations','none',...
           'gravitationalAcceleration',9.81,...
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
    potential_fields = {'sensorNames','sensors','sensor','sensorName','dataNames','dataName','dataType','dataTypes'};
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
    
    % correct potential naming errors: gravitationalAcceleration
    potential_fields = {'gravitationalAcceleration','gravity','g','gScalar','accelerationScalar','accelScalar','gravityScalar'};
    has_field = isfield(importOptions,potential_fields);
    ifield = find(has_field);
    if any(has_field); option.gravitationalAcceleration = importOptions.(potential_fields{ifield(1)}); end

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
        if resampleFlag; option.resample = importOptions.resample; end

    end
end

% get data directory
if isempty(option.dataDirectory)
    ok = questdlg('Select APDM monitorData directory containing exported .h5 data files','Data Directory','OK',{'OK'});
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
        option.sensorNames = sense;
        
    % otherwise make requested sensor a cell element
    elseif any(strcmpi(option.sensorNames,{'acc','accel','accelerometer'}))
        option.sensorNames = {'accel'};
    elseif any(strcmpi(option.sensorNames,{'gyro','gyroscope'}))
        option.sensorNames = {'gyro'};
    elseif any(strcmpi(option.sensorNames,{'imu','inertial','inertial_sensor','inertialSensor','inertialMeasurementUnit','IMU'}))
        option.sensorNames = {'accel','gyro'};
    elseif any(strcmpi(option.sensorNames,{'mag','magnetometer','magnetic','magneticField','hall','hallSensor'}))
        option.sensorNames = {'mag'};
    elseif any(strcmpi(option.sensorNames,{'baro','barometer','pressure'}))
        option.sensorNames = {'baro'};
    elseif any(strcmpi(option.sensorNames,{'temp','temperature'}))
        option.sensorNames = {'temp'};
    elseif any(strcmpi(option.sensorNames,{'quaternion','q','orientation','quat'}))
        option.sensorNames = {'quaternion'};
    else
        error('Unrecognized user requested sensorName')
    end
end

% TRIAL NAMES
if isa(option.trialNames,'char')
    
    % if string given, but not 'all'
    if ~contains(option.trialNames,'all')
        
        % then assume a single trial requested, change to a cell element
        option.trialNames = {option.trialNames};
        
    % otherwise if all trials
    else
        
        % get named trial file names
        option.trialNames = dir(fullfile(data.directory,'*.h5'));
        option.trialNames = {option.trialNames.name};
        
        % for each trial name
        for tn = 1:numel(option.trialNames)
            
            % keep only trial name (filename after first _ and before .h5)
            underscore = strfind(option.trialNames{tn},'_');
            if ~isempty(underscore)
                option.trialNames{tn} = option.trialNames{tn}(underscore(1)+1:end-3);
            end
            
        end
        
        % keep unique, change to cell to handle in 'if cell' block next
        option.trialNames = unique(option.trialNames);
        
    end
    
end

% LOCATION NAMES
allLocationsFlag = false;
if isa(option.locationNames,'char')
    
    % if contains 'all' then set flag
    if contains(option.locationNames,'all','IgnoreCase',true)
        
        allLocationsFlag = true;
        
    % otherwise make requested location a cell element
    else
        
        option.locationNames = {option.locationNames};
        
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
    
% for each user requested trial name
for t = 1:length(option.trialNames)

    % get all files containing this trial name
    trialNames = dir(fullfile(data.directory,['*' option.trialNames{t} '.h5']));

    % warn user if empty
    if isempty(trialNames)
        fprintf('-WARNING: user requested to import trial ''%s'', but there were no associated file names.\n',option.trialNames{t})

    % continue if not empty
    else

        % remove leading numbers up to first _ and trailing .h5
        trialNames = {trialNames.name};
        for n = 1:length(trialNames)
            underscore = strfind(trialNames{n},'_');
            if ~isempty(underscore)
            	trialNames{n} = trialNames{n}(underscore(1)+1:end-3);
            end
        end

        % keep unique names
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

            % get associated filename
            filenames = dir(fullfile(data.directory,['*' trialNames{u} '.h5']));
            filenames = {filenames.name};

            % if only one exists
            if length(filenames) == 1

                % initialize in data.trials struct
                data.trials.(store_as_this).filename = filenames{1};

            % otherwise if more than one
            else

                % sort by unicode order
                [~,sorted_indices] = sort(filenames);
                filenames = filenames(sorted_indices);

                % handle according to storeSameTrials option

                % if keeping first trial
                if strcmpi(option.storeSameTrials,'first')
                    data.trials.(store_as_this).filename = filenames{1};

                % if keeping last trial
                elseif strcmpi(option.storeSameTrials,'last')
                    data.trials.(store_as_this).filename = filenames{end};

                % otherwise, storing multiple
                else

                    % for each
                    for n = 1:length(filenames)

                        % if appending field
                        if strcmpi(option.storeSameTrials,'appendField')
                            data.trials.(store_as_this)(n).filename = filenames{n};

                        % otherwise appending trial name
                        else
                            data.trials.([store_as_this '_' num2str(n)]).filename = filenames{n};
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
    
% for each trial
trialNames = fieldnames(data.trials);
for t = 1:length(trialNames)

    % for each field
    for f = 1:length(data.trials.(trialNames{t}))

        % keep track of earliest and latest time stamp
        start_timestamp = 0;
        end_timestamp = inf;
        
        % get apdm file
        h5f = fullfile(data.directory,data.trials.(trialNames{t})(f).filename);

        % get annotation data
        data.trials.(trialNames{t})(f).apdmAnnotations = h5read(h5f,'/Annotations');
        data.trials.(trialNames{t})(f).apdmAnnotations.Annotation = cellstr(data.trials.(trialNames{t})(f).apdmAnnotations.Annotation');
        data.trials.(trialNames{t})(f).apdmAnnotations.Time = double(data.trials.(trialNames{t})(f).apdmAnnotations.Time) * 10^-6;

        % get info for sensor/processed data
        info.sensors = h5info(h5f,'/Sensors');
        info.processed = h5info(h5f,'/Processed');
        
        % number of locations
        nLocations = length(info.sensors.Groups);
        apdmLocations = cell(1,nLocations);
        
        % for each location
        for l = 1:nLocations
            
            % get configuration => location name
            config = h5info(h5f,[info.sensors.Groups(l).Name,'/Configuration']);
            apdmLocations{l} = valfname(config.Attributes(1).Value);
            
        end
        
        % update location names if reading all
        if allLocationsFlag; option.locationNames = apdmLocations; end
            

        % for each location
        for l = 1:length(option.locationNames)
            
            % get apdm group index
            apdmGroupIndex = strcmpi(option.locationNames{l},apdmLocations);
            
            % report if none
            if ~any(apdmGroupIndex)
                
                warning('User requested to import data for location %s from file %s but there was no location with this name. Aborting import for this location.',option.locationNames{l},h5f);
                
            % otherwise continue
            else
                
                % get time, same for all sensors at this location
                time = double(h5read(h5f,[info.sensors.Groups(apdmGroupIndex).Name,'/Time'])) * 10^-6;

                % make sure time stamps unique
                [time,iunique] = unique(time);

                % update start/end timestamp
                if time(1) > start_timestamp; start_timestamp = time(1); end
                if time(end) < end_timestamp; end_timestamp = time(end); end

                % for each sensor
                for s = 1:length(option.sensorNames)
                    
                    % get data
                    gotData = true;
                    try raw = double(h5read(h5f,[info.sensors.Groups(apdmGroupIndex).Name,'/',apdmSensorNames{strcmpi(option.sensorNames{s},sense)}]));
                    catch
                        gotData = false;
                        warning('User requested to import data for sensor %s from location %s and file %s but there was no sensor with this name. Aborting import for this sensor.',option.sensorNames{s},option.locationNames{l},h5f);
                    end
                    
                    % proceed if got data
                    if gotData

                        % store
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).time = time';
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).data = raw(:,iunique);
                        data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency = 1/mean(diff(time));
                        
                        % convert accel to g
                        if strcmpi(option.sensorNames{s},'accel')
                            data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).data = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).data / option.gravitationalAcceleration;
                        end

                        % update fastest/slowest sampling frquency
                        if data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency > highest_samplingFrequency
                            highest_samplingFrequency = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                        end
                        if data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency < lowest_samplingFrequency
                            lowest_samplingFrequency = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(option.sensorNames{s}).original_samplingFrequency;
                        end
                        
                    end

                end
                
            end

        end

        % save start/end timestamps
        data.trials.(trialNames{t})(f).start_timestamp = start_timestamp;
        data.trials.(trialNames{t})(f).end_timestamp = end_timestamp;

    end

end

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
                    new_sf = data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).original_samplingFrequency; % this will be the case if option.resample = 'mean'
                    if isa(option.resample,'char')
                        if strcmp(option.resample,'high')
                            new_sf = highest_samplingFrequency;
                        elseif strcmp(option.resample,'low')
                            new_sf = lowest_samplingFrequency;
                        end
                    elseif isa(option.resample,'double')
                        new_sf = option.resample;
                    else
                        error('resample option should only be a character array or double.')
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
                                                                                                                   data.trials.(trialNames{t})(f).locations.(option.locationNames{l}).(sensors{s}).time,'pchip')';
                                                                                                     
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

    
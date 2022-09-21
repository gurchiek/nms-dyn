function [ data, notes ] = importTRC(varargin)
%Reed Gurchiek, 2020, reed.gurchiek@uvm.edu
%
%   imports marker position data in .trc format
%
%--------------------------INPUTS-----------------------------------------
%
%   Name, Value pair:
%
%       1) dataDirectory (default: 'choose')
%           -string denoting directory containing .trc files
%           -if 'choose' then user can browse for the directory
%
%       2) trialNames (default: 'all')
%           -string denoting names of trials to keep (e.g. trialName.trc)
%           -if multiple trials then cell {'tname1','tname2',...}
%           -if 'choose' then user will be prompted to select one or
%               multiple trials from all within the directory
%           -if all, then all loaded
%           -trialName corresponds to the .trc filename, e.g. to read
%               walking.trc then use trialNames = {'walking'};
%           -the data associated with this trial will be stored in the
%               output data struct under the trial field but the name will
%               be modified to be a valid fieldname (e.g. '_' instead of
%               space)
%
%       3) markerNames (default: 'all')
%           -string denoting names of markers to keep
%           -should be name of markers as they appear in .trc file
%           -if multiple markers then cell {'mname1','mname2',...}
%           -if all, then all loaded
%           -the data associated with a given marker will be stored in the
%               output data struct under the marker field but the name will
%               be modified to be a valid fieldname (e.g. '_' instead of
%               space)
%
%       4) transferMatrix (default: eye(3))
%           -3x3 matrix to rotate marker data to frame of user's choice
%
%       5) lowPassCutoff (default: 0)
%           -double, frequency at which to low pass filter marker data
%           -if 0, then filtering is not done
%           -if any marker has missing data, then no filtering is done for
%               that trial
%           -4th order, zero lag butterworth, requires matlab dsp toolbox
%
%       6) missingDataThreshold (default: 0)
%           -use this to handle missing data
%           -if double, then if number of consecutive missing frames is <
%               than this number, then gaps are filled with pchip interp
%           -if number of consecutive missing frames exceeds this number,
%               data is dealt with according to 'deleteData' option (7)
%           -if 'auto', then the threshold of allowable consecutive missed
%               frames is round( 1/2/fc * sf) where fc is low pass cutoff 
%               frequency and sf is sampling frequency so that largest 
%               window allowed to interpolate for corresponds to one half 
%               cycle of the fastest expected dynamics. If no low pass
%               cutoff given then 6 Hz assumed which mean consecutive
%               missing data frame windows will be pchip interpolated if
%               the window is <= 0.0833 s.
%           -for interpolation correction, also require there be at least
%               two observed datapoints on both ends of the missing data
%               window
%           -if data is missing at beginning (end) of trial then the
%               threshold for this missing data window will be
%               0.5*threshold and it is required that there be at least 4
%               observed data points immediately after (before) this window
%
%       7) deleteData (default: 'none')
%           -as noted in (6), if number of consecutive missed frames
%           exceeds missingDataThreshold, then deleteData controls handling
%               -if 'none', then no data deleted, saved with NaNs
%               -if 'deleteTrial', then all marker data deleted and
%                   data.trial.(trialName).trialDeleted flag is set to 1
%               -if 'deleteMarker', then marker data deleted only for those
%                   markers whose consecutive missed frames exceeds thresh.
%                   Deleted markers can be found in
%                   data.trial.(trialName).deletedMarkers
%
%       8) newStartTime (default: 0)
%           -double, effectively trims start of trial
%           -if 0, nothing trimmed
%           -if requested newStartTime is before time associated with first
%               frame in .trc file, then this time will be used instead
%
%       9) newEndTime (default: inf)
%           -double, effectively trims end of trial
%           -if inf, nothing trimmed
%           -if requested newEndTime is after time associated with last
%               frame in .trc file, then this time will be used instead
%
%       10) resample (default: 0)
%           -double, frequency to resample to.  if 0, no resample
%           -if downsampled, then lowpassed at half downsample frequency
%               first to anti-alias
%           -if any marker has missing data, then no resampling is done
%
%       11) reportStatus (default: 0)
%           -import status will be printed to command window if 1
%
%--------------------------OUTPUTS-----------------------------------------
%
%   data:
%           data.
%                directory
%                trialNames
%                trial.
%                      trialName1.
%                      trialName2.
%                      trialNameN.
%                                 trialDeleted: see input (7)
%                                 deletedMarkers: see input (7)
%                                 samplingFrequency
%                                 nFrames
%                                 firstFrame
%                                 lastFrame
%                                 startTime: to sync with other instr.
%                                 endTime: to sync with other instr.
%                                 duration: in seconds
%                                 time: to sync with other instr.
%                                 nMarkers
%                                 markers.
%                                         (markerName).
%                                                      position = 3xn
%
%   notes:
%       cell array of strings noting manipulations to handle missing frames
%
%--------------------------------------------------------------------------
%% importTRC

% initialization
notes = {''};
option.dataDirectory = {'choose'};
option.trialNames = {'all'};
option.renameTrials = {0};
option.markerNames = {'all'};
option.renameMarkers = {0};
option.transferMatrix = {eye(3)};
option.lowPassCutoff = {0};
option.missingDataThreshold = {'auto'};
option.deleteData = {'none'};
option.newStartTime = {0};
option.newEndTime = {inf};
option.resample = {0};
option.reportStatus = {0};

% if single input
if length(varargin) == 1
    
    % if struct
    if isstruct(varargin{1})
        
        % change structure to Name, Value pair varargin
        optstruct = varargin{1}; varargin = {};
        fn = fieldnames(optstruct);
        if ~isempty(fn)
            varargin = cell(1,length(fn)*2);
            i = 1;
            for f = 1:length(fn)
                varargin{i} = fn{f};
                varargin{i+1} = optstruct.(fn{f});
                i = i + 2;
            end
        end
    else
        error('If only one input argument then must be the option structure')
    end
    
end
       
% if option updates given
if ~isempty(varargin)
    if mod(length(varargin),2)
        error('Input arguments must be even number: (Name1, Value1, Name2, Value2, ...)')
    end
    % for each option
    for k = 1:length(varargin)/2
        % correct potential naming errors
        if any(strcmpi(varargin{2*k-1},{'trialName','trial','trials'})); varargin{2*k-1} = 'trialNames';
        elseif any(strcmpi(varargin{2*k-1},{'renameTrial','rename_trial','rename_trials'})); varargin{2*k-1} = 'renameTrials';
        elseif any(strcmpi(varargin{2*k-1},{'markerName','markers'})); varargin{2*k-1} = 'markerNames';
        elseif any(strcmpi(varargin{2*k-1},{'renameMarker','rename_marker','rename_markers'})); varargin{2*k-1} = 'renameMarkers';
        elseif any(strcmpi(varargin{2*k-1},{'report','status','report_status','statusReport','status_report'})); varargin{2*k-1} = 'reportStatus';
        elseif any(strcmpi(varargin{2*k-1},{'directory','dir','path'})); varargin{2*k-1} = 'dataDirectory';
        elseif any(strcmpi(varargin{2*k-1},{'markerTransformMatrix','markerTransform','marker_transform','transformMatrix','transform_matrix','transform','roation_matrix','rotation','rotationMatrix'})); varargin{2*k-1} = 'transferMatrix';
        elseif any(strcmpi(varargin{2*k-1},{'threshold','thresh','interpolationThreshold','splineThreshold','missingFramesThreshold'})); varargin{2*k-1} = 'missingDataThreshold';
        elseif any(strcmpi(varargin{2*k-1},{'newStart','new_start','start_time','startTime','start','startTrim','start_trim','trim_start','trimStart','trimStartTime'})); varargin{2*k-1} = 'newStartTime';
        elseif any(strcmpi(varargin{2*k-1},{'newEnd','new_end','end_time','endTime','end','endTrim','end_trim','trimEnd','trim_end','trimEndTime'})); varargin{2*k-1} = 'newEndTime';
        elseif any(strcmpi(varargin{2*k-1},{'cutoff','lowPass','cutoffFrequency','frequency','filter','filt'})); varargin{2*k-1} = 'lowPassCutoff';
        end
        
        % make cell element if not
        if ~isa(varargin{2*k},'cell'); varargin{2*k} = varargin(2*k); end
        
        % assign value to name
        option.(varargin{2*k-1}) = varargin{2*k};
    end
end
       
% if no dataDirectory
if any(strcmpi(option.dataDirectory{1},{'choose' 'pick' '?' 'select'}))
    % get directory
    ok = questdlg('Select the data directory containing the .trc files','Data Directory','OK','Cancel','OK');
    % cancel?
    if isempty(ok)||strcmp(ok,'Cancel'); error('importTRC  terminated');
    % otherwise
    else
        % select dir
        option.dataDirectory{1} = uigetdir(cd,'Select the data directory containing the .trc files');
    end
end

% get trialnames if users wants to choose or wants all
if any(strcmpi(option.trialNames{1},{'choose' 'pick' '?' 'all' 'select'}))
    % save boolean for later
    userSelect = 0;
    if any(strcmpi(option.trialNames{1},{'choose' 'pick' '?' 'select'}))
        userSelect = 1;
    end
    dataFolder = dir(fullfile(option.dataDirectory{1},'*.trc'));
    option.trialNames = cell(length(dataFolder),1);
    ifile = 1;
    while ifile <= numel(dataFolder)
        % delete if hidden
        if dataFolder(ifile).name(1) == '.'
            dataFolder(ifile) = [];
            option.trialNames(ifile)= [];
        % otherwise
        else
            % save trialname
            option.trialNames{ifile} = replace(dataFolder(ifile).name,'.trc','');
            ifile = ifile+1;
        end
    end
    
    % select if user wants choose
    if userSelect
        % select trials to analyze
        itrialNames = listdlg('ListString',option.trialNames,'PromptString','Select the trial data to import:','SelectionMode','multiple');

        % cancel?
        if isempty(itrialNames); error('-importTRC terminated');
        else; option.trialNames = option.trialNames(itrialNames);
        end
    end
    nTrials = length(option.trialNames);
else
    % verify input correctly
    [nTrials,c] = size(option.trialNames);
    if c > 1 && nTrials == 1
     option.trialNames = option.trialNames';
     nTrials = c;
    elseif c > 1 && nTrials > 1
     error('trialNames should be an n by 1 cell array.')
    end
    % verify existence
    k = 1;
    while k <= nTrials
        if isempty(dir(fullfile(option.dataDirectory{1},[option.trialNames{k} '.trc'])))
            notes{length(notes)+1} = sprintf('-Warning: user requested to import %s but it does not exist',fullfile(option.dataDirectory{1},[option.trialNames{k} '.trc']));
            if option.reportStatus{1}; fprintf([notes{end} '\n']); end
            option.trialNames(k) = [];
            nTrials = nTrials - 1;
            if nTrials == 0
                error('All trials were deleted...')
            end
        else
            k = k + 1;
        end
    end
end

% handle trial renaming
if numel(option.renameTrials) > 1
     [r,c] = size(option.renameTrials);
     if c ~= 2; error('renameTrials option must be n by 2 cell array.'); end
     if numel(option.renameTrials) ~= length(unique(option.renameTrials)); error('All elements in renameTrials must be unique. See INPUTS section of code.'); end
     for k = 1:r
         try
             temp.(option.renameTrials{k,2}) = 1;
         catch problem
             if strcmp(problem.identifier,'MATLAB:AddField:InvalidFieldName')
                 error('Second column of renameTrials cell array must contain valid field names');
             end
         end
     end
     clear temp
end

% update second column of trialNames with corresponding field name
option.trialNames = horzcat(option.trialNames,cell(nTrials,1));
for k = 1:nTrials
    % get index of row in rename array
    ind = strcmp(option.renameTrials(:,1),option.trialNames{k,1});
    if any(ind)
     % change name
     option.trialNames{k,2} = option.renameTrials{ind,2};
    else
     % keep same but validate
     option.trialNames{k,2} = valfname(option.trialNames{k,1});
    end
end

% handle markers
allMarkers = 0;
if numel(option.markerNames) == 1
    if strcmpi(option.markerNames{1},'all'); allMarkers = 1; end 
else
     % for each markerName
     [nMarkers,c] = size(option.markerNames);
     if c > 1 && nMarkers == 1
         option.markerNames = option.markerNames';
     elseif c > 1 && nMarkers > 1
         error('markerNames should be an n by 1 cell array.')
     end
end

% handle marker renaming
if numel(option.renameMarkers) > 1
     [r,c] = size(option.renameMarkers);
     if c ~= 2; error('renameMarkers option must be n by 2 cell array.'); end
     if numel(option.renameMarkers) ~= length(unique(option.renameMarkers)); error('All elements in renameMarkers must be unique. See INPUTS section of code.'); end
     for k = 1:r
         try
             temp.(option.renameMarkers{k,2}) = 1;
         catch problem
             if strcmp(problem.identifier,'MATLAB:AddField:InvalidFieldName')
                 error('Second column of renameMarkers cell array (names to change trials too) must contain valid field names');
             end
         end
     end
     clear temp
end

% if one start/end times given, then make such for all trials
if length(option.newStartTime) == 1; option.newStartTime = repmat(option.newStartTime,[1 numel(option.trialNames)]); end
if length(option.newEndTime) == 1; option.newEndTime = repmat(option.newEndTime,[1 numel(option.trialNames)]); end

    
%% read marker data

% initialize data structure
data.directory = option.dataDirectory{1};
data.trialNames = option.trialNames(:,2);

% for trial k
for k = 1:numel(data.trialNames)
    
    % status
    filename = fullfile(data.directory,[option.trialNames{k,1} '.trc']);
    if option.reportStatus{1}; fprintf('-Importing marker data: %s\n',filename); end
    
    % inititate trial field
    trialName = data.trialNames{k};
    data.trial.(trialName) = struct('trialDeleted',0,'deletedMarkers',{''},'samplingFrequency',[],'nFrames',[],'firstFrame',1,'lastFrame',[],'time',[],'nMarkers',[],'markerNames',{''});
    
    % open file
    data.trial.(trialName).filename = filename;
    fid = fopen(filename,'r');
    
    %read capture session specs
    specs = textscan(fid,'%f %f %f %f %s %f %f %f','HeaderLines',2,'Delimiter','\t');
    
    % if no data
    if isempty(specs{1})
            notes{length(notes)+1} = sprintf('-Warning: user requested to import %s but it is either not formatted correctly or empty. Deleting trial...',filename);
            if option.reportStatus{1}; fprintf([notes{end} '\n']); end
            data.trial.(trialName).trialDeleted = 1;
    else
        
        data.trial.(trialName).samplingFrequency = specs{1}(1);
        trcNumFrames = specs{3}(1);
        data.trial.(trialName).originalMarkerUnits = specs{5}{1};
        trcEndTime = (trcNumFrames + specs{7}(1) - 2)/data.trial.(trialName).samplingFrequency;
        trcStartTime = (specs{7}(1) - 1)/data.trial.(trialName).samplingFrequency;

        % shrink trim end time if larger than trial actual
        if option.newEndTime{k} > trcEndTime; option.newEndTime{k} = trcEndTime; end

        % lengthen trim start time if less than trial actual
        if option.newStartTime{k} < trcStartTime; option.newStartTime{k} = trcStartTime; end

        % get first frame (corresponding to newStartTime)
        data.trial.(trialName).firstFrame = ceil(data.trial.(trialName).samplingFrequency * (option.newStartTime{k}-1e-12)) + 1;

        % get last frame frame (corresponding to newEndTime)
        data.trial.(trialName).lastFrame = floor(data.trial.(trialName).samplingFrequency * (option.newEndTime{k}+1e-12)) + 1;

        % frames to skip in .trc file to jump to user requested first frame
        skip2firstFrame = data.trial.(trialName).firstFrame - specs{7}(1);

        % get nFrames to keep given user requested trim
        data.trial.(trialName).nFrames = data.trial.(trialName).lastFrame - data.trial.(trialName).firstFrame + 1;

        % time array
        data.trial.(trialName).time = zeros(1,data.trial.(trialName).nFrames);

        % scalar to make units m
        transferMatrix = option.transferMatrix{1};
        if strcmpi(data.trial.(trialName).originalMarkerUnits,'mm'); transferMatrix = transferMatrix / 1000; end

        % marker names are column titles, remove first two and empty cells
        ntrcmarkers = specs{4}(1);
        trcMarkerNames = textscan(fid,repmat('%s',[1,ntrcmarkers*3]),1,'Delimiter','\t');
        trcMarkerNames(1:2) = [];
        j = 1; while j <= length(trcMarkerNames); if isempty(trcMarkerNames{j}{1}); trcMarkerNames(j) = []; else; trcMarkerNames{j} = trcMarkerNames{j}{1}; j=j+1; end; end

        % sometimes marker names appear after subject ID separated by :, remove...
        for j = 1:length(trcMarkerNames)
            icolon = strfind(trcMarkerNames{j},':');
            if ~isempty(icolon); trcMarkerNames{j}(1:icolon) = []; end
        end

        % get requested markers
        if allMarkers
            reqMarkerNames = trcMarkerNames;
        else
            reqMarkerNames = option.markerNames;
        end

        % get name of marker for field
        nMarkers = length(reqMarkerNames);
        newMarkerNames = cell(nMarkers,1);
        for j = 1:nMarkers
            % get index of row in rename array
            ind = strcmp(option.renameMarkers(:,1),reqMarkerNames{j});
            if any(ind)
                % change name
                newMarkerNames{j} = option.renameMarkers{ind,2};
            else
                % keep same but validate
                newMarkerNames{j} = valfname(reqMarkerNames{j});
            end
        end

        % for each requested marker
        markerColumn = zeros(1,length(reqMarkerNames));
        j = 1;
        while j <= length(reqMarkerNames)

            % get index in trc marker cell array
            thisMarkerColumn = find(strcmp(trcMarkerNames,reqMarkerNames{j}));

            % if more than one marker with this name
            if length(thisMarkerColumn) > 1

                % warn user, use first
                notes{length(notes)+1} = sprintf('-Warning: More than one marker is named %s in %s, using first',reqMarkerNames{j},filename);
                if option.reportStatus{1}; fprintf([notes{end} '\n']); end
                thisMarkerColumn = thisMarkerColumn(1);

            end

            % if requested marker unavailable
            if isempty(thisMarkerColumn)

                % warn user, remove
                notes{length(notes)+1} = sprintf('-Warning: User requested to import marker %s but it was unavailable in %s. This trial will not have this marker.',reqMarkerNames{j},filename);
                if option.reportStatus{1}; fprintf([notes{end} '\n']); end
                markerColumn(j) = [];
                reqMarkerNames(j) = [];
                newMarkerNames(j) = [];

            else

                % get marker column
                markerColumn(j) = 3 * thisMarkerColumn;

                % save name and allocate space
                data.trial.(trialName).marker.(newMarkerNames{j}).position = zeros(3,data.trial.(trialName).nFrames);

                % next
                j = j + 1;

            end

        end

        % update stored marker specs
        data.trial.(trialName).markerNames = fieldnames(data.trial.(trialName).marker);
        data.trial.(trialName).nMarkers = length(data.trial.(trialName).markerNames);

        % skip rest of marker titles line and next line
        textscan(fid,'%s',1,'HeaderLines',1);

        % skip to user requested first frame
        if skip2firstFrame ~= 0
            textscan(fid,'%s',1,'HeaderLines',skip2firstFrame);
        end

        % for each frame
        hasMissingFrames = 0;
        for j = 1:data.trial.(trialName).nFrames

            % get time and marker positions
            filerow = cell2mat(textscan(fid,repmat('%f',[1,ntrcmarkers*3+2]),1,'HeaderLines',1,'Delimiter','\t'));
            
            % time
            data.trial.(trialName).time(j) = filerow(2);

            %for each marker
            for i = 1:data.trial.(trialName).nMarkers

                % assign xyz marker data as column vector and transform according to 
                data.trial.(trialName).marker.(newMarkerNames{i}).position(1:3,j) = transferMatrix * filerow(markerColumn(i):markerColumn(i)+2)';

                % missing frames?
                if any(isnan(filerow(markerColumn(i):markerColumn(i)+2)))

                    % initialize handler if first one
                    if ~hasMissingFrames; data.trial.(trialName).missingData = struct(); end
                    hasMissingFrames = 1;

                    % initialize if first for this marker
                    if ~isfield(data.trial.(trialName).missingData,data.trial.(trialName).markerNames{i})
                        data.trial.(trialName).missingData.(data.trial.(trialName).markerNames{i}).indices = [];
                    end

                    % handle
                    data.trial.(trialName).missingData.(data.trial.(trialName).markerNames{i}).indices = ...
                                [data.trial.(trialName).missingData.(data.trial.(trialName).markerNames{i}).indices j];
                end

            end

        end

        % close
        fclose(fid);

        % update trial name
        data.trialNames{k} = trialName;

        % for each marker with missing data
        if hasMissingFrames

            % reset has missing frames
            % if still some missing after then no resampling or filtering...
            hasMissingFrames = 0;

            %report
            notes{length(notes)+1} = sprintf('-Warning: Missing data: File: %s',filename);
            if option.reportStatus{1}; fprintf(['\n' notes{end} '\n']); end

            % get threshold
            threshold = option.missingDataThreshold{1};

            % if user requested 'auto'
            if isa(threshold,'char')

                % auto is 1/2/fc where fc is low pass cutoff frequency so that
                % largest window we will allow it to interpolate for
                % corresponds to one half cycle of the fastest expected
                % dynamics

                % if now low pass given
                if option.lowPassCutoff{1} == 0

                    % assume 6 Hz
                    threshold = 1/2/6;

                % otherwise use requested low pass
                else

                    threshold = 1/2/option.lowPassCutoff{1};

                end

                % convert to samples
                threshold = round(threshold * data.trial.(trialName).samplingFrequency);

            end

            % for each marker missing data
            missingMarker = fieldnames(data.trial.(trialName).missingData);
            ndeleted = 0;
            for j = 1:numel(missingMarker)

                % report
                notes{length(notes)+1} = sprintf('     -Marker: %s',missingMarker{j});
                if option.reportStatus{1}; fprintf([notes{end} '\n']); end

                % get frames with data
                obsFrames = 1:data.trial.(trialName).nFrames;
                obsFrames(data.trial.(trialName).missingData.(missingMarker{j}).indices) = [];
                obsData = data.trial.(trialName).marker.(missingMarker{j}).position(:,obsFrames);

                % spec missing data windows
                augFrames = [0 obsFrames data.trial.(trialName).nFrames+1];
                missingWindowSize = diff(augFrames)-1;
                iWindow = find(missingWindowSize > 0);
                missingWindowSize = missingWindowSize(iWindow);
                startMiss = augFrames(iWindow) + 1;
                endMiss = startMiss + missingWindowSize - 1;
                prevObsWindowSize = startMiss - [1 endMiss(1:end-1)] - 1; 
                if startMiss(1) == 1; prevObsWindowSize(1) = inf; end
                postObsWindowSize = [prevObsWindowSize(2:end) data.trial.(trialName).nFrames - endMiss(end)]; 
                if endMiss(end) == data.trial.(trialName).nFrames; postObsWindowSize(end) = inf; end

                % window specific interpolation requirements
                maxAllowMiss = repmat(threshold,[1 length(iWindow)]);
                minAllowPrev = repmat(2,[1 length(iWindow)]);
                minAllowPost = minAllowPrev;
                if startMiss(1) <= 2
                    maxAllowMiss(1) = round(threshold/2); 
                    minAllowPost(1) = 4;
                    minAllowPrev(1) = 0;
                end
                if endMiss(end) >= data.trial.(trialName).nFrames - 1
                    maxAllowMiss(end) = round(threshold/2); 
                    minAllowPost(end) = 0;
                    minAllowPrev(end) = 4;
                end

                % get can fix flags
                canFixWindow = (missingWindowSize <= maxAllowMiss) & (prevObsWindowSize >= minAllowPrev) & (postObsWindowSize >= minAllowPost);

                % if any interpolation requirements violated
                attemptInterp = 1;
                if ~all(canFixWindow)

                    % report
                    notes{length(notes)+1} = sprintf('          -Error: number of consecutive missed frames (%d) exceeds threshold (%d) for at least one missing data window or not enough observed data near a missing data window for interpolation.',max(diff([0 obsFrames data.trial.(trialName).nFrames])),threshold);
                    if option.reportStatus{1}; fprintf(notes{end}); end

                    % if deleting trial or marker then do so now
                    if any(strcmpi(option.deleteData{1},{'deleteTrial','trial'}))

                        % delete trial
                        notes{end} = strcat(notes{end},' Deleting trial data.');
                        if option.reportStatus{1}; fprintf(' Deleting trial data.\n'); end
                        data.trial.(trialName).trialDeleted = 1;
                        data.trial.(trialName).marker = [];
                        break;

                    elseif any(strcmpi(option.deleteData{1},{'deleteMarker','marker'}))

                        % delete marker
                        attemptInterp = 0;
                        ndeleted = ndeleted + 1;
                        notes{end} = strcat(notes{end},' Deleting marker data.');
                        if option.reportStatus{1}; fprintf(' Deleting marker data.\n'); end
                        data.trial.(trialName).deletedMarkers{ndeleted} = missingMarker{j};
                        data.trial.(trialName).marker = rmfield(data.trial.(trialName).marker,missingMarker{j});

                    else

                        % save with NaNs
                        notes{end} = strcat(notes{end},' Interpolating any possible windows; saving others with NaNs.');
                        if option.reportStatus{1}; fprintf(' Interpolating any possible windows; saving others with NaNs.\n'); end

                    end

                end

                % if attempting interp
                if attemptInterp
                    
                    if any(canFixWindow)
                        notes{length(notes)+1} = '               -Applying PCHIP interpolation';
                        if option.reportStatus{1}; fprintf([notes{end} '\n']); end
                    end

                    % for each missing data window
                    for w = 1:length(canFixWindow)

                        % if can fix
                        if canFixWindow(w)

                            % then report
                            missingFrames = startMiss(w):endMiss(w);
                            notes{length(notes)+1} = sprintf('                    -(window %d) Frames:',w);
                            iframe = 1;
                            lineFrames = 1;
                            while iframe <= missingWindowSize(w)

                                % if reached 15 frames for a line
                                if lineFrames > 15

                                    % display
                                    if option.reportStatus{1}; fprintf([notes{end} '\n']); end

                                    % new line
                                    lineFrames = 1;
                                    notes{length(notes)+1} = sprintf('                                         %d,',missingFrames(iframe));

                                else
                                    notes{end} = sprintf('%s %d, ',notes{end},missingFrames(iframe));
                                end
                                iframe = iframe + 1;
                                lineFrames = lineFrames + 1;
                            end
                            if option.reportStatus{1}; fprintf([notes{end} '\n']); end

                            % and interpolate
                            data.trial.(trialName).marker.(missingMarker{j}).position(:,missingFrames) = interp1(data.trial.(trialName).time(obsFrames)',obsData',data.trial.(trialName).time(missingFrames),'pchip')';

                        else

                            % otherwise there will be NaNs
                            % throw flag to disable filtering/resampling
                            hasMissingFrames = 1;

                        end

                    end

                end

            end

        end

        % new marker names if some deleted
        if ~data.trial.(trialName).trialDeleted 
            data.trial.(trialName).markerNames = fieldnames(data.trial.(trialName).marker);
            data.trial.(trialName).nMarkers = numel(data.trial.(trialName).markerNames);
        end

        % resample?
        if option.resample{1} > 0 && ~data.trial.(trialName).trialDeleted && ~hasMissingFrames

            % if already sampled at requested fs
            if option.resample{1} == data.trial.(trialName).samplingFrequency

                % no need to interp, report and exit
                if option.reportStatus{1}; fprintf('-Raw data was sampled at requested resample rate.  No resampling necessary.\n'); end

            else

                % status
                if option.reportStatus{1}; fprintf('-Resampling\n'); end

                % downsampling?
                downsample = 0;
                if option.resample{1} < data.trial.(trialName).samplingFrequency
                    downsample = 1;
                    [b,a] = butter(2, option.resample{1}/data.trial.(trialName).samplingFrequency,'low');
                end
                data.trial.(trialName).samplingFrequency = option.resample{1};

                % new and old time
                oldTime = data.trial.(trialName).time;
                data.trial.(trialName).time = oldTime(1):1/data.trial.(trialName).samplingFrequency:oldTime(end); % new time
                data.trial.(trialName).nFrames = length(data.trial.(trialName).time); % new nframes

                % for each marker
                for j = 1:data.trial.(trialName).nMarkers

                    % if downsampling
                    if downsample

                        % lowpass at half resample rate (anti alias)
                        data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position = filtfilt(b,a,data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position')';

                    end

                    % resample
                    data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position = ...
                        interp1(oldTime',data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position',data.trial.(trialName).time','pchip')';

                end

            end

        end

        % filter?
        if option.lowPassCutoff{1} > 0 && ~data.trial.(trialName).trialDeleted && ~hasMissingFrames

            % cutoff must be half sampling frequency
            if option.lowPassCutoff{1} < 0.5 * data.trial.(trialName).samplingFrequency

                % status
                if option.reportStatus{1}; fprintf('-Filtering (@ %f Hz)\n',option.lowPassCutoff{1}); end

                % filter coefs (4th order zero lag)
                [b,a] = butter(2, 2 * option.lowPassCutoff{1}/data.trial.(trialName).samplingFrequency,'low');

                % for each marker
                for j = 1:data.trial.(trialName).nMarkers

                    % filter
                    data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position = filtfilt(b,a,data.trial.(trialName).marker.(data.trial.(trialName).markerNames{j}).position')';

                end

            end

        end
        
        %
    
    end

end

end

function nameout = valfname(namein)
nameout = replace(namein,{' ','-',},'_');
validdec = hex2dec(dec2hex('abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'));
l = 1;
while l <= length(nameout)
    if ~any(hex2dec(dec2hex(nameout(l))) == validdec)
        nameout(l) = [];
    else
        l = l+1;
    end
end
if (48 <= hex2dec(dec2hex(nameout(1)))) && (hex2dec(dec2hex(nameout(1))) <= 57); nameout = strcat('x',nameout); end
end
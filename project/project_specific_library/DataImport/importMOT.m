function [ data ] = importMOT(varargin)
%Reed Gurchiek, 2018, reed.gurchiek@uvm.edu
%
%   importMOT imports force plate data in .mot format
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
%           -string denoting names of trials to keep
%           -if multiple trials then cell {'tname1','tname2',...}
%           -if 'choose' then user will be prompted to select one or
%               multiple trials from all within the directory
%           -if all, then all loaded
%           -trialName corresponds to the .mot filename, e.g. to read
%               walking.mot then use trialNames = {'walking'};
%           -the data associated with this trial will be stored in the
%               output data struct under the trial field but the name will
%               be modified to be a valid fieldname (e.g. '_' instead of
%               space)
%
%       3) transferMatrix (default: eye(3))
%           -3x3 matrix to rotate marker data to frame of user's choice
%           -NOTE: often vicon exports .mot ensuring x forward, y up, z lat
%
%       4) lowPassCutoff (default: 0)
%           -double, frequency at which to low pass filter marker data
%           -if 0, then filtering is not done
%           -if data is deleted either for whole trial or for single
%               plate, then no filtering is done
%           -if different cutoffs desired for different trials in
%               'trialNames' then lowPassCutoff should be cell = {x1 x2 xn}
%               where xi is desired cutoff for trialNamei
%           -cop data is not filtered
%
%       5) newStartTime (default: 0)
%           -double, effectively trims start of trial
%           -if 0, nothing trimmed
%           -if requested newStartTime is before time associated with first
%               sample in .mot file, then this time will be used instead
%
%       6) newEndTime (default: inf)
%           -double, effectively trims end of trial
%           -if inf, nothing trimmed
%           -if requested newEndTime is after time associated with last
%               sample in .mot file, then this time will be used instead
%
%       7) removeBias (default: 0)
%           -flag to control bias removal from force and moment data
%           -finds the 'stillest' (least variable) window of 0.25 seconds
%               defines the bias as the mean output during this window
%           -is trial specific so if want to remove bias for trialName1 but
%               not trialName2 then input 'removeBias' {1 0}.
%           -to remove bias from all just input 'removeBias' {1}
%
%       8) resample (default: 0)
%           -double, frequency to resample to.  if 0, no resample
%
%       9) reportStatus (default: 0)
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
%                                 samplingFrequency
%                                 nSamples
%                                 firstSample
%                                 lastSample
%                                 startTime: to sync with other instr.
%                                 endTime: to sync with other instr.
%                                 duration: in seconds
%                                 time: to sync with other instr.
%                                 nForcePlates
%                                 forcePlate(1).
%                                 forcePlate(2).
%                                 forcePlate(n).
%                                          force = 3xn
%                                          cop = 3xn
%                                          torque = 3xn
%
%   notes:
%       cell array of strings noting manipulations to handle missing trials
%       and missing force plates
%
%--------------------------------------------------------------------------
%% importMOT

% initialization
notes = {''};
option.dataDirectory = {'choose'};
option.trialNames = {'all'};
option.renameTrials = {0};
option.transferMatrix = {eye(3)};
option.lowPassCutoff = {0};
option.newStartTime = {0};
option.newEndTime = {inf};
option.removeBias = {0};
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
        
    % if char array, then must be a file path
    elseif ischar(varargin{1})
        
        % verify is a .mot
        if length(varargin{1}) <= 4
            error('If only one input argument is a char array then must be a file path to a .mot file. The char array input is not a path to a .mot file.')
        elseif ~strcmp(varargin{1}(end-3:end),'.mot')
            error('If only one input argument is a char array then must be a file path to a .mot file. The char array input is not a path to a .mot file.')
        else
            % parse directory and file name, reformulate as Name, Value
            % pair varargin
            varargin1 = varargin{1}; varargin = cell(1,4);
            ifilesep = regexp(varargin1,filesep);
            if isempty(ifilesep)
                varargin{1} = 'dataDirectory';
                varargin{2} = '';
                varargin{3} = 'trialNames';
                varargin{4} = {varargin1(1:end-4)};
            else
                varargin{1} = 'dataDirectory';
                varargin{2} = {varargin1(1:ifilesep(end))};
                varargin{3} = 'trialNames';
                varargin{4} = {varargin1(ifilesep(end)+1:end-4)};
            end
        end
        
    else
        error('If only one input argument then must be the option structure or a char array specifying path to .mot file to import')
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
        elseif any(strcmpi(varargin{2*k-1},{'report','status'})); varargin{2*k-1} = 'reportStatus';
        elseif any(strcmpi(varargin{2*k-1},{'directory','dir','path'})); varargin{2*k-1} = 'dataDirectory';
        elseif any(strcmpi(varargin{2*k-1},{'forcePlateTransferMatrix','plateTransferMatrix','transform','transferFunction','rotation','rotationMatrix'})); varargin{2*k-1} = 'transferMatrix';
        elseif any(strcmpi(varargin{2*k-1},{'newStart','startTime','start','startTrim','trimStart','trimStartTime'})); varargin{2*k-1} = 'newStartTime';
        elseif any(strcmpi(varargin{2*k-1},{'newEnd','endTime','end','endTrim','trimEnd','trimEndTime'})); varargin{2*k-1} = 'newEndTime';
        elseif any(strcmpi(varargin{2*k-1},{'cutoff','lowPass','cutoffFrequency','frequency','filter','filt'})); varargin{2*k-1} = 'lowPassCutoff';
        elseif any(strcmpi(varargin{2*k-1},{'biasRemoval','correctBias','biasCorrection'})); varargin{2*k-1} = 'removeBias';
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
    ok = questdlg('Select the AMTI data directory containing .mot files','Data Directory','OK','Cancel','OK');
    % cancel?
    if isempty(ok)||strcmp(ok,'Cancel'); error('importAMTI  terminated');
    % otherwise
    else
        % select dir
        option.dataDirectory{1} = uigetdir(cd,'Select data directory containing .mot files');
    end
end

% get trialnames if users wants to choose or wants all
if any(strcmpi(option.trialNames{1},{'choose' 'pick' '?' 'all' 'select'}))
    % save boolean for later
    userSelect = 0;
    if any(strcmpi(option.trialNames{1},{'choose' 'pick' '?' 'select'}))
        userSelect = 1;
    end
    dataFolder = dir(fullfile(option.dataDirectory{1},'*.mot'));
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
            option.trialNames{ifile} = replace(dataFolder(ifile).name,'.mot','');
            ifile = ifile+1;
        end
    end
    
    % select if user wants choose
    if userSelect
        % select trials to analyze
        itrialNames = listdlg('ListString',option.trialNames,'PromptString','Select the trial data to import:','SelectionMode','multiple');

        % cancel?
        if isempty(itrialNames); error('-importAMTI terminated');
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
        if isempty(dir(fullfile(option.dataDirectory{1},[option.trialNames{k} '.mot'])))
            notes{length(notes)+1} = sprintf('-Warning: user requested to import %s but it does not exist',fullfile(option.dataDirectory{1},[option.trialNames{k} '.mot']));
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
     temp = struct();
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

% if one start/end times given, then make such for all trials
if length(option.newStartTime) == 1; option.newStartTime = repmat(option.newStartTime,[1 numel(option.trialNames)]); end
if length(option.newEndTime) == 1; option.newEndTime = repmat(option.newEndTime,[1 numel(option.trialNames)]); end

% if one low pass cutoff, then make such for all trials
if length(option.lowPassCutoff) == 1; option.lowPassCutoff = repmat(option.lowPassCutoff,[1 numel(option.trialNames)]); end

% if one removeBias, then make such for all trials
if length(option.removeBias) == 1; option.removeBias = repmat(option.removeBias,[1 numel(option.trialNames)]); end

    
%% read force plate data

% initialize data structure
data.directory = option.dataDirectory{1};
data.trialNames = option.trialNames(:,2);

% for trial k
for k = 1:numel(data.trialNames)
    
    % status
    filename = fullfile(data.directory,[option.trialNames{k,1} '.mot']);
    if option.reportStatus{1}; fprintf('-Importing force plate data: %s\n',filename); end
    
    % inititate trial field
    trialName = data.trialNames{k};
    data.trial.(trialName) = struct('trialDeleted',0,'samplingFrequency',[],'nSamples',0,'time',[],'nForcePlates',[]);

    % open file
    data.trial.(trialName).filename = filename;
    fid = fopen(filename,'r');

    % num rows/columns
    within_header = true;
    nHeaderLines = 0;
    while within_header
        this_row = fgets(fid);
        if contains(this_row,'nRows')
            nRows = str2double(this_row(strfind(this_row,'=')+1:end));
        elseif contains(this_row,'nColumns')
            nColumns = str2double(this_row(strfind(this_row,'=')+1:end));
        elseif contains(this_row,'endheader')
            within_header = false;
        end
        nHeaderLines = nHeaderLines + 1;
    end
    fclose(fid);
    nHeaderLines = nHeaderLines + 1; % b/c column headers are line after endheader

    % num force plates
    nPlates = (nColumns - 1)/9;
    data.trial.(trialName).nForcePlates = nPlates;

    % read data
    dat = readmatrix(filename,'FileType','text','NumHeaderLines',nHeaderLines,'OutputType','double','Delimiter','\t');

    % keep rows
    rows = dat(:,1) >= option.newStartTime{k} & dat(:,1) <= option.newEndTime{k};
    
    % specs
    data.trial.(trialName).nSamples = length(rows);
    data.trial.(trialName).time = dat(rows,1)';
    data.trial.(trialName).samplingFrequency = 1/mean(diff(data.trial.(trialName).time));

    % force, cop, moment
    for j = 1:nPlates
        data.trial.(trialName).forcePlate(j).force = option.transferMatrix{1} * dat(rows,j*9-7:j*9-5)';
        data.trial.(trialName).forcePlate(j).cop = option.transferMatrix{1} * dat(rows,j*9-4:j*9-2)';
        data.trial.(trialName).forcePlate(j).torque = option.transferMatrix{1} * dat(rows,j*9-1:j*9+1)';

        % if remove bias
        if option.removeBias{k}

            % get most still quarter second
            i = staticndx(data.trial.(trialName).forcePlate(j).force,round(data.trial.(trialName).samplingFrequency/4));

            % get bias
            data.trial.(trialName).forcePlate(j).forceBias = mean(data.trial.(trialName).forcePlate(j).force(:,i(1):i(2)),2);
            data.trial.(trialName).forcePlate(j).momentBias = mean(data.trial.(trialName).forcePlate(j).moment(:,i(1):i(2)),2);

            % remove bias
            data.trial.(trialName).forcePlate(j).force = data.trial.(trialName).forcePlate(j).force - data.trial.(trialName).forcePlate(j).forceBias;
            data.trial.(trialName).forcePlate(j).moment = data.trial.(trialName).forcePlate(j).moment - data.trial.(trialName).forcePlate(j).momentBias;

        end
        
    end

    % resample?
    if option.resample{1} > 0

        % status
        if option.reportStatus{1}; fprintf('-Resampling to %f Hz\n',option.resample{1}); end

        % new frequency
        data.trial.(trialName).samplingFrequency = option.resample{1};

        % new and old time
        oldTime = data.trial.(trialName).time;
        newTime = data.trial.(trialName).time(1):1/data.trial.(trialName).samplingFrequency:data.trial.(trialName).time(end);
        data.trial.(trialName).time = newTime;
        data.trial.(trialName).nSamples = length(data.trial.(trialName).time);

        % for each force plate
        dataNames = {'force' 'cop' 'torque'};
        for j = 1:nPlates

            % for each dataType
            for i = 1:3

                % resample
                data.trial.(trialName).forcePlate(j).(dataNames{i}) = ...
                    interp1(oldTime',data.trial.(trialName).forcePlate(j).(dataNames{i})',newTime','pchip')';

            end

        end

    end

    % filter?
    if option.lowPassCutoff{k} > 0

        % status
        if option.reportStatus{1}; fprintf('-Filtering force and moment data (@ %f Hz)\n',option.lowPassCutoff{k}); end

        % for each force plate
        dataNames = {'force' 'torque'};
        for j = 1:nPlates

            % for each dataType
            for i = [1 2]

                % filter
                data.trial.(trialName).forcePlate(j).(dataNames{i}) = ...
                    bwfilt(data.trial.(trialName).forcePlate(j).(dataNames{i}),option.lowPassCutoff{k},data.trial.(trialName).samplingFrequency,'low',4);

            end

        end

    end
        
end
    
end

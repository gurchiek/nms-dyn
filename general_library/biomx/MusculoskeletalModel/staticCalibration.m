function model = staticCalibration(model,static,options)

% marker data from a static trial is stored in the static struct as per
% static.(markerName).position = 3xn double (global position from static
% standing trial in anatomic position). The mass and body weight of the
% subject can also be specified if there is available force plate data
% stored as per static.forcePlate(k).force(2,:) = 1xn double (force plate
% data during static standing trial). The use of multiple force plates can
% be specified in options. For example to use force plates 1 and 3 then
% input options.useForcePlates = [1 3]. The default is 1. The body mass can
% also be specified given gravitational acceleration as per
% options.gravitationalAcceleration (m/s/s). Default is 9.81. Positions and
% force data are averaged over some interval of time. The default interval
% is the length of the trial. If you specify
% options.nStaticSamples then the window in which the sum of the variances
% of all marker positions or force plate data is a minimum where the window
% length = options.nStaticSamples will be used for determining position
% and or body weight/mass data

% For force plate and marker data the
% y-axis (row 2) is the vertical direction per ISB standards.

% force plate and marker data must be sampled at the same rate

% INPUTS
% model - nms model struct
% static - struct, data during static trial
%           static.marker.(markerName).position = 3xn position data
%           static.forcePlate(k).force(2,:) = vertical GRF
% options - struct, calibration options
%           options.gravitationalAcceleration, default = 9.81
%           options.useForcePlates = 1
%           options.nStaticSamples = length of trial

%% static calibration

% initialization
defOptions.gravitationalAcceleration = 9.81;
defOptions.useForcePlates = 1;
defOptions.nStaticSamples = [];
if nargin == 2
    options = struct();
end
options = inherit(options,defOptions);
hasMarker = isfield(static,'marker');
if hasMarker; inputMarkerNames = fieldnames(static.marker); end
hasFP = isfield(static,'forcePlate');
if hasFP
    nsamp = size(static.forcePlate(options.useForcePlates(1)).force,2);
elseif hasMarker
    nsamp = size(static.marker.(inputMarkerNames{1}).position,2);
end
if isempty(options.nStaticSamples); options.nStaticSamples = nsamp; end

% static indices
if options.nStaticSamples == nsamp
    fpstill = 1:nsamp;
    mkrstill = 1:nsamp;
else
    nfp = 0;
    if hasFP
        nfp = length(options.useForcePlates);
        data = zeros(3*nfp,nsamp);
        i = 1:3;
        for k = 1:nfp
            data(i,1:nsamp) = static.forcePlate(options.useForcePlates(k)).force;
            i = i + 3;
        end
        fpstill = staticndx(data,options.nStaticSamples);
        fpstill = fpstill(1):fpstill(2);
    end
    if hasMarker
        nmkr = length(inputMarkerNames);
        data = zeros(3*nmkr,nsamp);
        i = 1:3;
        for k = 1:nmkr
            data(i,1:nsamp) = static.marker.(inputMarkerNames{k}).position;
            i = i + 3;
        end
        mkrstill = staticndx(data,options.nStaticSamples);
        mkrstill = mkrstill(1):mkrstill(2);
    end
end

% body weight (newtons), mass (kg)
if hasFP
    grf = zeros(1,length(fpstill));
    for k = 1:nfp
        grf = grf + static.forcePlate(options.useForcePlates(k)).force(2,fpstill);
    end
    model.bodyWeight = mean(grf);
    model.mass = model.bodyWeight / options.gravitationalAcceleration;
    fprintf('-Subject mass = %5.2f\n',model.mass)
end

% marker positions
if hasMarker
    
    % assign all markers specified in model marker names
    modelMarkerNames = model.markerNames;
    for k = 1:length(modelMarkerNames)
        if any(strcmp(modelMarkerNames{k},inputMarkerNames))
            model.marker.(modelMarkerNames{k}).position = mean(static.marker.(modelMarkerNames{k}).position(:,mkrstill),2);
        end
    end
    
end

end
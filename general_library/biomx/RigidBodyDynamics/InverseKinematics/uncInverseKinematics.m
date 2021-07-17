function trial = uncInverseKinematics(model,trial,options)

% solves unconstrained inverse kinematics for each segment in nms
% model.segmentNames

% INPUTS
% model - nms model struct
% trial - nms trial struct with marker data
% options - struct
%           options.coordinateSystem = char, coordinate system name
%           options.analysisName = char, analysis name
%           options.lowPassCutoff = butterworth filter low pass cutoff

% unpack
marker = trial.marker;
mkr = fieldnames(marker);
seg = model.segmentNames;
lp = options.lowPassCutoff;
cs = options.coordinateSystem;
analysis = options.analysisName;

% for each marker
for m = 1:length(mkr)
    [d1,d2] = fdiff(marker.(mkr{m}).position,1/trial.samplingFrequency,5);
    trial.marker.(mkr{m}).velocity = d1;
    trial.marker.(mkr{m}).acceleration = d2;
end

% for each segment
for s = 1:length(seg)
    
    % if model has desired cs
    if isfield(model.segment.(seg{s}),cs)
    
        % get reference configuration
        ref_q = model.segment.(seg{s}).(cs).orientation;
        ref_origin_world = model.segment.(seg{s}).(cs).position;
        ref_markers_world = modelSegmentMarkerPositions(model,seg{s});

        % segment markers in displaced configuration
        segmkr = model.segment.(seg{s}).markerNames;
        for m = 1:length(segmkr)
            if any(strcmp(segmkr{m},mkr))
                displaced_markers_world.(segmkr{m}).position = marker.(segmkr{m}).position;
            end
        end

        % get displaced configurations
        [orientation,position] = rigidBodyDisplacement_v1(ref_q,ref_origin_world,ref_markers_world,displaced_markers_world);

        body.segment.(seg{s}).(cs).orientation = orientation;
        body.segment.(seg{s}).(cs).position = position;

        % differentiate, low pass
        [~, w] = diffq(orientation,1,1/trial.samplingFrequency,5);
        v = fdiff(position,1/trial.samplingFrequency,5);
        if ~any(isnan(w(1,:))) && ~any(isnan(v(1,:)))
            w = bwfilt(w,lp,trial.samplingFrequency,'low',4);
            v = bwfilt(v,lp,trial.samplingFrequency,'low',4);
        end
        body.segment.(seg{s}).(cs).angularVelocity = w;
        body.segment.(seg{s}).(cs).velocity = v;

        clear displaced_markers_world
    
    end
    
end

trial.(analysis).body = body;

end
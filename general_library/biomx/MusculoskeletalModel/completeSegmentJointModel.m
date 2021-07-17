function model = completeSegmentJointModel(model)

% specify number of segments, segment indices, number of joints, joint
% indices, joint connections, number of markers for each segment and total,
% number of accelerometers/gyroscopes for each segment and total

% segments
model.segmentNames = fieldnames(model.segment);
model.nSegments = length(model.segmentNames);
model.segmentIndices = zeros(1,model.nSegments);
for k = 1:model.nSegments; model.segmentIndices(k) = model.segment.(model.segmentNames{k}).index; end

% joints
model.jointNames = fieldnames(model.joint);
model.nJoints = length(model.jointNames);
model.jointIndices = zeros(1,model.nJoints);
model.jointConnections = zeros(model.nJoints,2);
for k = 1:model.nJoints
    model.jointIndices(k) = model.joint.(model.jointNames{k}).index;
    
    % column 1 of row k is the index of the parent segment for joint k
    model.jointConnections(k,1) = model.segment.(model.joint.(model.jointNames{k}).parent.segment).index;
    
    % column 2 of row k is the index of the child segment for joint k
    model.jointConnections(k,2) = model.segment.(model.joint.(model.jointNames{k}).child.segment).index;
    
end

% marker and sensor counts
model.nMarkers = 0;
model.nAccelerometers = 0;
model.nGyroscopes = 0;
model.nMagnetometers = 0;
model.nBarometers = 0;
for k = 1:model.nSegments
    
    % markers
    model.segment.(model.segmentNames{k}).nMarkers = length(model.segment.(model.segmentNames{k}).markerNames);
    model.nMarkers = model.nMarkers + model.segment.(model.segmentNames{k}).nMarkers;
    for j = 1:model.segment.(model.segmentNames{k}).nMarkers
        model.segment.(model.segmentNames{k}).marker.(model.segment.(model.segmentNames{k}).markerNames{j}) = struct();
    end
    
    % acceleorometers
    model.segment.(model.segmentNames{k}).nAccelerometers = length(model.segment.(model.segmentNames{k}).accelerometerNames);
    model.nAccelerometers = model.nAccelerometers + model.segment.(model.segmentNames{k}).nAccelerometers;
    for j = 1:model.segment.(model.segmentNames{k}).nAccelerometers
        model.segment.(model.segmentNames{k}).accelerometer.(model.segment.(model.segmentNames{k}).accelerometerNames{j}) = struct();
    end
    
    % gyroscopes
    model.segment.(model.segmentNames{k}).nGyroscopes = length(model.segment.(model.segmentNames{k}).gyroscopeNames);
    model.nGyroscopes = model.nGyroscopes + model.segment.(model.segmentNames{k}).nGyroscopes;
    for j = 1:model.segment.(model.segmentNames{k}).nGyroscopes
        model.segment.(model.segmentNames{k}).gyroscope.(model.segment.(model.segmentNames{k}).gyroscopeNames{j}) = struct();
    end
    
    % magnetometers
    model.segment.(model.segmentNames{k}).nMagnetometers = length(model.segment.(model.segmentNames{k}).magnetometerNames);
    model.nMagnetometers = model.nMagnetometers + model.segment.(model.segmentNames{k}).nMagnetometers;
    for j = 1:model.segment.(model.segmentNames{k}).nMagnetometers
        model.segment.(model.segmentNames{k}).magnetometer.(model.segment.(model.segmentNames{k}).magnetometerNames{j}) = struct();
    end
    
    % barometers
    model.segment.(model.segmentNames{k}).nBarometers = length(model.segment.(model.segmentNames{k}).barometerNames);
    model.nBarometers = model.nBarometers + model.segment.(model.segmentNames{k}).nBarometers;
    for j = 1:model.segment.(model.segmentNames{k}).nBarometers
        model.segment.(model.segmentNames{k}).barometer.(model.segment.(model.segmentNames{k}).barometerNames{j}) = struct();
    end
    
end

% all markers
model.markerSegments = cell(model.nMarkers,1);
model.markerNames = cell(model.nMarkers,1);
model.markerTrustValue = zeros(1,model.nMarkers);
i = 1;
for k = 1:model.nSegments
    
    for j = 1:model.segment.(model.segmentNames{k}).nMarkers

        model.markerTrustValue(i) = model.segment.(model.segmentNames{k}).markerTrustValue(j);
        model.markerNames{i} = model.segment.(model.segmentNames{k}).markerNames{j};
        model.markerSegments{i} = model.segmentNames{k};
        i = i + 1;
        
    end
    
end

% all accelerometers
model.accelerometerSegments = cell(model.nAccelerometers,1);
model.accelerometerNames = cell(model.nAccelerometers,1);
i = 1;
for k = 1:model.nSegments
    
    for j = 1:model.segment.(model.segmentNames{k}).nAccelerometers

        model.accelerometerNames{i} = model.segment.(model.segmentNames{k}).accelerometerNames{j};
        model.accelerometerSegments{i} = model.segmentNames{k};
        i = i + 1;
        
    end
        
end

% all gyroscopes
model.gyroscopeSegments = cell(model.nGyroscopes,1);
model.gyroscopeNames = cell(model.nGyroscopes,1);
i = 1;
for k = 1:model.nSegments
    
    for j = 1:model.segment.(model.segmentNames{k}).nGyroscopes

        model.gyroscopeNames{i} = model.segment.(model.segmentNames{k}).gyroscopeNames{j};
        model.gyroscopeSegments{i} = model.segmentNames{k};
        i = i + 1;
        
    end
        
end

% all magnetometers
model.magnetometerSegments = cell(model.nMagnetometers,1);
model.magnetometerNames = cell(model.nMagnetometers,1);
i = 1;
for k = 1:model.nSegments
    
    for j = 1:model.segment.(model.segmentNames{k}).nMagnetometers

        model.magnetometerNames{i} = model.segment.(model.segmentNames{k}).magnetometerNames{j};
        model.magnetometerSegments{i} = model.segmentNames{k};
        i = i + 1;
        
    end
        
end

% all barometers
model.barometerSegments = cell(model.nBarometers,1);
model.barometerNames = cell(model.nBarometers,1);
i = 1;
for k = 1:model.nSegments
    
    for j = 1:model.segment.(model.segmentNames{k}).nBarometers

        model.barometerNames{i} = model.segment.(model.segmentNames{k}).barometerNames{j};
        model.barometerSegments{i} = model.segmentNames{k};
        i = i + 1;
        
    end
        
end

% constraints
nConstraints = model.nJoints * 3; % 3 per joint (non-dislocating)
nConstraints = nConstraints + model.nSegments; % 1 per segment (unit quaternion)
for j = 1:model.nJoints
    nConstraints = nConstraints + 3 - model.joint.(model.jointNames{j}).rotationDOF; % 1 for each dof less than 3
end
model.nConstraints = nConstraints;

end


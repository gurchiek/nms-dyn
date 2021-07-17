function segment = modelIndex2Segment(model,index)

% returns segment (char, name of segment) corresponding the the input index
% (integer)

segment = model.segmentNames{model.segmentIndices == index};

end
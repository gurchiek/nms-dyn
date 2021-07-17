function marker = modelSegmentMarkerPositions(model,segmentName)

% returns global position of each segment marker for segmentName in
% reference configuration

for m = 1:model.segment.(segmentName).nMarkers
    marker.(model.segment.(segmentName).markerNames{m}).position = model.marker.(model.segment.(segmentName).markerNames{m}).position;
end

end
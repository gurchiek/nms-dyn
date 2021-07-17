function model = getLocalMarkerPositions(model,cs)

% for each segment
seg = fieldnames(model.segment);
for s = 1:length(seg)
    
    % for each marker
    segmkr = model.segment.(seg{s}).markerNames;
    for m = 1:model.segment.(seg{s}).nMarkers
        
        % get relative to frame origin and rotate to frame
        model.segment.(seg{s}).marker.(segmkr{m}).position.(cs) = qrot(model.segment.(seg{s}).(cs).orientation, model.marker.(segmkr{m}).position - model.segment.(seg{s}).(cs).position,'inverse');
        
    end
                                                                    
    
    
end

end
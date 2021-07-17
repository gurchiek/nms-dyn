function segment = modelMarker2Segment(model,marker)
segment = model.markerSegments{strcmp(marker,model.markerNames)};
end
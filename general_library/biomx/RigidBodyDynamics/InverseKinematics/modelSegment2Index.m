function index = modelSegment2Index(model,segment)
index = model.segmentIndices(strcmp(segment,model.segmentNames));
end
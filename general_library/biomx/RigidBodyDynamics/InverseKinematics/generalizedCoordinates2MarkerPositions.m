function marker = generalizedCoordinates2MarkerPositions(model,x,markerNames,cs)

% returns global marker positions corresponding to the set of input
% generalized coordinates (x) and the local marker positions in each
% marker's corresponding segment frame corresponding to the input
% coordinate system name (cs, char)

% get all if none given
if nargin == 2; markerNames = model.markerNames; end

% for each marker
marker = struct();
for m = 1:length(markerNames)
    
    % marker index
    imarker = strcmp(markerNames{m},model.markerNames);
    
    % continue if exists
    if any(imarker)
    
        % get marker segment and segment index
        seg = model.markerSegments{imarker};
        iseg = modelSegment2Index(model,seg);

        % get marker position in acs frame
        v = model.segment.(seg).marker.(markerNames{m}).position.(cs);

        % get seg origin position and orientation
        p = x(7*iseg - 6 : 7*iseg - 4,:);
        q = x(7*iseg - 3 : 7*iseg,:);

        % transform
        marker.(markerNames{m}).position = p + qrot(q,v);
        
    end
    
end
    
end
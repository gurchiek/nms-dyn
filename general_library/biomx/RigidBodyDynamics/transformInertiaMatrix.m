function model = transformInertiaMatrix(model,cs)

% transforms the principal inertia matrix (diagonal) in
% segment.(segmentName).principal.inertiaMatrix (must already be computed)
% to the frame specified by the input cs (char, e.g. 'isb'). 

% for each segment
for k = 1:length(model.segmentNames)
    
    % dcm such that v_cs = R * v_principal
    R = convq(qprod(qconj(model.segment.(model.segmentNames{k}).(cs).orientation),model.segment.(model.segmentNames{k}).principal.orientation),'dcm');
    
    % transform
    model.segment.(model.segmentNames{k}).(cs).inertiaTensor = R * model.segment.(model.segmentNames{k}).principal.inertiaTensor * R';
    
end

end
function body = getGlobalBodyContourGeometry(model,body,contour,cs)

% updates the global position and axis of a body contour for each frame
% given the kinematics of the coordinate system (cs) in the nms body struct
% and using reference data from the nms model struct. The global
% position/axis of the contour must be specified in the nms model struct
% for the input coordinate system

% get local position/axis
p = model.bodyContour.(contour).local.(cs).position;
a = model.bodyContour.(contour).local.(cs).axis;
seg = model.bodyContour.(contour).segment;
pseg = body.segment.(seg).(cs).position;
qseg = body.segment.(seg).(cs).orientation;

% get global
body.bodyContour.(contour).position = pseg + qrot(qseg,p);
body.bodyContour.(contour).axis = qrot(qseg,a);

end
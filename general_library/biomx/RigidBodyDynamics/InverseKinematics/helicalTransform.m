function u2 = helicalTransform(u1,axis,angle,point,trans)
% see spoor and veldpaus 1980 eq 26
u2 = u1 + trans * axis + (1 - cos(angle)) * cross(axis,cross(axis,u1 - point)) + sin(angle) * cross(axis,u1 - point);
end
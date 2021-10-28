function [y,x] = delpKnee(f)

% computes antero posterior (x) and superior-inferior (y) translations from
% the delp 2392 knee model given flexion angle f

% antero posterior (positive is anterior), negated for left leg
u = [-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
v = [-0.0032 0.00179 0.00411 0.0041 0.00212 -0.001 -0.0031 -0.005227 -0.005435 -0.005574 -0.005435 -0.00525];
x = interp1(u,v,f,'pchip');

% superior inferior
u = [-2.0944 -1.22173 -0.523599 -0.349066 -0.174533 0.159149 2.0944];
v = [-0.4226 -0.4082 -0.399 -0.3976 -0.3966 -0.395264 -0.396];
y = interp1(u,v,f,'pchip');

end
function [a,i,y,x,z] = laiarnoldKnee(f)

% same as walker knee except uses values for interpolation from
% LaiArnold2017 osim model, differs from rajagopalKnee only in the x/y
% translations (rajagopal used a different joint center)

% rotation order: flexion, adduction, internal rotation

% knee angles for interpolation
u = [0 0.174533 0.349066 0.523599 0.698132 0.872665 1.0472 1.22173 1.39626 1.5708 1.74533 1.91986 2.0944];

% adduction
v = [0 0.0126809 0.0226969 0.0296054 0.0332049 0.0335354 0.0308779 0.0257548 0.0189295 0.011407 0.00443314 -0.00050475 -0.0016782];
a = interp1(u,v,f,'pchip');

% internal rotation (negative for left leg)
v = [0 0.059461 0.109399 0.150618 0.18392 0.210107 0.229983 0.24435 0.254012 0.25977 0.262428 0.262788 0.261654];
i =  interp1(u,v,f,'pchip');

% superior inferior
v = [0 0.000301 0.000143 -0.000401 -0.001233 -0.002243 -0.003316 -0.004346 -0.005239 -0.005924 -0.006361 -0.006539 -0.00648];
y = interp1(u,v,f,'pchip');

% antero posterior (positive is anterior), negated for left leg
v = [0 0.001055 0.002061 0.00289 0.003447 0.003676 0.003559 0.00311 0.002373 0.001418 0.000329 -0.000805 -0.001898];
x = interp1(u,v,f,'pchip');

% medio lateral (not specified in walker's paper and not in rajagopal...)
% for right leg, positive is medial, for left leg, positive is lateral
v = [0 5.3e-05 0.000188 0.000378 0.000597 0.000825 0.001045 0.001247 0.00142 0.001558 0.001661 0.001728 0.00176];
z = interp1(u,v,f,'pchip');

end
function [phi,dphi_dlm] = pennationConstantThickness(lm,muscle)

% l is muscle length relative to optimal length, phi0 is pennation angle at
% optimal fiber length in radians. Assumes constant volume/thickness of
% muscle

phi0 = muscle.phi0;
l0 = muscle.optimalFiberLength;

x = l0 * sin(phi0) ./ lm;
phi = asin(x);
dphi_dlm = -x ./ lm ./ sqrt(1 - x.*x);

end
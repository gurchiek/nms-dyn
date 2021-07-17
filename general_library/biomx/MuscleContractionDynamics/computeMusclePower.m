function power = computeMusclePower(force,fiberVelocity,fiberLength,pennation,time)

% IN
% force in newtons (directed along line of action of mtu, ie, after cos(phi) projection)
% fiber velocity in meters/second
% fiber length in meters
% pennation angle in radians
% time array in seconds

% OUT
% power in watts

phidot = fdiff(pennation,time,5);
sdot = fiberVelocity .* cos(pennation) - fiberLength .* sin(pennation) .* phidot;
% s = fiberLength .* cos(pennation); sdot2 = fdiff(s,time,5); % this is a numerical computation of sdot, should closely match sdot from above
power = -force .* sdot; % negate since positive force is in shortening (negative velocity) direction
% p2 = -force .* fiberVelocity; % this is the wrong way to compute muscle power

end
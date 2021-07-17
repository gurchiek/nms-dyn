function [f,s] = tflquadratic(lm,lmtu,muscle)

% justification for schutte model (see buchanan 04)
% tendons fail at 3.5*Fmax at 10% strain
% tendon force = Fmax at 3.3%
% tendons are linearly elastic starting at 1.27%

s0 = muscle.maxForceTendonStrain;
m = muscle.tendonElasticModulus;
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
ls = muscle.tendonSlackLength;

% linear region intercept
b = 1 - m * s0;

st = -2 * b / m;
a = m / 2 / st;

% tendon length
lt = lmtu - sqrt(lm.*lm - l0*l0*sin(phi0)*sin(phi0));

f = zeros(1,length(lt));
d1 = zeros(1,length(lt));

% strain
s = (lt - ls)/ls;

% crimp flattening region
i = s > 0 & s < st;
f(i) = a * s(i).^2;

% linear elasticity region
i = s >= st;
f(i) = m * s(i) + b;

end
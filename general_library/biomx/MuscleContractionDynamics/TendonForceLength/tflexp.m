function [f,d1] = tflexp(lm,lmtu,muscle)

s0 = muscle.maxForceTendonStrain;
k = muscle.tendonNonlinearExpShapeFactor;
ek = exp(k);
m = muscle.tendonElasticModulus;
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
ls = muscle.tendonSlackLength;

% linear region intercept
b = 1 - m * s0;

Ft = b / (1 - k * ek / (ek - 1));
st = (Ft - b) / m;

% tendon length
lt = lmtu - sqrt(lm.*lm - l0*l0*sin(phi0)*sin(phi0));

f = zeros(1,length(lt));
d1 = zeros(1,length(lt));

% strain
s = (lt - ls)/ls;

% nonlinear region (uncrimping)
i = 0 < s & s < st;
f(i) = Ft / (ek - 1) * (exp(k * s(i) / st) - 1);
d1(i) = k / st * Ft / (ek - 1) * exp(k*s(i)/st);

% linear region
i = s >= st;
f(i) = m * s(i) + b;
d1(i) = m;

end
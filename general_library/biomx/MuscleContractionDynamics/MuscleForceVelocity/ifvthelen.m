function [vm,dvm_dlm,ft] = ifvthelen(lm,act,lmtu,muscle)

l0 = muscle.optimalFiberLength;
vmax = muscle.normalizedMaxVelocity * l0;
a = muscle.coefShorteningHeat;
flen = muscle.maxEccentricForce;

% tendon force 
ft = muscle.tendonForceLengthFunction(lm,lmtu,muscle);

% passive muscle force length
fp = muscle.passiveForceLengthFunction(lm,muscle);

% active muscle force length
fl = muscle.activeForceLengthFunction(lm,act,muscle);

% pennation angle
phi = muscle.pennationFunction(lm,muscle);

% normalized force velocity scalar
f_ = ft ./ cos(phi) - fp;

b = zeros(1,length(ft));

% shortening
i = f_ <= fl;
b(i) = fl(i) + f_(i)/a;

% lengthening
i = ~i;
b(i) = (2 + 2/a) * (fl(i) * flen - f_(i)) / (flen - 1);

% muscle velocity
v = (0.25 + 0.75 * act) .* (f_ - fl) ./ b;

vm = v * vmax;

dvm_dlm = [];

end
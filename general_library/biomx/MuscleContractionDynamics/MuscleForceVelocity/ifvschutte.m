function [vm,dvm_dlm,ft] = ifvschutte(lm,act,lmtu,muscle)

l0 = muscle.optimalFiberLength;
d = muscle.coefDamping;
vmax = muscle.normalizedMaxVelocity * l0;
a = muscle.coefShorteningHeat;

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

v = zeros(1,length(ft));

% shortening
i = f_ <= fl;
b = f_(i)/a + fl(i) + d;
v(i) = (b - sqrt(b.^2 - 4 * d / a * (f_(i) - fl(i)))) * a / 2 / d;

% lengthening
i = ~i;
k = a / (a + 1);
b = f_(i) - 1.8 * fl(i) - 0.13 * d * k;
v(i) = (b + sqrt(b.^2 + 4 * d * 0.8 * k * (f_(i) - fl(i)))) / 2 / d; % schutte thesis is missing the ^2 for b in sqrt()

vm = v * vmax;

dvm_dlm = [];

end
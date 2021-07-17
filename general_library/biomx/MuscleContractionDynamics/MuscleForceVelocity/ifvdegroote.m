function [vm,dvm_dlm,ft] = ifvdegroote(lm,act,lmtu,muscle)

l0 = muscle.optimalFiberLength;
vmax = muscle.normalizedMaxVelocity * l0;

c1 = -0.318323436899127;
c2 = -8.149156043475250;
c4 = 0.885644059915004;

% tendon force 
[ft,dft_dlm] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);

% passive muscle force length
[fp,dfp_dlm] = muscle.passiveForceLengthFunction(lm,muscle);

% active muscle force length
[afl,dafl_dlm] = muscle.activeForceLengthFunction(lm,act,muscle);

% pennation angle
[phi,dphi_dlm] = muscle.pennationFunction(lm,muscle);
fphi = cos(phi);
dfphi_dlm = -sin(phi) .* dphi_dlm;

% normalized force velocity scalar
fv = (ft ./ cos(phi) - fp) ./ afl;
dfv_dlm = (dft_dlm ./ fphi - ft ./ fphi ./ fphi .* dfphi_dlm - dfp_dlm) ./ afl - (ft .* fphi - fp) ./ afl ./ afl .* dafl_dlm;

vn = sinh((fv - c4) / c1) / c2;
vm = vn * vmax;
dvm_dlm = vmax / c2 / c1 * cosh((fv - c4) / c1) .* dfv_dlm;

end
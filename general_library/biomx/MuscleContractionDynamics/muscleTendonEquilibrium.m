function [f,df_dlm,df_dvm,muscleForce] = muscleTendonEquilibrium(t,lm,vm,muscle,time)

% for implicit contraction dynamics solvers (ode15i)

vmax = muscle.normalizedMaxVelocity * muscle.optimalFiberLength;
F0 = muscle.maxForce;

% interpolate inputs
lmtu = interp1(time.mtuKinematics,muscle.mtu.length,t,'pchip');
a = interp1(time.excitation, muscle.activation,t,'pchip');

% activation nonlinearity
a = muscle.activationNonlinearityFunction(a,muscle);

% tendon force
[ft,dft_dlm] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
muscleForce = F0 * ft;

% pennation angle
[phi,dphi_dlm] = muscle.pennationFunction(lm,muscle);
fphi = cos(phi);
dfphi_dlm = -sin(phi) * dphi_dlm;

% active muscle force length
[afl,adfl_dlm] = muscle.activeForceLengthFunction(lm,a,muscle);

% passive muscle force length
[fp,dfp_dlm] = muscle.passiveForceLengthFunction(lm,muscle);

% force velocity
[fv,dfv_dvm] = muscle.forceVelocityFunction(vm,muscle);

% equilibrium equation
d = muscle.coefDamping;
f = (fv * afl + fp + d * vm / vmax) * fphi - ft;

% derivatives
df_dvm = (dfv_dvm .* afl + d / vmax) .* fphi;
df_dlm = (fv .* adfl_dlm + dfp_dlm) .* fphi + (fv .* afl + fp + d * vm / vmax) * dfphi_dlm - dft_dlm;

end
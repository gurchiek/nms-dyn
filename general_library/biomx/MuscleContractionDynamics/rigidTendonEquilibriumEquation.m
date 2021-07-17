function muscle = rigidTendonEquilibriumEquation(muscle,time,ind)

% interpolate inputs
lmtu = interp1(time.mtuKinematics,muscle.mtu.length,time.simulation(ind),'pchip');
vmtu = interp1(time.mtuKinematics,muscle.mtu.velocity,time.simulation(ind),'pchip');
act = interp1(time.excitation,muscle.activation,time.simulation(ind),'pchip');

% mtu params
lt = muscle.tendonSlackLength;
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
F0 = muscle.maxForce;
d = muscle.coefDamping;
v0 = muscle.normalizedMaxVelocity * l0;

% fiber length and velocity
s = lmtu - lt;
h = l0 * sin(phi0);
lm = sqrt(s.*s + h*h);
vm = s .* vmtu ./ lm;

% passive/active muscle force
act = muscle.activationNonlinearityFunction(act,muscle);
afl = muscle.activeForceLengthFunction(lm,act,muscle);
fv = muscle.forceVelocityFunction(vm,muscle);
fp = muscle.passiveForceLengthFunction(lm,muscle);
phi = muscle.pennationFunction(lm,muscle);

% store
muscle.force(ind) = F0 * (fv * afl + fp + d * vm / v0) * cos(phi);
muscle.fiberLength(ind) = lm;
muscle.fiberVelocity(ind) = vm;

end
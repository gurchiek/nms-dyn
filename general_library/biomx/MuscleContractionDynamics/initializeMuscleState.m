function muscle = initializeMuscleState(muscle,time)

n = length(time.simulation);
muscle.fiberLength = zeros(1,n);
muscle.fiberVelocity = zeros(1,n);
muscle.force = zeros(1,n);
muscle.power = zeros(1,n);
muscle.work = zeros(1,n);

% assume rigid tendon
lmtu = interp1(time.mtuKinematics,muscle.mtu.length,time.simulation(1),'pchip');
lt = muscle.tendonSlackLength + 0.001; % slightly strained
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
s = lmtu - lt;
h = l0*sin(phi0);
lm = sqrt(s*s + h*h);
vm = s/lm * interp1(time.mtuKinematics,muscle.mtu.velocity,time.simulation(1),'pchip');

options = muscle.implicitSolverOptions;
[muscle.fiberLength(1),muscle.fiberVelocity(1)] = decic(muscle.implicitDynamics,time.simulation(1),lm,[],vm,[],options,muscle,time);
[~,~,~,muscle.force(1)] = muscle.implicitDynamics(time.simulation(1),muscle.fiberLength(1),muscle.fiberVelocity(1),muscle,time);

end
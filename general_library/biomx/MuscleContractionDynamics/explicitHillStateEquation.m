function vm = explicitHillStateEquation(t,lm,muscle,time)

% interpolate inputs
lmtu = interp1(time.mtuKinematics,muscle.mtu.length,t,'pchip');
a = interp1(time.excitation, muscle.activation,t,'pchip');

vm = muscle.inverseForceVelocityFunction(lm,a,lmtu,muscle);

end
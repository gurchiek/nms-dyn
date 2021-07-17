function muscle = simulateMuscleContraction(muscle,time,ispan)

%{ 


%}

istart = ispan(1);
iend = ispan(2);

for k = istart:iend-1

    % 
    [~,x] = muscle.solver(muscle.stateEquation,[time(k) time(k+1)],muscle.fiberLength(:,k),options,muscle,time,k);
    muscle.state(:,k+1) = x;
    muscle.force(:,k+1) = muscle.forceNow;
    

end

end

function dxdt = dynamics(t,x,muscle,time)

% states
a = x(1:end-1);
lm = x(end);

% normalize
lopt = muscle.optimalFiberLength;
lm = lm / muscle.optimalFiberLength;

% inputs
e = interp1(time,muscle.excitation,t,'pchip');
lmtu = interp1(time,muscle.mtu.length,t,'pchip');
a = interp1(time, muscle.activation,t,'pchip');

% activation nonlinearity
a = muscle.activationNonlinearity(a,muscle);

% pennation angle
phi = muscle.pennation(lm,muscle);

% get tendon length
lt = lmtu - lm * cos(phi);

% get tendon force
ft = muscle.tendonForceLength(lt,muscle);
muscle.forceNow = ft;

% get muscle velocity
dldt = muscle.inverseForceVelocity(ft,lm,a,muscle);
dldt = dldt * muscle.normalizedVmax * muscle.optimalFiberLength;

% activation dynamics
dadt = muscle.activationDynamics(a,e,muscle);

% packup
dxdt = [dadt; dldt];


end
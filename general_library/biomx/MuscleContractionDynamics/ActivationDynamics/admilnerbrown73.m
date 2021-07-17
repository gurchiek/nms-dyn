function a = admilnerbrown73(time,e,muscle)

% wn = natural frequency
% d = emd

d = muscle.electromechanicalDelay;
d = round(d/mean(diff(time)));
wn = mean([1/muscle.activationTimeConstant,1/(muscle.activationTimeConstant/muscle.activationDeactivationRatio)]);
e(e < muscle.minExcitation) = muscle.minExcitation;
options = muscle.activationDynamicsSolverOptions;

% runge kutta
u01 = e(1);
u02 = (e(2) - e(1)) / (time(2) - time(1));
[~,a] = muscle.activationDynamicsSolver(@(t,a) diffeq(t,a,e,time,wn),time(1:end-d),[u01; u02],options);
a = [a(1,1)*ones(1,d) a(:,1)'];

end

function dadt = diffeq(t,a,e,time,wn)
e = interp1(time,e,t,'pchip');
dadt = zeros(2,1);
dadt(1) = a(2);
dadt(2) = -2 * wn * a(2) - wn * wn * a(1) + wn * wn * e;
end
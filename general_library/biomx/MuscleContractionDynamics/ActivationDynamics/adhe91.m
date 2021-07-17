function a = adhe91(time,e,muscle)

% c1 = activation constant
% c2 = deactivation constant
% d = emd

d = muscle.electromechanicalDelay;
d = round(d/mean(diff(time)));
tact = muscle.activationTimeConstant;
tdeact = tact/muscle.activationDeactivationRatio;
e(e < muscle.minExcitation) = muscle.minExcitation;
options = muscle.activationDynamicsSolverOptions;

c2 = 1/tdeact;
c1 = 1/tact - c2;
[~,a] =  muscle.activationDynamicsSolver(@(t,a) diffeq(t,a,e,time,c1,c2),time(1:end-d),e(1),options);
a = [a(1)*ones(1,d) a'];

end

function dadt = diffeq(t,a,e,time,c1,c2)
e = interp1(time,e,t,'pchip');
dadt = (e - a) * (c1 * e + c2);
end
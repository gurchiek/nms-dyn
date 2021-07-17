function a = adwinters88(time,e,muscle)

% c1 = activation constant
% c2 = deactivation constant
% d = emd

d = muscle.electromechanicalDelay;
d = round(d/mean(diff(time)));
c1 = mean([muscle.activationTimeConstant,muscle.activationTimeConstant/muscle.activationDeactivationRatio]);
e(e < muscle.minExcitation) = muscle.minExcitation;
options = muscle.activationDynamicsSolverOptions;

[~,a] = muscle.activationDynamicsSolver(@(t,a) diffeq(t,a,e,time,c1),time(1:end-d),e(1),options);
a = [a(1)*ones(1,d) a'];

end

function dadt = diffeq(t,a,e,time,c1)
e = interp1(time,e,t,'pchip');
dadt = (e - a) / c1;
end
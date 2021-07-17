function a = adwinters95(time,e,muscle)

% c1 = activation constant
% c2 = deactivation constant
% d = emd

d = muscle.electromechanicalDelay;
d = round(d/mean(diff(time)));
c1 = muscle.activationTimeConstant;
c2 = c1/muscle.activationDeactivationRatio;
e(e < muscle.minExcitation) = muscle.minExcitation;
options = muscle.activationDynamicsSolverOptions;

[~,a] = muscle.activationDynamicsSolver(@(t,a) diffeq(t,a,e,time,c1,c2),time(1:end-d),e(1),options);
a = [a(1)*ones(1,d) a'];

end

function dadt = diffeq(t,a,e,time,c1,c2)
e = interp1(time,e,t,'pchip');
if e > a; tau = c1 * (0.5 + 1.5 * a); % activation
else; tau = c2 / (0.5 + 1.5 * a); end % deactivation
dadt = (e - a) / tau;
end
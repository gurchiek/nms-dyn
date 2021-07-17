function a = adwinters95c(time,e,muscle)

% tanh smooth approximation to Winters 1995 discontinuous piecewise
% nonlinear first order activation model (also see Thelen 03). This first
% presented by De Groote et al. 2016
% c1 = activation constant
% c2 = deactivation constant
% d = emd

d = muscle.electromechanicalDelay;
d = round(d/mean(diff(time)));
c1 = muscle.activationTimeConstant;
c2 = c1/muscle.activationDeactivationRatio;
b = muscle.activationDeactivationTransitionSmoothness; % 0.1
e(e < muscle.minExcitation) = muscle.minExcitation;
options = muscle.activationDynamicsSolverOptions;

[~,a] = muscle.activationDynamicsSolver(@(t,a) diffeq(t,a,e,time,c1,c2,b),time(1:end-d),e(1),options);
a = [a(1)*ones(1,d) a'];

end

function dadt = diffeq(t,a,e,time,c1,c2,b)
e = interp1(time,e,t,'pchip');
f = 0.5 * tanh(b * (e - a));
s = 0.5 + 1.5 * a;
dadt = (1 / c1 ./ s .* (f + 0.5) + s / c2 * (0.5 - f) ) .* (e - a);
end
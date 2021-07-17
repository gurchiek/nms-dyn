function a = adlloyd03(time,e,muscle)

% c1, c2 = see paper
% d = emd

d = muscle.electromechanicalDelay;
dt = mean(diff(time));
d = round(d/dt);
c1 = muscle.dt2ActivationDynamicsC1;
c2 = muscle.dt2ActivationDynamicsC2;
e(e < muscle.minExcitation) = muscle.minExcitation;

b1 = c1 + c2;
b2 = c1 * c2;
alpha = 1.0 + b1 + b2;

nappend = d;
if nappend < 2; nappend = 2; end
e = [e(1)*ones(1,nappend) e];
a = e;
for k = nappend+1:length(e)

    a(k) = alpha * e(k-d) - b1 * a(k-1) - b2 * a(k-2);

end
a(1:nappend) = [];

end
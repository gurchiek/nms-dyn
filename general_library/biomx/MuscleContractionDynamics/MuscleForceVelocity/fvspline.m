function [f,df_dvm,d2f_dvm2] = fvspline(vm,muscle)

lopt = muscle.optimalFiberLength;
vmax = muscle.normalizedMaxVelocity * lopt;
a = muscle.coefShorteningHeat;
fvecc = muscle.eccentricForceVelocityFunction;

vn0 = -1:0.03:0;
vn0 = [vn0 a/4,a/3,a/2,a,3*a/2:0.1:1.0];
vm0 = vn0 * vmax;

f0ecc = fvecc(vm0(vm0>0),muscle);
f0con = fvhill(vn0(vn0<=0),a);
f0 = [f0con f0ecc];

pp = spline(vm0,f0);
pp1 = mkpp(vm0,pp.coefs(:,1:3)*diag([3 2 1]),1);
pp2 = mkpp(vm0,pp1.coefs(:,1:2)*diag([2 1]),1);

f = ppval(pp,vm);
df_dvm = ppval(pp1,vm);
d2f_dvm2 = ppval(pp2,vm);

end
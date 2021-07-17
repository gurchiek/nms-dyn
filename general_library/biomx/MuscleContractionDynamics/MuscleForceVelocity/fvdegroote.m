function [f,df_dvm] = fvdegroote(vm,muscle)


lopt = muscle.optimalFiberLength;
vmax = muscle.normalizedMaxVelocity * lopt;
vn = vm / vmax;

c1 = -0.318323436899127;
c2 = -8.149156043475250;
c3 = -0.374121508647863;
c4 = 0.885644059915004;

g = c2 * vn + c3;
gs = sqrt(g.*g + 1);

f = c4 + c1 * log( g + gs );
df_dvm = c1 * c2 / vmax * (1 + g ./ gs) ./ (g + gs);

end
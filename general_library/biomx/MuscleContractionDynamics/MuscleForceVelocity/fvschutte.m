function f = fvschutte(vm,muscle)

% normalized muscle force-velocity relationship as per Schutte thesis eq
% A.3.7. uses fvhill for shortening (v <= 0)

lopt = muscle.optimalFiberLength;
vmax = muscle.normalizedMaxVelocity * lopt;
vn = vm / vmax;

a = muscle.coefShorteningHeat;

f = zeros(1,length(vn));
f(vn<=0) = fvhill(vn(vn<=0),a);
b = a/(a+1);
f(vn>0) = (1.8 * vn(vn>0) + 0.13 * b) ./ (vn(vn>0) + 0.13 * b);

end
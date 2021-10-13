function [f,d1] = tflblemker(lm,lmtu,muscle)

ls = muscle.tendonSlackLength;
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
L1 = muscle.tendonMultiplicativeModulus; % blemker 05 = 2.7e6, fiorentino 14b = 1.2e6
L2 = muscle.tendonExponentialModulus; % blemker 05 = 46.4, fiorentino 14b = 50
lam_toe = muscle.tendonToeStretch; % blemker 05 = fiorentino 14b = 1.03

lt = lmtu - sqrt(lm.*lm - l0*l0*sin(phi0)*sin(phi0));
ln = lt/ls;

i = ln <= 1;
f(i) = 0;
d1(i) = 0;

i = ln > 1 & ln < lam_toe;
f(i) = L1 * (exp(L2 * (ln(i) - 1)) - 1);
d1(i) = L2 * L1 * exp(L2 * (ln(i) - 1));

L3 = L2 * L1 * exp(L2 * (lam_toe - 1));
L4 = L1 * (exp(L2 * (lam_toe - 1)) - 1) - L3 * lam_toe;

i = ln >= lam_toe;
f(i) = L3 * ln(i) + L4;
d1(i) = L3;

end
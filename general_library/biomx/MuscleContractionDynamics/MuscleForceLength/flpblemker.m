function [f,df_dlm] = flpblemker(lm,muscle)

% from blemker et al. 05, Table 1

l0 = muscle.optimalFiberLength;
P1 = 0.05;
P2 = 6.6;
lam_toe = 1.06;
lam_ofl = 1.0;

ln = lm/l0;
lam = ln * lam_ofl;

f = zeros(1,length(lm));

i = lam <= lam_ofl;
f(i) = 0;
df_dlm(i) = 0;

i = lam > lam_ofl & lam < lam_toe;
f(i) = P1 * (exp(P2 * (ln(i) - 1)) - 1);
df_dlm(i) = P2 * P1 * exp(P2 * (ln(i) - 1)) / l0;

P3 = P2 * P1 * exp(P2 * (lam_toe / lam_ofl - 1));
P4 = P1 * (exp(P2 * (lam_toe / lam_ofl - 1)) - 1) - P3 * lam_toe / lam_ofl;

i = lam >= lam_toe;
f(i) = P3 * ln(i) + P4;
df_dlm(i) = P3 / l0;

end
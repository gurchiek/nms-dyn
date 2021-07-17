function [f,df_dlm,d2f_dlm2] = flpexpplus(lm,muscle)

% equation 3 in thelen 03 modeling passive muscle force-length
% relationship. l is normalized fiber length, k is a shape factor (thelen
% had 5), and e is strain due to max force that was adjusted based on age
% (thelen had 0.6 for young and 0.5 for old)

k = muscle.passiveForceLengthShapeFactor;
s0 = muscle.maxForceMuscleStrain;
l0 = muscle.optimalFiberLength;

ln = lm/l0;

c1 = exp(k) - 1;
f = (exp(k*(ln-1)/s0) - 1) / c1;
df_dlm = k * exp(k*(ln-1)/s0) / c1 / s0 / l0;
d2f_dlm2 = k * df_dlm / s0 / l0;



end
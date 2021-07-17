function [f,df_dlm,d2f_dlm2] = flpexp(lm,muscle)

% equation A.3.13 in schutte PhD thesis. Also used in Buchanan 04
% f = e^(10(l-1))/e^5

% notice passive forces still present at lengths below optimum. Schutte
% justified this model noting exponential relationships have been observed
% for other connective tissues:
%   Fung 1967, Elasticity of soft tissues in simple elongation
%   Haut 1972, A constitutive equation for collagen fibers
% and specifically muscle:
%   Hatze 1974, A model of skeletal muscle suitable for optimal motion problems
%   Winters 1990, Ch 5, Multiple Muscle Systems

k = muscle.passiveForceLengthShapeFactor; % 5
e0 = muscle.maxForceMuscleStrain; % 0.5
l0 = muscle.optimalFiberLength;

ln = lm/l0;

f = exp(k*(ln-1)/e0)/exp(k); 
df_dlm = f * k / l0 / e0;
d2f_dlm2 = df_dlm * k / l0 / e0;



end
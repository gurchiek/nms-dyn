function a = actnonlinAc(a,muscle)

% nonlinear activation model presented by meyer et al. 2019. Is a
% non-piecewise (smooth) fit to manal and Buchanan 2003 A-model. 
% this function uses activationNonlinearityShapeFactor as the single
% parameter (-3 < A < 0). This A is used to determine the parameter (c) in
% Meyer's model such that the derivatives match Lloyd/Besier 03's
% exponential model at a = 0. Note that in Meyer's original model, they
% specified c directly and it was allowed to vary between 0 and 0.35. I
% have found that c/2 ~ A used in Manal/Buchanan 03 'single parameter'
% paper.

A = muscle.activationNonlinearityShapeAexp;

g1 = -7.623;
g2 = 29.280;
g3 = 0.884;
g4 = 17.227;
g5 = 4.108;

alpha = -g1 * (g2 * g3^g4 + g5)^(-2) * g4 * g2 * g3^(g4-1);
c = A / (exp(A) - 1) / (alpha - 1);
a(1,:) = (1 - c) * a(1,:) + c * (1 + g1 ./ (g2 * (a(1,:) + g3).^g4 + g5) );

end
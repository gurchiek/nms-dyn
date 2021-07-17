function a = actnonlinAexp(a,muscle)

% nonlinearity of activation-force relationship
% modeled as in Lloyd/Besier 03, -3 < A < 0
% they cite Potvin et al. 1996

A = muscle.activationNonlinearityShapeAexp;

a(1,:) = (exp(A * a(1,:)) - 1) / (exp(A) - 1);

end
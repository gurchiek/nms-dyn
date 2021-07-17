function [f,df_dlm] = tflspline(lm,lmtu,muscle)

% justification for schutte model (see buchanan 04)
% tendons fail at 3.5*Fmax at 10% strain
% tendon force = Fmax at 3.3%
% tendons are linearly elastic starting at 1.27%

s0 = muscle.maxForceTendonStrain;
l0 = muscle.optimalFiberLength;
phi0 = muscle.phi0;
ls = muscle.tendonSlackLength;

% spline model
e0 = [-0.1:0.005:s0/2,s0:0.01:0.2];
lt0 = ls * e0 + ls;
lmtu0 = (ls + l0) * ones(1,length(e0));
lm0 = sqrt((lmtu0 - lt0).^2 + l0^2 * sin(phi0)^2);
f0 = muscle.tendonSplineForceLengthFunction(lm0,lmtu0,muscle);
pp = spline(e0,f0);
pp1 = mkpp(e0,pp.coefs(:,1:3) * diag([3 2 1]),1);

% tendon length
[phi,dphi_dlm] = muscle.pennationFunction(lm,muscle);
lt = lmtu - lm .* cos(phi);
dlt_dlm = lm .* sin(phi) .* dphi_dlm - cos(phi);

% strain
s = (lt - ls)/ls;
ds_dlm = dlt_dlm / ls;

% evaluate
f = ppval(pp,s);
df_dlm = ds_dlm .* ppval(pp1,s);

end
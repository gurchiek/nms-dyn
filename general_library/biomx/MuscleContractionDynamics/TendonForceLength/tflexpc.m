function [f,df_dlm] = tflexpc(lm,lmtu,muscle)

% this motivated by trying to make de groote 16 params fit with physical
% params included in other models (like thelen 03), for example, tendon
% elastic modulus in linear region, max force tendon strain, etc.
% Originally tried to match so that ft = Fmax at strain = s0, but this
% gave way too large value. Instead s0 in this function is actually the
% strain at which the slope of the tendonForce-strain function equals the
% tendon elastic modulus

s0 = muscle.maxForceTendonStrain;
k = muscle.tendonElasticModulus;
ls = muscle.tendonSlackLength;

% pennation angle
[phi,dphi_dlm] = muscle.pennationFunction(lm,muscle);
fphi = cos(phi);

% get tendon length
lt = lmtu - lm .* fphi;
dlt_dlm = lm .* sin(phi) .* dphi_dlm - fphi;

s = (lt - ls) / ls;
ds_dlm = dlt_dlm / ls;

c = exp(-k*s0);
eks = exp(k*s);
f = c * (eks - 1);
df_dlm = k * c * eks .* ds_dlm;

end
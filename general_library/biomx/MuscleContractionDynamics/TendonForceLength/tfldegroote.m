function [f,df_dlm] = tfldegroote(lm,lmtu,muscle)

ls = muscle.tendonSlackLength;

k = 35;
c1 = 0.2;
c2 = 0.995;
c3 = 0.25;


% pennation angle
[phi,dphi_dlm] = muscle.pennationFunction(lm,muscle);

% get tendon length
lt = lmtu - lm .* cos(phi);
dlt_dlm = lm .* sin(phi) .* dphi_dlm - cos(phi);
ltn = lt / ls;

f = c1 * exp(k * (ltn - c2)) - c3;
df_dlm = k * c1 * exp(k * (ltn - c2)) .* dlt_dlm / ls;

end
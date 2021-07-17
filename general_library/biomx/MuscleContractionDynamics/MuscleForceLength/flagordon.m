function [f,df_dlm,d2f_dlm2] = flagordon(lm,act,muscle)

% interpolation of points on gordon (1966) table 1
% buchanan 04 and besier 03 use a cubic spline (also here)
% gordon 66 table 1 gives values near optimum. Optimum length is mean of
% the two points in the table that had max force (2.13 and 2.18
% micrometers) so optimum = mean([2.13 2.18]) = 2.155. Another point on
% ascending curve is f = 0.84 at l = 1.67 um (77% opt) from figure 12.
% Also shows lower bound = 1.27 um (58.93% opt), upper bound = 3.65 um 
% (169.37% opt). However, users can supply their own lower/upper bounds
% (e.g. common to use 0.5 and 1.5). Gordon data is default

lb = muscle.activeForceLengthLowerBound;
ub = muscle.activeForceLengthUpperBound;
lopt = muscle.optimalFiberLength;

if isfield(muscle,'submaxOptimalFiberLengthAdjustmentFunction')
    if ~isempty(muscle.submaxOptimalFiberLengthAdjustmentFunction)
        [~,lopt] = muscle.submaxOptimalFiberLengthAdjustmentFunction(lm,act,muscle);
    end
end

ln = lm./lopt;

% gordon 66 table 1 data + endpoints (0 and upper and lower bound)
f0 = [0 0 0 0.84 0.9709 0.9860 0.9987 1.00 1.00 0.9885 0.9706 0 0 0];
l0 = [lb-0.02 lb-0.01 lb 0.7749 0.9188 0.9420 0.9652 0.9884 1.0116 1.0348 1.0580 ub ub+0.01 ub+0.02];

% spline + derivatives
pp = spline(l0,f0);
pp1 = mkpp(pp.breaks,pp.coefs(:,1:3) * diag([3 2 1]),1);
pp2 = mkpp(pp1.breaks,pp1.coefs(:,1:2) * diag([2 1]), 1);
f = act .* ppval(pp,ln);
df_dlm = act .* ppval(pp1,ln) ./ lopt;
d2f_dlm2 = act .* ppval(pp2,ln) ./ lopt ./ lopt;

end
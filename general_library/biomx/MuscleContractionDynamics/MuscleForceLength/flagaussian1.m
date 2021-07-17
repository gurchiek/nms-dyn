function [f,df_dlm,d2f_dlm2] = flagaussian1(lm,act,muscle)

% approximation to active force-length curve using guassian density
% function, v is a shape factor, equivalent to the variance from the
% gaussian density perspective. l is normalized fiber length. Thelen 03 had
% v = 0.45, but using 0.45^2 gives better fit to Woittiez's parabolic
% approximation and Gordon's data (maybe the gamma parameter was supposed
% to be standard dev instead of variance...)

v = muscle.activeForceLengthGaussian1Shape;
l0 = muscle.optimalFiberLength;

if isfield(muscle,'submaxOptimalFiberLengthAdjustmentFunction')
    if ~isempty(muscle.submaxOptimalFiberLengthAdjustmentFunction)
        [~,l0] = muscle.submaxOptimalFiberLengthAdjustmentFunction(lm,act,muscle);
    end
end

ln = lm./l0;

x = ln - 1;
f = act .* exp(-x.*x/v);
df_dlm = -2 * x .* f / v ./ l0;
d2f_dlm2 = -2 * (f./l0 + x.*df_dlm) / v ./ l0;

end
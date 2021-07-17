function [f,df_dlm] = flaquadratic(lm,act,muscle)

% parabolic approximation to muscle active force-length relationship as in
% Woittiez 1984, see also Buchanan et al. 2004, and Crouch and Huang (2016)
% r is range, l is normalized fiber length

r = muscle.activeForceLengthRange;
l0 = muscle.optimalFiberLength;

if isfield(muscle,'submaxOptimalFiberLengthAdjustmentFunction')
    if ~isempty(muscle.submaxOptimalFiberLengthAdjustmentFunction)
        [~,l0] = muscle.submaxOptimalFiberLengthAdjustmentFunction(lm,act,muscle);
    end
end

ln = lm ./ l0;
f = act .* (1 - (4/r/r) * (ln - 1).^2);
df_dlm = -8/r/r * act .* (ln - 1) ./ l0;

end
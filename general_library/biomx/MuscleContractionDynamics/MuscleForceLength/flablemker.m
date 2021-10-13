function [f,df_dlm] = flablemker(lm,act,muscle)

% from Blemker et al. 05,  Table 1 (constitutive model equations)

l0 = muscle.optimalFiberLength;
lam_ofl = 1.4;

if isfield(muscle,'submaxOptimalFiberLengthAdjustmentFunction')
    if ~isempty(muscle.submaxOptimalFiberLengthAdjustmentFunction)
        [~,l0] = muscle.submaxOptimalFiberLengthAdjustmentFunction(lm,act,muscle);
    end
end

ln = lm ./ l0;
lam = ln * lam_ofl;

f = zeros(1,length(lm));

i = lam <= 0.6 * lam_ofl;
f(i) = act(i) * 9 .* (ln(i) - 0.4).^2;
df_dlm(i) = 18 * act(i) .* (ln(i) - 0.4) ./ l0;

i = lam > 0.6 * lam_ofl & lam < 1.4 * lam_ofl;
f(i) = act(i) .* (1 - 4 * (1 - ln(i)).^2 );
df_dlm(i) = 8 * act(i) .* (1 - ln(i)) ./ l0;

i = lam >= 1.4 * lam_ofl;
f(i) = act(i) * 9 .* (ln(i) - 1.6).^2;
df_dlm(i) = 18 * act(i) .* (ln(i) - 1.6) ./ l0;

end
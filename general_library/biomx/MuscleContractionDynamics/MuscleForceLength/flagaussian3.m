function [f,df_dlm] = flagaussian3(lm,act,muscle)

l0 = muscle.optimalFiberLength;

if isfield(muscle,'submaxOptimalFiberLengthAdjustmentFunction')
    if ~isempty(muscle.submaxOptimalFiberLengthAdjustmentFunction)
        [~,l0] = muscle.submaxOptimalFiberLengthAdjustmentFunction(lm,act,muscle);
    end
end

ln = lm./l0;

b(1,1) = 0.815;
b(2,1) = 1.055;
b(3,1) = 0.162;
b(4,1) = 0.063;
b(1,2) = 0.433;
b(2,2) = 0.717;
b(3,2) = -0.03;
b(4,2) = 0.200;
b(1,3) = 0.100;
b(2,3) = 1.000;
b(3,3) = 0.5*sqrt(0.5);
b(4,3) = 0.000;

f = zeros(1,length(lm));
df_dlm = zeros(1,length(lm));
for i = 1:3
    num = ln - b(2,i);
    den = b(3,i) + b(4,i) * ln;
    x = num ./ den;
    bell = b(1,i) * exp(-x.*x / 2);
    f = f + bell;
    
    dx_dlm = (b(3,i) + b(4,i) * b(2,i)) ./ den ./ den ./ l0;
    dbell = -bell .* x .* dx_dlm;
    df_dlm = df_dlm + dbell;
end

f = act .* f;
df_dlm = act .* df_dlm;

end
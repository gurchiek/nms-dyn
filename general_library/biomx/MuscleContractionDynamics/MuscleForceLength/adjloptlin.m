function [lm,l0] = adjloptlin(lm,act,muscle)

% Huijing (1996) and Guimaraes (1994) suggest increases in optimal fiber
% length with decreased activation. Relationship was modeled linearly in
% Lloyd/Besier 03 (also Buchanan 04). Lloyd and Besier used coefficient c =
% 0.15



c = muscle.coefSubmaxOptimalFiberLengthAdjustment;
l0 = muscle.optimalFiberLength;

l0 = l0 .* (c * (1 - act) + 1);
lm = lm ./ l0;



end
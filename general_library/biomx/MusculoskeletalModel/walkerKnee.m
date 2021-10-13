function [a,i,y,x,dadf,didf,dydf,dxdf] = walkerKnee(f)

% computes knee varus (adduction - a), internal rotation (i), superior
% translation (y) and anterior translation (x) given flexion angle f using
% equations in Walker et al. (1988). Also returns derivatives wrt flexion
% angle f. Flexion angle should be in radians. Output angles in radians and
% translations in meters.

d = f * 180 / pi;

a = (0.0791 * d - 5.733e-4 * d.^2 - 7.682e-6 * d.^3 + 5.759e-8 * d.^4) * pi / 180;
if nargout > 4; dadf = 0.0791 - 0.0011466 * d - 2.3046e-5 * d.^2 + 2.3036e-7 * d.^3; end

i = (0.3695 * d - 2.958e-3 * d.^2 + 7.666e-6 * d.^3) * pi / 180;
if nargout > 4; didf = 0.3695 - 0.005916 * d + 2.2998e-5 * d.^2; end

y = (-0.0683 * d + 8.804e-4 * d.^2 - 3.75e-6 * d.^3) / 1000;
if nargout > 4; dydf = (-0.0683 + 0.0017608 * d - 1.125e-5 * d.^2) * 180 / pi / 1000; end

x = (-0.1283 * d + 4.796e-4 * d.^2) / 1000;
if nargout > 4; dxdf = (-0.1283 + 9.592e-4 * d) * 180 / pi / 1000; end

end
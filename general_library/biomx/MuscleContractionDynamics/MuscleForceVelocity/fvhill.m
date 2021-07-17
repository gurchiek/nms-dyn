function [f,d1] = fvhill(v,a)

% normalized muscle force-velocity relationship for shortening only
% winters says generally 0.1 < a < 1.0, 0.1 < a < 0.25 for slow fibers, and
% a > 0.25 for fast fibers. Winters suggests adjusting according to
% proportion of slow/fast twitch fibers (eg from Yamaguchi 90 table). Note
% this is same form of equation given in Buchanan et al 2004 eq 27. He only
% states that a = ~0.25, but also has the constant b. No values for b are
% given but it can be solved for by noting that f = 0 @ v = 1. Note this is
% also the same equation given in schutte's 92 phd thesis eq A.3.7 except
% in her equation a was denoted k_v and another variable (unfortunately
% called 'a' also...) was in the numerator. Schutte does not give a value
% for this 'a' (the one in the numerator), but again it can be found by
% noting f = 0 @ v = 1 which shows in her equation it must have been 1.
% v is muscle velocity (if < 0 => shortening)

if nargin == 1; a = 0.25; end
if isempty(a); a = 0.25; end

f = (1 + v) ./ (1 - v/a);
d1 = (1 + 1/a) ./ (1 - v/a).^2;

end
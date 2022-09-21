function M = rienerEdrich1999PassiveKneeMoment(hip_angle, knee_angle, ankle_angle)

% given ankle dorsiflexion angle (plantarflexion < 0), knee_angle
% (flexion > 0), and hip_angle (flexion > 0), this function returns the 
% passive knee moment due to all passive structures (including muscles, 
% ligaments, etc.). From Riener and Edrich 1999. Used by Miller et al. 2012
% sprinting study

% flipped sign of ankle angle from riener and edrich paper s.t. dorsiflexion > 0

% INPUTS
% ankle_angle - dorsiflexion angle in radians
% knee_angle - knee flexion angle in radians
% hip_angle - hip flexion angle in radians

% OUTPUTS
% M - knee flexion moment

M =  exp(1.800 + 0.0460 * ankle_angle * 180/pi - 0.0352 * knee_angle * 180/pi + 0.0217 * hip_angle * 180/pi) + ...
    -exp(-3.971 + 0.0004 * ankle_angle * 180/pi + 0.0495 * knee_angle * 180/pi - 0.0128 * hip_angle * 180/pi) + ...
    -4.820 + exp(2.220 - 1.50 * knee_angle * 180/pi);

end
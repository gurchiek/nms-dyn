function M = rienerEdrich1999PassiveHipMoment(hip_angle, knee_angle)

% given knee_angle (flexion > 0), and hip_angle (flexion > 0), return the 
% passive hip flexion moment due to all passive structures (including muscles, 
% ligaments, etc.). From Riener and Edrich 1999. Used by Miller et al. 2012
% sprinting study

% INPUTS
% knee_angle - knee flexion angle in radians
% hip_angle - hip flexion angle in radians

% OUTPUTS
% M - hip flexion moment

M =  exp(1.4655 - 0.0034 * knee_angle * 180/pi - 0.0750 * hip_angle * 180/pi) - exp(1.3403 - 0.0226 * knee_angle * 180/pi + 0.0305 * hip_angle * 180/pi) + 8.072;

end
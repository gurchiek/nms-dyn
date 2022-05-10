function M = rienerEdrich1999PassiveAnkleMoment(ankle_angle, knee_angle)

% given ankle dorsiflexion angle (plantarflexion < 0) and knee_angle
% (flexion > 0), this function returns the passive ankle moment due to all
% passive structures (including muscles, ligaments, etc.). From Riener and
% Edrich 1999. Used by Miller et al. 2012 sprinting study

% flipped sign of ankle angle and moment from riener and edrich paper s.t.
% dorsiflexion > 0

% INPUTS
% ankle_angle - dorsiflexion angle in radians
% knee_angle - knee flexion angle in radians

% OUTPUTS
% M - ankle dorsiflexion moment

M = exp(-7.9763 - 0.1949 * ankle_angle * 180/pi + 0.0008 * knee_angle * 180/pi) - exp(2.1016 + 0.0843 * ankle_angle * 180/pi - 0.0176 * knee_angle * 180/pi) + 1.792;

end
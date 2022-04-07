function [ q ] = intqode15s( q0, w, t, b2w, inbody, forward, options)
%Reed Gurchiek, 2020
%   intqode15i time integrates the quaternion q0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (q0) using ode15i (fully implicit differentiation)
%
%   system here is dynamic-algebraic, dynamic equations are the usual
%   quaternion kinematic equation, the algebraic equation are the unit
%   length constraint. Only the vector components of the quaternion are
%   treated as dynamic variables, the scalar part is treated as an
%   algebraic variable
%
%   q is s.t. its rotation operation is per: v2 = q * v1 * q_conj
%   q(4,:) is the scalar part, q(1:3,:) is the x, y, z vector part
%
%--------------------------INPUTS------------------------------------------
%
%   q0:
%       4x1, initial quaternion from which integration begins
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does q rotate body frame referenced vectors to world
%       frame? if yes then b2w = 1. If not, b2w = 0 (i.e.
%       world to body). e.g. if b2w = 1 => v_world = q * v_body * q_conj
%
%   inbody:
%       boolean. Is w expressed in the body frame? If yes, then inbody = 1,
%       if not, then inbody = 0.
%
%   forward:
%       boolean. if integrate from beginning to end then forward = 1 and r0
%       corresponds to r at t = t(1). If integrate from end to beginning
%       then forward = 0 and r0 corresponds to r at t = t(end)
%
%-------------------------------OUTPUTS------------------------------------
%
%   q:
%       4xn time integrated quaternion array
%
%--------------------------------------------------------------------------
%% intqode15s

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% integrate
options.Jacobian = @daesysjac;
options.Mass = [eye(3), zeros(3,1); zeros(1,4)];
options.MassSingular = 'yes';
[~,q] = ode15s(@daesys,t,q0,options,w,t,b2w,inbody);
q = q';

% flip back?
if ~forward
    q = flip(q,2);

end

end

function out = daesys(tk,q,w,t,b2w,inbody)

omega = interp1(t,w',tk,'pchip')';
out = zeros(4,1);
A = qstatemat(omega,b2w,inbody); % quaternion kinematics state matrix
out(1:3) = A(1:3,:) * q; % use only vector part for kinematics, scalar part treated as algebraic state in unit length constraint
out(4) = (q' * q) - 1; % unit length constraint

end

function [dfdq] = daesysjac(tk,q,w,t,b2w,inbody)

omega = interp1(t,w',tk,'pchip')';

% jacobian of daesys wrt q
dfdq = zeros(4,4);

% dynamic eq (first 3 dae sys eq)
A = qstatemat(omega,b2w,inbody);
dfdq(1:3,1:4) = A(1:3,:);

% unit length constraint
dfdq(4,:) = 2 * q';

end
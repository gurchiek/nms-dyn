function [ q ] = intqode15i( q0, w, t, b2w, inbody, forward, options)
%UNDER CONSTRUCTION: NEED TO CONVERT DAE TO ODE USING SYMBOLIC MATH TOOLBOX
%SEE: reduceDifferentialOrder, Solve Differential Algebraic Equations
%Reed Gurchiek, 2020
%   intqode15i time integrates the quaternion q0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (q0) using ode15i (fully implicit differentiation)
%
%   system here is dynamic-algebraic, dynamic equations are the usual
%   quaternion kinematic equation, the algebraic equation are the unit
%   length constraint
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
%% intqode15i

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% integrate
options.Jacobian = @daesysjac;
options.MassSingular = 'yes';
[~,q] = ode15i(@daesys,t,q0,qstatemat(w(:,1),b2w,inbody) * q0,options,w,t,b2w,inbody);
% q = normalize(q',1,'norm');
q = q';

% flip back?
if ~forward
    q = flip(q,2);

end

end

function res = daesys(tk,q,qd,w,t,b2w,inbody)

omega = interp1(t,w',tk,'pchip')';
res = zeros(4,1);
z4 = qd - qstatemat(omega,b2w,inbody) * q; % quaternion kinematics
res(1:3) = z4(1:3); % use only vector part for kinematics, scalar part treated as algebraic state in unit length constraint
res(4) = (q' * q) - 1; % time derivative of unit length constraint

end

function [dfdq,dfdqd] = daesysjac(tk,q,qd,w,t,b2w,inbody)

omega = interp1(t,w',tk,'pchip')';

% jacobian of dae system equations wrt dq_dt
dfdqd = zeros(4,4);
dfdqd(1:3,1:3) = eye(3);

% jacobian of unit constraint eq (4th dae sys eq) wrt q
dfdq = zeros(4,4);
dfdq(4,:) = 2 * q';

% jacobian of dynamic eq (first 4 dae sys eq) wrt q
A = qstatemat(omega,b2w,inbody);
dfdq(1:3,1:4) = -A(1:3,:);

end
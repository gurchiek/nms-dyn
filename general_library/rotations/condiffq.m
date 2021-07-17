function [ qdot, qdot0 ] = condiffq(q,t)
%% UNDER CONSTRUCTION
% under current implementation, both quaternion unit length and quaternion
% velocities orthogonal to itself are constraints being implemented, but
% these are not independent (2nd is derivative of first). This may explain
% why solver warns "matrix badly scaled..." However, considered this b/c
% quaternion should be orthogonal to its velocity. Using 5 point central
% difference technique satisfies this to about 1e-3 which may be close
% enough, but I wanted to try to do better... For now it seems 5 point
% central difference will suffice and is way faster

%Reed Gurchiek, 2021
%   numerically differentiates quaternion consistent with unit length
%   constraint. Uses 4th order interpolating polynomial.
%
%----------------------------------INPUTS----------------------------------
%
%   q:
%       4 x n array of quaternion column vectors, row 4 = scalar part, rows
%       1-3 = vector part, n must be greater than or equal to 5
%
%   t:
%       time array if same size as q or time between samples (dt)
%
%---------------------------------OUTPUTS----------------------------------
%
%   qdot:
%       quaternion derivative consistent with constraints
%
%   qdot0;
%       quaternion derivative unconstrained solution, based on
%       interpolating quartic polynomial
%
%--------------------------------------------------------------------------
%% condiffq

% create time array if dt given
n = size(q,2);
if length(t) == 1
    t = 0:t:(n-1)*t;
elseif size(t,2) == 1
    t = t'; % force column vector
end

% initialization
A = zeros(20,20); % maps coefs to target quaternions
C = zeros(20,20); % C .* [A(:,5:end) zeros(20,4)] maps coefs to target quaternion velocities
qdot0 = zeros(4,n); % unconstrained estimate, constrained estimate initialized here
qdot = zeros(4,n); % constrained estiamte
options = optimoptions('fmincon','Algorithm','interior-point','SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true,'CheckGradients',false,'ConstraintTolerance',1e-6,'Display','off','HessianFcn',@lagrangianhess);
% warning('off','MATLAB:nearlySingularMatrix')

% for each quaternion
for k = 1:n
    
    % get indices for interpolation
    if k < 3
        i = 1:5;
        ii = k;
    elseif k > n-2
        i = n-4:n;
        if k == n-1
            ii = 4;
        else
            ii = 5;
        end
    else
        i = k-2:k+2;
        ii = 3;
    end
    
    % get times for interpolation
    v = t(i);
    v = v - v(ii); % center around target point
    
    % get targets for interpolation
    p = q(:,i);
    
    % stack p
    p = tower(p);
    
    % for each quaternion target
    for j = 1:5
        
        % for each component of the quaternion
        for m = 1:4
                
            % for each power of time
            for z = 4:-1:0
                
                % parametrize A s.t. A*x = p, x the coefs of interpolating polynomial
                r = 4*(j-1) + m;
                c = 16 - 4*z + m;
                A(r,c) = v(j) ^ z;
                C(r,c) = z;
            end
            
        end
        
    end
    
    % initialize with unconstrained solution
    x0 = lsqlin(A,p);
                
    % constrained solution
    B = C.*[A(:,5:end) zeros(20,4)]; % maps coefs to quaternion velocities
    x = fmincon(@fun,x0,[],[],[],[],[],[],@nonlcon,options,A,p,B);
    pdot = B * x;
    qdot(:,k) = pdot(4*(ii-1)+1:4*ii);
    
    % unconstrained solution
    pdot0 = B * x0;
    qdot0(:,k) = pdot0(4*(ii-1)+1:4*ii);
    
end

end

% least squares objective
function [fx,gradient,hessian] = fun(x,A,p,B)

fx = (p - A*x)' * (p - A*x); % cost
gradient = -2 * (p - A*x)' * A;
hessian = 2 * (A'*A);

end

% nonlinear constraints
function [c,ceq,dcdx,gradient,hessian] = nonlcon(x,A,p,B)

% unused
c = [];
dcdx = [];

% init
ceq = zeros(10,1);
gradient = zeros(10,length(x));
hessian = zeros(length(x),length(x),10);

% unit length
for k = 1:5
    i = 4*(k-1)+1:4*k;
    Ak = A(i,:);
    ceq(k) = x' * (Ak' * Ak) * x - 1;
    gradient(k,:) = 2 * x' * (Ak' * Ak);
    hessian(:,:,k) = 2 * (Ak'* Ak);
end

% quaternion velocity orthogonal to itself
for k = 6:10
    j = k-5;
    i = 4*(j-1)+1:4*j;
    Ak = A(i,:);
    Bk = B(i,:);
    ceq(k) = x' * Ak' * Bk * x;
    gradient(k,:) = x' * ( Bk' * Ak + Ak' * Bk);
    hessian(:,:,k) = Bk' * Ak + Ak' * Bk;
end

gradient = gradient';

end

% hessian of lagrangian: objective + sum( lamda * constraints )
function hess = lagrangianhess(x,lambda,A,p,B)

[~,~,fhess] = fun(x,A,p,B);
[~,~,~,~,chess] = nonlcon(x,A,p,B);
hess = fhess;
lam = lambda.eqnonlin;
for k = 1:length(lam); hess = hess + lam(k) * chess(:,:,k); end

end
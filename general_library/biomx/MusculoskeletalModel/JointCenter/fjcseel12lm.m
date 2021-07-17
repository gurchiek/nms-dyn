function [r1,r2] = fjcseel12lm(w1,w2,w1dot,w2dot,a1,a2,r1,r2,lb1,lb2,ub1,ub2)
%   
%   functional rotation axis estimator: seel's 2012 method and levenberg
%   marquardt as opposed to gauss-newton as described in seel paper. if
%   constraints given then uses trust region reflective algorithm
%
%   angular velocities w1,w2 should be of two bodies (1,2) that articulate
%   via a hinge joint
%
%----------------------------------INPUTS----------------------------------
%
%   w1:
%       3xn array of angular velocity vector of frame 1 measured in frame 1
%
%   w2:
%       3xn array of angular velocity vector of frame 2 measured in frame 2
%
%   w1dot:
%       3xn array of angular acceleration vectors of frame 1 measured in
%       frame 1
%
%   w2dot:
%       3xn array of angular acceleration vectors of frame 2 measured in
%       frame 2
%
%   a1:
%       3xn array of accelerometer data from frame 1 measured in frame 1
%
%   a2:
%       3xn array of accelerometer data from frame 2 measured in frame 2
%
%   r1:
%       3x1 first estimate of location of frame 1 relative to joint center
%       in frame 1 (points from jc to frame 1)
%
%   r2:
%       3x1 first estimate of location of frame 2 relative to joint center
%       in frame 2 (points from jc to frame 2)
%
%   lb1,lb2:
%       lower bound input to lsqnonlin is [lb1; lb2], lbi is lower bound
%       for ri, lbi is 3x1
%
%   ub1,ub2:
%       upper bound input to lsqnonlin is [ub1; ub2], ubi is upper bound
%       for ri, ubi is 3x1
%
%---------------------------------OUTPUTS----------------------------------
%
%   r1,r2:
%       3x1 final estimates of vectors pointing from jc to frame1,frame2
%
%--------------------------------------------------------------------------
%% fjcseel12lm

% either all bounds given or all are set empty
if nargin ~= 12
    lb1 = [];
    lb2 = [];
    ub1 = [];
    ub2 = [];
end

% if any bounds are empty, then none are used
algo = 'trust-region-reflective';
if isempty(lb1) || isempty(lb2) || isempty (ub1) || isempty (ub2)
    fprintf('-Not all upper/lower bounds given. No user input bounds are being used.\n');
    algo = 'levenberg-marquardt';
end

% levenberg marquardt
x0 = [r1; r2];
options = optimoptions('lsqnonlin','Algorithm',algo,'CheckGradients',false,'SpecifyObjectiveGradient',true,'Display','none');
x = lsqnonlin(@(x)fun(x,w1,w2,w1dot,w2dot,a1,a2),x0,[lb1; lb2],[ub1; ub2],options);

% unpack
r1 = x(1:3);
r2 = x(4:6);

end

function [err,jac] = fun(x,w1,w2,w1dot,w2dot,a1,a2)

r1 = x(1:3);
r2 = x(4:6);
err = zeros(size(w1,2),1);
jac = zeros(size(w1,2),4);
mag1 = zeros(size(w1,2),1);
mag2 = mag1;

for k = 1:size(w1,2)
    
    y1 = a1(:,k);
    y2 = a2(:,k);
    
    C1 = skew(w1(:,k)) * skew(w1(:,k)) + skew(w1dot(:,k));
    C2 = skew(w2(:,k)) * skew(w2(:,k)) + skew(w2dot(:,k));
    
    mag1(k) = y1'*y1 + 2*y1'*C1*r1 + r1'*(C1'*C1)*r1;
    mag2(k) = y2'*y2 + 2*y2'*C2*r2 + r2'*(C2'*C2)*r2;
    
    err(k) = y1'*y1 + 2*y1'*C1*r1 + r1'*(C1'*C1)*r1 - y2'*y2 - 2*y2'*C2*r2 - r2'*(C2'*C2)*r2;
    
    jac(k,1:3) =  2*y1'*C1 + 2*r1'*(C1'*C1);
    jac(k,4:6) = -2*y2'*C2 - 2*r2'*(C2'*C2);

end

% disp(sqrt(err'*err/size(w1,2)))

end
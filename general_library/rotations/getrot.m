function [ r ] = getrot(a,b,rtype,w)
%Reed Gurchiek, 2020
%   getrot computes the rotation operator structure r of type rtype that
%   minimizes:
%   
%           1/2 * (a - rot(r,b))' * diag(w) * (a - rot(r,b))
%
%----------------------------------INPUTS----------------------------------
%
%   a, b:
%       3 x n array of column vectors expressed in frame A and 3 x n array 
%       of column vectors expressed in frame B respectively. Each column in
%       a should correspond to the same vector in the same column of b.
%
%   rtype:
%       char array, rotation operator type, can be either:
%           (1) 'q' for quaternion in which case davenport's q method is
%                   used to solve wahba's problem
%           (2) 'dcm' for direction cosine matrix in which case svd is used
%                   used to solve wahba's problem
%
%       NOTE: anecdotally, over many simulations, svd and q-method seem to
%             the same when there are several reference vectors while
%             q-method seems more robust with fewer reference vectors (e.g.
%             2-3). SVD is about twice as fast.
%
%   w (optional):
%       weights corresponding to trust given to each observation vector
%
%---------------------------------OUTPUTS----------------------------------
%
%   r:
%       rotation operator structure of type rtype
%
%--------------------------------REFERENCES--------------------------------
%
%   Shuster and Oh (1981) Three axis attitude determinations from vector
%   observations
%
%   Markley and Mortari (2000) Quaternion attitude estimation using vector
%   observations
%
%--------------------------------------------------------------------------
%% getrot

% error check
[ar,ac] = size(a);
[br,bc] = size(b);
if br ~= 3 || ar ~= 3; error('a and b must be 3 x n.'); end
if bc == 1 || ac == 1; error('a and b must have at least 2 columns.'); end
if bc ~= ac; error('a and b must have same number of columns.'); end

% weights
% using formulation in Markley and Mortari, weights do not have to sum to 1
% if implementing in quest, this would only change the initial guess of the
% eigenvalue of the optimal q
if nargin < 4
    W = eye(ac);
else
    [wr,wc] = size(w);
    if wr ~= 1 && wc ~= 1; error('w must be 1xn or nx1.'); end
    if wr ~= ac && wc ~= ac; error('w must be 1xn or nx1.'); end
    W = diag(w);
end

% IF QUATERNION
if strcmpi(rtype,'q')
    
    B = a * W * b';
    S = B + B';
    z = [B(2,3) - B(3,2); B(3,1) - B(1,3); B(1,2) - B(2,1)];
    K = [S - eye(3) * trace(B), -z; -z', trace(B)]; % -z used here s.t. q = q * b * q_conj
    [q,lam] = eig(K); [~,imax] = max(diag(lam));
    r.q = q(:,imax);
    
% IF DCM    
elseif strcmpi(rtype,'dcm')
    
    [U,~,V] = svd(a * W * b');
    dcm = U*diag([1 1 det(U)*det(V)])*V';
    r.dcm = dcm;
    
end
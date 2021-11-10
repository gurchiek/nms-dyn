function [a,i,y,x,z,dadf,didf,dydf,dxdf,dzdf,Rj] = walkerKnee(f,side)

% Reed Gurchiek, 2021

% computes knee varus (adduction - a), internal rotation (i), superior
% translation (y), anterior translation (x), and ML translation (z) given flexion angle f using
% equations in Walker et al. (1988). Also returns derivatives wrt flexion
% angle f. Flexion angle should be in radians. Output angles in radians and
% translations in meters. 

% side = 1 => right left, side = -1 => left leg

% rotations and translations are relative to femur. Rotation sequence is
% zxy: let p0_W be the location of the mid epicondyle (JCS origin)
% in the neutral configuration. Let this point be aligned with the femur
% and tibia coordiante system origins in the neutral configuration (b0_W and
% a0_W, respectively). Let a_W and b_W be the locations of the tibia and
% femur coordinate system origins given an arbitrary joint displacement.
% Let r_A = [x, y, z] be the joint translation vector output from this function
% (represented the the femur frame, A) and let r_W be its representation in
% the world frame and let r_B be its representation in the tibia frame. 
% Then
%
%                           b_W = a_W + r_W
%                           r_W = R_A * r_A
%                           r_A = Rj * r_B
%
% where R_A maps vectors represented in the femur frame to their world frame,
% representation, Rj maps vectors represented in the tibia frame to their
% femur frame representation, and
%
%                           Rj = Rf * Ra * Ri
%
% where
%
%             Rf = I - sinf * [e3]x + (1-cosf) * [e3]x[e3]x
%             Ra = I + sina * [e1]x + (1-cosa) * [e1]x[e1]x
%             Ri = I + sini * [e2]x + (1-cosi) * [e2]x[e2]x
%
% and [ei]x is the skew symmetric form of the ith natural basis

% see section below (tibia to femur change of basis) concerning how to
% implement walker's equations; ie, did walker intend for the reported
% translations to be represented in the rotated tibia frame (in which case
% a change of basis is necessary to represent translations in tibia frame).
% I tend to agree with the lower section

% analytical derivatives have been verified (for both the upper section and
% lower section

% default to right leg
if nargin == 1; side = 1; end

d = f * 180 / pi; % convert to degrees per convention in walker eqs, converted back to radians below

% adduction
a = (0.0791 * d - 5.733e-4 * d.^2 - 7.682e-6 * d.^3 + 5.759e-8 * d.^4) * pi / 180;
if nargout > 5; dadf = 0.0791 - 0.0011466 * d - 2.3046e-5 * d.^2 + 2.3036e-7 * d.^3; end

% internal rotation
i = (0.3695 * d - 2.958e-3 * d.^2 + 7.666e-6 * d.^3) * pi / 180;
if nargout > 5; didf = 0.3695 - 0.005916 * d + 2.2998e-5 * d.^2; end

% cranial caudal
y = (-0.0683 * d + 8.804e-4 * d.^2 - 3.75e-6 * d.^3) / 1000;
if nargout > 5; dydf = (-0.0683 + 0.0017608 * d - 1.125e-5 * d.^2) * 180 / pi / 1000; end

% antero posterior
x = (-0.1283 * d + 4.796e-4 * d.^2) / 1000;
if nargout > 5; dxdf = (-0.1283 + 9.592e-4 * d) * 180 / pi / 1000; end

% walker original translations were femur translations relative to tibia,
% we output tibia translations relative to femur, adjust by negating
y = -y;
x = -x;
z = zeros(1,length(f));

if nargout > 5
    dydf = -dydf;
    dxdf = -dxdf;
    dzdf = z;
end

% handle left/right sideness
a = side * a;
i = side * i;
z = side * z;

if nargout > 5
    dadf = side * dadf;
    didf = side * didf;
    dzdf = side * dzdf;
end
    

%% tibia to femur change of basis

% lai, arnold et al. 2017 spline implementation of walker's knee is
% different than rajagopals

% rajagopal only negates the walker translations

% lai arnold negate and rotate to the femur frame

% discrepancy because walker original equations represent translations
% relative to the tibia frame. Essentially rajagopal assumes walker did:
% translate first (when frames aligned) then rotate whereas lai arnold
% assume walker did: rotate first then translate along new (rotated) axes

% if comment this part out, data will better match rajagopal
% if implement this part, data will better match lai arnold

% analytic derivatives have been verified compared to finite differences

% walker says translations expressed relative to tibia frame, to express in
% femur, need to not only negate but rotate to femur frame, construct joint
% rotation matrix here and rotate
Rf = zeros(3,3,length(f));
Ra = zeros(3,3,length(f));
Ri = zeros(3,3,length(f));
Rj = zeros(3,3,length(f));

I = eye(3);
e1 = skew(I(:,1));
e2 = skew(I(:,2));
e3 = skew(I(:,3));

r0 = [x; y; z];
if nargout > 5; dr0_df = [dxdf; dydf; dzdf]; end
r = zeros(3,length(f));

for k = 1:length(f)
    Rf(:,:,k) = I - sin(f(k)) * e3 + (1 - cos(f(k))) * e3*e3; % equivalent to I + sin(-f) * e3 + (1 - cos(-f)) * e3*e3
    Ra(:,:,k) = I + sin(a(k)) * e1 + (1 - cos(a(k))) * e1*e1;
    Ri(:,:,k) = I + sin(i(k)) * e2 + (1 - cos(i(k))) * e2*e2;
    Rj(:,:,k) = Rf(:,:,k)  * Ra(:,:,k)  * Ri(:,:,k) ;
    
    r(:,k) = Rj(:,:,k) * r0(:,k);
end

x = r(1,:);
y = r(2,:);
z = r(3,:);

if nargout > 5
    dr_df = zeros(3,length(f));
    for k = 1:length(f)
        dRf_df = -cos(f(k)) * e3 + sin(f(k)) * e3*e3;
        dRj_df = dRf_df * Ra(:,:,k) * Ri(:,:,k);
        dr_df(:,k) = dRj_df * r0(:,k) + Rj(:,:,k) * dr0_df(:,k);
    end
    dxdf = dr_df(1,:);
    dydf = dr_df(2,:);
    dzdf = dr_df(3,:);
end

end
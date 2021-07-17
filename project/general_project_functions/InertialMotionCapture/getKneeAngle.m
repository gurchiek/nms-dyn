function [xrts,xcomp] = getKneeAngle(stime,ws,wt,theta,R,wsd)

% fuse accelerometer-based knee angle estimate (theta) with direct
% integration using complementary filter (xcomp) is in Seel et al. 2014 and
% using RTS kalman smoother (xrts)

% INPUTS
% stime - sensor time array
% ws - shank angular rate signal
% wt - thigh angular rate signal
% theta - rad, knee angle estimate from dynamics (see Seel et al. 2014 eq 14)
% R - measurement noise covariance associated with theta

% third axis of ws and wt should be aligned (assuming hinge)

%% get knee angle

% complementary filter gain
% seel et al. 2014 used 0.01 (see lambda following eq 15)
% RTS vs Comp filter study revealed best was 0.005
compgain = 0.005;

% initialize a priori/posteriori covariance
P_ = zeros(1,length(stime)); % priori
P = P_; % posteriori
P(1) = R(1);

% a priori/posteriori state (knee angle)
xrts = zeros(1,length(stime)); % posteriori
x_ = xrts; % priori
xrts(1) = theta(1);

% change in knee angle based on integrating gyros projected onto flexion axis
dw = cumtrapz(stime,wt(3,:)-ws(3,:));

% forward from start
K = zeros(1,length(stime)); % kalman gain
xcomp = xrts;
for k = 2:length(stime)

    % propagate state
    w = 0.5 * ( (wt(3,k-1) - ws(3,k-1)) + (wt(3,k) - ws(3,k)) ); % trapezoidal integration
    dt = stime(k) - stime(k-1);
    x_(k) = xrts(k-1) + w * dt;

    % a priori state covariance
    P_(k) = P(k-1) + 2 * (wsd * dt)^2;

    % kalman gain
    K(k) = P_(k) / (P_(k) + R(k));

    % measurement update
    xrts(k) = x_(k) + K(k) * (theta(k) - x_(k));
    P(k) = (1 - K(k)) * P_(k) * (1 - K(k)) + K(k) * R(k) * K(k);

    % seel complementary filter
    xcomp(k) = compgain * theta(k) + (1-compgain) * (xcomp(k-1) + dw(k) - dw(k-1));

end

% smooth backward from end to istart
Pf = P;
Pf_ = P_;
xf = xrts;
xf_ = x_;
for k = length(stime)-1:-1:1
    K(k) = Pf(k) / Pf_(k+1);
    P(k) = Pf(k) - K(k) * (Pf_(k+1) - P(k+1)) * K(k);
    xrts(k) = xf(k) + K(k) * (xrts(k+1) - xf_(k+1));
end
    
end
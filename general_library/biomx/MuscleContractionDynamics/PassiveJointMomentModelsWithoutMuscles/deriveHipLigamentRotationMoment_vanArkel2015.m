function deriveHipLigamentRotationMoment_vanArkel2015()

% based on van arkel 2015 fig 3, using flex and adduction from average of
% dorn JA1 9 m/s sprint trial: flexion = 18 to 19, add = -7 to -9. So
% closest config for van arkel data is flex = 30 deg and add = 0 deg

% fit bi-exponential of form used in Audu '85 and Andersen '99

% initialize with valuues from andersen thesis 1999
x0 = [-0.03, 14.94, 0.03, -14.94, 0.92, -0.92];

% minimize
x = fminunc(@fun,x0,optimoptions('fminunc','Algorithm','quasi-newton'));

% demo
angle_deg = -40:40;
angle = angle_deg*pi/180;

k1 = x(1);
k2 = x(2);
k3 = x(3);
k4 = x(4);
theta1 = x(5);
theta2 = x(6);

moment = biexp(angle,k1,k2,k3,k4,theta1,theta2);
plot(angle_deg,moment)
xlabel('Hip Rotation (deg)')
ylabel('Moment (Nm)')

fprintf('\n\nOpenSim Expression: %s',sprintf("%f*exp(%f*(q-%f))+%f*exp(%f*(q+%f))",x(1),x(2),x(5),x(3),x(4),-x(6)))

end

%% generic biexponential model

function t = biexp(a,k1,k2,k3,k4,theta1,theta2)

t = k1*exp(k2*(a-theta1))+k3*exp(k4*(a-theta2));

end

%% derivative of generic biexponential model

function dt = dbiexp(a,k1,k2,k3,k4,theta1,theta2)

dt = k1*k2*exp(k2*(a-theta1))+k3*k4*exp(k4*(a-theta2));

end

%% objective function

function J = fun(x)

% unpack
k1 = x(1);
k2 = x(2);
k3 = x(3);
k4 = x(4);
theta1 = x(5);
theta2 = x(6);

% torques
Y1 = -5;
Y2 = 0;
Y3 = 0;
Y4 = 0;
Y5 = 5;

% angles corresponding to torques above
A1 = 35*pi/180;
A2 = 2.5*pi/180;
A3 = 0;
A4 = -2.5*pi/180;
A5 = -35*pi/180;

% slopes
Y6 = -0.03*180/pi;
Y7 = -0.03*180/pi;

% angles corresponding to slopes
A6 = 25*pi/180;
A7 = -25*pi/180;

% calc squared error in torques
J1 = (biexp(A1,k1,k2,k3,k4,theta1,theta2) - Y1)^2;
J2 = (biexp(A2,k1,k2,k3,k4,theta1,theta2) - Y2)^2;
J3 = (biexp(A3,k1,k2,k3,k4,theta1,theta2) - Y3)^2;
J4 = (biexp(A4,k1,k2,k3,k4,theta1,theta2) - Y4)^2;
J5 = (biexp(A5,k1,k2,k3,k4,theta1,theta2) - Y5)^2;

% calc squared error in slopes
J6 = (dbiexp(A6,k1,k2,k3,k4,theta1,theta2) - Y6)^2;
J7 = (dbiexp(A7,k1,k2,k3,k4,theta1,theta2) - Y7)^2;

% sum
J = J1 + J2 + J3 + J4 + J5 + J6 + J7;

end

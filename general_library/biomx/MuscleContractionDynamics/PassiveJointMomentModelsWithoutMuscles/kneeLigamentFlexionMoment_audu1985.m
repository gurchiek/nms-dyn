function [t] = kneeLigamentFlexionMoment_audu1985(a)

% Musa Audu thesis 1985, Table 2.4 and eq. for Mp on pg. 55

% knee flexion for a > 0 

k1 = 3.1;
k2 = 5.9;
k3 = 10.5;
k4 = 11.8;
theta1 = -0.09;
theta2 = -1.218;

t = -k1 * exp(-k2 * (-a - theta2)) + k3 * exp(-k4 * (theta1 + a));

end
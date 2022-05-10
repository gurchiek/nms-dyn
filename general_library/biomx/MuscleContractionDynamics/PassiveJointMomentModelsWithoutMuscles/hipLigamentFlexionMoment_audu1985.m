function [t] = hipLigamentFlexionMoment_audu1985(a)

% Musa Audu thesis 1985, Table 2.4 and eq. for Mp on pg. 55

k1 = 2.6;
k2 = 5.8;
k3 = 8.7;
k4 = 1.3;
theta1 = 0.95;
theta2 = 0.1744;

t = k1 * exp(-k2 * (a - theta2)) - k3 * exp(-k4 * (theta1 - a));

end
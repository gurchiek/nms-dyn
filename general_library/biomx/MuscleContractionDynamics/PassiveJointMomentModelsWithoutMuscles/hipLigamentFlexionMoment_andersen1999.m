function [t] = hipLigamentFlexionMoment_andersen1999(a)

% Frank Andersen 1999 thesis, table G.2 and eq. 4.4 (pg 74)

k1 = -2.44;
k2 = 5.05;
k3 = 1.51;
k4 = -21.88;
theta = 1.81;
phi = -0.47;

t = k1*exp(k2*(a-theta))+k3*exp(k4*(a-phi));

end
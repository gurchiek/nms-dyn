function t = kneeLigamentFlexionMoment_andersen1999(a)

% Frank Andersen 1999 thesis, table G.2 and eq. 4.4 (pg 74)

k1 = -6.09;
k2 = 33.94;
k3 = 11.03;
k4 = -11.33;
theta1 = 0.13;
theta2 = -2.40;

t = -k1*exp(k2*(-a-theta1))-k3*exp(k4*(-a-theta2));

end
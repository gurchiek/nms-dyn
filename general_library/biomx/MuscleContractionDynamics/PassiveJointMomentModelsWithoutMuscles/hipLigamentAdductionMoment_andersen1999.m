function t = hipLigamentAdductionMoment_andersen1999(a)

% Frank Andersen 1999 thesis, table G.2 and eq. 4.4 (pg 74)

k1 = -0.03;
k2 = 14.94;
k3 = 0.03;
k4 = -14.94;
theta1 = 0.50;
theta2 = -0.50;

t = k1*exp(k2*(a-theta1))+k3*exp(k4*(a-theta2));

end
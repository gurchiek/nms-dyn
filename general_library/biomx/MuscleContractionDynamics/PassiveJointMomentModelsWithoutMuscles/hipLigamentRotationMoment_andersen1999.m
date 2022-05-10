function t = hipLigamentRotationMoment_andersen1999(a)

% Frank Andersen 1999 thesis, table G.2 and eq. 4.4 (pg 74)

k1 = -0.03;
k2 = 14.94;
k3 = 0.03;
k4 = -14.94;
theta = 0.92;
phi = -0.92;

t = k1*exp(k2*(a-theta))+k3*exp(k4*(a-phi));

end
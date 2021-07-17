function a = actnonlinA(a,muscle)

% nonlinearity of activation-force relationship
% modeled as in Manal/Buchanan 03. Manal/Buchanan constrained 0 < A <= 0.12
% model originally motivated by data from Woods & Bigland-Ritchie (1983)
% in this function we calculate A based on the shape factor from
% Lloyd/Besier 2003 which was allowed to vary from -3 to 0. To do this, the
% parameter c from Meyer et al. 2019's continuous version of Manal/Buchanan
% model is calculated as in actnonlinAc (to match derivatives with
% Lloyd/Besier 2003 model at a = 0). Then the A used here is c/(0.35/0.12)
% which ensures the ratio c/A is the same as for the maximum nonlinearity
% values reported in Meyer (c=0.35) and Manal/Buchanan (A=0.12)

A = muscle.activationNonlinearityShapeAexp;

g1 = -7.623;
g2 = 29.280;
g3 = 0.884;
g4 = 17.227;
g5 = 4.108;

alpha = -g1 * (g2 * g3^g4 + g5)^(-2) * g4 * g2 * g3^(g4-1);
c = A / (exp(A) - 1) / (alpha - 1);

A = c/(0.35/0.12);

% node
u0 = 0.3085 - A * sqrt(2) / 2;
a0 = 0.3085 + A * sqrt(2) / 2;
i1 = a(1,:) < u0;
i2 = a(1,:) >= u0;


% linear region
m = (1 - a0) / (1 - u0);
b = a0 - m * u0;
a(1,i2) = m * a(1,i2) + b;

% nonlinear region
f = @(x)m - x * ((exp(a0/x) - 1) / u0) / (((exp(a0/x) - 1) / u0) * u0 + 1);
f1 = @(x)1/u0 * ((1 - a0/x) * exp(-a0/x) - 1);
alpha = newtraph(f,f1,1,1e-6);
beta = (exp(a0/alpha) - 1) / u0;
a(1,i1) = alpha * log(beta * a(1,i1) + 1);

end
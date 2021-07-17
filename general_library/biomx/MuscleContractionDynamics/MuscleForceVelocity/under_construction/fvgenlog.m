function [f,d1,d2] = fvgenlog(v,u,a)

tau = 1/a;
f = zeros(1,length(v));
i = v <= 0;
f(i) = fvhill(v(i),a);
d1(i) = (1 + tau) ./ (1 - tau * v(i)).^2;
d2(i) = 2 * tau * (1 + tau) ./ (1 - tau * v(i)).^3;
i = ~i;
p = 0.001;
b = (1 + tau) / (1 - u^(-p));
q = u^p - 1;
f(i) = u ./ (1 + q * exp(-b*p*v(i))).^(1/p);
d1(i) = b * (1 - (f(i)/u).^p) .* f(i);
d2(i) = b * ( 1 - (f(i)/u).^p * (1 + p) ) .* d1(i);

end
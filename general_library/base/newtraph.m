function x = newtraph(f,f1, x, TOL)

% newton raphson root finder
% f - function handle
% f1 - handle to df1/dx
% x - initial guess
% TOL - convergence criterion

delta = inf;
f0 = f(x);
fnew = f0;
while delta >= TOL * (1+abs(f0))
    f0 = fnew;
    x = x - f0/f1(x);
    fnew = f(x);
    delta = abs(fnew - f0);
end

end
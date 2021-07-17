function out = cdfilter(in,cf,sf)

% critically damped low-pass filter
% in - signal to be filtered
% cf - cutoff
% sf - sampling frequency

wn = cf * 2 * pi;
c1 = 2 * wn;
c2 = wn * wn;
out = dtSecondOrderSystem(in,c1,c2,c2,1/sf,c2dOptions('PrewarpFrequency',wn,'Method','tustin'));

end

function [x] = dtSecondOrderSystem(in,c1,c2,c3,Ts,options)

s = tf('s');
P = c3 / (s^2 + c1 * s + c2);
Pd = c2d(P,Ts,options);
D = Pd.Denominator{1};
N = Pd.Numerator{1};
c = D(1);
u0 = N(1)/c;
u1 = N(2)/c;
u2 = N(3)/c;
x1 = D(2)/c;
x2 = D(3)/c;

% initialize
x = zeros(1,length(in));
x(1) = in(1);
x(2) = in(2);

for k = 3:length(in)
    x(:,k) = u0 * in(k) + u1 * in(k-1) + u2 * in(k-2) - x1 * x(k-1) - x2 * x(k-2);
end

end
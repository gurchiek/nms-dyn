function [ cor, lag, istart, xsync, ysync ] = xcor( x, y, sf )
%Reed Gurchiek, 2018
%   xcor computes the cross correlation of signals x and y and the indices 
%   that align the signals
%
%   I think MATLABs built in xcorr available in base package. Best to use
%   it
%
%---------------------------INPUTS-----------------------------------------
%
%   x:
%     1xn signal
%
%   y:
%     1xm signal
%
%   sf:
%     sampling frequency.  Must be same for both
%       
%
%--------------------------OUTPUTS-----------------------------------------
%
%   istart:
%     1x2 indices that align the signals.  The best synchronization
%     between the two signals is x(istart(1):end) and y(istart(2):end).
%
%   cor:
%     correlation of the two signals
%
%   lag:
%     lags corresponding to each element of cor.
%
%   xsync, ysync:
%     synced signals. xsync = x(istart(1):n). ysync = y(istart(2):n).
%
%--------------------------------------------------------------------------
%% xcor

%dims
[r1,c1] = size(x);
[r2,c2] = size(y);
if r1 ~= 1
    if c1 ~= 1
        error('signals must be 1xn');
    end
    xn = r1;
    x = x';
else
    xn = c1;
end
if r2 ~= 1
    if c2 ~= 1
        error('signals must be 1xn');
    end
    yn = r2;
    y = y';
else
    yn = c2;
end

%for some reason, I only get accurate cross correlations when x and y are
%of equal length, length is a power of 2 and I don't zeros pad.  Zero
%padding is necessary for two reasons (pow of 2 for fft and to check lags
%for the whole length).  If I don't zero pad then I can only check lags up
%to +/- length/2.  But for whatever reason, when I zero pad, the max
%correlation is always at or near 0??? so for now I'm commenting this out
%and requiring input be pow of 2 and equal length
n = xn;

% %zero pad
% n = max([xn yn]);
% n2 = 2*n-1;
% x = [x zeros(1,n2-xn)];
% y = [y zeros(1,n2-yn)];

%transform, conjugate convolve, retransform
sig = [x; y];
[f,lag] = fdft(sig,sf);
cor = f(1,:).*conj(f(2,:));
cor = ifdft(cor);

%sort to compensate for negative freq
[lag,isrt] = sort(lag);
cor = cor(isrt);

%convert freq to discrete time steps and compensate for fdft zero pad
lag = round(lag*length(lag)/sf);
cor(lag < -(n-1) | lag > (n-1)) = [];
lag(lag < -(n-1) | lag > (n-1)) = [];

%sync
istart = [0 0];
[~,imx] = max(cor);
if lag(imx) < 0
    %then y lags x
    istart(1) = 1;
    istart(2) = -lag(imx);
    
    %sync
    ysync = y(istart(2):yn);
    xsync = x(1:xn);
else
    %x lags y
    istart(1) = 1+lag(imx);
    istart(2) = 1;
    
    %sync
    xsync = x(istart(1):xn);
    ysync = y(1:yn);
end

end
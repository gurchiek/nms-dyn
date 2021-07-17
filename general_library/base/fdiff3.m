function [ D1, D2 ] = fdiff3( data, time )
%Reed Gurchiek, 2021
%   fdiff3 time differentiates data once (D1) and twice (D2) using time
%   array (or scalar) 'time' using 3 point central difference method.
%   Requires at least 3 points. Works for both uniform and
%   non-uniform grids.
%
%   first/last points based on forward/backward differences
%
%------------------------------INPUTS--------------------------------------
%
%   data:
%       mxn where m is the number of time-series and n is the number of
%       data points for each time-series (column vectors)
%
%   time:
%       1xn time array or 1x1 scalar denoting time interval (e.g. 0.01 for
%       100 Hz sampling frequency).
%
%------------------------------OUTPUTS-------------------------------------
%
%   D1:
%       first derivative
%
%   D2:
%       second derivative
%
%--------------------------------------------------------------------------

%%  fdiff3

% get number of elements
[ndim,n] = size(data);
nt = length(time);

% allocate
D1 = zeros(ndim,n);
D2 = D1;

% first point of D1 estimate based on forward difference
if nt > 1

    % non uniform grid
    D1(:,1) = (data(:,2) - data(:,1))/(time(2) - time(1));
else

    % uniform grid
    D1(:,1) = (data(:,2) - data(:,1))/time;

end

% for second to second-to-last points, use 3 point central difference
for k = 2:n-1

    % non uniform grid
    if nt > 1 
        D1(:,k) = (data(:,k+1) - data(:,k-1))/(time(k+1) - time(k-1));
        D2(:,k) = (data(:,k+1) - 2*data(:,k) + data(:,k-1))/((time(k+1) - time(k-1))/2)^2;

    % uniform grid
    else
        D1(:,k) = (data(:,k+1) - data(:,k-1))/(2*time);
        D2(:,k) = (data(:,k+1) - 2*data(:,k) + data(:,k-1))/(time^2);
    end

end

% final slope of D1 based on backward difference
if nt > 1

    % non uniform grid
    D1(:,n) = (data(:,n) - data(:,n-1))/(time(n) - time(n-1));

else

    % uniform grid
    D1(:,n) = (data(:,n) - data(:,n-1))/time;

end

% first point of 2nd derivative based on forward difference of D1
if nt > 1

    % non uniform grid
    D2(:,1) = (D1(:,2) - D1(:,1))/(time(2) - time(1));

else

    % uniform grid
    D2(:,1) = (D1(:,2) - D1(:,1))/time;

end

% last 2nd derivative based on backward difference of D1
if nt > 1

    % non uniform grid
    D2(:,n) = (D1(:,n) - D1(:,n-1))/(time(n) - time(n-1));

else

    % uniform grid
    D2(:,n) = (D1(:,n) - D1(:,n-1))/time;

end

end
function [ d1, d2 ] = fdiff5( data, time )
%Reed Gurchiek, 2021
%   fdiff5 time differentiates data once (D1) and twice (D2) using time
%   array (or scalar) 'time' using 5 point quartic polynomial
%   interpolation. Requires at least 5 points. Works for both uniform and
%   non-uniform grids.
%
%   see comments in code for relationship with 5 point method based on
%   truncated Taylor polynomials (they are equivalent if the time array is
%   a uniform grid)
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

%%  fdiff5

%get number of elements
[ndim,n] = size(data);
nt = length(time);

% allocate
d1 = zeros(ndim,n);
d2 = zeros(ndim,n);

% if constant grid then cacluate constant matrices used in interpolation
% for uniform grid, vandermonde matrix (V) is constant and can be written
% as V = Vbar * D where Vbar is the vandermonde matrix correspoding to
% constant grid with step size 1 and D is diagonal. Vbar could be
% calculated vander([-2 -1 0 1 2]). Only need the inverse of the V in the
% algorithm: V_inverse = D_inverse * Vbar_inverse. Vbar_inverse is provided
% here explicitly and can be verified by doing [N,D] = rat(inv(Vbar)) where
% element i,j of the inverse is N(i,j)/D(i,j). The inverse of the diagonal
% matrix D is straight forward
if nt == 1
    
    % constant vandermonde matrix (see comments above)
    Vbar = vander([-2 -1 0 1 2]);
    D = diag([time^4,time^3,time^2,time,1]);
    V = Vbar * D;
    
    % inverse of Vbar described above
    Vbar_inverse = [ 1/24  -1/6   1/4  -1/6   1/24;...
                    -1/12   1/6    0   -1/6   1/12;...
                    -1/24   2/3  -5/4   2/3  -1/24;...
                     1/12  -2/3    0    2/3  -1/12;...
                      0      0     1     0     0  ];
    D_inverse = diag([1/time^4, 1/time^3, 1/time^2, 1/time,1]);
    V_inverse =  D_inverse * Vbar_inverse; % inverse of vandermonde matrix
    V1 = [V(:,2:4) * diag([4 3 2]), ones(5,1), zeros(5,1)]; % matrix s.t. V1 * p = first derivative where p is the coefs of the interpolating quartic polynomial
    V2 = [V(:,3:4) * diag([12 6]), 2 * ones(5,1), zeros(5,2)]; % same as for V1 except for second derivative
    
    % for verification note that the 5 point method based on truncated
    % Taylor polynomials results in:
    % dy3/dt = (2/3 * y4 - 2/3 * y2 - 1/12 * y5 + 1/12 * y1) / dt
    % using the approach laid out above this should be equivalent to
    % V1(3,:) * p, where p = V_inverse * y. But since y3 corresponds to t3
    % = 0 (is the center of the interpolation grid), then 
    % V1(3,:) = [0 0 0 1 0] and thus V1(3,:) * p effectively grabs the fourth
    % coefficient of p which is equal to V_inverse(4,:) * y which is shown
    % to be: D_inverse(4,4) * (1/12*y1 - 2/3*y2 + 2/3*y4 - 1/12*y5) (since
    % D is diagonal). D_inverse(4,4) being 1/dt thus yields the same
    % expression as for 5 point method based on truncated Taylor expansion
    % shown above
    
end

% for each time series
for r = 1:ndim
    
    % for each datapoint
    for c = 1:n
        
        % get indices of datapoints for interpolation (i) and index for 
        % current datapoint derivative being calculated for (k)
        if c < 3
            i = 1:5;
            k = c;
        elseif c > n-2
            i = n-4:n;
            k = 5 + c - n; % if c = n => k = 5, if c = n-1 => k = 4
        else
            i = c-2:c+2;
            k = 3; % interior point
        end
        
        % get interpolating datapoints
        y = data(r,i)';
        
        % if non uniform grid
        if nt > 1
            V = vander(time(i)-time(i(1)));
            p = V \ y; % coefs of interpolating quartic polynomial
            V1 = [V(:,2:4) * diag([4 3 2]), ones(5,1), zeros(5,1)];
            V2 = [V(:,3:4) * diag([12 6]), 2 * ones(5,1), zeros(5,2)];
            
        % otherwise, use already calculated constant vandermonde inverse
        else
            
            p = V_inverse * y; % coefs of interpolating quartic polynomial
            
        end

        % first derivative
        d1(r,c) = V1(k,:) * p;

        % second derivative
        d2(r,c) = V2(k,:) * p;
        
    end
    
end

end
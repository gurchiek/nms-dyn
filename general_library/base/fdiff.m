function [ D1, D2 ] = fdiff( data, time, npoint, TOL )
%Reed Gurchiek, 2021
%   fdiff time differentiates data once (D1) and twice (D2) using time
%   array (or scalar) 'time' using 3 or 5 point central difference method.
%   If time array is constant grid (up to a user set tolerance: default
%   = 1e-12) then derivative is based on an assumed constant grid with step
%   size equal to the average time difference in the user provided time
%   array. If 5 point selected then uses fdiff5. Default is 5 point method.
%   uses fdiff5 or fdiff3
%
%------------------------------INPUTS--------------------------------------
%
%   data:
%       mxn where m is the number of time-series and n is the number of
%       data points for each time-series (column vectors)
%
%   time:
%       1xn time array or 1x1 scalar denoting time interval (e.g. 0.01 for
%       100 Hz sampling frequency).  if 1xn time array and constant grid,
%       then npoint central difference method used.  If non-constant grid,
%       and 5 point requested, then differentiation done using derivative
%       of polynomial interpolated via lagrange method.
%
%   npoint (optional: default = 5):
%       number of points to use.  3 or 5 point method.
%
%   TOL (optional: default = 1e-12):
%       if time grid constant then dt_k = t_k+1 - t_k will be same for all
%       k, which would be dt_i - dt_j = 0 for all i,j. Thus, the grid is
%       considered constant if abs(dt_i - dt_j) < TOL for all i,j. If TOL
%       set to zero, then forces use of time array (does not assume
%       constant time step)
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

%%  fdiff

% tolerance for determining constant time steps
if nargin < 4
    TOL = 1e-12;
end

% get number of elements
nt = length(time);

% if time array given and TOL not = 0
if nt > 1 && TOL ~= 0
    
    % time step
    dt = diff(time);

    % if constant grid to within user specified tolerance
    if all(abs(diff(dt)) < TOL)

        % then assume constant grid
        time = mean(dt);

    end
    
end

% npoint default
if nargin == 2
    npoint = 5; % default
end

% if 5 point, use fdiff5
if npoint == 5
    
    [D1,D2] = fdiff5(data,time);

% if 3 point
else
    
    [D1,D2] = fdiff3(data,time);
    
end

end



%% UNUSED

% this is old and currently unused, but shows how 5 point interpolating
% quartic polynomial is estimated using lagrange method. fdiff5 does the
% same thing, but a little differently (more general)

% %if 5 point
% if npoint == 5
%     %for 3rd to 3rd to last points
%     for k = 3:n-2
%         %use derivative of polynomial interpolated via Lagrange method
%         if nt > 1 
%             %sum time points excluding center
%             t = time(k-2:k+2); t(3) = [];
%             tS = sum(t);
%             tSv = [tS-t(1); tS-t(2); tS-t(3); tS-t(4)]; %time sums as vector
%             %get cross product terms
%             prod = t'*t;
%             prod = triu(prod,1);
%             xpS = zeros(4,1); %cross product sum
%             xp3 = ones(4,1); %triple cross product used in divisors
%             div = zeros(4,1); %divisors in lagrange coefficients
%             for c = 1:4
%                 for row = 1:4
%                     if row ~= c
%                         xp3(c,1) = xp3(c,1)*t(row);
%                     end
%                     for col = 1:4
%                         if row ~= c && col ~= c
%                             xpS(c,1) = xpS(c,1) + prod(row,col);
%                         end
%                     end
%                 end
%                 div(c,1) = t(c)^3 - t(c)^2*tSv(c) + t(c)*xpS(c,1) - xp3(c,1);
%             end
%             %sum data points excluding center normalized by appropriate lagrangian divisor
%             d = data(:,k-2:k+2); d(:,3) = [];
%             d = d./repmat(div',[ndim 1]);
%             dS = sum(d,2);
%             
%             %get derivative
%             D1(:,k) = 3*time(k)^2*dS - ...
%                       2*time(k)*d*tSv + ...
%                       d*xpS;
%             D2(:,k) = 6*time(k)*dS - 2*d*tSv;
%         else
%             %if constant time interval then use Taylor Series derivation
%             D1(:,k) = (8*(data(:,k+1)-data(:,k-1)) - (data(:,k+2)-data(:,k-2)))/(12*time);
%             D2(:,k) = (16*(data(:,k+1)+data(:,k-1)) - 30*data(:,k) - (data(:,k+2)+data(:,k-2)))/(12*time^2);
%         end
%     end
% end


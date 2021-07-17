function [ out ] = mafilt( in, npoint )
%Reed Gurchiek,
%   mafilt is an npoint moving average filter.  If npoint is even then
%   average is average of current npoint window and previous.  Odd npoint
%   is more efficient. Uses midpoint moving average (non-causal)
%
%---------------------------INPUTS-----------------------------------------
%
%   in:
%       m x n unfiltered signal.  Dimension of greatest length is
%       considered time dimension
%
%   npoint:
%       window size over which to average
%
%--------------------------OUTPUTS-----------------------------------------
%
%   out:
%       filtered signal       
%
%--------------------------------------------------------------------------
%% mafilt

%work with columns as time dim
[r,c] = size(in);
if r > c
    n = r;
    nsig = c;
    in = in';
else
    n = c;
    nsig = r;
end
out = zeros(nsig,n);

%if even
if ~mod(npoint,2)

    %zero pad for initial and final points
    half = npoint/2;
    in = [zeros(r,half-1) in zeros(r,half+1)];

    %filter
    winsum = sum(in(:,1:npoint),2);
    winavg0 = winsum/(npoint - half + 1);
    for k = 1:n

        %divisor depends on whether using full window or not (end points)
        if k < half
            div = npoint - half + k;
        elseif k > n-half
            div = npoint - half + n - k;
        else
            div = npoint;
        end

        %get mean
        winavg = winsum/div;
        out(:,k) = 0.5*(winavg0 + winavg);

        %update for next iteration
        winavg0 = winavg;
        winsum = winsum - in(:,k) + in(:,k+npoint);

    end

%if odd
else

    %zero pad for initial and final points
    half = (npoint-1)/2;
    in = [zeros(nsig,half) in zeros(nsig,half+1)];

    %filter
    winsum = sum(in(:,1:npoint),2);
    for k = 1:n

        %divisor depends on whether using full window or not (end points)
        if k <= half
            div = half+k;
        elseif k > n-half
            div = npoint - half + n - k;
        else
            div = npoint;
        end

        %get mean
        out(:,k) = winsum/div;

        %update winsum for next iteration
        winsum = winsum - in(:,k) + in(:,k+npoint);

    end

end
    
%back to original dims if necessary
if r > c
    out = out';
end


end
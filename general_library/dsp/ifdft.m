function [ x ] = ifdft( f )
%Reed Gurchiek,
%   ifdft computes the inverse discrete fourier transform of a signal (x) 
%   using the radix-2 decimation in time fast fourier transform algorithm.
%
%   better to use matlabs built in ifft if available
%
%---------------------------INPUTS-----------------------------------------
%
%   f:
%       1xn signal in frequency domain
%
%   sf (optional):
%       sampling frequency associated with x.  If t is given then frequency 
%       will be returned
%
%--------------------------OUTPUTS-----------------------------------------
%
%   x:
%      1xn signal in time domain 
%
%   w:
%      1xn frequencies (if time given, otherwise null)
%
%--------------------------------------------------------------------------
%% ifdft

%set dimensions
[r,c] = size(f);
if r > c
    f = f';
    n0 = r;
    nsig = c;
else
    n0 = c;
    nsig = r;
end

%make signal length a power of 2
p = ceil(log2(n0));
n = 2^p;
z = zeros(nsig,n-n0);
f = [f z];

%initialize f as x in bit-reversed order
x = zeros(nsig,n);
bin = char(p);
for k = 0:n-1
    
    %get index in binary
    bin0 = dec2bin(k,p);
    
    %reverse bits
    for j = 1:p
        bin(j) = bin0(p-j+1);
    end
    
    %get index
    ind = bin2dec(bin);
    
    %switch
    x(:,k+1) = f(:,ind+1);
    x(:,ind+1) = f(:,k+1);
end

%outer loop iterates p times
for k = 1:p
    %get length of sub-dft
    sub = 2^k;
    i1 = 1;
    while i1 < n
        %for each consecutive index in sub-dft
        for m = 0:sub/2-1
            %for each signal
            for h = 1:nsig
                %butterfly
                odd = exp(1i*2*pi*m/sub)*x(h,i1 + m + sub/2);
                x(h,i1 + m + sub/2) = x(h,i1 + m) - odd;
                x(h,i1 + m) = x(h,i1 + m) + odd;
            end
        end
        i1 = i1 + sub;
    end
end

%normalize
x = real(x/n);

%back to original dimensions
if r > c
    x = x';
end

end
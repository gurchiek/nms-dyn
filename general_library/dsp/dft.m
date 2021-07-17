function [ Y, varargout ] = dft(y,varargin)
%Reed Gurchiek, 2017
%   dft performs discrete fourier transform of input signal 'y'.
%
%-----------------------------INPUTS---------------------------------------
%
%   y:
%       1xn signal (time-series).
%
%   varargin:
%       input sampling frequency as numeric to return angular frequency in
%       output of dft (varargout)
%
%       input 'plot' if you want dft to plot frequency spectrum (if 'plot'
%       is input, sampling frequency must also be given)
%
%----------------------------OUTPUTS---------------------------------------
%
%   Y:
%       fourier transform of y
%
%   varargout:
%       angular frequency if sampling frequency given in varargin
%
%--------------------------------------------------------------------------

%% dft

%length of y determines resolution of transform
n = length(y);

%create row array of indices
x = 0:n-1;

%for each index
Y = zeros(1,n);
for k = x
    for j = x
    
        %compute coefficient
        Y(k+1) = Y(k+1) + y(j+1)*exp(-2*pi*1i*k*j/n);
        
    end
end

%if plot given with no sampling frequency
if length(varargin) == 1 && strcmpi(varargin{1},'plot')
    %then cant perform plot, explain to user
    warning('dft cannot perform frequency plot without sampling frequency provided')
%if a numeric given
elseif length(varargin) == 1 && isa(varargin{1},'numeric')
    %then it should be sampling frequency, output frequency to user
    T = 1/varargin{1};
    w = x./(n*T);
    varargout = {w};
%if two extra input args given
elseif length(varargin) == 2 && (strcmpi(varargin{1},'plot')||strcmpi(varargin{2},'plot'))...
        && (isa(varargin{1},'numeric')||isa(varargin{2},'numeric'))
    %then get frequency and plot
    if isa(varargin{1},'numeric')
        T = 1/varargin{1};
    elseif isa(varargin{2},'numeric')
        T = 1/varargin{2};
    end
    w = x./(n*T);
    varargout = {w};
    plot(w,abs(Y))
    xlabel('Frequency');ylabel('Magnitude');
end

end


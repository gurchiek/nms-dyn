function [ ens, ub, lb ] = ensavg(data,centralTendency,varianceType,varianceScale)
%Reed Gurchiek, 2019
%   takes time series data matrix and computes ensemble average time series
%   and time series variance and plots
%
%----------------------------------INPUTS----------------------------------
%
%   data:
%       n x m, m is time index, n is number of time series over which to
%       average
%
%   centralTendency:
%       char array, 'mean' or 'median', how data averaged
%
%   varianceType:
%       char array, either 'sd' or 'quantile'. Will define upper
%       bound and lower bound of plot
%
%   varianceScale:
%       double, how to scale variance type:
%           (1) if 'std', then num of sd's for upper/lower bound
%           (2) if 'quantile', then defines the range of probability about
%           central tendency to cover. Example: if varianceType =
%           'quantile' and varianceScale = 0.8, then the lower bound of the
%           ensemble plot will be the 0.1 quantile and the upper bound will
%
%---------------------------------OUTPUTS----------------------------------
%
%   ens:
%       1 x m, ensemble average of time series data
%
%   ub:
%       1 x m, ubber bound of time series ensemble average
%
%   lb: 
%       1 x m, lower bound of time series ensemble average
%
%--------------------------------------------------------------------------
%% ensavg 

% get ens
centralTendency = str2func(centralTendency);
ens = centralTendency(data);

% if std for variance
if any(strcmpi(varianceType,{'std','sd'}))
    sd = std(data);
    ub = ens + varianceScale*sd;
    lb = ens - varianceScale*sd;

% if quantile
elseif any(strcmpi(varianceType,{'q','quantile'}))
    ub = quantile(data,0.5+varianceScale/2);
    lb = quantile(data,0.5-varianceScale/2);
    
else
    error('Input varianceType must be ''std'', ''sd'', ''q'' or ''quantile''');
end

end
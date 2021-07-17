function out = cdfiltfilt(in,cf,sf)

% critically damped low-pass forward backward filter with double-pass 
% adjustment
% in - signal to be filtered
% cf - cutoff
% sf - sampling frequency

[ndim,nsamp] = size(in);
trans = ndim > nsamp;
if trans
    in = in'; 
    [ndim,nsamp] = size(in);
end

% adjust cutoff
cf = cf / sqrt(2^(1/4) - 1);

% for each dimension
out = zeros(ndim,nsamp);
for r = 1:ndim
    
    % forward pass
    out(r,:) = cdfilter(in(r,:),cf,sf);
    
    % backward pass
    out(r,:) = flip(cdfilter(flip(out(r,:)),cf,sf));
    
end

% retranspose if necessary
if trans; out = out'; end

end
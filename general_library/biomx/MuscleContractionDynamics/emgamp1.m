function e = emgamp1(e,sf,options)

hp = options.highCutoff;
hn = options.highOrder;
e = bwfilt(e,hp,sf,'high',hn);
e = abs(e);

if strcmpi(options.method,'rms')
    
    e = e.^2;
    e = mafilt(e,options.windowSize);
    e = sqrt(e);
    
elseif strcmpi(options.method,'mav')
    
    e = mafilt(e,options.windowSize);
    
elseif strcmpi(options.method,'butter')
    
    e = bwfilt(e,options.lowCutoff,sf,'low',options.lowOrder);
    
end

end
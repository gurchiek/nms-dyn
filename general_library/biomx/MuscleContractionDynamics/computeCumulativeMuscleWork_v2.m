function work = computeCumulativeMuscleWork_v2(power,time)

% same as computeCumulativeMuscleWork except integrates power wrt to time
% instead of F*ds

% IN
% power in watts
% time in seconds

% OUT
% work.concentric in joules
% work.eccentric in joules

work.concentric = 0;
work.eccentric = 0;

for k = 1:length(time)-1
    
    % concentric
    if power(k) >= 0 && power(k+1) >= 0
        
        work.concentric = work.concentric + abs( (time(k+1) - time(k)) * (power(k) + power(k+1)) / 2);
        
    % eccentric
    elseif power(k) < 0 && power(k+1) < 0
        
        work.eccentric = work.eccentric + abs( (time(k+1) - time(k)) * (power(k) + power(k+1)) / 2);
    
    else
        
        % time at zero power
        tmid = interp1([power(k) power(k+1)],[time(k) time(k+1)],0,'linear');
        
        % first and second portions of work around zero crossing
        work1 = abs((tmid - time(k)) * power(k) / 2);
        work2 = abs((time(k+1) - tmid) * power(k+1) / 2);
        
        % assign type
        if power(k) > 0
            work.concentric = work.concentric + work1;
            work.eccentric = work.eccentric + work2;
        else
            work.concentric = work.concentric + work2;
            work.eccentric = work.eccentric + work1;
        end
        
    end
    
end

end
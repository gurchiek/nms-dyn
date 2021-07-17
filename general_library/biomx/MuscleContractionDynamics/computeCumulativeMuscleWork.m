function work = computeCumulativeMuscleWork(force,fiberLength,pennation)

% IN
% force in newtons
% fiber length in meters

% OUT
% work.concentric in joules
% work.eccentric in joules

work.concentric = 0;
work.eccentric = 0;

s = fiberLength .* cos(pennation);
ds = diff(s);
    

for k = 1:length(ds)
    
    % concentric
    if ds(k) < 0
        
        work.concentric = work.concentric + abs(ds(k) * (force(k) + force(k+1)) / 2);
        
    % eccentric
    elseif ds(k) > 0
        
        work.eccentric = work.eccentric + abs(ds(k) * (force(k) + force(k+1)) / 2);
    
    end
    
end

end
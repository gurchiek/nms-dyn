function stride = gaitEventDetection(t,w,sf)

% event detection algo from Mansour et al. 2015: swing  phase associated
% with large positive peaks in angular rate signal. These are identified
% first after low pass filtering at 3 hz. 
% Before each peak is a zero crossing and the foot off event is
% associated with the negative peak in the raw gyro signal just before this
% crossing. Likewise, after each peak is a zero crossing and the foot
% contact event is associaged with the negative peak in the raw gyro signal
% just after this crossing. 

% gait classification not perfect and neither is event detection, some
% non-stride data may make it through. Best practice is to apply
% lower/upper bounds on gait params (e.g. stride time, duty factor, etc)
% and remove outliers. This done in walkingStrideAnalysis_basic

% INPUTS:
% t - 1xn, timestamps
% w - 3xn, gyro (lateral distal shank), rad/s
% sf - sampling frequency

% OUTPUTS:
% stride, 1xm struct, fields specify:
%   (1) timestamp of swing phase
%   (2) timestamp of previous foot off event
%   (3) timestamp of next foot contact event
%   (4) timestamp of the start of the walking bout this stride is in (t(1))
%   (5) timestamp of the end of the walking bout this stride is in (t(end))

%%

swing_gyro_min_peak = 1.0;

% low pass gyro @ 3
wz = bwfilt(w(3,:),3,sf,'low',4);

% get all positive peaks > swingpeakmin rad/s
[~,ipos] = findpeaks(wz,'MinPeakHeight',swing_gyro_min_peak);
nEstimatedStrides = length(ipos);

% get all negative peaks
[~,ineg] = findpeaks(-w(3,:),'MinPeakHeight',0);

% get all positive and negative going zero crossings
[i,type] = crossing0(wz);
pz = i(contains(type,{'n2p','n2z','z2p'}));
nz = i(contains(type,{'p2n','p2z','z2n'}));

% initialize stride struct
stride(1:nEstimatedStrides) = struct('swingPhaseTimestamp',[],'prevFootOffTimestamp',[],'nextFootContactTimestamp',[],'boutStartTimestamp',t(1),'boutEndTimestamp',t(end));

% identify FO before each identified swing phase
% identify FC after each identified swing phase (ipos)
% for each positive peak (swing phase)
for k = 1:nEstimatedStrides
    
    % timestamp associated with peak angular velocity in swing
    stride(k).swingPhaseTimestamp = t(ipos(k));
    
    % get last positive going crossing
    x = pz(pz < ipos(k));
    if ~isempty(x)

        % negative peak just before this
        x = ineg(ineg < x(end));

        if ~isempty(x); stride(k).prevFootOffTimestamp = t(x(end)); end

    end
    
    % get the next negative going crossing
    x = nz(nz > ipos(k));
    
    % continue if non-empty
    if ~isempty(x)
        
        % use next negative peak
        x = ineg(ineg > x(1));
        
        if ~isempty(x); stride(k).nextFootContactTimestamp = t(x(1)); end
            
    end
    
end

    
end
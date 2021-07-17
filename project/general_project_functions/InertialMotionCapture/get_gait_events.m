function [ events ] = get_gait_events(a,time,options)
%% get_gait_events
%   Reed Gurchiek, 2020, rgurchiek@gmail.com
%
%   identifies instants of stride start (foot contact) and swing start
%   (foot off) given accelerometer signal aligned with long axis of thigh
%
%   requires signal processing toolbox
%
%----------------------------------INPUTS----------------------------------
%
%   a:
%       n element array, accelerometer data aligned with long axis of thigh
%
%   time:
%       n element time array in seconds
%
%   options:
%       struct, fields:
%           (1) minimumStrideTime: minimum allowable stride time, seconds
%           (2) maximumStrideTime: maximum allowable stride time, seconds
%           (3) minimumDutyFactor: minimum allowable duty factor, 0.0 - 1.0
%           (4) maximumDutyFactor: maximum allowable duty factor, 0.0 - 1.0
%           (5) nMinimumStrides: minimum number of strides required for
%                   extraction, otherwise, delete bout flag is set
%
%           -note: any strides that do not meet criteria (1) - (4) are
%           removed
%
%---------------------------------OUTPUTS----------------------------------
%
%   events:
%       struct, fields:
%           (1) deleteBout: if 1 then bout should be deleted
%           (2) strideStart: time associated with estimted stride start
%           (3) swingStart: time associated with estimated swing start
%           (4) strideTime
%           (5) dutyFactor
%
%--------------------------------------------------------------------------
%% get_gait_events

% init
deleteBout = 0;
dt = mean(diff(time));
sf = 1/dt;
strideStart = [];
swingStart = [];
minimumStrideTime = options.minimumStrideTime;
maximumStrideTime = options.maximumStrideTime;
minimumDutyFactor = options.minimumDutyFactor;
maximumDutyFactor = options.maximumDutyFactor;
nMinimumStrides = options.nMinimumStrides;

% get frequency characteristics
a10 = bwfilt(a,10,sf,'high',4);
[fpow,freq] = pwelch(a - mean(a),rectwin(round(sf*2)),[],4096,sf);
fpow(freq < 0.5 | freq > 4) = [];
freq(freq < 0.5 | freq > 4) = [];
[~,ipow] = extrema(fpow);
ipow(ipow == 1) = []; ipow(ipow == length(fpow)) = [];
freq = freq(ipow);
fpow = fpow(ipow);
[~,imax] = max(fpow);
stpf = freq(imax);
fpow(freq >= stpf) = [];
freq(freq >= stpf) = [];

% assume stride frequency is the maximum remaining
[~,imax] = max(fpow);
strf = freq(imax);

% if empty then delete
if isempty(strf) || isempty(stpf)

    deleteBout = 1;

else

    % low pass at stpf, strf, and 5*strf
    astp = bwfilt(a,stpf,sf,'low',4);
    astr = bwfilt(a,strf,sf,'low',4);
    astrx = bwfilt(a,5*stpf/2,sf,'low',4);

    % get minima/maxima of stride/step filtered signals
    clear imax
    [~,imax.str,~,imin.str] = extrema(astr);
    [~,imax.stp,~,imin.stp] = extrema(astp);

    % remove endpoints
    imin.str(imin.str == 1) = []; 
    imax.str(imax.str == 1) = []; 
    imax.stp(imax.stp == 1) = [];
    imin.stp(imin.stp == 1) = [];
    imin.str(imin.str == length(astr)) = []; 
    imax.str(imax.str == length(astr)) = [];
    imax.stp(imax.stp == length(astr)) = [];
    imin.stp(imin.stp == length(astr)) = [];

    % get instants where z low passed at 5*strf crosses 1 g
    icrossg = crossing0(astrx-1,{'n2p'});

    % sometimes false minima identified within stride
    % require minima be within min and max stride times
    i = 1;
    while i <= length(imin.str) - 1
        if imin.str(i+1)-imin.str(i) < floor(minimumStrideTime*sf)
            
            % get variance between points
            int_length = imin.str(i+1) - imin.str(i);
            var1 = var(a10(imin.str(i):imin.str(i) + int_length));
            if imin.str(i+1) + int_length > length(a)
                var2 = var(a10(imin.str(i+1):end));
            else
                var2 = var(a10(imin.str(i+1):imin.str(i+1) + int_length));
            end
            
            % remove one with lesser variance
            if var1 > var2
                imin.str(i+1) = [];
            elseif var2 > var1
                imin.str(i) = [];
              
            % otherwise use one with lowest associated stpf filtered min
            else
            
                [~,temp1] = min(abs(imin.str(i) - imin.stp));
                [~,temp2] = min(abs(imin.str(i+1) - imin.stp));
                if temp1 == temp2
                    if astr(imin.str(i+1)) < astr(imin.str(i))
                        imin.str(i) = [];
                    else
                        imin.str(i+1) = [];
                    end
                else
                    if astp(imin.stp(temp2)) < astp(imin.stp(temp1))
                        imin.str(i) = [];
                    else
                        imin.str(i+1) = [];
                    end
                end
                
            end
        elseif imin.str(i+1)-imin.str(i) > ceil(maximumStrideTime*sf)
            imin.str(i) = [];
        else
            i = i + 1;
        end
    end

    % need at least 2 more minima than nMinimumStrides
    if length(imin.str) < nMinimumStrides + 2
        
        deleteBout = 1;

    else

        % gait phase detection algorithm:
        % get last step peak between stride minima = swing start
        % get following valley for each stride peak ~ FC
        % next 1g crossing in astrx is best estimate of FC

        % for each minima
        swingStart = zeros(1,length(imin.str) - 1);
        strideStart = zeros(1,length(imin.str)-1);
        i = 1;
        while i <= length(imin.str)-1

            deleteStride = 0;

            % get astp peaks between current and next astr minima
            swingStart0 = imax.stp(imax.stp > imin.str(i) & imax.stp < imin.str(i+1));

            % if empty then delete
            if isempty(swingStart0)
                deleteStride = 1;
            % otherwise
            else

                % if 1 peak then this is our estimate
                % if 2 peaks then take the latest
                if length(swingStart0) == 2
                    swingStart0 = max(swingStart0);
                % if more than 2 peaks then take the one corresponding
                % to the largest peak
                elseif length(swingStart0) > 2
                    [~,swingStart00] = max(astp(swingStart0));
                    swingStart0 = swingStart0(swingStart00);
                end

                % get swing start
                swingStart(i) = time(swingStart0);

                % get next valley
                strideStart0 = imin.stp(swingStart0 < imin.stp);

                % if is empty then delete
                if isempty(strideStart0)
                    deleteStride = 1;

                % also require this valley be less than 1g
                elseif astp(strideStart0(1)) >= 1
                    deleteStride = 1;

                else

                    % get next instant where astrx crossed 1g
                    crossg = icrossg(icrossg > strideStart0(1));

                    % if none then delete
                    if isempty(crossg)
                        deleteStride = 1;

                    else

                        % 1g crossing instant is best estimate of FC. 
                        crossg = crossg(1);

                        % require crossg be within 320 ms of strideStart0
                        if (crossg - strideStart0(1))/sf > 0.320
                            deleteStride = 1;
                        else
                            % interpolate between current crossg 
                            % (immediately after) and previous to estimate
                            strideStart(i) = (dt - astrx(crossg-1)*time(crossg) + astrx(crossg)*time(crossg-1))/(astrx(crossg) - astrx(crossg-1));
                        end

                    end

                end

            end

            if deleteStride
                swingStart(i) = [];
                strideStart(i) = [];
                imin.str(i) = [];
            else
                i = i + 1;
            end

        end
        
    end
    
end

if isempty(strideStart)
    deleteBout = 1;
end

 % if not deleting
if ~deleteBout

    % stride ends are stride starts without first
    strideEnd = strideStart;
    strideStart(end) = [];
    strideEnd(1) = [];

    % FC before first swing start not identified, delete
    swingStart(1) = [];

    % get stride endpoints and check times
    nStrides = length(strideStart);
    events.strideStart = zeros(1,nStrides);
    events.strideEnd = zeros(1,nStrides);
    events.swingStart = zeros(1,nStrides);
    events.strideTime = zeros(1,nStrides);
    events.dutyFactor = zeros(1,nStrides);
    i = 1;
    while i <= nStrides

        deleteStride = 0;

        % get stride time
        strideTime0 = strideEnd(i) - strideStart(i);

        % get duty factor
        dutyFactor0 = (swingStart(i)-strideStart(i))/strideTime0;

        % verify stride time/duty factor within constraints
        if strideTime0 > maximumStrideTime || strideTime0 < minimumStrideTime
            deleteStride = 1;
        elseif dutyFactor0 > maximumDutyFactor || dutyFactor0 < minimumDutyFactor
            deleteStride = 1;
        end

        % if didn't meet critieria
        if deleteStride

            % delete stride
            strideEnd(i) = [];
            strideStart(i) = [];
            swingStart(i) = [];
            nStrides = nStrides - 1;
            events.strideStart(i) = [];
            events.strideEnd(i) = [];
            events.strideTime(i) = [];
            events.swingStart(i) = [];
            events.dutyFactor(i) = [];

        % otherwise save
        else

            events.strideStart(i) = strideStart(i);
            events.strideEnd(i) = strideEnd(i);
            events.strideTime(i) = strideTime0;
            events.swingStart(i) = swingStart(i);
            events.dutyFactor(i) = dutyFactor0;
            i = i + 1;

        end

    end

end

events.deleteBout = deleteBout;

end

function [ out ] = bwfilt(in,cf,sf,type,order)
%   bwfilt uses MATLABs butter function to determine the transfer
%   function coefficients to filter signal(s) in sampled at frequency sf by
%   a specified order according to the specified filter type
%   'low','high','bandpass','bandstop'.  The transfer function is
%   implemented in filtfilt to remove phase shift (i.e. filter is zero lag)
%
%---------------------------INPUTS-----------------------------------------
%
%   in:
%       m x n signal to be filtered.  the longest dimension is considered
%       the time dimension.
%
%   cf:
%       cutoff frequency.  If vector then type should be bandpass.
%
%   sf:
%       scalar, sampling frequency in samples/second.
%
%   type (optional):
%       'low','high','bandpass','bandstop', default = 'low'
%
%   order (optional):
%       filter order, should be even, default = 4;
%
%--------------------------OUTPUTS-----------------------------------------
%
%   out:
%       filtered signal
%
%--------------------------------------------------------------------------
%% bwfilt

% filter type
if nargin > 3
    if contains(type,'l','IgnoreCase',1)
        type = 'low';
    elseif contains(type,'h','IgnoreCase',1)
        type = 'high';
    elseif contains(type,'stop','IgnoreCase',1)
        type = 'stop';
    elseif contains(type,'b','IgnoreCase',1)
        type = 'bandpass';
    else
        type = 'low';
    end
else
    type = 'low';
end

% filter order
if nargin > 4
    % if odd, make even
    if mod(order,2)
        order = order + 1;
        warning('User requested filter order (%d) is not even.  Using order = %d instead.',order-1,order)
    end
    % divide by 2 to compensate for filtfilt
    order = order/2;
else
    order = 2;
end
    
% get transfer fxn coefs
[b,a] = butter(order,2*cf/sf,type);

% transpose to adjust for filtfilt
[r,c] = size(in);
if c > r; in = in'; end

% filter
out = filtfilt(b,a,in);
if c > r; out = out'; end


end

function [ max,imax,min,imin ] = extrema( x )
%Reed Gurchiek,
%   extrema finds local minima and maxima of the vector x
%
%---------------------------INPUTS-----------------------------------------
%
%   x:
%       n-element array for which the local minima and maxima will be found
%
%--------------------------OUTPUTS-----------------------------------------
%
%   max,imax:
%       local maxima values (max) and their indices (imax)
%
%   min,imin:
%       local minima values (min) and their indices (imin)
%
%--------------------------------------------------------------------------
%% extrema

%initialize
max = [];
min = [];
imax = [];
imin = [];


%get differences
d = diff(x);

%get extrema if any nonzero changes
if any(d)
    
    %allocation
    imax = zeros(1,length(d));
    imin = zeros(1,length(d));
    
    %endpoints are always local extrema
    first = find(x ~= x(1));
    first(2:end) = [];
    last = find(x ~= x(end));
    last(1:end-1) = [];
    
    if x(1) < x(first)
        iminFirst = 1:first-1;
        imaxFirst = [];
    else
        iminFirst = [];
        imaxFirst = 1:first - 1;
    end
    
    if x(end) < x(last)
        iminLast = last+1:length(x);
        imaxLast = [];
    else
        imaxLast = last+1:length(x);
        iminLast = [];
    end
    
    %for each element
    maxct = 0;
    minct = 0;
    direction0 = sign(x(first)-x(first-1));
    constant = 0;
    for k = first+1:last+1
        
        %current trajectory
        direction = sign(x(k) - x(k-1));
        
        %if no change
        if direction == 0
            
            constant = constant + 1;
            
        %otherwise
        else
            
            %if local minimum
            if direction == 1 && direction0 == -1
                
                %update min/imin
                minct = minct + 1 + constant;
                imin(minct-constant:minct) = k-1-constant:k-1;
            
            %if local maximum
            elseif direction == -1 && direction0 == 1
                
                %update max/imax
                maxct = maxct + 1 + constant;
                imax(maxct-constant:maxct) = k-1-constant:k-1;
            end
            
            %current trajectory is next iteration previous
            direction0 = direction;
            
            %no consecutive constant
            constant = 0;
            
        end
    end
    
    %finish
    imax = [imaxFirst imax imaxLast];
    imax(imax==0) = [];
    max = x(imax);
    imin = [iminFirst imin iminLast];
    imin(imin==0) = [];
    min = x(imin);
end


end

function [ i, type ] = crossing0( x, type0 )
%   crossing0 finds the zero crossings in the 1D array x.
%
%---------------------------INPUTS-----------------------------------------
%
%   x:
%       1D array
%       
%   type0 (optional):
%       cell array, type of zero crossing.  
%           1) 'p2z': positive to zero
%           2) 'p2n': positive to negative
%           3) 'z2n': zero to negative
%           4) 'n2z': negative to zero
%           5) 'n2p': negative to positive
%           6) 'z2p': zero to positive
%           7) 'all': 1) through 6)
%               -combos allowed (e.g. type = {'p2n' 'n2p'});
%
%--------------------------OUTPUTS-----------------------------------------
%
%   i:
%       1xp array of zero crossing indices
%
%   type: 
%       1xp cell array of type of crossing associated with the indices in i
%       (see INPUT type for description of names
%
%--------------------------------------------------------------------------
%% crossing0

%type
if nargin == 2
    if ~iscell(type0)
        if strcmpi(type0,'all')
            type0 = {'p2z' 'p2n' 'z2n' 'n2z' 'n2p' 'z2p'};
        else
            type0{1} = type0;
        end
    elseif any(strcmpi('all',type0))
        type0 = {'p2z' 'p2n' 'z2n' 'n2z' 'n2p' 'z2p'};
    end
else
    type0 = {'p2z' 'p2n' 'z2n' 'n2z' 'n2p' 'z2p'};
end

%for each sample
ct = 0;
sgn0 = sign(x(1));
i = [];
type = {''};
for k = 2:length(x)
    
    %current sign
    sgn = sign(x(k));
    
    %if crossed
    if sgn ~= sgn0
        
        %positive to zero
        if sgn0 == 1 && sgn == 0
            if any(strcmpi('p2z',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'p2z';
            end
        %positive to negative
        elseif sgn0 == 1 && sgn == -1
            if any(strcmpi('p2n',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'p2n';
            end
        %zero to negative
        elseif sgn0 == 0 && sgn == -1
            if any(strcmpi('z2n',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'z2n';
            end
        %negative to zero
        elseif sgn0 == -1 && sgn == 0
            if any(strcmpi('n2z',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'n2z';
            end
        %negative to positive
        elseif sgn0 == -1 && sgn == 1
            if any(strcmpi('n2p',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'n2p';
            end
        %zero to positive
        elseif sgn0 == 0 && sgn == 1
            if any(strcmpi('z2p',type0))
                ct = ct + 1;
                i(ct) = k;
                type{ct} = 'z2p';
            end
        end
        
    end
    
    %update previous sign
    sgn0 = sgn;
    
end
    

end
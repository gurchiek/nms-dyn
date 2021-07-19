function trial = getMocapGaitEvents(trial,options)

% must have characterized foot principal frame kinematics (velocity in
% particular) and knee joint angle

% options:
% (1) grfThreshold = threshold above which is foot contact
% (2) analysisName = name for inv kin analysis (e.g. 'constrained')
% (3) side = 'right' or 'left'

% updates following events (note: anl = 'analysisName'):
% (1) trial.(anl).events.footContact: instant foot hit force plate
% (2) trial.(anl).events.footOff: instant foot came off force plate
% (3) trial.(anl).events.footContact2: instant foot hit ground after force plate foot off event
% (4) trial.(anl).events.footOff0: instant foot came off ground prior to force plate foot contact
% (5) trial.(anl).events.peakKneeFlexionSwing1: instant knee flexion was maximum during the swing phase after the force plate foot off event
% (6) trial.(anl).events.peakKneeFlexionSwing0: instant knee flexion was maximum during the swing phase before the force plate foot contact event
% (7) trial.(anl).events.peakKneeFlexionMidStance: knee flexion has two peaks
%           across a stride (generally): one during stance and one during 
%           swing. The one during stance is not necessarily the maximum 
%           knee flexion angle during stance, but is associated with the 
%           knee flexion during the loading phase. peakKneeFlexionMidStance 
%           returns the instant of this event

% the numbers (e.g. footOff0, peakKneeFexionSwing1, footContact2) indicate
% the gait cycle where a gait cyle 0 starts at the foot contact prior to
% the force plate, gait cyle 1 starts at the force plate foot contact, and
% gait cycle 2 starts at the foot contact after the force plate foot off 

% expects one foot contact to be present from the first force plate signal
% (ie trial.forcePlate(1))

% since only one foot contact is present, right or left is not specified in
% the events structure (it simply pertains to the one that hit the force
% plate)

%% get gait events

% unpack
thresh = options.grfThreshold;
side = options.side;
anl = options.analysisName;

% get instances GRF crossed threshold: positive going = foot contact, negative going = foot off
[ix,type] = crossing0(trial.forcePlate(1).force(2,:)-thresh,{'z2p','p2z','n2p','p2n'});
fc = ix(strcmp(type,'z2p')|strcmp(type,'n2p'));
trial.(anl).events.footContact = fc(1);
fo = ix(strcmp(type,'p2z')|strcmp(type,'p2n'));
trial.(anl).events.footOff = fo(1)-1;

% estimate foot off from previous contact using kinematic data (no GRF...)
% O'Connor et al. 2007
% foot midpoint vertical velocity peaks at toe off and valleys at contact
% very near contact is another peak
% we want the one prior to GRF based foot contact
% so identify the two peaks prior to this point and use the one associated with the largest velocity
[~,fo0] = findpeaks(trial.(anl).body.segment.([side '_foot']).principal.velocity(2,:));
fo0(fo0 >= fc(1)) = [];
fo0 = fo0(end-1:end);
[~,imax] = max(trial.(anl).body.segment.([side '_foot']).principal.velocity(2,fo0));
trial.(anl).events.footOff0 = fo0(imax);

% estimate next foot contact
% first get two least valleys within next 50% stride time after foot off
% foot contact is the later one
strideTime = trial.(anl).events.footOff - trial.(anl).events.footOff0;
[pfc2,fc2] = findpeaks(-trial.(anl).body.segment.([side '_foot']).principal.velocity(2,:)); pfc2 = -pfc2;
pfc2(fc2 <= trial.(anl).events.footOff) = [];
fc2(fc2 <= trial.(anl).events.footOff) = [];
pfc2(fc2 > trial.(anl).events.footOff + round(strideTime * trial.samplingFrequency / 2)) = [];
fc2(fc2 > trial.(anl).events.footOff + round(strideTime * trial.samplingFrequency / 2)) = [];
if length(fc2) >= 2
    [~,imin] = min(pfc2);
    imin1 = fc2(imin);
    pfc2(imin) = [];
    fc2(imin) = [];
    [~,imin] = min(pfc2);
    imin2 = fc2(imin);
    fc2 = imin2;
    if imin1 > imin2; fc2 = imin1; end
    trial.(anl).events.footContact2 = fc2;
    
    % peak knee flexion: swing1 (swing phase after footContact)
    [~,imax] = max(trial.(anl).body.joint.([side '_knee']).flexion.angle(trial.(anl).events.footOff:trial.(anl).events.footContact2));
    trial.(anl).events.peakKneeFlexionSwing1 = imax + trial.(anl).events.footOff - 1;
end

% peak knee flexion: swing0 (swing phase prior to footContact)
[~,imax] = max(trial.(anl).body.joint.([side '_knee']).flexion.angle(trial.(anl).events.footOff0:trial.(anl).events.footContact));
trial.(anl).events.peakKneeFlexionSwing0 = imax + trial.(anl).events.footOff0 - 1;

% peak knee flexion: stance
[~,imax] = findpeaks(trial.(anl).body.joint.([side '_knee']).flexion.angle(trial.(anl).events.footContact:trial.(anl).events.footOff));
trial.(anl).events.peakKneeFlexionStance = imax + trial.(anl).events.footContact - 1;



end
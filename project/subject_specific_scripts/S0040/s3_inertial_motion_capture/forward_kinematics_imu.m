%% SCRIPT 3: invertial motion capture

% imu driven kinematics

% need following gen coord to inform model:
%   (1) foot position: pf, ankle jc
%   (2) foot orientation: qf
%   (3) shank position: ps, knee jc
%   (4) shank orientation: qs
%   (5) thigh position: pt, hip jc
%   (6) thigh orientation: qt
%   (7) pelvis position: pp, hip jc
%   (8) pelvis orientation: qp

% algorithm:
%   (1) get foot contact/off events
%   (2) get shank orientation at mid stance
%   (3) integrate forward to foot off and backward to foot contact
%   (4) get thigh orientation, 2 options:
%       (4a) integration as for shank via steps 2-3
%       (4b) via Seel 2014 method:
%               (4bi) get knee jc accel based on shank/thigh angular rate (gyro), position vectors (sensor to kjc) from calibration, and shank/thigh acceleration
%               (4bii) these should differ in the joint plane only through a rotation about the knee axis: angle estimated as in Seel et al. 2014 eq (14)
%               (4biii) fuse knee angle estimate from 4bii and by integrating angular rates projected onto joint axes
%                           -option 1: RTS smoother
%                           -option 2: complementary filter
%               (4biii) get qt given qs from 2-3 and knee angle from 4bii
%   (5) get knee joint center acceleration
%   (6) get ankle joint center acceleration
%   (7) double integrate
%   (8) adjust offset so ankle jc (foot position) is at the same height above ground as in static pose
%   (9) get foot pitch angle from midstance to foot off assuming the vector from ground contact point under toe to ajc is constant
%   (10) get foot pitch angle from foot contact to midstance assuming the vector from ground contact point under heel to ajc is constant
%   (11) with foot pitch, construct foot quaternion assuming heading is same as shank and roll is 0
%   (12) get shank position (knee jc) given ankle jc, shank orientation, and constant ankle2knee vector from model
%   (13) get thigh position (hip jc) give knee jc, thigh orientation, and constant knee2hip vector from model
%   (14) get pelvis position = thigh position from (13)
%   (15) get pelvis orientation: assume null except heading is average shank heading during stance

close all
clear
clc

% subject ID
subid = 'S0040';

% set name for this analysis
anl = 'imc';

% use seels complementary filter or RTS version
filter_method = 'rts'; % 'comp' or 'rts'

% marker-based dynamics analysis name
% the sensor event detection will identify all foot contact/offs
% so this used to make sure the same stance phase is analyzed between the
% imu-driven and marker-driven analyses
mkranl = 'constrained';

% load calibrated model
load(replace(cd,'s3_inertial_motion_capture',['nmsdyn_' subid '.mat']))

% set trial names to analyze here
tnames = {'walk_1','walk_2','walk_3','walk_4','walk_5','walk_6','walk_7','walk_8','walk_9','walk_10'};

% gyro biases
bs = model.gyroscope.distal_lateral_shank_right.bias; % shank
bt = model.gyroscope.anterior_thigh_right.bias; % thigh

% gravity scalar for accelerometer normalization
gs = model.accelerometer.distal_lateral_shank_right.meanMagnitude;
gt = model.accelerometer.anterior_thigh_right.meanMagnitude;

% processing params
lpc = session.kinematicLowPassCutoff;
grav = session.gravitationalAcceleration;

% vectors pointing from sensor location to knee joint center in mechanical frame
rs = model.segment.right_shank.imu.distal_lateral_shank_right.sensor2KneeJointCenter.mechanical.position;
rt = model.segment.right_thigh.imu.anterior_thigh_right.sensor2KneeJointCenter.mechanical.position;

% sensor to segment orientation: q st v_seg_mechanical = q * v_sensor * q_conj
qs2s = model.segment.right_shank.imu.distal_lateral_shank_right.sensor2segment.mechanical.orientation;
qs2t = model.segment.right_thigh.imu.anterior_thigh_right.sensor2segment.mechanical.orientation;

% for each trial
for t = 1:length(tnames)
    
    fprintf('-trial %d/%d: %s\n',t,length(tnames),tnames{t})
    
    % get sensor data
    stime = trial.(tnames{t}).sensorTime;
    sf = 1/mean(diff(stime));
    wsraw = trial.(tnames{t}).gyroscope.locations.distal_lateral_shank_right.gyro.data - bs; % for event detection using shank gyro
    atraw = model.accelerometer.anterior_thigh_right.meanDirection' * trial.(tnames{t}).accelerometer.locations.anterior_thigh_right.accel.data / gt; % for event detection using thigh accel
    ws = bwfilt(wsraw,lpc,sf,'low',4);
    wt = bwfilt(trial.(tnames{t}).gyroscope.locations.anterior_thigh_right.gyro.data - bt,lpc,sf,'low',4);
    wsdot = bwfilt(fdiff(ws,1/sf,5),lpc,sf,'low',4);
    wtdot = bwfilt(fdiff(wt,1/sf,5),lpc,sf,'low',4);
    as = grav * bwfilt(trial.(tnames{t}).accelerometer.locations.distal_lateral_shank_right.accel.data / gs,lpc,sf,'low',4);
    at = grav * bwfilt(trial.(tnames{t}).accelerometer.locations.anterior_thigh_right.accel.data / gt,lpc,sf,'low',4);
    
    % transform to mechanical frame
    wsraw = qrot(qs2s,wsraw);
    ws = qrot(qs2s,ws);
    wsdot = qrot(qs2s,wsdot);
    as = qrot(qs2s,as);
    wt = qrot(qs2t,wt);
    wtdot = qrot(qs2t,wtdot);
    at = qrot(qs2t,at);
    
    % gait events
    % gyro-based
    stride = gaitEventDetection(stime,wsraw,sf); % gyro-based 
    
    % accel-based (remaining syntax assumes gyro-based, would need to adapt
    % for accel-based)
%     events =
%     get_gait_events(atraw,stime,struct('minimumStrideTime',0.9,'maximumStrideTime',1.6,'minimumDutyFactor',0.45,'maximumDutyFactor',0.75,'nMinimumStrides',1));
    
    % get imu-stride closest to FP contact in mocap trial
    % this only done for eventual comparison to marker + force plate
    % analysis
    fcs = [stride.nextFootContactTimestamp];
    mfc = trial.(tnames{t}).(trial.(tnames{t}).(mkranl).kinematicsTimeName)(trial.(tnames{t}).(mkranl).events.footContact);
    [~,imin] = min(abs(fcs - mfc));
    trial.(tnames{t}).(anl).events.footContactTime = stride(imin).nextFootContactTimestamp;
    trial.(tnames{t}).(anl).events.footContact = find(stime == stride(imin).nextFootContactTimestamp);
    trial.(tnames{t}).(anl).events.footOffTime = stride(imin+1).prevFootOffTimestamp;
    trial.(tnames{t}).(anl).events.footOff = find(stime == stride(imin+1).prevFootOffTimestamp);
    ifo = trial.(tnames{t}).(anl).events.footOff;
    ifc = trial.(tnames{t}).(anl).events.footContact;
    
    % get joint center acceleration based on thigh and shank data
    Ms = zeros(3,3,length(stime)); % will need this later, Ms = wskew * wskew + askew, where w is angular rate and a is angular acceleration
    cs = zeros(3,length(stime)); % knee joint center acceleration in shank mechanical frame
    ct = cs; % knee joint center acceleration in thigh mechanical frame
    theta = zeros(1,length(stime)); % knee joint angle
    for k = 1:length(stime)
        
        % get knee joint center accel given sensor accel, sensor ang rate
        % and know position vector: sensor to knee joint center
        Ms(:,:,k) = skew(ws(:,k))*skew(ws(:,k)) + skew(wsdot(:,k));
        Mt = skew(wt(:,k))*skew(wt(:,k)) + skew(wtdot(:,k));
        cs(:,k) = as(:,k) + Ms(:,:,k) * rs;
        ct(:,k) = at(:,k) + Mt * rt;
        
        % cs and ct should only differ in joint plane up to a rotation
        % through the knee joint angle, so get angles between cs and ct in
        % joint plane (see Seel et al. 2014 eq 14)
        dotprod = cs(1:2,k)' * ct(1:2,k);
        csmag = sqrt(cs(1:2,k)' * cs(1:2,k));
        ctmag = sqrt(ct(1:2,k)' * ct(1:2,k));
        theta(k) = acos( dotprod / csmag / ctmag ); % knee angle estimate
    end
    theta = bwfilt(theta,lpc,sf,'low',4);
    
    % initialize mid stance shank orientation
    % get stillest quarter of stance time for shank
    stancetime = trial.(tnames{t}).(anl).events.footOffTime - trial.(tnames{t}).(anl).events.footContactTime;
    istill = staticndx(as(:,ifc:ifo),round(sf * stancetime / 4)) + ifc - 1;
    istart = round(mean(istill));
    g_s = normc(mean(as(:,istill(1):istill(2)),2)); % world frame vertical in shank frame
    axis = normc([g_s(3); 0; -g_s(1)]);
    axis = sign(axis(3)) * axis; % make sure axis in same half plane as shank z
    angle = sign(g_s(1)) * acosd(g_s(2));
    qs0 = [axis*sind(angle/2); cosd(angle/2)];
    
    % get qs integrating forward/backward
    qs = zeros(4,length(stime));
    qs(:,istart) = qs0;
    qs(:,istart:end) = intqexp(qs0,ws(:,istart:end),stime(istart:end),1,1,1,1);
    qs(:,1:istart) = intqexp(qs0,ws(:,1:istart),stime(1:istart),1,1,1,0);
    
    % initialize mid stance thigh orientation
    g_t = normc(mean(at(:,istill(1):istill(2)),2));
    axis = normc([g_t(3); 0; -g_t(1)]);
    axis = sign(axis(3)) * axis;
    angle = sign(g_t(1)) * acosd(g_t(2));
    qt0 = [axis*sind(angle/2); cosd(angle/2)];
    
    % get qt integrating forward/backward
    qti = zeros(4,length(stime));
    qti(:,istart) = qt0;
    qti(:,istart:end) = intqexp(qt0,wt(:,istart:end),stime(istart:end),1,1,1,1);
    qti(:,1:istart) = intqexp(qt0,wt(:,1:istart),stime(1:istart),1,1,1,0);
    
    % get qst taking thigh to shank
    % knee angle based on quaternion integration (assuming hinge) would be
    % twice the arcosine of the scalar part of qst
    qst = qprod(qconj(qs),qti);
    
    % alternatively, get knee angle via seel 2014 method
    % seel (2014) notes accel based knee angle estimate is "less reliable
    % in moments of large acceleration changes" (in paragraph before eq 15)
    % so characterize measurement uncertainty based on accel/gyro noise and
    % magnitudes of thigh/shank acceleration derivatives
    da = vecnorm(fdiff(as,1/sf,5)) + vecnorm(fdiff(at,1/sf,5));
    
    % knee angle from rts smoother or complementary filter
    wsd = model.gyroscope.distal_lateral_shank_right.magnitudeStandardDeviation + model.gyroscope.anterior_thigh_right.magnitudeStandardDeviation; % sum gyro noise sd
    asd = model.accelerometer.distal_lateral_shank_right.magnitudeStandardDeviation + model.accelerometer.anterior_thigh_right.magnitudeStandardDeviation; % sum accel noise sd
    R = 0.25 * da * (asd^2 + wsd^2); % measurement noise covariance
    [xrts,xcomp] = getKneeAngle(stime,ws,wt,theta,R,wsd);
    if strcmp(filter_method,'comp')
        xfilt = xcomp;
    elseif strcmp(filter_method,'rts')
        xfilt = xrts;
    end
    
    % get thigh orientation
    qt = zeros(4,length(stime));
    qt(3,:) = sin(xfilt/2);
    qt(4,:) = cos(xfilt/2);
    qt = qprod(qs,qt);
    
    % get knee joint center acceleration in world frame
    cw = qrot(qs,cs) - [0 grav 0]';
    
    % get ankle joint center acceleration
    rjc = model.segment.right_shank.child.jointPosition.mechanical;
    caw = zeros(3,length(stime));
    for k = 1:length(stime)
        caw(:,k) = cw(:,k) + qrot(qs(:,k),Ms(:,:,k) * rjc);
    end
    
    % integrate forward/backward from mid stance (istart), v0 = 0 here
    vw = zeros(3,length(stime));
    vw(:,istart:end) = cumtrapz(stime(istart:end),caw(:,istart:end)')';
    vw(:,1:istart) = flip(cumtrapz(flip(-stime(1:istart)),flip(-caw(:,1:istart)',1)))';
    pf = cumtrapz(stime,vw')';
    
    % adjust so height at istart is equal to ankle jc height in static pose
    x0 = model.joint.right_ankle.position - pf(:,istart);
    pf = pf + x0;
    
    % get foot pitch angle after midstance
    s = vecnorm(model.joint.right_ankle.position([1 3]) - model.marker.right_toe_tip.position([1 3])); % distance between proj of ajc onto ground and proj of toe tip onto ground
    pf(1,:) = pf(1,:) - pf(1,istart) - s;
    atheta = zeros(1,length(stime));
    atheta(istart:ifo) = atan2(pf(2,istart:ifo),-pf(1,istart:ifo));
    atheta(istart:ifo) = atheta(istart:ifo) - atheta(istart);
    atheta(istart:ifo) = -atheta(istart:ifo);
    
    % get ankle angle before midstance
    s = vecnorm(model.joint.right_ankle.position([1 3]) - model.marker.right_heel.position([1 3])); % distance between proj of ajc onto ground and proj of heel onto ground
    pf(1,:) = pf(1,:) - pf(1,istart) + s;
    atheta(ifc:istart) = atan2(pf(2,ifc:istart),pf(1,ifc:istart));
    atheta(ifc:istart) = atheta(ifc:istart) - atheta(istart);
    
    % convert to quaternion assuming same heading as shank and 0 roll with
    % adjustment for pitch/roll of mechanical frame in static pose
    model_euler = convq(qconj(model.segment.right_foot.mechanical.orientation),'yzx');
    qf = convq(qconj(qs),'yzx');
    shank_heading = qf(1,:); % save shank heading for pelvis q later
    qf(2,:) = atheta + model_euler(2);
    qf(3,:) = model_euler(3);
    qf = qconj(conveuler(qf,'yzx','q'));
    
    % get knee joint center location (shank position)
    ps = pf + qrot(qs,-rjc);
    
    % get hip joint center location (thigh position)
    pt = ps + qrot(qt,-model.segment.right_thigh.child.jointPosition.mechanical);
    
    % get pelvis orientation (assume null) except that heading is constant
    % and equal to average shank heading during stance
    qp = zeros(3,length(stime));
    qp(1,:) = mean(shank_heading(ifc:ifo));
    qp = qconj(conveuler(qp,'yzx','q'));
        
    % get pelvis position
    pp = pt + qrot(qp,-model.segment.pelvis.child.jointPosition.mechanical);
    
    % concatenate gen coords into one vector and convert to multibody
    % system only during stance (since less able to characterize foot
    % beyond stance at the moment)
    x = [pp; qp; pt; qt; ps; qs; pf; qf];
    x = x(:,ifc:ifo);
    xdot = fdiff(x,1/sf,5);
    xddot = fdiff(x,1/sf,5);
    trial.(tnames{t}).(anl).body.generalizedCoordinates.mechanical.position = x;
    trial.(tnames{t}).(anl).body.generalizedCoordinates.mechanical.velocity = xdot;
    trial.(tnames{t}).(anl).body.generalizedCoordinates.mechanical.acceleration = xddot;
    trial.(tnames{t}).(anl).body = generalizedCoordinates2MultibodySystem(model,trial.(tnames{t}).(anl).body,struct('coordinateSystem','mechanical','lowPassCutoff',lpc,'samplingFrequency',sf));
    trial.(tnames{t}).(anl).body = coordinateTransformation(model,trial.(tnames{t}).(anl).body,'mechanical','principal');
    trial.(tnames{t}).(anl).body = coordinateTransformation(model,trial.(tnames{t}).(anl).body,'mechanical','anatomical');
    trial.(tnames{t}).(anl).body = patellaModel(model,trial.(tnames{t}).(anl).body,'right');
    trial.(tnames{t}).(anl).body = getGlobalBodyContourGeometry(model,trial.(tnames{t}).(anl).body,'right_femoralCondyle','anatomical');
    trial.(tnames{t}).(anl).body = getGlobalMuscleGeometry(model,'anatomical',trial.(tnames{t}).(anl).body);
    trial.(tnames{t}).(anl).body = getKneeFlexionMomentArm5(model,trial.(tnames{t}).(anl).body,'right');
    trial.(tnames{t}).(anl).body = getAnkleFlexionMomentArm5(model,trial.(tnames{t}).(anl).body,'right');
    trial.(tnames{t}).(anl).body = getVelocityMTU(trial.(tnames{t}).(anl).body,struct('samplingFrequency',sf,'lowPassCutoff',lpc));
    
    % update events since truncating to stance phase only
    trial.(tnames{t}).(anl).events.footContact = 1;
    trial.(tnames{t}).(anl).events.footOff = ifo-ifc+1;
    
    % get muscle excitations
    trial.(tnames{t}) = getMuscleExcitations(model,trial.(tnames{t}),'imc');
    
    % create new time array in trial.(trialName) associated with
    % imu-identified stance phase
    trial.(tnames{t}).imcTime = stime(ifc:ifo);
    
    % set time array names
    trial.(tnames{t}).(anl).kinematicsTimeName = 'imcTime';
    trial.(tnames{t}).(anl).excitationTimeName = 'sensorTime';
    
end

beep

%% save

ok = questdlg('Save (will overwrite any existing)?','Save','Yes','No','Yes');
if ~isempty(ok)
    if ok(1) == 'Y'
        clearvars -except model session trial
        session.forward_kinematics_imu_date = datetime;
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep




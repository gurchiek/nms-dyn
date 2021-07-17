function model = sensor2segment(model,session)

% function used in script 1: calibrate musculoskeletal geometry

% must have already run calibrateIMU
% must have already imported star + walking trials 1-10 and data stored in
% session.trial...

% computes the quatiernion s.t. v_mechanical = q * v_sensor * q_conj for
% both thigh and shank, stored in model.segment.right_shank.imu.distal_lateral_shank_right.sensor2segment.mechanical.orientation
% and equivalently for right_thigh

% also computes the vector pointing from the imu to the knee joint center
% (shank parent joint position and thigh child joint position), stored in:
% model.right_shank.imu.distal_lateral_shank_right.sensor2KneeJointCenter.mechanical.position
% and equivalently for right_thigh

% world vertical axes from static trial in shank/thigh accel frames
ys = model.accelerometer.distal_lateral_shank_right.meanDirection;
yt = model.accelerometer.anterior_thigh_right.meanDirection;

% accelerometer normalization for 1g
gs = model.accelerometer.distal_lateral_shank_right.meanMagnitude;
gt = model.accelerometer.anterior_thigh_right.meanMagnitude;

% gyro bias
bs = model.gyroscope.distal_lateral_shank_right.bias;
bt = model.gyroscope.anterior_thigh_right.bias;

% get star calibration data
opt = session.dataImport.gyro.options;
opt.locations = {'anterior_thigh_right', 'distal_lateral_shank_right'};
opt.trialNames = {'Star_Calibration'};
opt.renameTrials = {'Star_Calibration','star'};
opt.sensors = {'gyro','accel'};
stardat = importMC10x(opt);
starind = model.musculoskeletalGeometryCalibration.starOptions.indices.right_hip; % this should be indices of hip movement (not the knee flexion/ankle movements), sagittal plane data is taken from walking since thigh accelerations/ang vel larger there thus better manifests radial vectors
wtstar = stardat.trials.star.locations.anterior_thigh_right.gyro.data(:,starind);
atstar = stardat.trials.star.locations.anterior_thigh_right.accel.data(:,starind);
wsstar = stardat.trials.star.locations.distal_lateral_shank_right.gyro.data(:,starind);
asstar = stardat.trials.star.locations.distal_lateral_shank_right.accel.data(:,starind);

% data for sensor to segment alignment
% straight level walking + star hip rotations and knee flex/ext
% may only use walks 8-10 anticipating these three walks will be validation
% trials wherein walks 1-7 are used for mtu parameter identification
tnames = {'walk_8','walk_9','walk_10'};%,'walk_1','walk_2','walk_3','walk_4','walk_5','walk_6','walk_7'};

% num data points for each calibration trial
trial = session.trial;
n = zeros(1,length(tnames)+1);
for t = 1:length(tnames); n(t) = length(trial.(tnames{t}).sensorTime); end
n(end) = length(starind);

% initialize matrices containing shank/thigh angular rates + derivs + accel for all cal trials
ws = zeros(3,sum(n));
wt = ws;
wsdot = ws;
wtdot = ws;
as = ws;
at = ws;

% process calibration data from walking trials
lpc = 6; % low pass walking trials at 6 hz
gyrosf = session.dataImport.gyro.options.resample;
accsf = session.dataImport.accel.options.resample;
i = 1;
for t = 1:length(tnames)
    
    % remove bias + filter shank/thigh gyro
    ws(:,i:sum(n(1:t))) = bwfilt(trial.(tnames{t}).gyroscope.locations.distal_lateral_shank_right.gyro.data - bs,lpc,gyrosf,'low',4);
    wt(:,i:sum(n(1:t))) = bwfilt(trial.(tnames{t}).gyroscope.locations.anterior_thigh_right.gyro.data - bt,lpc,gyrosf,'low',4);
    
    % differentiate + filter angular rates
    wsdot(:,i:sum(n(1:t))) = bwfilt(fdiff(ws(:,i:sum(n(1:t))),1/gyrosf,5),lpc,gyrosf,'low',4);
    wtdot(:,i:sum(n(1:t))) = bwfilt(fdiff(wt(:,i:sum(n(1:t))),1/gyrosf,5),lpc,gyrosf,'low',4);
    
    % normalize shank/thigh accel (by gravity scalar from static) + smooth
    as(:,i:sum(n(1:t))) = bwfilt(trial.(tnames{t}).accelerometer.locations.distal_lateral_shank_right.accel.data / gs,lpc,accsf,'low',4);
    at(:,i:sum(n(1:t))) = bwfilt(trial.(tnames{t}).accelerometer.locations.anterior_thigh_right.accel.data / gt,lpc,accsf,'low',4);
    
    % next trial
    i = sum(n(1:t)) + 1;
end

% process calibration data from star trials
lpc = 3; % low pass star data at 3 Hz
ws(:,i:sum(n)) = bwfilt(wsstar - bs,lpc,gyrosf,'low',4);
wt(:,i:sum(n)) = bwfilt(wtstar - bt,lpc,gyrosf,'low',4);
wsdot(:,i:sum(n)) = bwfilt(fdiff(ws(:,i:sum(n)),1/gyrosf,5),lpc,gyrosf,'low',4);
wtdot(:,i:sum(n)) = bwfilt(fdiff(wt(:,i:sum(n)),1/gyrosf,5),lpc,gyrosf,'low',4);
as(:,i:sum(n)) = bwfilt(asstar / gs,lpc,accsf,'low',4);
at(:,i:sum(n)) = bwfilt(atstar / gt,lpc,accsf,'low',4);

% get knee rotation axes in sensor frames
zs0 = [0 0 1]';
zt0 = [0 -1 0]';
[zs,zt] = fraseel12lm(ws,wt,zs0,zt0);

% report
fprintf('-Angle between optimization-based knee flexion axis in shank IMU frame and world vertical in shank IMU frame (should be close to 90): %5.2f degrees\n',acosd(ys'*zs))
fprintf('-Angle between optimization-based knee flexion axis in thigh IMU frame and world vertical in thigh IMU frame (should be close to 90): %5.2f degrees\n',acosd(yt'*zt))

% now we have two reference vectors measured in mechanical (from mocap) and
% sensor frames: (1) knee flexion axis, (2) gravity
% use this to construct sensor to segment orientation

% knee flexion axis in mechanical frames is the third basis vec
zsmech = [0 0 1]';
ztmech = [0 0 1]';

% get gravity (world vertical) in mechanical frames
ysmech = qrot(qconj(model.segment.right_shank.mechanical.orientation),[0 1 0]');
ytmech = qrot(qconj(model.segment.right_thigh.mechanical.orientation),[0 1 0]');

% get dcm st v_shank_mechanical = Rs * v_shank_sensor (and likewise for thigh)
Rs = triad([zsmech ysmech],[zs ys]);
Rt = triad([ztmech ytmech],[zt yt]);

% report
fprintf('-Knee flexion axis in shank IMU frame: x = %3.2f, y = %3.2f, z = %3.2f\n',Rs(3,1),Rs(3,2),Rs(3,3))
fprintf('-Knee flexion axis in thigh IMU frame: x = %3.2f, y = %3.2f, z = %3.2f\n',Rt(3,1),Rt(3,2),Rt(3,3))
fprintf('-Shank long axis in shank IMU frame: x = %3.2f, y = %3.2f, z = %3.2f\n',Rs(2,1),Rs(2,2),Rs(2,3))
fprintf('-Shank long axis in thigh IMU frame: x = %3.2f, y = %3.2f, z = %3.2f\n',Rt(2,1),Rt(2,2),Rt(2,3))

% rotate gyro/accel data to segment frame
ws = Rs * ws;
wsdot = Rs * wsdot;
as = Rs * as;
wt = Rt * wt;
wtdot = Rt * wtdot;
at = Rt * at;

% get vectors pointing from accel location to knee joint centers in segment frames (star cal data only)
rs =  qrot(model.segment.right_shank.mechanical.orientation,model.joint.right_knee.position - model.marker.right_lateral_distal_shank.position,'inverse'); % first guess for shank is based on distal lateral shank marker
rt =  qrot(model.segment.right_thigh.mechanical.orientation,model.joint.right_knee.position - model.marker.right_anterior_thigh25.position,'inverse'); % first guess for thigh
lbs = [rs(1) - 0.05; rs(2) - 0.05; rs(3) - 0.05]; % lower bound for shank
ubs = [rs(1) + 0.05; rs(2) + 0.05; 0]; % upper bound for shank
lbt = [rt(1) - 0.05; rt(2) - 0.05; rt(3) - 0.05]; % lower bound for thigh
ubt = [0; rt(2) + 0.05; rt(3) + 0.05]; % upper bound for thigh
[rs,rt] = fjcseel12lm(ws(:,i:sum(n)),wt(:,i:sum(n)),wsdot(:,i:sum(n)),wtdot(:,i:sum(n)),as(:,i:sum(n))*session.gravitationalAcceleration,at(:,i:sum(n))*session.gravitationalAcceleration,rs,rt,lbs,lbt,ubs,ubt);

% adjust s.t. points are closest to sensors (see seel 2014 eq 9)
rs(3) = rs(3) - mean([rs(3) rt(3)]);
rt(3) = rt(3) - mean([rs(3) rt(3)]);

% report
fprintf('-Shank sensor to knee joint center in shank frame: x = %3.2f, y = %3.2f, z = %3.2f, magnitude = %5.2f\n',rs(1),rs(2),rs(3),vecnorm(rs))
fprintf('-Thigh sensor to knee joint center in thigh frame: x = %3.2f, y = %3.2f, z = %3.2f, magnitude = %5.2f\n',rt(1),rt(2),rt(3),vecnorm(rt))

% update model: sensor to segment orientations
model.segment.right_shank.imu.distal_lateral_shank_right.sensor2segment.mechanical.orientation = convdcm(Rs,'q');
model.segment.right_thigh.imu.anterior_thigh_right.sensor2segment.mechanical.orientation = convdcm(Rt,'q');

% update model: sensor to knee jc for shank/thigh
model.segment.right_shank.imu.distal_lateral_shank_right.sensor2KneeJointCenter.mechanical.position = rs;
model.segment.right_thigh.imu.anterior_thigh_right.sensor2KneeJointCenter.mechanical.position = rt;

end
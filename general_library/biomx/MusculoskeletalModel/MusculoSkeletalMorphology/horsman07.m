function model = horsman07(options)

% horsman 2007 mtu model
% tendon lengths are provided but these are not to be confused with tendon
% slack length (see Horsman thesis). In thesis, say these were obtained
% from literature.

if nargin == 0
    options.singleVM = false;
    options.singleVL = false;
    options.singleSOL = false;
end
if ~isfield(options,'singleVM'); options.singleVM = false; end
if ~isfield(options,'singleVL'); options.singleVL = false; end
if ~isfield(options,'singleSOL'); options.singleSOL = false; end

% general
model.sex = 'male';
model.height = 1.74;
model.mass = 105;

% table 2: bony landmarks
model.marker.right_asis.position = [3.76 8.78 4.15]' / 100;
model.marker.left_asis.position = [3.76 8.78 -22.09]' / 100;
model.marker.right_psis.position = [-11.33 8.58 -4.53]' / 100;
model.marker.left_psis.position = [-11.14 8.97 -13.34]' / 100;
model.marker.right_trochanter.position = [-5.98 -3.66 5.12]' / 100;
model.marker.right_med_femoral_epicondyle.position = [7.68 -40.50 -3.21]' / 100;
model.marker.right_lat_femoral_epicondyle.position = [3.17 -39.96 5.47]' / 100;
model.marker.right_medial_tibial_condyle.position = [7.78 -44.05 -2.06]' / 100;
model.marker.right_lateral_tibial_condyle.position = [3.28 -43.60 5.22]' / 100;
model.marker.right_tibial_tuberosity.position = [1.26 -45.65 5.21]' / 100;
model.marker.right_fibular_head.position = [8.74 -45.77 4.27]' / 100;
model.marker.right_medial_malleolus.position = [11.20 -79.21 1.04]' / 100;
model.marker.right_lateral_malleolus.position = [4.50 -81.59 4.55]' / 100;
model.marker.right_metatarsal1.position = [19.82 -90.81 1.29]' / 100;
model.marker.right_metatarsal5.position = [10.42 -95.04 4.52]' / 100;
model.marker.right_heel.position = [3.25 -81.97 -2.3075]' / 100; % average of med/lat gastroc/soleus insertions
model.markerNames = fieldnames(model.marker);

% table 4: ligament geometry
model.ligament.right_patellar.origin.position = [10.2 -39.7 3.6]' / 100;
model.ligament.right_patellar.origin.segment = 'right_patella';
model.ligament.right_patellar.insertion.position = [8.5 -45.5 3.8]' / 100;
model.ligament.right_patellar.insertion.segment = 'right_shank';
model.ligament.right_patellar.length = vecnorm(model.ligament.right_patellar.origin.position - model.ligament.right_patellar.insertion.position);
model.ligament.right_patellar.local.anatomical.insertion.position = [3.57 34.74 0.29]' / 100;

% table 5: femoral condyle cylinder
model.bodyContour.right_femoralCondyle.type = 'cylinder';
model.bodyContour.right_femoralCondyle.position = [6.06 -40.22 -1.75]' / 100;
model.bodyContour.right_femoralCondyle.axis = normalize([-0.37 0.04 0.93]');
model.bodyContour.right_femoralCondyle.radius = 2.46 / 100;
model.bodyContour.right_femoralCondyle.segment = 'right_thigh';

% table 6: joint centers/axes
model.joint.right_hip.position = [0 0 0]';
model.joint.right_knee.position = [3.84 -40.78 1.38]' / 100;
model.joint.right_ankle.position = [9.33 -81.36 3.14]' / 100;
model.joint.right_femurPatellar.position = [3.51 -38.51 1.90]' / 100;

model.joint.right_femurPatellar.flexion.axis = normalize([-0.465 0.024 0.885]');
model.joint.right_knee.flexion.axis = normalize([-0.528 -0.107 0.843]');
model.joint.right_ankle.flexion.axis = normalize([-0.73 -0.206 0.652]');
model.joint.right_ankle.adduction.axis = normalize([-0.780 -0.223 -0.584]'); % subtalar

% table 1: Horsman thesis, pg 141
model.joint.right_hip.euler.xyz = [-0.07 0.05 0]';
model.joint.right_knee.euler.xyz = [0.26 -0.61 0.16]';
model.joint.right_ankle.euler.xyz = [0.14 0.59 -0.01]';

% adjust knee joint center using mid femoral epicondyle point, knee joint
% axis, and point on knee joint axis as is done in star calibration-based
% definition
midEpicondyle = mean([model.marker.right_med_femoral_epicondyle.position,model.marker.right_lat_femoral_epicondyle.position],2);
model.joint.right_knee.position = model.joint.right_knee.position + model.joint.right_knee.flexion.axis * (midEpicondyle - model.joint.right_knee.position)' * model.joint.right_knee.flexion.axis;

% segments
model.segment.pelvis.mass = 3.18;
model.segment.pelvis.markerNames = {'right_asis','left_asis','right_psis','left_psis'};
model.segment.pelvis.nMarkers = 4;
model.segment.right_thigh.mass = 11.54;
model.segment.right_thigh.markerNames = {'right_trochanter','right_med_femoral_epicondyle','right_lat_femoral_epicondyle'};
model.segment.right_thigh.nMarkers = 3;
model.segment.right_shank.mass = 4.0;
model.segment.right_shank.markerNames = {'right_tibial_tuberosity','right_medial_tibial_condyle','right_lateral_tibial_condyle','right_fibular_head','right_medial_malleolus','right_lateral_malleolus'};
model.segment.right_shank.nMarkers = 6;
model.segment.right_foot.mass = 1.30;
model.segment.right_foot.markerNames = {'right_heel','right_metatarsal1','right_metatarsal5'};
model.segment.right_foot.nMarkers = 3;
model.segmentNames = {'pelvis','right_thigh','right_shank','right_foot'};
model.segmentIndices = [1 2 3 4];

%% inferior vastus lateralis

% morphology
model.muscle.right_inferiorVastusLateralis.pcsa = 10.7 / 100 / 100;
model.muscle.right_inferiorVastusLateralis.optimalFiberLength = 4.2 / 100;
model.muscle.right_inferiorVastusLateralis.fiberLength = 3.3 / 100;
model.muscle.right_inferiorVastusLateralis.tendonLength = 9.6 / 100;
model.muscle.right_inferiorVastusLateralis.mass = 48 / 1000;
model.muscle.right_inferiorVastusLateralis.pennation = 0;
model.muscle.right_inferiorVastusLateralis.phi0 = 0;
model.muscle.right_inferiorVastusLateralis.bodyContour = '';
model.muscle.right_inferiorVastusLateralis.nViaPoints = 0;
model.muscle.right_inferiorVastusLateralis.nElements = 6;
model.muscle.right_inferiorVastusLateralis.scaleSegment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.joints = {'right_knee'};

% attachment elements
model.muscle.right_inferiorVastusLateralis.element(1).origin.position = [2.69 -29.27 2.17]' / 100;
model.muscle.right_inferiorVastusLateralis.element(1).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(1).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(1).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusLateralis.element(2).origin.position = [2.09 -24.72 2.18]' / 100;
model.muscle.right_inferiorVastusLateralis.element(2).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(2).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(2).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusLateralis.element(3).origin.position = [1.19 -20.26 2.39]' / 100;
model.muscle.right_inferiorVastusLateralis.element(3).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(3).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(3).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusLateralis.element(4).origin.position = [-0.01 -15.88 2.81]' / 100;
model.muscle.right_inferiorVastusLateralis.element(4).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(4).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(4).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusLateralis.element(5).origin.position = [-1.51 -11.59 3.44]' / 100;
model.muscle.right_inferiorVastusLateralis.element(5).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(5).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(5).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusLateralis.element(6).origin.position = [-3.30 -7.38 4.28]' / 100;
model.muscle.right_inferiorVastusLateralis.element(6).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusLateralis.element(6).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_inferiorVastusLateralis.element(6).insertion.segment = 'right_patella';

%% superior vastus lateralis

% morphology
model.muscle.right_superiorVastusLateralis.pcsa = 59.0 / 100 / 100;
model.muscle.right_superiorVastusLateralis.optimalFiberLength = 9.1 / 100;
model.muscle.right_superiorVastusLateralis.fiberLength = 7.0 / 100;
model.muscle.right_superiorVastusLateralis.tendonLength = 9.6 / 100;
model.muscle.right_superiorVastusLateralis.mass = 568 / 1000;
model.muscle.right_superiorVastusLateralis.pennation = 0;
model.muscle.right_superiorVastusLateralis.phi0 = 0;
model.muscle.right_superiorVastusLateralis.bodyContour = '';
model.muscle.right_superiorVastusLateralis.nViaPoints = 0;
model.muscle.right_superiorVastusLateralis.viaPoint = struct();
model.muscle.right_superiorVastusLateralis.nElements = 2;
model.muscle.right_superiorVastusLateralis.scaleSegment = 'right_thigh';
model.muscle.right_superiorVastusLateralis.joints = {'right_knee'};

% attachment elements
model.muscle.right_superiorVastusLateralis.element(1).origin.position = [-2.66 -3.32 6.10]' / 100;
model.muscle.right_superiorVastusLateralis.element(1).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusLateralis.element(1).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_superiorVastusLateralis.element(1).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusLateralis.element(2).origin.position = [-0.90 -1.61 5.16]' / 100;
model.muscle.right_superiorVastusLateralis.element(2).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusLateralis.element(2).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_superiorVastusLateralis.element(2).insertion.segment = 'right_patella';

%% vastus lateralis

% if single VL then use mean of superior + inferior VL geometry and combined mass and pcsa
if options.singleVL
    
%     model.muscle.right_vastusLateralis = model.muscle.right_superiorVastusLateralis;
    
    % morphology
    model.muscle.right_vastusLateralis.pcsa = sum([model.muscle.right_superiorVastusLateralis.pcsa,model.muscle.right_inferiorVastusLateralis.pcsa]);
    model.muscle.right_vastusLateralis.mass = sum([model.muscle.right_superiorVastusLateralis.mass,model.muscle.right_inferiorVastusLateralis.mass]);
    model.muscle.right_vastusLateralis.optimalFiberLength = sum([model.muscle.right_superiorVastusLateralis.optimalFiberLength,model.muscle.right_inferiorVastusLateralis.optimalFiberLength]);
    model.muscle.right_vastusLateralis.fiberLength = sum([model.muscle.right_superiorVastusLateralis.fiberLength,model.muscle.right_inferiorVastusLateralis.fiberLength]);
    model.muscle.right_vastusLateralis.tendonLength = sum([model.muscle.right_superiorVastusLateralis.tendonLength,model.muscle.right_inferiorVastusLateralis.tendonLength]);
    model.muscle.right_vastusLateralis.pennation = sum([model.muscle.right_superiorVastusLateralis.pennation,model.muscle.right_inferiorVastusLateralis.pennation]);
    model.muscle.right_vastusLateralis.phi0 = asin(model.muscle.right_vastusLateralis.fiberLength / model.muscle.right_vastusLateralis.optimalFiberLength * sin(model.muscle.right_vastusLateralis.pennation));
    model.muscle.right_vastusLateralis.bodyContour = '';
    model.muscle.right_vastusLateralis.nViaPoints = 0;
    model.muscle.right_vastusLateralis.viaPoint = struct();
    model.muscle.right_vastusLateralis.nElements = 2;
    model.muscle.right_vastusLateralis.scaleSegment = 'right_thigh';
    model.muscle.right_vastusLateralis.joints = {'right_knee'};

    % attachment elements
    model.muscle.right_vastusLateralis.element(1).origin.position = mean([model.muscle.right_superiorVastusLateralis.element(1).origin.position,model.muscle.right_inferiorVastusLateralis.element(1).origin.position],2);
    model.muscle.right_vastusLateralis.element(1).origin.segment = 'right_thigh';
    model.muscle.right_vastusLateralis.element(1).insertion.position = mean([model.muscle.right_superiorVastusLateralis.element(1).insertion.position,model.muscle.right_inferiorVastusLateralis.element(1).insertion.position],2);
    model.muscle.right_vastusLateralis.element(1).insertion.segment = 'right_patella';
    
    model.muscle.right_vastusLateralis.element(2).origin.position = mean([model.muscle.right_superiorVastusLateralis.element(2).origin.position,model.muscle.right_inferiorVastusLateralis.element(2).origin.position],2);
    model.muscle.right_vastusLateralis.element(2).origin.segment = 'right_thigh';
    model.muscle.right_vastusLateralis.element(2).insertion.position = mean([model.muscle.right_superiorVastusLateralis.element(2).insertion.position,model.muscle.right_inferiorVastusLateralis.element(2).insertion.position],2);
    model.muscle.right_vastusLateralis.element(2).insertion.segment = 'right_patella';
    
    % remove inferior + superior VL
    model.muscle = rmfield(model.muscle,{'right_inferiorVastusLateralis','right_superiorVastusLateralis'});
    
end

%% inferior vastus medialis

% morphology
model.muscle.right_inferiorVastusMedialis.pcsa = 9.8 / 100 / 100;
model.muscle.right_inferiorVastusMedialis.optimalFiberLength = 7.6 / 100;
model.muscle.right_inferiorVastusMedialis.fiberLength = 6.2 / 100;
model.muscle.right_inferiorVastusMedialis.tendonLength = 9.6 / 100;
model.muscle.right_inferiorVastusMedialis.mass = 78 / 1000;
model.muscle.right_inferiorVastusMedialis.pennation = 0;
model.muscle.right_inferiorVastusMedialis.phi0 = 0;
model.muscle.right_inferiorVastusMedialis.bodyContour = '';
model.muscle.right_inferiorVastusMedialis.nViaPoints = 0;
model.muscle.right_inferiorVastusMedialis.viaPoint = struct();
model.muscle.right_inferiorVastusMedialis.nElements = 2;
model.muscle.right_inferiorVastusMedialis.scaleSegment = 'right_thigh';
model.muscle.right_inferiorVastusMedialis.joints = {'right_knee'};

% attachment elements
model.muscle.right_inferiorVastusMedialis.element(1).origin.position = [4.17 -29.43 0.75]' / 100;
model.muscle.right_inferiorVastusMedialis.element(1).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusMedialis.element(1).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_inferiorVastusMedialis.element(1).insertion.segment = 'right_patella';

model.muscle.right_inferiorVastusMedialis.element(2).origin.position = [5.25 -29.22 0.78]' / 100;
model.muscle.right_inferiorVastusMedialis.element(2).origin.segment = 'right_thigh';
model.muscle.right_inferiorVastusMedialis.element(2).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_inferiorVastusMedialis.element(2).insertion.segment = 'right_patella';

%% middle vastus medialis

% morphology
model.muscle.right_middleVastusMedialis.pcsa = 23.2 / 100 / 100;
model.muscle.right_middleVastusMedialis.optimalFiberLength = 7.6 / 100;
model.muscle.right_middleVastusMedialis.fiberLength = 6.2 / 100;
model.muscle.right_middleVastusMedialis.tendonLength = 9.6 / 100;
model.muscle.right_middleVastusMedialis.mass = 186 / 1000;
model.muscle.right_middleVastusMedialis.pennation = 0;
model.muscle.right_middleVastusMedialis.phi0 = 0;
model.muscle.right_middleVastusMedialis.bodyContour = '';
model.muscle.right_middleVastusMedialis.nViaPoints = 0;
model.muscle.right_middleVastusMedialis.viaPoint = struct();
model.muscle.right_middleVastusMedialis.nElements = 2;
model.muscle.right_middleVastusMedialis.scaleSegment = 'right_thigh';
model.muscle.right_middleVastusMedialis.joints = {'right_knee'};

% attachment elements
model.muscle.right_middleVastusMedialis.element(1).origin.position = [3.68 -24.91 1.22]' / 100;
model.muscle.right_middleVastusMedialis.element(1).origin.segment = 'right_thigh';
model.muscle.right_middleVastusMedialis.element(1).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_middleVastusMedialis.element(1).insertion.segment = 'right_patella';

model.muscle.right_middleVastusMedialis.element(2).origin.position = [4.73 -24.71 1.26]' / 100;
model.muscle.right_middleVastusMedialis.element(2).origin.segment = 'right_thigh';
model.muscle.right_middleVastusMedialis.element(2).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_middleVastusMedialis.element(2).insertion.segment = 'right_patella';

%% superior vastus medialis

% morphology
model.muscle.right_superiorVastusMedialis.pcsa = 26.9 / 100 / 100;
model.muscle.right_superiorVastusMedialis.optimalFiberLength = 8.3 / 100;
model.muscle.right_superiorVastusMedialis.fiberLength = 6.8 / 100;
model.muscle.right_superiorVastusMedialis.tendonLength = 9.6 / 100;
model.muscle.right_superiorVastusMedialis.mass = 236 / 1000;
model.muscle.right_superiorVastusMedialis.pennation = 0;
model.muscle.right_superiorVastusMedialis.phi0 = 0;
model.muscle.right_superiorVastusMedialis.bodyContour = '';
model.muscle.right_superiorVastusMedialis.nViaPoints = 0;
model.muscle.right_superiorVastusMedialis.viaPoint = struct();
model.muscle.right_superiorVastusMedialis.nElements = 6;
model.muscle.right_superiorVastusMedialis.scaleSegment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.joints = {'right_knee'};

% attachment elements
model.muscle.right_superiorVastusMedialis.element(1).origin.position = [2.59 -19.76 1.76]' / 100;
model.muscle.right_superiorVastusMedialis.element(1).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(1).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(1).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusMedialis.element(2).origin.position = [3.55 -19.58 1.79]' / 100;
model.muscle.right_superiorVastusMedialis.element(2).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(2).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(2).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusMedialis.element(3).origin.position = [1.21 -14.60 2.29]' / 100;
model.muscle.right_superiorVastusMedialis.element(3).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(3).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(3).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusMedialis.element(4).origin.position = [2.17 -14.42 2.32]' / 100;
model.muscle.right_superiorVastusMedialis.element(4).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(4).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(4).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusMedialis.element(5).origin.position = [-0.08 -8.01 2.98]' / 100;
model.muscle.right_superiorVastusMedialis.element(5).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(5).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(5).insertion.segment = 'right_patella';

model.muscle.right_superiorVastusMedialis.element(6).origin.position = [0.42 -7.92 2.99]' / 100;
model.muscle.right_superiorVastusMedialis.element(6).origin.segment = 'right_thigh';
model.muscle.right_superiorVastusMedialis.element(6).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_superiorVastusMedialis.element(6).insertion.segment = 'right_patella';

%% vastus medialis

% if single VM then use superior VM geometry and combined mass and pcsa
if options.singleVM
    
    model.muscle.right_vastusMedialis = model.muscle.right_superiorVastusMedialis;

    % morphology
    model.muscle.right_vastusMedialis.pcsa = sum([model.muscle.right_superiorVastusMedialis.pcsa,model.muscle.right_middleVastusMedialis.pcsa,model.muscle.right_inferiorVastusMedialis.pcsa]);
    model.muscle.right_vastusMedialis.mass = sum([model.muscle.right_superiorVastusMedialis.mass,model.muscle.right_middleVastusMedialis.mass,model.muscle.right_inferiorVastusMedialis.mass]);
    model.muscle = rmfield(model.muscle,{'right_inferiorVastusMedialis','right_middleVastusMedialis','right_superiorVastusMedialis'});
    
end

%% vastus intermedius

% morphology
model.muscle.right_vastusIntermedius.pcsa = 38.1 / 100 / 100;
model.muscle.right_vastusIntermedius.optimalFiberLength = 7.7 / 100;
model.muscle.right_vastusIntermedius.fiberLength = 6.2 / 100;
model.muscle.right_vastusIntermedius.tendonLength = 12.6 / 100;
model.muscle.right_vastusIntermedius.mass = 309 / 1000;
model.muscle.right_vastusIntermedius.pennation = 12 * pi/180;
model.muscle.right_vastusIntermedius.phi0 = 9.637231 * pi/180;
model.muscle.right_vastusIntermedius.bodyContour = '';
model.muscle.right_vastusIntermedius.nViaPoints = 0;
model.muscle.right_vastusIntermedius.viaPoint = struct();
model.muscle.right_vastusIntermedius.nElements = 6;
model.muscle.right_vastusIntermedius.scaleSegment = 'right_thigh';
model.muscle.right_vastusIntermedius.joints = {'right_knee'};

% attachment elements
model.muscle.right_vastusIntermedius.element(1).origin.position = [5.41 -22.86 2.55]' / 100;
model.muscle.right_vastusIntermedius.element(1).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(1).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_vastusIntermedius.element(1).insertion.segment = 'right_patella';

model.muscle.right_vastusIntermedius.element(2).origin.position = [3.71 -17.44 2.95]' / 100;
model.muscle.right_vastusIntermedius.element(2).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(2).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_vastusIntermedius.element(2).insertion.segment = 'right_patella';

model.muscle.right_vastusIntermedius.element(3).origin.position = [1.62 -11.67 3.74]' / 100;
model.muscle.right_vastusIntermedius.element(3).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(3).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_vastusIntermedius.element(3).insertion.segment = 'right_patella';

model.muscle.right_vastusIntermedius.element(4).origin.position = [4.74 -23.17 3.53]' / 100;
model.muscle.right_vastusIntermedius.element(4).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(4).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_vastusIntermedius.element(4).insertion.segment = 'right_patella';

model.muscle.right_vastusIntermedius.element(5).origin.position = [2.92 -17.81 4.11]' / 100;
model.muscle.right_vastusIntermedius.element(5).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(5).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_vastusIntermedius.element(5).insertion.segment = 'right_patella';

model.muscle.right_vastusIntermedius.element(6).origin.position = [1.01 -11.97 4.64]' / 100;
model.muscle.right_vastusIntermedius.element(6).origin.segment = 'right_thigh';
model.muscle.right_vastusIntermedius.element(6).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_vastusIntermedius.element(6).insertion.segment = 'right_patella';

%% rectus femoris

% morphology
model.muscle.right_rectusFemoris.pcsa = 28.9 / 100 / 100;
model.muscle.right_rectusFemoris.optimalFiberLength = 7.8 / 100;
model.muscle.right_rectusFemoris.fiberLength = 6.7 / 100;
model.muscle.right_rectusFemoris.tendonLength = 9.6 / 100;
model.muscle.right_rectusFemoris.mass = 239 / 1000;
model.muscle.right_rectusFemoris.pennation = 22 * pi/180;
model.muscle.right_rectusFemoris.phi0 = 18.770452 * pi/180;
model.muscle.right_rectusFemoris.bodyContour = '';
model.muscle.right_rectusFemoris.nViaPoints = 0;
model.muscle.right_rectusFemoris.viaPoint = struct();
model.muscle.right_rectusFemoris.nElements = 2;
model.muscle.right_rectusFemoris.scaleSegment = 'right_thigh';
model.muscle.right_rectusFemoris.joints = {'right_hip','right_knee'};

% attachment elements
model.muscle.right_rectusFemoris.element(1).origin.position = [3.02 4.27 2.03]' / 100;
model.muscle.right_rectusFemoris.element(1).origin.segment = 'pelvis';
model.muscle.right_rectusFemoris.element(1).insertion.position = [9.46 -35.06 3.48]' / 100;
model.muscle.right_rectusFemoris.element(1).insertion.segment = 'right_patella';

model.muscle.right_rectusFemoris.element(2).origin.position = [3.02 4.27 2.03]' / 100;
model.muscle.right_rectusFemoris.element(2).origin.segment = 'pelvis';
model.muscle.right_rectusFemoris.element(2).insertion.position = [8.86 -35.03 4.48]' / 100;
model.muscle.right_rectusFemoris.element(2).insertion.segment = 'right_patella';

%% biceps femoris long head

% morphology
model.muscle.right_bicepsFemorisLong.pcsa = 27.2 / 100 / 100;
model.muscle.right_bicepsFemorisLong.optimalFiberLength = 8.5 / 100;
model.muscle.right_bicepsFemorisLong.fiberLength = 7.1 / 100;
model.muscle.right_bicepsFemorisLong.tendonLength = 13.0 / 100;
model.muscle.right_bicepsFemorisLong.mass = 245 / 1000;
model.muscle.right_bicepsFemorisLong.pennation = 30 * pi/180;
model.muscle.right_bicepsFemorisLong.phi0 = 24.686125 * pi/180;
model.muscle.right_bicepsFemorisLong.bodyContour = '';
model.muscle.right_bicepsFemorisLong.nViaPoints = 0;
model.muscle.right_bicepsFemorisLong.viaPoint = struct();
model.muscle.right_bicepsFemorisLong.nElements = 1;
model.muscle.right_bicepsFemorisLong.scaleSegment = 'right_thigh';
model.muscle.right_bicepsFemorisLong.joints = {'right_hip','right_knee'};

% attachment elements
model.muscle.right_bicepsFemorisLong.element(1).origin.position = [-3.78 -6.09 -1.71]' / 100;
model.muscle.right_bicepsFemorisLong.element(1).origin.segment = 'pelvis';
model.muscle.right_bicepsFemorisLong.element(1).insertion.position = [1.63 -45.15 4.62]' / 100;
model.muscle.right_bicepsFemorisLong.element(1).insertion.segment = 'right_shank';

%% biceps femoris short head

% morphology
model.muscle.right_bicepsFemorisShort.pcsa = 11.8 / 100 / 100;
model.muscle.right_bicepsFemorisShort.optimalFiberLength = 9.1 / 100;
model.muscle.right_bicepsFemorisShort.fiberLength = 11.2 / 100;
model.muscle.right_bicepsFemorisShort.tendonLength = 3.1 / 100;
model.muscle.right_bicepsFemorisShort.mass = 114 / 1000;
model.muscle.right_bicepsFemorisShort.pennation = 0;
model.muscle.right_bicepsFemorisShort.phi0 = 0;
model.muscle.right_bicepsFemorisShort.bodyContour = '';
model.muscle.right_bicepsFemorisShort.nViaPoints = 0;
model.muscle.right_bicepsFemorisShort.viaPoint = struct();
model.muscle.right_bicepsFemorisShort.nElements = 3;
model.muscle.right_bicepsFemorisShort.scaleSegment = 'right_thigh';
model.muscle.right_bicepsFemorisShort.joints = {'right_knee'};

% attachment elements
model.muscle.right_bicepsFemorisShort.element(1).origin.position = [0.58 -19.35 1.77]' / 100;
model.muscle.right_bicepsFemorisShort.element(1).origin.segment = 'right_thigh';
model.muscle.right_bicepsFemorisShort.element(1).insertion.position = [1.63 -45.15 4.62]' / 100;
model.muscle.right_bicepsFemorisShort.element(1).insertion.segment = 'right_shank';

model.muscle.right_bicepsFemorisShort.element(2).origin.position = [1.81 -23.83 1.34]' / 100;
model.muscle.right_bicepsFemorisShort.element(2).origin.segment = 'right_thigh';
model.muscle.right_bicepsFemorisShort.element(2).insertion.position = [1.63 -45.15 4.62]' / 100;
model.muscle.right_bicepsFemorisShort.element(2).insertion.segment = 'right_shank';

model.muscle.right_bicepsFemorisShort.element(3).origin.position = [2.68 -28.65 1.60]' / 100;
model.muscle.right_bicepsFemorisShort.element(3).origin.segment = 'right_thigh';
model.muscle.right_bicepsFemorisShort.element(3).insertion.position = [1.63 -45.15 4.62]' / 100;
model.muscle.right_bicepsFemorisShort.element(3).insertion.segment = 'right_shank';

%% semimembranosus

% morphology
model.muscle.right_semimembranosus.pcsa = 17.1 / 100 / 100;
model.muscle.right_semimembranosus.optimalFiberLength = 8.1 / 100;
model.muscle.right_semimembranosus.fiberLength = 7.1 / 100;
model.muscle.right_semimembranosus.tendonLength = 15.7 / 100;
model.muscle.right_semimembranosus.mass = 146 / 1000;
model.muscle.right_semimembranosus.pennation = 25 * pi/180;
model.muscle.right_semimembranosus.phi0 = 21.742951 * pi/180;
model.muscle.right_semimembranosus.bodyContour = '';
model.muscle.right_semimembranosus.nViaPoints = 0;
model.muscle.right_semimembranosus.viaPoint = struct();
model.muscle.right_semimembranosus.nElements = 1;
model.muscle.right_semimembranosus.scaleSegment = 'right_thigh';
model.muscle.right_semimembranosus.joints = {'right_hip','right_knee'};

% attachment elements
model.muscle.right_semimembranosus.element(1).origin.position = [-2.80 -6.61 -2.03]' / 100;
model.muscle.right_semimembranosus.element(1).origin.segment = 'pelvis';
model.muscle.right_semimembranosus.element(1).insertion.position = [4.12 -43.84 -2.97]' / 100;
model.muscle.right_semimembranosus.element(1).insertion.segment = 'right_shank';

%% semitendinosus

% morphology
model.muscle.right_semitendinosus.pcsa = 14.7 / 100 / 100;
model.muscle.right_semitendinosus.optimalFiberLength = 14.2 / 100;
model.muscle.right_semitendinosus.fiberLength = 15.7 / 100;
model.muscle.right_semitendinosus.tendonLength = 23.7 / 100;
model.muscle.right_semitendinosus.mass = 220 / 1000;
model.muscle.right_semitendinosus.pennation = 0;
model.muscle.right_semitendinosus.phi0 = 0;
model.muscle.right_semitendinosus.bodyContour = '';
model.muscle.right_semitendinosus.nViaPoints = 7;
model.muscle.right_semitendinosus.nElements = 1;
model.muscle.right_semitendinosus.scaleSegment = 'right_thigh';
model.muscle.right_semitendinosus.joints = {'right_hip','right_knee'};

% attachment elements
model.muscle.right_semitendinosus.element(1).origin.position = [-4.03 -6.07 -2.78]' / 100;
model.muscle.right_semitendinosus.element(1).origin.segment = 'pelvis';
model.muscle.right_semitendinosus.element(1).insertion.position = [7.22 -49.29 -0.24]' / 100;
model.muscle.right_semitendinosus.element(1).insertion.segment = 'right_shank';

% via points
model.muscle.right_semitendinosus.viaPoint(1).position = [2.9 -43.5 -2.9]' / 100;
model.muscle.right_semitendinosus.viaPoint(1).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(2).position = [3.1 -44.2 -2.9]' / 100;
model.muscle.right_semitendinosus.viaPoint(2).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(3).position = [3.7 -44.9 -2.6]' / 100;
model.muscle.right_semitendinosus.viaPoint(3).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(4).position = [4.4 -45.7 -2.2]' / 100;
model.muscle.right_semitendinosus.viaPoint(4).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(5).position = [5.0 -46.2 -1.9]' / 100;
model.muscle.right_semitendinosus.viaPoint(5).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(6).position = [5.4 -46.6 -1.7]' / 100;
model.muscle.right_semitendinosus.viaPoint(6).segment = 'right_shank';

model.muscle.right_semitendinosus.viaPoint(7).position = [5.6 -47.2 -1.4]' / 100;
model.muscle.right_semitendinosus.viaPoint(7).segment = 'right_shank';

%% medial gastrocnemius

% morphology
model.muscle.right_medialGastrocnemius.pcsa = 43.8 / 100 / 100;
model.muscle.right_medialGastrocnemius.optimalFiberLength = 6.0 / 100;
model.muscle.right_medialGastrocnemius.fiberLength = 5.7 / 100;
model.muscle.right_medialGastrocnemius.tendonLength = 21.2 / 100;
model.muscle.right_medialGastrocnemius.mass = 278 / 1000;
model.muscle.right_medialGastrocnemius.pennation = 11 * pi/180;
model.muscle.right_medialGastrocnemius.phi0 = 10.443658 * pi/180;
model.muscle.right_medialGastrocnemius.bodyContour = 'right_femoralCondyle';
model.muscle.right_medialGastrocnemius.nViaPoints = 0;
model.muscle.right_medialGastrocnemius.viaPoint = struct();
model.muscle.right_medialGastrocnemius.nElements = 1;
model.muscle.right_medialGastrocnemius.scaleSegment = 'right_shank';
model.muscle.right_medialGastrocnemius.joints = {'right_knee','right_ankle'};

% attachment elements
model.muscle.right_medialGastrocnemius.element(1).origin.position = [5.04 -36.71 -1.48]' / 100;
model.muscle.right_medialGastrocnemius.element(1).origin.segment = 'right_thigh';
model.muscle.right_medialGastrocnemius.element(1).insertion.position = [3.01 -82.21 -2.74]' / 100;
model.muscle.right_medialGastrocnemius.element(1).insertion.segment = 'right_foot';

%% lateral gastrocnemius

% morphology
model.muscle.right_lateralGastrocnemius.pcsa = 24.0 / 100 / 100;
model.muscle.right_lateralGastrocnemius.optimalFiberLength = 5.7 / 100;
model.muscle.right_lateralGastrocnemius.fiberLength = 4.8 / 100;
model.muscle.right_lateralGastrocnemius.tendonLength = 23.4 / 100;
model.muscle.right_lateralGastrocnemius.mass = 144 / 1000;
model.muscle.right_lateralGastrocnemius.pennation = 25 * pi/180;
model.muscle.right_lateralGastrocnemius.phi0 = 20.847943 * pi/180;
model.muscle.right_lateralGastrocnemius.bodyContour = 'right_femoralCondyle';
model.muscle.right_lateralGastrocnemius.nViaPoints = 0;
model.muscle.right_lateralGastrocnemius.viaPoint = struct();
model.muscle.right_lateralGastrocnemius.nElements = 1;
model.muscle.right_lateralGastrocnemius.scaleSegment = 'right_shank';
model.muscle.right_lateralGastrocnemius.joints = {'right_knee','right_ankle'};

% attachment elements
model.muscle.right_lateralGastrocnemius.element(1).origin.position = [3.43 -37.75 2.21]' / 100;
model.muscle.right_lateralGastrocnemius.element(1).origin.segment = 'right_thigh';
model.muscle.right_lateralGastrocnemius.element(1).insertion.position = [2.90 -81.98 -1.89]' / 100;
model.muscle.right_lateralGastrocnemius.element(1).insertion.segment = 'right_foot';

%% medial soleus

% morphology
model.muscle.right_medialSoleus.pcsa = 94.3 / 100 / 100;
model.muscle.right_medialSoleus.optimalFiberLength = 2.4 / 100;
model.muscle.right_medialSoleus.fiberLength = 1.8 / 100;
model.muscle.right_medialSoleus.tendonLength = 8.5 / 100;
model.muscle.right_medialSoleus.mass = 238.5 / 1000;
model.muscle.right_medialSoleus.pennation = 64 * pi/180;
model.muscle.right_medialSoleus.phi0 = 42.383953 * pi/180;
model.muscle.right_medialSoleus.bodyContour = '';
model.muscle.right_medialSoleus.nViaPoints = 0;
model.muscle.right_medialSoleus.viaPoint = struct();
model.muscle.right_medialSoleus.nElements = 3;
model.muscle.right_medialSoleus.scaleSegment = 'right_shank';
model.muscle.right_medialSoleus.joints = {'right_ankle'};

% attachment elements
model.muscle.right_medialSoleus.element(1).origin.position = [7.63 -58.10 0.81]' / 100;
model.muscle.right_medialSoleus.element(1).origin.segment = 'right_shank';
model.muscle.right_medialSoleus.element(1).insertion.position = [4.18 -81.71 -2.71]' / 100;
model.muscle.right_medialSoleus.element(1).insertion.segment = 'right_foot';

model.muscle.right_medialSoleus.element(2).origin.position = [7.21 -54.96 0.57]' / 100;
model.muscle.right_medialSoleus.element(2).origin.segment = 'right_shank';
model.muscle.right_medialSoleus.element(2).insertion.position = [4.18 -81.71 -2.71]' / 100;
model.muscle.right_medialSoleus.element(2).insertion.segment = 'right_foot';

model.muscle.right_medialSoleus.element(3).origin.position = [6.50 -52.52 0.27]' / 100;
model.muscle.right_medialSoleus.element(3).origin.segment = 'right_shank';
model.muscle.right_medialSoleus.element(3).insertion.position = [4.18 -81.71 -2.71]' / 100;
model.muscle.right_medialSoleus.element(3).insertion.segment = 'right_foot';

%% lateral soleus

% morphology
model.muscle.right_lateralSoleus.pcsa = 85.9 / 100 / 100;
model.muscle.right_lateralSoleus.optimalFiberLength = 2.6 / 100;
model.muscle.right_lateralSoleus.fiberLength = 1.9 / 100;
model.muscle.right_lateralSoleus.tendonLength = 8.5 / 100;
model.muscle.right_lateralSoleus.mass = 238.5 / 1000;
model.muscle.right_lateralSoleus.pennation = 59 * pi/180;
model.muscle.right_lateralSoleus.phi0 = 38.784392 * pi/180;
model.muscle.right_lateralSoleus.bodyContour = '';
model.muscle.right_lateralSoleus.nViaPoints = 0;
model.muscle.right_lateralSoleus.viaPoint = struct();
model.muscle.right_lateralSoleus.nElements = 3;
model.muscle.right_lateralSoleus.scaleSegment = 'right_shank';
model.muscle.right_lateralSoleus.joints = {'right_ankle'};

% attachment elements
model.muscle.right_lateralSoleus.element(1).origin.position = [1.85 -54.40 2.79]' / 100;
model.muscle.right_lateralSoleus.element(1).origin.segment = 'right_shank';
model.muscle.right_lateralSoleus.element(1).insertion.position = [2.90 -81.98 -1.89]' / 100;
model.muscle.right_lateralSoleus.element(1).insertion.segment = 'right_foot';

model.muscle.right_lateralSoleus.element(2).origin.position = [1.57 -51.72 2.92]' / 100;
model.muscle.right_lateralSoleus.element(2).origin.segment = 'right_shank';
model.muscle.right_lateralSoleus.element(2).insertion.position = [2.90 -81.98 -1.89]' / 100;
model.muscle.right_lateralSoleus.element(2).insertion.segment = 'right_foot';

model.muscle.right_lateralSoleus.element(3).origin.position = [0.97 -47.81 3.08]' / 100;
model.muscle.right_lateralSoleus.element(3).origin.segment = 'right_shank';
model.muscle.right_lateralSoleus.element(3).insertion.position = [2.90 -81.98 -1.89]' / 100;
model.muscle.right_lateralSoleus.element(3).insertion.segment = 'right_foot';

%% soleus

% if single SOL then combine, remove lateral + medial
if options.singleSOL
    
    % morphology
    model.muscle.right_soleus.pcsa = sum([model.muscle.right_lateralSoleus.pcsa,model.muscle.right_medialSoleus.pcsa]);
    model.muscle.right_soleus.optimalFiberLength = mean([model.muscle.right_lateralSoleus.optimalFiberLength,model.muscle.right_medialSoleus.optimalFiberLength]);
    model.muscle.right_soleus.fiberLength = mean([model.muscle.right_lateralSoleus.fiberLength,model.muscle.right_medialSoleus.fiberLength]);
    model.muscle.right_soleus.tendonLength = mean([model.muscle.right_lateralSoleus.tendonLength,model.muscle.right_medialSoleus.tendonLength]);
    model.muscle.right_soleus.mass = mean([model.muscle.right_lateralSoleus.mass,model.muscle.right_medialSoleus.mass]);
    model.muscle.right_soleus.pennation = mean([model.muscle.right_lateralSoleus.pennation,model.muscle.right_medialSoleus.pennation]);
    model.muscle.right_soleus.phi0 = asin(model.muscle.right_soleus.fiberLength / model.muscle.right_soleus.optimalFiberLength * sin(model.muscle.right_soleus.pennation));
    model.muscle.right_soleus.bodyContour = '';
    model.muscle.right_soleus.nViaPoints = 0;
    model.muscle.right_soleus.viaPoint = struct();
    model.muscle.right_soleus.nElements = 3;
    model.muscle.right_soleus.scaleSegment = 'right_shank';
    model.muscle.right_soleus.joints = {'right_ankle'};

    % attachment elements
    model.muscle.right_soleus.element(1).origin.position = mean([model.muscle.right_lateralSoleus.element(1).origin.position,model.muscle.right_medialSoleus.element(1).origin.position],2);
    model.muscle.right_soleus.element(1).origin.segment = 'right_shank';
    model.muscle.right_soleus.element(1).insertion.position = mean([model.muscle.right_lateralSoleus.element(1).insertion.position,model.muscle.right_medialSoleus.element(1).insertion.position],2);
    model.muscle.right_soleus.element(1).insertion.segment = 'right_foot';

    model.muscle.right_soleus.element(2).origin.position = mean([model.muscle.right_lateralSoleus.element(2).origin.position,model.muscle.right_medialSoleus.element(2).origin.position],2);
    model.muscle.right_soleus.element(2).origin.segment = 'right_shank';
    model.muscle.right_soleus.element(2).insertion.position = mean([model.muscle.right_lateralSoleus.element(2).insertion.position,model.muscle.right_medialSoleus.element(2).insertion.position],2);
    model.muscle.right_soleus.element(2).insertion.segment = 'right_foot';

    model.muscle.right_soleus.element(3).origin.position = mean([model.muscle.right_lateralSoleus.element(3).origin.position,model.muscle.right_medialSoleus.element(3).origin.position],2);
    model.muscle.right_soleus.element(3).origin.segment = 'right_shank';
    model.muscle.right_soleus.element(3).insertion.position = mean([model.muscle.right_lateralSoleus.element(3).insertion.position,model.muscle.right_medialSoleus.element(3).insertion.position],2);
    model.muscle.right_soleus.element(3).insertion.segment = 'right_foot';
    
    % remove medial + lateral soleus
    model.muscle = rmfield(model.muscle,{'right_lateralSoleus','right_medialSoleus'});

end

%% peroneus longus

% morphology
model.muscle.right_peroneusLongus.pcsa = 23.9 / 100 / 100;
model.muscle.right_peroneusLongus.optimalFiberLength = 3.4 / 100;
model.muscle.right_peroneusLongus.fiberLength = 3.6 / 100;
model.muscle.right_peroneusLongus.tendonLength = 15.9 / 100;
model.muscle.right_peroneusLongus.mass = 86 / 1000;
model.muscle.right_peroneusLongus.pennation = 16 * pi/180;
model.muscle.right_peroneusLongus.phi0 = 16.968824 * pi/180;
model.muscle.right_peroneusLongus.bodyContour = '';
model.muscle.right_peroneusLongus.nViaPoints = 4;
model.muscle.right_peroneusLongus.nElements = 3;
model.muscle.right_peroneusLongus.scaleSegment = 'right_shank';
model.muscle.right_peroneusLongus.joints = {'right_ankle'};

% attachment elements
model.muscle.right_peroneusLongus.element(1).origin.position = [1.67 -48.99 4.08]' / 100;
model.muscle.right_peroneusLongus.element(1).origin.segment = 'right_shank';
model.muscle.right_peroneusLongus.element(1).insertion.position = [7.18 -87.15 3.54]' / 100;
model.muscle.right_peroneusLongus.element(1).insertion.segment = 'right_foot';

model.muscle.right_peroneusLongus.element(2).origin.position = [1.90 -52.73 3.73]' / 100;
model.muscle.right_peroneusLongus.element(2).origin.segment = 'right_shank';
model.muscle.right_peroneusLongus.element(2).insertion.position = [7.18 -87.15 3.54]' / 100;
model.muscle.right_peroneusLongus.element(2).insertion.segment = 'right_foot';

model.muscle.right_peroneusLongus.element(3).origin.position = [2.16 -56.43 3.40]' / 100;
model.muscle.right_peroneusLongus.element(3).origin.segment = 'right_shank';
model.muscle.right_peroneusLongus.element(3).insertion.position = [7.18 -87.15 3.54]' / 100;
model.muscle.right_peroneusLongus.element(3).insertion.segment = 'right_foot';

% via points
model.muscle.right_peroneusLongus.viaPoint(1).position = [4.7 -76.8 2.7]' / 100;
model.muscle.right_peroneusLongus.viaPoint(1).segment = 'right_shank';

model.muscle.right_peroneusLongus.viaPoint(2).position = [4.8 -78.3 2.8]' / 100;
model.muscle.right_peroneusLongus.viaPoint(2).segment = 'right_shank';

model.muscle.right_peroneusLongus.viaPoint(3).position = [5.1 -80.3 2.9]' / 100;
model.muscle.right_peroneusLongus.viaPoint(3).segment = 'right_shank';

model.muscle.right_peroneusLongus.viaPoint(4).position = [5.5 -81.4 3.1]' / 100;
model.muscle.right_peroneusLongus.viaPoint(4).segment = 'right_shank';

%% tibialis anterior

% morphology
model.muscle.right_tibialisAnterior.pcsa = 26.6 / 100 / 100;
model.muscle.right_tibialisAnterior.optimalFiberLength = 4.6 / 100;
model.muscle.right_tibialisAnterior.fiberLength = 5.7 / 100;
model.muscle.right_tibialisAnterior.tendonLength = 23.5 / 100;
model.muscle.right_tibialisAnterior.mass = 129 / 1000;
model.muscle.right_tibialisAnterior.pennation = 10 * pi/180;
model.muscle.right_tibialisAnterior.phi0 = 12.425662 * pi/180;
model.muscle.right_tibialisAnterior.bodyContour = '';
model.muscle.right_tibialisAnterior.nViaPoints = 2;
model.muscle.right_tibialisAnterior.nElements = 3;
model.muscle.right_tibialisAnterior.scaleSegment = 'right_shank';
model.muscle.right_tibialisAnterior.joints = {'right_ankle'};

% attachment elements
model.muscle.right_tibialisAnterior.element(1).origin.position = [5.78 -46.65 4.26]' / 100;
model.muscle.right_tibialisAnterior.element(1).origin.segment = 'right_shank';
model.muscle.right_tibialisAnterior.element(1).insertion.position = [14.55 -87.06 1.79]' / 100;
model.muscle.right_tibialisAnterior.element(1).insertion.segment = 'right_foot';

model.muscle.right_tibialisAnterior.element(2).origin.position = [6.36 -49.36 3.89]' / 100;
model.muscle.right_tibialisAnterior.element(2).origin.segment = 'right_shank';
model.muscle.right_tibialisAnterior.element(2).insertion.position = [14.55 -87.06 1.79]' / 100;
model.muscle.right_tibialisAnterior.element(2).insertion.segment = 'right_foot';

model.muscle.right_tibialisAnterior.element(3).origin.position = [6.38 -54.64 2.94]' / 100;
model.muscle.right_tibialisAnterior.element(3).origin.segment = 'right_shank';
model.muscle.right_tibialisAnterior.element(3).insertion.position = [14.55 -87.06 1.79]' / 100;
model.muscle.right_tibialisAnterior.element(3).insertion.segment = 'right_foot';

% via points
model.muscle.right_tibialisAnterior.viaPoint(1).position = [12.0 -78.0 2.8]' / 100;
model.muscle.right_tibialisAnterior.viaPoint(1).segment = 'right_shank';

model.muscle.right_tibialisAnterior.viaPoint(2).position = [13.8 -85.2 2.6]' / 100;
model.muscle.right_tibialisAnterior.viaPoint(2).segment = 'right_foot';

%% anatomical coordinate system

model = anatomicalCoordinateSystem(model,struct('side','right'));

% create patella segment (requires knee flexion angle)
model.joint.right_knee.flexion.angle = acosd(dot(model.segment.right_thigh.anatomical.basis(2).vector,model.segment.right_shank.anatomical.basis(2).vector));
model = patellaModel(model,model,'right');

% anthropometry
model.rightLegLength = vecnorm(model.marker.right_asis.position - model.marker.right_medial_malleolus.position);
model.segment.pelvis.width = vecnorm(model.marker.right_asis.position - model.marker.left_asis.position);
model.segment.pelvis.depth = vecnorm(mean([model.marker.right_asis.position, model.marker.left_asis.position],2) - mean([model.marker.right_psis.position, model.marker.left_psis.position],2));
model.segment.right_thigh.length = model.segment.right_thigh.anatomical.basis(2).vector' * (model.joint.right_hip.position - model.segment.right_thigh.anatomical.position); % project mid epicondyle to hip jc onto thigh long axis
model.segment.right_shank.length = vecnorm(mean([model.marker.right_medial_tibial_condyle.position,model.marker.right_lateral_tibial_condyle.position],2) - model.segment.right_shank.anatomical.position); % tibiale to mid mal as in de leva 96
model.segment.right_foot.width = vecnorm(model.marker.right_metatarsal1.position - model.marker.right_metatarsal5.position);
model.joint.right_knee.width = vecnorm(model.marker.right_lat_femoral_epicondyle.position - model.marker.right_med_femoral_epicondyle.position);
model.joint.right_ankle.width = vecnorm(model.marker.right_lateral_malleolus.position - model.marker.right_medial_malleolus.position);

%% transform global muscle geometry to local

model = getLocalMuscleGeometry(model,'anatomical');

% this would decrease moment arm and decrease range of MTU length
% model.muscle.right_medialGastrocnemius.local.anatomical.insertion.position(1) = model.muscle.right_medialGastrocnemius.local.anatomical.insertion.position(1) + 0.01;

%% mtu length

msc = fieldnames(model.muscle);
for m = 1:length(msc)
    model = getLengthMTU(model,msc{m},model);
end

%% packup

model.muscleNames = fieldnames(model.muscle);
model.nMuscles = length(model.muscleNames);
model.segmentNames = fieldnames(model.segment);
model.nSegments = length(model.segmentNames);

end
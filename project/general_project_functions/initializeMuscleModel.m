function model = initializeMuscleModel(model)

% use single VM, single VL, and single SOL
options.singleVM = true;
options.singleVL = true;
options.singleSOL = true;

% initialize with horsman 07 muscle model
% scale model here with adjustments to knee extensor insertions so moment arm data better align with literature
model = scaleTwenteMuscleGeometry2(model,options); 

% this project is for muscles crossing knee joint only, remove uniarticular
% ankle joint muscles
model.muscle = rmfield(model.muscle,{'right_soleus','right_tibialisAnterior','right_peroneusLongus'});

% scale optimal fiber length/tendon slack length
fiberRange = 'refMuscleFiberLengthRangeArnold11.mat'; % see also 'refMuscleFiberLengthRangeArnold13.mat'
mtuRange = 'refMTULengthRangeS0040.mat';
model = getMuscleTendonMorphology(model,fiberRange,mtuRange);

% associate emg sensor location name
model.muscle.right_bicepsFemorisLong.emg.names = {'biceps_femoris_right'};
model.muscle.right_bicepsFemorisShort.emg.names = {'biceps_femoris_right'};
model.muscle.right_vastusLateralis.emg.names = {'vastus_lateralis_right'};
model.muscle.right_lateralGastrocnemius.emg.names = {'lateral_gastrocnemius_right'};
model.muscle.right_medialGastrocnemius.emg.names = {'medial_gastrocnemius_right'};
model.muscle.right_vastusMedialis.emg.names = {'vastus_medialis_right'};
model.muscle.right_rectusFemoris.emg.names = {'rectus_femoris_right'};
model.muscle.right_semimembranosus.emg.names = {'semitendinosus_right'};
model.muscle.right_semitendinosus.emg.names = {'semitendinosus_right'};
model.muscle.right_vastusIntermedius.emg.names = {'vastus_medialis_right','vastus_lateralis_right'};

% load default muscle properties
genmsc = defaultMuscleModel;

% combine default msc params with horsman data
msc = fieldnames(model.muscle);
for k = 1:length(msc)
    
    % everything specified in model.muscle is given to default muscle
    model.muscle.(msc{k}) = inherit(model.muscle.(msc{k}),genmsc);
    
    % pcsa was manipulated but may not agree with force = pcsa * stress,
    % update here
    model.muscle.(msc{k}).maxForce = model.muscle.(msc{k}).pcsa * model.muscle.(msc{k}).maxStress;

end

% set coef damping to 0.01 (Krause, Millard 13) and v0 to 15 (Arnold 13)
model.muscle = updateStaticMuscleProperties(model.muscle,struct('coefDamping',0.01,'normalizedMaxVelocity',15));

% slightly different than dissertation: strength groups and activation
% groups both the same, splitting hamstrings into lateral and medial
% groups, this justified for activation properties due to % slow oxidative
% (see dissertation), thus also splitting based on strength as well

% strength group
% maxForce scales together
model.muscleGroup.strengthGroup.gastrocnemii = {'right_medialGastrocnemius','right_lateralGastrocnemius'};
model.muscleGroup.strengthGroup.lateralKneeFlexors = {'right_bicepsFemorisLong','right_bicepsFemorisShort'};
model.muscleGroup.strengthGroup.medialKneeFlexors = {'right_semimembranosus','right_semitendinosus'};
model.muscleGroup.strengthGroup.kneeExtensors = {'right_rectusFemoris','right_vastusMedialis','right_vastusIntermedius','right_vastusLateralis'};

% activation group (same as strength)
% same activation dynamics settings
model.muscleGroup.activationGroup.gastrocnemii = {'right_medialGastrocnemius','right_lateralGastrocnemius'};
model.muscleGroup.activationGroup.lateralKneeFlexors = {'right_bicepsFemorisLong','right_bicepsFemorisShort'};
model.muscleGroup.activationGroup.medialKneeFlexors = {'right_semimembranosus','right_semitendinosus'};
model.muscleGroup.activationGroup.kneeExtensors = {'right_rectusFemoris','right_vastusMedialis','right_vastusIntermedius','right_vastusLateralis'};

% structural group
% optimal fiber length and tendon slack length scale together
% this not used in this project, fiber length/tendon slack length
% estimation is muscle specific and is determined using
% getMuscleTendonMorphology (see above)
model.muscleGroup.structuralGroup.gastrocnemii = {'right_medialGastrocnemius','right_lateralGastrocnemius'};
model.muscleGroup.structuralGroup.bicepsFemorisLong = {'right_bicepsFemorisLong'};
model.muscleGroup.structuralGroup.bicepsFemorisShort = {'right_bicepsFemorisShort'};
model.muscleGroup.structuralGroup.medialKneeFlexors = {'right_semimembranosus','right_semitendinosus'};
model.muscleGroup.structuralGroup.vasti = {'right_vastusMedialis','right_vastusIntermedius','right_vastusLateralis'};
model.muscleGroup.structuralGroup.rectusFemoris = {'right_rectusFemoris'};

% now that the high level muscle groups have been specified, update groupings for each muscle
model = updateMuscleGroupings(model);

% update tendon percentage of ankle muscles for display purposes
properties.proximalMTUTendonPercentage = 0.2;
model.muscle = updateStaticMuscleProperties(model.muscle,properties,{'right_medialGastrocnemius','right_lateralGastrocnemius'});

% save muscle names and num
model.muscleNames = fieldnames(model.muscle);
model.nMuscles = length(model.muscleNames);

end
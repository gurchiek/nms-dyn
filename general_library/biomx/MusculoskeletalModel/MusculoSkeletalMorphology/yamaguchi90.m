function model = yamaguchi90(model)

%% vastus lateralis

model.muscle.vastusLateralis.percentSO = [0.45 0.48 0.378  0.469];

%% vastus medialis

model.muscle.vastusMedialis.percentSO = [0.5 0.47 0.437 0.615];

%% vastus intermedius

model.muscle.vastusIntermedius.percentSO = 0.5;

%% rectus femoris

model.muscle.rectusFemoris.percentSO = [0.45 0.381 0.295 0.42 0.428];

%% biceps femoris long head

model.muscle.bicepsFemorisLong.percentSO = [0.65 0.669 0.669];

%% biceps femoris short head

model.muscle.bicepsFemorisShort.percentSO = [0.65 0.669];

%% semitendinosus

model.muscle.semitendinosus.percentSO = 0.5;

%% semimembranosus

model.muscle.semimembranosus.percentSO = 0.5;

%% medial gastrocnemius

model.muscle.medialGastrocnemius.percentSO = [0.55 0.482 0.508];

%% lateral gastrocnemius

model.muscle.lateralGastrocnemius.percentSO = [0.55 0.482 0.435 0.503];

%% soleus

model.muscle.soleus.percentSO = [0.75 0.75 0.864 0.89];

%% peroneus longus

model.muscle.peroneusLongus.percentSO = [0.6 0.625];

%% tibialis anterior

model.muscle.tibialisAnterior.percentSO = [0.7 0.73 0.734 0.727];

end
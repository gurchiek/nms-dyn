function model = delp90(model)

%% vastus lateralis

model.muscle.vastusLateralis.maxForce = 1871.0;
model.muscle.vastusLateralis.optimalFiberLength = 8.4 / 100;
model.muscle.vastusLateralis.tendonSlackLength = 15.70 / 100;
model.muscle.vastusLateralis.phi0 = 5.0 * pi/180;

%% vastus medialis

model.muscle.vastusMedialis.maxForce = 1294.0;
model.muscle.vastusMedialis.optimalFiberLength = 8.9 / 100;
model.muscle.vastusMedialis.tendonSlackLength = 12.6 / 100;
model.muscle.vastusMedialis.phi0 = 5.0 * pi/180;

%% vastus intermedius

model.muscle.vastusIntermedius.maxForce = 1365.0;
model.muscle.vastusIntermedius.optimalFiberLength = 8.7 / 100;
model.muscle.vastusIntermedius.tendonSlackLength = 13.6 / 100;
model.muscle.vastusIntermedius.phi0 = 3.0 * pi/180;

%% rectus femoris

model.muscle.rectusFemoris.maxForce = 779.0;
model.muscle.rectusFemoris.optimalFiberLength = 8.4 / 100;
model.muscle.rectusFemoris.tendonSlackLength = 34.6 / 100;
model.muscle.rectusFemoris.phi0 = 5.0 * pi/180;

%% biceps femoris long head

model.muscle.bicepsFemorisLong.maxForce = 717.0;
model.muscle.bicepsFemorisLong.optimalFiberLength = 10.9 / 100;
model.muscle.bicepsFemorisLong.tendonSlackLength = 34.10 / 100;
model.muscle.bicepsFemorisLong.phi0 = 0;

%% biceps femoris short head

model.muscle.bicepsFemorisShort.maxForce = 402.0;
model.muscle.bicepsFemorisShort.optimalFiberLength = 17.3 / 100;
model.muscle.bicepsFemorisShort.tendonSlackLength = 10.0 / 100;
model.muscle.bicepsFemorisShort.phi0 = 23.0 * pi/180;

%% semimembranosus

model.muscle.semimembranosus.maxForce = 1030.0;
model.muscle.semimembranosus.optimalFiberLength = 8.0 / 100;
model.muscle.semimembranosus.tendonSlackLength = 35.9 / 100;
model.muscle.semimembranosus.phi0 = 15 * pi/180;

%% semitendinosus

model.muscle.semitendinosus.maxForce = 328.0;
model.muscle.semitendinosus.optimalFiberLength = 20.1 / 100;
model.muscle.semitendinosus.tendonSlackLength = 26.2 / 100;
model.muscle.semitendinosus.phi0 = 5.0 * pi/180;

%% medial gastrocnemius

model.muscle.medialGastrocnemius.maxForce = 1113.0;
model.muscle.medialGastrocnemius.optimalFiberLength = 4.5 / 100;
model.muscle.medialGastrocnemius.tendonSlackLength = 40.8 / 100;
model.muscle.medialGastrocnemius.phi0 = 17.0 * pi/180;

%% lateral gastrocnemius

model.muscle.lateralGastrocnemius.maxForce = 488.0;
model.muscle.lateralGastrocnemius.optimalFiberLength = 6.4 / 100;
model.muscle.lateralGastrocnemius.tendonSlackLength = 38.5 / 100;
model.muscle.lateralGastrocnemius.phi0 = 8.0 * pi/180;

%% soleus

model.muscle.soleus.maxForce = 2839.0;
model.muscle.soleus.optimalFiberLength = 3.0 / 100;
model.muscle.soleus.tendonSlackLength = 26.8 / 100;
model.muscle.soleus.phi0 = 25.0 * pi/180;

%% peroneus longus

model.muscle.peroneusLongus.maxForce = 754.0;
model.muscle.peroneusLongus.optimalFiberLength = 4.9 / 100;
model.muscle.peroneusLongus.tendonSlackLength = 34.5 / 100;
model.muscle.peroneusLongus.phi0 = 10.0 * pi/180;

%% tibialis anterior

model.muscle.tibialisAnterior.maxForce = 603.0;
model.muscle.tibialisAnterior.optimalFiberLength = 9.8 / 100;
model.muscle.tibialisAnterior.tendonSlackLength = 22.3 / 100;
model.muscle.tibialisAnterior.phi0 = 5.0 * pi/180;

%% optimal fiber length to tendon slack length ratio

msc = fieldnames(model.muscle);
for m = 1:length(msc)
    model.muscle.(msc{m}).optimalFiberLengthTendonSlackLengthRatio = model.muscle.(msc{m}).optimalFiberLength / model.muscle.(msc{m}).tendonSlackLength;
end

end
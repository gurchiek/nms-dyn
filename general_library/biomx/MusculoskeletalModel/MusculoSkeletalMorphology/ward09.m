function model = ward09(model)

%% vastus lateralis

model.muscle.vastusLateralis.pcsa = 35.1 / 100 / 100;
model.muscle.vastusLateralis.mass = 375.9 / 1000;
model.muscle.vastusLateralis.fiberLength = 9.94 / 100;
model.muscle.vastusLateralis.sarcomereLength = 2.14e-6;
model.muscle.vastusLateralis.pennation = 18.4 * pi/180;

%% vastus medialis

model.muscle.vastusMedialis.pcsa = 20.6 / 100 / 100;
model.muscle.vastusMedialis.mass = 239.4 / 1000;
model.muscle.vastusMedialis.fiberLength = 9.68 / 100;
model.muscle.vastusMedialis.sarcomereLength = 2.24e-6;
model.muscle.vastusMedialis.pennation = 29.6 * pi/180;

%% vastus intermedius

model.muscle.vastusIntermedius.pcsa = 16.7 / 100 / 100;
model.muscle.vastusIntermedius.mass = 171.9 / 1000;
model.muscle.vastusIntermedius.fiberLength = 9.93 / 100;
model.muscle.vastusIntermedius.sarcomereLength = 2.17e-6;
model.muscle.vastusIntermedius.pennation = 4.5 * pi/180;

%% rectus femoris

model.muscle.rectusFemoris.pcsa = 13.5 / 100 / 100;
model.muscle.rectusFemoris.mass = 110.6 / 1000;
model.muscle.rectusFemoris.fiberLength = 7.59 / 100;
model.muscle.rectusFemoris.sarcomereLength = 2.42e-6;
model.muscle.rectusFemoris.pennation = 13.9 * pi/180;

%% biceps femoris long head

model.muscle.bicepsFemorisLong.pcsa = 11.3 / 100 / 100;
model.muscle.bicepsFemorisLong.mass = 113.4 / 1000;
model.muscle.bicepsFemorisLong.fiberLength = 9.76 / 100;
model.muscle.bicepsFemorisLong.sarcomereLength = 2.35e-6;
model.muscle.bicepsFemorisLong.pennation = 11.6 * pi/180;

%% biceps femoris short head

model.muscle.bicepsFemorisShort.pcsa = 5.1 / 100 / 100;
model.muscle.bicepsFemorisShort.mass = 59.8 / 1000;
model.muscle.bicepsFemorisShort.fiberLength = 11.03 / 100;
model.muscle.bicepsFemorisShort.sarcomereLength = 3.31e-6;
model.muscle.bicepsFemorisShort.pennation = 12.3 * pi/180;

%% semimembranosus

model.muscle.semimembranosus.pcsa = 18.4 / 100 / 100;
model.muscle.semimembranosus.mass = 134.3 / 1000;
model.muscle.semimembranosus.fiberLength = 6.90 / 100;
model.muscle.semimembranosus.sarcomereLength = 2.61e-6;
model.muscle.semimembranosus.pennation = 15.1 * pi/180;

%% semitendinosus

model.muscle.semitendinosus.pcsa = 4.8 / 100 / 100;
model.muscle.semitendinosus.mass = 99.7 / 1000;
model.muscle.semitendinosus.fiberLength = 19.30 / 100;
model.muscle.semitendinosus.sarcomereLength = 2.89e-6;
model.muscle.semitendinosus.pennation = 12.9 * pi/180;

%% medial gastrocnemius

model.muscle.medialGastrocnemius.pcsa = 21.1 / 100 / 100;
model.muscle.medialGastrocnemius.mass = 113.5 / 1000;
model.muscle.medialGastrocnemius.fiberLength = 5.10 / 100;
model.muscle.medialGastrocnemius.sarcomereLength = 2.59e-6;
model.muscle.medialGastrocnemius.pennation = 9.9 * pi/180;

%% lateral gastrocnemius

model.muscle.lateralGastrocnemius.pcsa = 9.7 / 100 / 100;
model.muscle.lateralGastrocnemius.mass = 62.2 / 1000;
model.muscle.lateralGastrocnemius.fiberLength = 5.88 / 100;
model.muscle.lateralGastrocnemius.sarcomereLength = 2.71e-6;
model.muscle.lateralGastrocnemius.pennation = 12.0 * pi/180;

%% soleus

model.muscle.soleus.pcsa = 51.8 / 100 / 100;
model.muscle.soleus.mass = 275.8 / 1000;
model.muscle.soleus.fiberLength = 4.40 / 100;
model.muscle.soleus.sarcomereLength = 2.12e-6;
model.muscle.soleus.pennation = 28.3 * pi/180;

%% peroneus longus

model.muscle.peroneusLongus.pcsa = 10.4 / 100 / 100;
model.muscle.peroneusLongus.mass = 57.7 / 1000;
model.muscle.peroneusLongus.fiberLength = 5.08 / 100;
model.muscle.peroneusLongus.sarcomereLength = 2.72e-6;
model.muscle.peroneusLongus.pennation = 14.1 * pi/180;

%% tibialis anterior

model.muscle.tibialisAnterior.pcsa = 10.9 / 100 / 100;
model.muscle.tibialisAnterior.mass = 80.1 / 1000;
model.muscle.tibialisAnterior.fiberLength = 6.83 / 100;
model.muscle.tibialisAnterior.sarcomereLength = 3.14e-6;
model.muscle.tibialisAnterior.pennation = 9.6 * pi/180;

%% optimal fiber length

optimalSarcomereLength = 2.7e-6; % this used by Ward, others have used 2.8
msc = fieldnames(model.muscle);
for m = 1:length(msc)
    model.muscle.(msc{m}).optimalFiberLength = model.muscle.(msc{m}).fiberLength * model.muscle.(msc{m}).sarcomereLength / optimalSarcomereLength;
end

%% pennation angle at optimal fiber length (phi0) assuming constant width

for m = 1:length(msc)
    model.muscle.(msc{m}).phi0 = asin(model.muscle.(msc{m}).fiberLength / model.muscle.(msc{m}).optimalFiberLength * sin(model.muscle.(msc{m}).pennation));
end

end
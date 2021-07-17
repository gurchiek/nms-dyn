clear
close all
clc

% same as demo_muscleModel except limited to generating certain figures

% initialize generic muscle
muscle = defaultMuscleModel;

%% activation dynamics

fig = figure;

% create excitation signal (step function)
t = 0:0.01:1.0;
n = length(t);
muscle.excitation = zeros(1,n);
muscle.excitation(t >= 0.05 & t <= 0.3) = 1.0;
plot(t,muscle.excitation,'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on

% he 91
muscle.activationDynamics = @adhe91;
a = muscle.activationDynamics(t,muscle.excitation,muscle);
p1 = plot(t,a,'k','LineWidth',2);

% milner brown 73
muscle.activationDynamics = @admilnerbrown73;
a = muscle.activationDynamics(t,muscle.excitation,muscle);
p2 = plot(t,a,'r--','LineWidth',2);

% piecewise milner brown 73
muscle.activationDynamics = @admilnerbrown73pw;
a = muscle.activationDynamics(t,muscle.excitation,muscle);
p3 = plot(t,a,'r','LineWidth',2);

% continuous piecewise winters 95
muscle.activationDynamics = @adwinters95c;
a = muscle.activationDynamics(t,muscle.excitation,muscle);
p4 = plot(t,a,'b','LineWidth',2);

% winters 88
muscle.activationDynamics = @adwinters88;
a = muscle.activationDynamics(t,muscle.excitation,muscle);
p5 = plot(t,a,'b--','LineWidth',2);

fig.Children.Box = 'off';
title('Activation Models')
xlabel('Time (s)')
ylabel('Activation')
ylim([0 1.1])
xlim([0 0.5])
legend([p1 p2 p3 p4 p5],{'he91','mb73','mb73pw','winters95c','winters88'})
grid on

%% activation nonlinearity

% activation values
figure
a = 0:0.01:1;
plot(a,a,'Color',[0.5 0.5 0.5],'LineWidth',2);
hold on

% A model
muscle.activationNonlinearityFunction = @actnonlinA;
muscle.activationNonlinearityShapeAexp = -1.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'k','LineWidth',2);
muscle.activationNonlinearityShapeAexp = -2.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'k--','LineWidth',2);

% C2 continuous A model
muscle.activationNonlinearityFunction = @actnonlinAc;
muscle.activationNonlinearityShapeAexp = -1.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'r','LineWidth',2);
muscle.activationNonlinearityShapeAexp = -2.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'r--','LineWidth',2);

% exponential A model
muscle.activationNonlinearityFunction = @actnonlinAexp;
muscle.activationNonlinearityShapeAexp = -1.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'b','LineWidth',2);
muscle.activationNonlinearityShapeAexp = -2.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'b--','LineWidth',2);

% title('Activation Nonlinearity')
% xlabel('Untransformed Activation')
% ylabel('Transformed Activation')
legend('none','Manal 03 (A) A = -1.5','Manal 03 (A) A = -2.5','Meyer 19 (Ac) A = -1.5','Meyer 19 (Ac) A = -2','Lloyd 03 (Aexp) A = -1.5','Lloyd 03 (Aexp) A = -2.5')
xlim([0 1])
ylim([0 1])
grid on


%% active force length

% muscle length
ln = 0.5:0.01:1.6;
lm = ln * muscle.optimalFiberLength;
act = ones(1,length(ln));

% gordon interpolation
fig = figure;
muscle.activeForceLengthFunction = @flagordon;
muscle.activeForceLengthLowerBound = 0.4;
muscle.activeForceLengthUpperBound = 1.6;
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'Color',[0.5 0.5 0.5],'LineWidth',2.0,'LineStyle','-');
hold on
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'Color',[0.5 0.5 0.5],'LineWidth',2.0,'LineStyle','--');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dgordon] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'Color',[0.5 0.5 0.5],'LineWidth',2.0,'LineStyle','-');

% gaussian 3
muscle.activeForceLengthFunction = @flagaussian3;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'k','LineWidth',2.0);
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.0;
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'k--','LineWidth',2.0);
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dgaussian3] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'k','LineWidth',2.0);

grid on
ylim([0 1.2])
fig.Children.FontSize = 18;
fig.Children.Box = 'off';
% xlabel('Fiber Length')
% ylabel('Normalized Force')
% title('Active Force-Length')
% legend('Gordon 66 (a = 1, \gamma = 0)','Gordon 66 (a = 0.5, \gamma = 0)','Gordon 66 (a = 0.5, \gamma = 0.15)',...
%        'De Groote 16 (gauss3) (a = 1, \gamma = 0)','De Groote 16 (gauss3) (a = 0.5, \gamma = 0)','De Groote 16 (gauss3) (a = 0.5, \gamma = 0.15)')

% derivatives
% half activation, gamma = 0.15
figure
plot(lm,dgordon,'r')
hold on
plot(lm,dgaussian3,'k')
xlabel('Muscle Fiber Length')
ylabel('Active F-L Derivative (dFn/dLm)')
title('Active F-L Function Derivatives (a = 0.5, \gamma = 0.15)')
legend('Gordon 66','De Groote 16 (gauss3)')
grid on

%% passive force length

fig=figure;

% exp plus (thelen)
muscle.passiveForceLengthFunction = @flpexpplus;
hold on
[fn,dexpbias] = muscle.passiveForceLengthFunction(lm,muscle);
plot(ln,fn,'k','LineWidth',2);

grid on
fig.Children.Box = 'off';
fig.Children.FontSize = 18;

% title('Passive F-L Function (\epsilon_0 = 0.55, k = 5)')
% xlabel('Fiber Length')
% ylabel('Normalized Force')
% legend('Thelen 03')

%% tendon force length

fig=figure;
hold on

% strains
strain = 0:0.001:0.08;

% tendon length
lt = muscle.tendonSlackLength * strain + muscle.tendonSlackLength;

% lmtu constant at l0 + ls
lmtu = (muscle.tendonSlackLength + muscle.optimalFiberLength) * ones(1,length(strain));

% muscle length
s = lmtu - lt;
lm = sqrt(s.^2 + muscle.optimalFiberLength^2 * sin(muscle.phi0)^2);

% expc
muscle.tendonForceLengthFunction = @tflexpc;
[ftexpc,dexpc] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ftexpc,'k','LineWidth',2);

% quadratic model (buchanan)
muscle.tendonForceLengthFunction = @tflquadratic;
ft = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ft,'Color',softblack,'LineWidth',2);

% degroote
muscle.tendonForceLengthFunction = @tfldegroote;
ftdegroote = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ftdegroote,'Color',softblack,'LineWidth',2,'LineStyle','--');

grid on
fig.Children.Box = 'off';
fig.Children.FontSize = 18;

% str = sprintf('Tendon F-L Function (strain_0 = %d%%, E = %3.1f)',round(muscle.maxForceTendonStrain*100),muscle.tendonElasticModulus);
% title(str)
% ylabel('Normalized Force')
% xlabel('Tendon Strain (%)')
% legend('Modified De Groote 16')

%% force velocity

% absolute fiber velocity
vn = -1:0.01:1; vm = vn * muscle.normalizedMaxVelocity * muscle.optimalFiberLength;
fig=figure;
hold on

% degroote
muscle.forceVelocityFunction = @fvdegroote;
[fdegroote,ddegroote] = muscle.forceVelocityFunction(vm,muscle);
plot(vn,fdegroote,'k','LineWidth',2);

% schutte
muscle.forceVelocityFunction = @fvschutte;
hold on
plot(vn,muscle.forceVelocityFunction(vm,muscle),'Color',[0.5 0.5 0.5],'LineWidth',2);

grid on
fig.Children.FontSize = 18;
fig.Children.Box = 'off';
% title('Force Velocity Functions (a = 0.25)')
% xlabel('Normalized Velocity')
% ylabel('Normalized Force')
% legend('De Groote 16','Schutte 92')


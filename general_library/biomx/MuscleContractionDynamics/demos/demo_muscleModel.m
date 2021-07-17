clear
close all
clc

% initialize generic muscle
muscle = defaultMuscleModel;

%% activation dynamics

% create excitation signal (step function)
time.excitation = 0:0.01:1.8;
n = length(time.excitation);
muscle.excitation = zeros(1,n);
muscle.excitation(time.excitation >=0.2 & time.excitation <= 0.5) = 0.5;
muscle.excitation(time.excitation >= 1.0 & time.excitation <= 1.3) = 1.0;
plot(time.excitation,muscle.excitation,'Color',[0.5 0.5 0.5]);
hold on

% he 91
muscle.activationDynamics = @adhe91;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p1 = plot(time.excitation,a,'k');

% milner brown 73
muscle.activationDynamics = @admilnerbrown73;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p2 = plot(time.excitation,a,'r--');

% piecewise milner brown 73
muscle.activationDynamics = @admilnerbrown73pw;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p3 = plot(time.excitation,a,'r');

% continuous piecewise winters 95
muscle.activationDynamics = @adwinters95c;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p4 = plot(time.excitation,a,'b');

% discontinuous piecewise winters 95
muscle.activationDynamics = @adwinters95;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p5 = plot(time.excitation,a,'b--');

% winters 88
muscle.activationDynamics = @adwinters88;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p6 = plot(time.excitation,a,'b:');

% zajac 89
muscle.activationDynamics = @adzajac89;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p7 = plot(time.excitation,a,'k--');

% discrete time second order (lloyd/besier 03)
muscle.activationDynamics = @adlloyd03;
a = muscle.activationDynamics(time.excitation,muscle.excitation,muscle);
p8 = plot(time.excitation,a,'r:');

title('Activation Models')
xlabel('Time (s)')
ylabel('Activation')
ylim([0 1.2])
legend([p1 p2 p3 p4 p5 p6 p7 p8],{'he91','mb73','mb73pw','winters95c','winters95','winters88','zajac89','lloyd03'})

%% activation nonlinearity

% activation values
figure
a = 0:0.01:1;
plot(a,a,'Color',[0.5 0.5 0.5]);
hold on

% A model
muscle.activationNonlinearityFunction = @actnonlinA;
muscle.activationNonlinearityShapeAexp = -1.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'k');
muscle.activationNonlinearityShapeAexp = -2.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'k--');
muscle.activationNonlinearityShapeAexp = -3.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'k:');

% C2 continuous A model
muscle.activationNonlinearityFunction = @actnonlinAc;
muscle.activationNonlinearityShapeAexp = -1.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'r');
muscle.activationNonlinearityShapeAexp = -2.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'r--');
muscle.activationNonlinearityShapeAexp = -3.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'r:');

% exponential A model
muscle.activationNonlinearityFunction = @actnonlinAexp;
muscle.activationNonlinearityShapeAexp = -1.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'b');
muscle.activationNonlinearityShapeAexp = -2.5;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'b--');
muscle.activationNonlinearityShapeAexp = -3.0;
plot(a,muscle.activationNonlinearityFunction(a,muscle),'b:');

title('Activation Nonlinearity')
xlabel('Untransformed Activation')
ylabel('Transformed Activation')
legend('none','Manal/Buchanan (A) A = -1','Manal/Buchanan (A) A = -2','Manal/Buchanan (A) A = -3','Meyer (Ac) A = -1','Meyer (Ac) A = -2','Meyer (Ac) A = -3','Lloyd/Besier (Aexp) A = -1','Lloyd/Besier (Aexp) A = -2','Lloyd/Besier (Aexp) A = -3')
xlim([0 1])
ylim([0 1])

%% active force length

% muscle length
ln = 0.5:0.01:1.5;
lm = ln * muscle.optimalFiberLength;
act = ones(1,length(ln));

% gordon interpolation
figure
muscle.activeForceLengthFunction = @flagordon;
muscle.activeForceLengthLowerBound = 0.4;
muscle.activeForceLengthUpperBound = 1.6;
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'k');
hold on
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'k');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dgordon] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'k--');

% gaussian 1
muscle.activeForceLengthGaussian1Shape = 0.45^2;
muscle.activeForceLengthFunction = @flagaussian1;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'b');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.0;
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'b');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dgaussian1] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'b--');

% gaussian 3
muscle.activeForceLengthFunction = @flagaussian3;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'r');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.0;
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'r');
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dgaussian3] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'r--');

% quadratic
muscle.activeForceLengthFunction = @flaquadratic;
plot(lm,muscle.activeForceLengthFunction(lm,act,muscle),'Color',[0.5 0.5 0.5]);
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.0;
plot(lm,muscle.activeForceLengthFunction(lm,0.5*act,muscle),'Color',[0.5 0.5 0.5]);
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
[fn,dquadratic] = muscle.activeForceLengthFunction(lm,0.5*act,muscle);
plot(lm,fn,'Color',[0.5 0.5 0.5],'LineStyle','--');

ylim([0 1.5])
xlabel('Fiber Length')
ylabel('Normalized Force')
title('Active Force-Length')
legend('gordon (a = 0, \gamma = 0)','gordon (a = 0.5, \gamma = 0)','gordon (a = 0.5, \gamma = 0.15)',...
       'guassian1 (a = 0, \gamma = 0)','gaussian1 (a = 0.5, \gamma = 0)','guassian1 (a = 0.5, \gamma = 0.15)',...
       'guassian3 (a = 0, \gamma = 0)','gaussian3 (a = 0.5, \gamma = 0)','guassian3 (a = 0.5, \gamma = 0.15)',...
       'quadratic (a = 0, \gamma = 0)','quadratic (a = 0.5, \gamma = 0)','quadratic (a = 0.5, \gamma = 0.15)')

% derivatives
% half activation, gamma = 0.15
figure
plot(lm,dgordon,'k')
hold on
plot(lm,dgaussian1,'b')
plot(lm,dgaussian3,'r')
plot(lm,dquadratic,'Color',[0.5 0.5 0.5])
xlabel('Muscle Fiber Length')
ylabel('Active F-L Derivative (dFn/dLm)')
title('Active F-L Function Derivatives (a = 0.5, \gamma = 0.15)')
legend('gordon','gaussian1','gaussian3','quadratic')

%% passive force length

% exp (schutte)
muscle.passiveForceLengthFunction = @flpexp;
muscle.passiveForceLengthShapeFactor = 5;
muscle.maxForceMuscleStrain = 0.55; 
figure
[fn,dexp] = muscle.passiveForceLengthFunction(lm,muscle);
plot(ln,fn,'k');

% biased exp (thelen)
muscle.passiveForceLengthFunction = @flpexpplus;
hold on
[fn,dexpbias] = muscle.passiveForceLengthFunction(lm,muscle);
plot(ln,fn,'r--');

title('Passive F-L Functions')
xlabel('Fiber Length')
ylabel('Normalized Force')
legend('exp (\epsilon_0 = 0.55, k = 5)','expplus (\epsilon_0 = 0.55, k = 5)')

% derivatives
figure
plot(ln,dexp,'k')
hold on
plot(ln,dexpbias,'r--')
title('Passive F-L Function Derivatives')
xlabel('Fiber Length')
ylabel('Derivative (dFn/dLm)')
legend('exp (\epsilon_0 = 0.55, k = 5)','expplus (\epsilon_0 = 0.55, k = 5)')

%% tendon force length

figure
hold on

% strains
strain = -0.02:0.001:0.1;

% tendon length
lt = muscle.tendonSlackLength * strain + muscle.tendonSlackLength;

% lmtu constant at l0 + ls
lmtu = (muscle.tendonSlackLength + muscle.optimalFiberLength) * ones(1,length(strain));

% muscle length
s = lmtu - lt;
lm = sqrt(s.^2 + muscle.optimalFiberLength^2 * sin(muscle.phi0)^2);

% exponential model
muscle.tendonForceLengthFunction = @tflexp;
ft = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ft,'k');

% quadratic model
muscle.tendonForceLengthFunction = @tflquadratic;
ft = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ft,'r--');

% degroote
muscle.tendonForceLengthFunction = @tfldegroote;
[ftdegroote,ddegroote] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ftdegroote,'b');

% expc
muscle.tendonForceLengthFunction = @tflexpc;
[ftexpc,dexpc] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ftexpc,'b--');

% spline
muscle.tendonForceLengthFunction = @tflspline;
muscle.tendonSplineForceLengthFunction = @tflexp;
[ftspline,dspline] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
plot(strain*100,ftspline,'b:');

str = sprintf('Tendon F-L Function (strain_0 = %d%%, E = %3.1f)',round(muscle.maxForceTendonStrain*100),muscle.tendonElasticModulus);
title(str)
ylabel('Normalized Force')
xlabel('Tendon Strain (%)')
legend('exp','quadratic','degroote','expc','spline')

% derivatives
figure
subplot(2,1,1)
plot(lm,ftdegroote,'b')
hold on
plot(lm,ftexpc,'b--')
plot(lm,ftspline,'b:')
title(str)
ylabel('Normalized Force')
xlabel('Fiber Length')
legend('degroote','expc','spline')

subplot(2,1,2)
plot(lm,ddegroote,'b')
hold on
plot(lm,dexpc,'b--')
plot(lm,dspline,'b:')
title('Tendon F-L Derivatives wrt Lm')
ylabel('Derivative (dFt/dLm)')
xlabel('fiber length')
legend('degroote','expc','spline')

% comparison of different spline functions
muscle.tendonForceLengthFunction = @tflspline;
muscle.tendonSplineForceLengthFunction = @tflexp;
[ftexp,dexp] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
muscle.tendonSplineForceLengthFunction = @tflquadratic;
[ftq,dq] = muscle.tendonForceLengthFunction(lm,lmtu,muscle);
figure
subplot(2,1,1)
plot(lm,ftexp,'k')
hold on
plot(lm,ftq,'r--')
title(str)
ylabel('Normalized Force')
xlabel('Fiber Length')
legend('spline (exp)','spline (quadratic)')

subplot(2,1,2)
plot(lm,dexp,'k')
hold on
plot(lm,dq,'r--')
title('Tendon F-L Derivatives wrt Lm')
ylabel('Normalized Force')
xlabel('Fiber Length')
legend('spline (exp)','spline (quadratic)')


%% force velocity

% absolute fiber velocity
vn = -1:0.01:1; vm = vn * muscle.normalizedMaxVelocity * muscle.optimalFiberLength;
figure
hold on

% degroote
muscle.forceVelocityFunction = @fvdegroote;
[fdegroote,ddegroote] = muscle.forceVelocityFunction(vm,muscle);
plot(vn,fdegroote,'k');

% schutte
muscle.forceVelocityFunction = @fvschutte;
hold on
plot(vn,muscle.forceVelocityFunction(vm,muscle),'r');

% spline: hill concentric, user-specified eccentric
muscle.forceVelocityFunction = @fvspline;
muscle.eccentricForceVelocityFunction = @fvschutte;
[fspline,dspline] = muscle.forceVelocityFunction(vm,muscle);
plot(vn,fspline,'b--');

title('Force Velocity Functions (a = 0.25)')
xlabel('Normalized Velocity')
ylabel('Normalized Force')
legend('degroote','schutte','spline (schutte)')

% derivatives
figure
p1 = plot(vn,fdegroote,'k');
hold on
p2 = plot(vn,fspline,'r');
muscle.coefShorteningHeat = 0.1;
[fspline1,dspline1] = muscle.forceVelocityFunction(vm,muscle);
p3 = plot(vn,fspline1,'b');
title('Force Velocity Functions + Derivatives')
xlabel('Normalized Velocity')
ylabel('Normalized Force')

yyaxis right
hold on
plot(vn,ddegroote,'k--')
plot(vn,dspline,'r--')
plot(vn,dspline1,'b--')
legend([p1 p2 p3],{'degroote','spline (schutte: a = 0.25)','spline (schutte: a = 0.1)'})

%% inverse force velocity

figure
hold on

% strains
strain = 0:0.001:0.06;

% tendon length
lt = muscle.tendonSlackLength * strain + muscle.tendonSlackLength;

% muscle length constant at optimum
lm = muscle.optimalFiberLength * ones(1,length(strain));

% mtu length
lmtu = lt + lm .* cos(muscle.pennationFunction(lm,muscle));

% activation
act = ones(1,length(lmtu));

% schutte
muscle.inverseForceVelocityFunction = @ifvschutte;
muscle.tendonForceLengthFunction = @tflexpc;
muscle.passiveForceLengthFunction = @flpexp;
muscle.activeForceLengthFunction = @flagaussian3;
muscle.coefShorteningHeat = 0.25;
muscle.maxForceTendonStrain = 0.04;
muscle.tendonElasticModulus = 35;
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
muscle.passiveForceLengthShapeFactor = 5;
[v,~,ft] = muscle.inverseForceVelocityFunction(lm,act,lmtu,muscle);
plot(v,ft,'b')

% thelen
muscle.inverseForceVelocityFunction = @ifvthelen;
muscle.tendonForceLengthFunction = @tflexpc;
muscle.passiveForceLengthFunction = @flpexp;
muscle.activeForceLengthFunction = @flagaussian3;
muscle.coefShorteningHeat = 0.25;
muscle.coefDamping = 0.1;
muscle.maxForceTendonStrain = 0.04;
muscle.tendonElasticModulus = 35;
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
muscle.passiveForceLengthShapeFactor = 5;
muscle.maxForceMuscleStrain = 0.5; 
[v,~,ft] = muscle.inverseForceVelocityFunction(lm,act,lmtu,muscle);
plot(v,ft,'r')

% degroote
muscle.inverseForceVelocityFunction = @ifvdegroote;
muscle.tendonForceLengthFunction = @tfldegroote;
muscle.passiveForceLengthFunction = @flpexp;
muscle.activeForceLengthFunction = @flagaussian3;
muscle.coefShorteningHeat = 0.25;
muscle.coefDamping = 0.1;
muscle.maxForceTendonStrain = 0.04;
muscle.tendonElasticModulus = 35;
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;
muscle.passiveForceLengthShapeFactor = 5;
muscle.maxForceMuscleStrain = 0.5; 
[v,d,ft] = muscle.inverseForceVelocityFunction(lm,act,lmtu,muscle);
plot(v,ft,'k')

xlabel('Velocity (m/s)')
ylabel('Normalized Force')
title('Inverse Force Velocity Functions')
legend('schutte','thelen','degroote')

% derivative
figure
plot(v,d,'k--')
title('Degroote Inverse F-V Derivative wrt Lm')
xlabel('Velocity')
ylabel('Derivative (dv/dLm)')


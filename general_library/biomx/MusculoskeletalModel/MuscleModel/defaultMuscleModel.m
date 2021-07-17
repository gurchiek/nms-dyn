function muscle = defaultMuscleModel()

% IMPORTANT: fieldnames (muscle properties) should not have underscores _

% activationGroup
% describes the group to which the muscle belongs for optimizing any
% activation dynamics parameters (electromechanicalDelay,
% activationTimeConstant, etc.), all muscles belonging to the same
% actuation group will have the same activation dynamics settings
% char array
muscle.activationGroup = '';

% structuralGroup
% describes the group to which the muscle belongs for scaling optimal fiber
% length and tendon slack length, all muscles in the same structural group
% will have the optimalFiberLength and tendonSlackLength scaled together in
% any global optimization routine
% char array
muscle.structuralGroup = '';

% strengthGroup
% describes the group to which the muscle belongs for scaling maxForce, all
% muscles in the same functional group will have maxForce scaled together
% in any global optimization routine
% char array
muscle.strengthGroup = '';

% bodyContour
% name of body contour field in body struct around which the muscle wraps
% char array
muscle.bodyContour = '';

% contourViaPoints
% structure containing details about via points along body contour around which muscle wraps for display
% struct
muscle.contourViaPoints = struct();

% nViaPoints
% number of via points through which the muscle passes
% integer
muscle.nViaPoints = [];

% viaPoint
% structure containing details about via points for muscle path computations
% struct
muscle.viaPoint = struct();

% nElements
% number of elements comprising the muscle
% integer
muscle.nElements = [];

% element
% structure containing details about individual muscle elements
% struc
muscle.element = struct();

% scaleSegment
% segment used to scale muscle geometry
% char array
muscle.scaleSegment = '';

% joints
% joints the muscle crosses
% char cell array
muscle.joints = {''};

% origin
% structure containing details about the origin of the muscle globally
% struct
muscle.origin = struct();

% insertion
% structure containing details about the insertion of the muscle globally
% struct
muscle.insertion = struct();

% local
% structure containing details about muscle origin/insertio/elements locally
% struct
muscle.local = struct();

% mtu
% structure containing mtu length and velocity arrays 
% length and velocity in meters and meters/second
% struct
muscle.mtu.length = [];
muscle.mtu.velocity = [];

% momentArm
% structure containing details about moment arm length for particular joints and degrees of freedom (e.g. knee flexion)
% lengths are in meters
% struct
muscle.momentArm = struct();

% pcsa
% physiological cross sectional area
% double, meters squared
muscle.pcsa = 40.0 / 100 / 100;

% maxForce
% maximum isometric force
% double, newtons
muscle.maxForce = 1200.0;

% maxStress
% max stress a muscle can produce
% 0.2 - 1.0 MPa (pascal = N/m/m), Winters and Stark 1988
% 0.25 MPa, Friederich (1990) from Delp 90 (thesis)
% 0.61 MPa, Wickiewicz (1983) from Delp 90 (thesis)
% 0.23 MPa, Spector (1980) from Delp 90 (thesis)
% F0 = s0 * pcsa
% double, pascals
muscle.maxStress = 0.3e6;

% mass
% double, kilograms
muscle.mass = 200.0 / 1000.0;

% optimalFiberLength
% double, meters
% refs: horsman 07, ward 09, delp 90, yamaguchi 90
muscle.optimalFiberLength = 1.0;

% tendonSlackLength
% double, meters
muscle.tendonSlackLength = 1.0;

% proximalMTUTendonPercentage
% for display purposes, the mtu will be displayed as a muscle (red) +
% tendon (grey, black, etc.), the tendon length will be divided into a
% proximal portion (origin to muscle) and a distal portion (muscle to
% insertion), and proximalMTUTendonPercentage describes what percentage of
% the tendon length is displayed in the proximal portion
% double, 0.0 - 1.0
muscle.proximalMTUTendonPercentage = 0.5;

% normalizedMaxVelocity
% absolute value of maximum shortening velocity 
% double, units optimal fiber lengths
% thelen 03 used 8-10
% zajac 89 used 10
% arnold 13 used 15
muscle.normalizedMaxVelocity = 10.0;

% phi0
% pennation angle at optimal fiber length
% double, radians
muscle.phi0 = 0.0 * pi/180;

% pennationFunction
% function, inputs: muscle length in meters, muscle
% returns pennation angle
muscle.pennationFunction = @pennationConstantThickness;

% emg.names
% names of emg locations from which excitation data are determined
% cell array of chars
% if more than one then excitation will be mean emg of all listed muscles (e.g. VI = mean(VM,VL) => emg.names = {'VM','VL'})
muscle.emg.names = {''};

% excitation
% time series, normalized by MVC (range: 0 - 1)
muscle.excitation = [];

% minExcitation
% all excitations below this value will be changed to this value
% double, 0 - 1
muscle.minExcitation = 0.01;

% activationDynamics
% simulates activation dynamics driven by excitations
% function, inputs: time, excitation, muscle
% options: adhe91, adlloyd03, admilnerbrown73, admilnerbrown73pw, adwinters88, adwinters95, adwinters95c, adzajac89
% returns activation
% adhe91 is order 1, nonlinear, dc = 1, uses both tact and tdeact continuous
% adzajac89 is order 1, bilinear, non unity gain, uses both tact and tdeact continuous
% adwinters95 is order 1, nonlinear, dc = 1, uses both tact and tdeact piecewise
% adwinters95c is order 1, nonlinear, uses both tact and tdeact continuously, overcomes piecewise discontinuity using hyperbolic tangent (see Falisse 2016)
% adwinters88 is order 1, linear, effect time constant is mean(tact,tdeact)
% admilnerbrown73 is order 2, linear, dc = 1, natural frequency is mean(1/tact,1/tdeact)
% admilnerbrown73 is same as admilnerbrown73 except uses both tact and tdeact piecewise
% adlloyd03 is dt order 2, dc = 1, doesnt use either tact nor tdeact, instead uses C1 and C2 specific to this function
muscle.activationDynamics = @admilnerbrown73;

% activationDynamicsSolver
% used in activationDynamics function, usually the ode solver
% function handle
muscle.activationDynamicsSolver = @ode45;

% activationDynamicsSolverOptions
% options used by solver, usually output from odeset
% struct
muscle.activationDynamicsSolverOptions = odeset('RelTol',1e-12);

% electromechanicalDelay
% parameter describing delay in input signal (excitation) reaching muscle
% to drive dynamics
% units seconds
muscle.electromechanicalDelay = 0.04;

% activationTimeConstant
% usually between 10 and 60 ms
% parameter in all but adlloyd03
% in continuous 2nd order models this informs natural frequency (1/tau)
% double, seconds
muscle.activationTimeConstant = 0.012;

% activationDeactivationRatio
% t_act / t_deact, max = 1.0, min usually 0.5 (beta in zajac 89, he used 0.5)
% parameter in all but adlloyd03
muscle.activationDeactivationRatio = 0.5;

% % deactivationTimeConstant
% % parameters in all but adlloyd03
% % double, seconds
% muscle.deactivationTimeConstant = 0.024;

% activationDeactivationTransitionSmoothness
% parameter in adwinters95c, controls how smooth activation/deactivation
% rates change in original piecewise formulation (De Groote 16)
muscle.activationDeactivationTransitionSmoothness = 0.1;

% dt2ActivationDynamicsC1
% parameters in adlloyd03 (2nd order discrete model)
% abs(C1) < 1
% double
muscle.dt2ActivationDynamicsC1 = -0.5;

% dt2ActivationDynamicsC2
% parameters in adlloyd03 (2nd order discrete model)
% abs(C2) < 1
% double
muscle.dt2ActivationDynamicsC2 = -0.5;

% activationNonlinearityFunction
% describes nonlinear relationship between activation and muscle force
% function, inputs: act, muscle
% returns activation
% options: actnonlinA, actnonlinAc, actnonlinAexp, actnonlinIdentity (no transform, linear)
muscle.activationNonlinearityFunction = @actnonlinAc;

% activationNonlinearityShapeAexp
% parameter in actnonlinAexp: -3 < A < 0, Lloyd/besier 03
% this now also used in actnonlinA and actnonlinAc, see those functions for
% description and how Aexp informs what was A and Ac
muscle.activationNonlinearityShapeAexp = -1.5;

% % activationNonlinearityShapeA
% % parameter in actnonlinA: 0 < A < 0.12, manal/buchanan 03
% muscle.activationNonlinearityShapeA = 0.06;
% 
% % activationNonlinearityShapeAc
% % parameter in actnonlinA: 0 < A < 0.12, meyer 19
% muscle.activationNonlinearityShapeAc = 0.06;

% submaxOptimalFiberLengthAdjustmentFunction
% adjusts optimal fiber length for use in active force length functions due
% to submaximal activation
% function, inputs: muscle length, activation, muscle
% returns normalized fiber length and adjusted optimal fiber length
% options: adjloptlin (linear adjustment from lloyd/besier 03)
muscle.submaxOptimalFiberLengthAdjustmentFunction = @adjloptlin;

% coefSubmaxOptimalFiberLengthAdjustment
% parameter in adjloptlin describing percentage change in optimal fiber
% length for a completely inactive muscle s.t l0new = c * l0old when a = 0
% see lloyd/besier 03
muscle.coefSubmaxOptimalFiberLengthAdjustment = 0.15;

% activeForceLengthFunction
% function, inputs: fiber length, activation, muscle
% returns normalized muscle force: a * fl in hill models
% options: flaguassian1, flaguassian3, flagordon, flaquadratic
muscle.activeForceLengthFunction = @flagaussian3;

% activeForceLengthLowerBound
% parameter in flagordon, determines the point of zero force before the
% ascending limb of the active F-L curve
% usually 0.4 - 0.6
muscle.activeForceLengthLowerBound = 0.4;

% activeForceLengthUpperBound
% parameter in flagordon, determines the point of zero force after the
% descending limb of the active F-L curve
% usually 1.5 - 1.6
muscle.activeForceLengthUpperBound = 1.6;

% activeForceLengthGaussian1Shape
% parameter in flaguassian1, is effectively the variance in the exponential
% function of the normal density function
% thelen 2003 used 0.45^2
muscle.activeForceLengthGaussian1Shape = 0.2025;

% activeForceLengthRange
% parameter in flaquadratic, effectively determines the zeros of Woittiez's
% parabolic approximation to the active F-L curve and the range of
% normalized fiber lengths (symmetric about the optimum) within which the
% fiber is modeled to produce force
muscle.activeForceLengthRange = 1.2;

% passiveForceLengthFunction
% function, inputs: fiber length, muscle
% options: flpexp (buchanan 04, schutte 92), flpexpplus (degroote 16, thelen 03)
muscle.passiveForceLengthFunction = @flpexpplus;

% passiveForceLengthShapeFactor
% parameter in flpexp and flpexpbias
muscle.passiveForceLengthShapeFactor = 5;

% maxForceMuscleStrain
% strain at which passive muscle force = F0
% thelen had 0.5 for old and 0.6 for young
muscle.maxForceMuscleStrain = 0.55;

% tendonForceLengthFunction
% function, inputs: fiber length, mtu length, muscle
% options: tflexp, tflexpc, tflquadratic, tfldegroote, tflspline
% tflexpc is close to what de groote used, but reformulated so that same
% parameters used in other functions could be used. expc/degroote/spline are C2
% continuous unlike the piecewise tflexp [thelen 03] and tflquadratic [schutte 92])
muscle.tendonForceLengthFunction = @tflexpc;

% maxForceTendonStrain
% parameter in tflexp, tflexpc, tflquadratic
% is the tendon strain at which tendon force = F0
% usually 3.3 - 4% (0.033 - 0.04)
muscle.maxForceTendonStrain = 0.04;

% tendonElasticModulus
% parameter in tflexp, tflexpc, tflquadratic
% in tflexp and tflquadratic it determines the slope of the linear region
% of the tendon stress-strain curve
% in tflexpc it is the slope of the persistently nonlinear stress-strain
% curve when strain = maxForceTendonStrain
% thelen had 42.7968 in tflexp, schutte had 37.5 in tflquadratic and de
% groote had 35 in tflexpc
muscle.tendonElasticModulus = 35;

% tendonNonlinearExpShapeFactor
% parameter in tflexp, thelen had 3
muscle.tendonNonlinearExpShapeFactor = 3;

% tendonSplineForceLengthFunction
% tendon force length function handle (either tflexp or tflquadratic
% used in tflspline, is the piecewise for length function to which the
% spline will be fit
muscle.tendonSplineForceLengthFunction = @tflexp;

% forceVelocityFunction
% function, inputs: fiber velocity, muscle
% options: fvdegroote, fvschutte, fvspline
% fvdegroote is a C2 continuous logistic function with similar shape to a
% damped hill f-v model
% fvschutte uses the hill equation for shortening velocities and an
% asymptotic eccentric function for lengthening velocities
% fvspline is a C2 continuous implementation of fvschutte which not so
% sharp at the zero velocity point and more closely resembles the hill
% equation for shortening velocities than does degroote
muscle.forceVelocityFunction = @fvdegroote;

% coefShorteningHeat
% parameter in hill equation, 0.1 <= a <= 0.5, lesser for slower fibers
% (type 1, oxidative) can scale using fiber type percentage data as in
% yamaguchi 90 table, 0.25 ~ transition slow to fast
muscle.coefShorteningHeat = 0.25;

% eccentricForceVelocityFunction
% is a force velocity function that must be specified for fvspline,
% effectively models the eccentric force-velocity relationship (fvspline
% used hill equation for shortening velocities)
muscle.eccentricForceVelocityFunction = @fvschutte;

% coefDamping
% coefficient of passive parallel damper in hill model which models
% viscoelastic properties of muscle (independent of active force-velocity
% relation)
% is param for normalized fiber velocities
% krause had 0.0125
% millard used 0.1 (but report optimal was 0.016 for at least one muscle)
% schutte used 0.5
% larger => less stiff, better handled by ode45, but probably less
% physiologically accurate
% not all inverse force velocity functions consider damping (eg degroote
% does not but schutte does)
muscle.coefDamping = 0.1;

% inverseForceVelocityFunction
% function, inputs: lm, act, lmtu, muscle
% returns velocity, derivative wrt to lm, normalized force
% options: ifvthelen, ifvschutte, ifvdegroote
% ifvdegroote is only C2 continuous one which could be used with ode23s or
% ode15s, otherwise all can be used with ode45
% used with explicitMuscleContractionDynamics
muscle.inverseForceVelocityFunction = @ifvschutte;

% maxEccentricForce
% upper asymptote of force velocity function
% Thelen's Flen
% Ch1 of Multiple Muscle Systems, Zahalak, cites Katz (1993) for
% justification of 1.8 (see pg 60 after fig 7) and Harry et al (1990) for 1.5, Harry et al. (1990)
% actually state the ratio in lengthening was between 1.2-1.5 and nearly
% constant (see fig 1 and first two sentences of results). 
% Thus, range should be about 1.2-1.8 (ish)
muscle.maxEccentricForce = 1.8;

% implicitDynamics
% function, inputs: t, lm, vm, muscle, time, k
% returns f(x,xdot,t) = 0
% must also return jacobian with respect to lm and vm and thus all hill
% model function used within must also return derivative with their
% respective state inputs: fv, fl, fp, fphi, phi, ft
% to be used with ode15i
muscle.implicitDynamics = @muscleTendonEquilibrium;

% explicitDynamics
% function, inputs: t, lm, muscle, time, k
% must also return jacobian with respect to lm if using ode23s or ode15s
% (only compatible ifv is degroote)
muscle.explicitDynamics = @explicitHillStateEquation;

% solverType
% options: 'implicitIntegration','explicitIntegration','algebraic'
% algebraic assumes rigid tendon (best for short tendon mtus)
muscle.solverType = 'implicitIntegration';

% implicitSolver
muscle.implicitSolver = @ode15i;

% implicitSolverOptions
% used even for explicit methods for intialization
muscle.implicitSolverOptions = odeset('RelTol',1e-6,'MaxStep',0.01,'Jacobian',@muscleTendonEquilibriumJacobian);

% explicitSolver
% if jacobian provided for ode23s or ode15s then ifv functions must provide
% non empty derivative
muscle.explicitSolver = @ode45;

% explicitSolverOptions
% eg from odeset
muscle.explicitSolverOptions = odeset('RelTol',1e-6,'MaxStep',0.01);

% algebraicSolver
muscle.algebraicSolver = @rigidTendonEquilibriumEquation;

% C2 continuous functions: all active F-L, all passive F-L, tflexpc,
% tfldegroote, fvspline, fvdegroote, ifvdegroote

% all the spline fxns are intended to make other previously used piecewise
% fxns C2 continuous as opposed to just C1. Of all of these the fvspline
% has the most choppy second derivative. The flagordon and tflspline fxns
% are more smooth at D2

end
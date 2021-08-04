function muscle = muscleContractionDynamics(model,muscle,muscleNames,time)

% INPUTS
% model - nms model struct
% muscle - nms muscle struct, must have mt length/velocity and moment arms
% muscleName - cell array of muscle names to simulate contraction for
% time - struct
%   time.mtuKinematics: 1xn time array corresponding to mtu.length, mtu.velocity, moment arms
%   time.excitation: 1xm time array corresponding to excitation (also corresponds to activation after simulating those dynamics)
%   time.simulation: 1xp time array corresponding to contraction dynamics variables after simulation (except for activation, activation time is same as excitation time)
%       (1) fiberLength: actual fiber length, not projection onto MTU line of action
%       (2) fiberVelocity: time-derivative of (1)
%       (3) force: fiber force projected onto MTU line of action
%       (4) work: concentric/eccentric, trapezoidal integration of F*ds (F is (3), s is fiber length projected onto MTU line of action)
%       (5) power: concentric => >0, eccentric => <0, product of (3) with velocity of s (see (4) for descriptio of s)
%       (6) torque: product of (3) with MTU moment arm

% output is same input muscle struct but with new fields: activation,
% fiberLength, fiberVelocity, force, work, power,
% torque.(jointName).(dofName) (e.g. torque.knee.flexion)

% to get total emd joint torques after simulation use sumMuslceTorques

% use all muscle names if none specified
if nargin == 2
    muscleNames = fieldnames(muscle);
elseif isempty(muscleNames)
    muscleNames = fieldnames(muscle);
end

% simulate contraction for each muscle
for m = 1:length(muscleNames)
    
    % current muscle being simulated
    curr_muscle = muscle.(muscleNames{m});
    
    % give dynamic properties (mtu length/velocity, excitation, etc) from model muscle
    curr_muscle = inherit(curr_muscle,model.muscle.(muscleNames{m}));
    
    % activation dynamics
    curr_muscle.activation = curr_muscle.activationDynamics(time.excitation,curr_muscle.excitation,curr_muscle);
    
    % initialize muscle state
    % preallocation of of fiber length/velocity, force, work, and power
    % initializes state at time.simulation(1)
    curr_muscle = initializeMuscleState(curr_muscle,time);
    
    % simulate contraction
    tic

    % implicit (ode15i)
    if strcmpi(curr_muscle.solverType,'implicitIntegration')

        % integrate
        [xt,x] = curr_muscle.implicitSolver(curr_muscle.implicitDynamics,time.simulation,curr_muscle.fiberLength(1),curr_muscle.fiberVelocity(1),curr_muscle.implicitSolverOptions,curr_muscle,time);
        curr_muscle.fiberLength = interp1(xt,x,time.simulation,'pchip');
        curr_muscle.fiberVelocity = fdiff(curr_muscle.fiberLength,time.simulation,5);
        for k = 1:length(time.simulation)
            [~,~,~,curr_muscle.force(k)] = curr_muscle.implicitDynamics(time.simulation(k),curr_muscle.fiberLength(k),curr_muscle.fiberVelocity(k),curr_muscle,time);
        end

    % explicit (ode45, ode23s, ode15s)
    elseif strcmpi(curr_muscle.solverType,'explicitIntegration')

        % integrate
        [xt,x] = curr_muscle.explicitSolver(curr_muscle.explicitDynamics,time.simulation,curr_muscle.fiberLength(1),curr_muscle.explicitSolverOptions,curr_muscle,time);
        curr_muscle.fiberLength = interp1(xt,x,time.simulation,'pchip');
        curr_muscle.fiberVelocity = fdiff(curr_muscle.fiberLength,time.simulation,5);
        curr_lmtu = interp1(time.mtuKinematics,curr_muscle.mtu.length,time.simulation,'pchip');
        curr_activation = interp1(time.excitation, curr_muscle.activation,time.simulation,'pchip');
        for k = 1:length(time.simulation)
            [~,~,curr_muscle.force(k)] = curr_muscle.inverseForceVelocityFunction(curr_muscle.fiberLength(k),curr_activation(k),curr_lmtu(k),curr_muscle);
        end

    % algebraic (rigidTendon)
    elseif strcmpi(curr_muscle.solverType,'algebraic')

        for k = 1:length(time.simulation)
            curr_muscle = curr_muscle.algebraicSolver(curr_muscle,time,k);
        end

    end
    curr_muscle.contractionDynamicsSolutionTime = toc;
    
    % instantaneous pennation angle
    curr_muscle.pennation = curr_muscle.pennationFunction(curr_muscle.fiberLength,curr_muscle);
    
    % muscle power and work
    curr_muscle.power = computeMusclePower(curr_muscle.force,curr_muscle.fiberVelocity,curr_muscle.fiberLength,curr_muscle.pennation,time.simulation);
    curr_muscle.work = computeCumulativeMuscleWork(curr_muscle.force,curr_muscle.fiberLength,curr_muscle.pennation);
    
    % muscle torque contributions
    joint = fieldnames(curr_muscle.momentArm);
    for j = 1:length(joint)
        dof = fieldnames(curr_muscle.momentArm.(joint{j}));
        for d = 1:length(dof)
            mom_arm = interp1(time.mtuKinematics,curr_muscle.momentArm.(joint{j}).(dof{d}),time.simulation,'pchip');
            curr_muscle.torque.(joint{j}).(dof{d}) = curr_muscle.force .* mom_arm;
        end
    end
    
    % update global muscle struct
    muscle.(muscleNames{m}).activation = curr_muscle.activation;
    muscle.(muscleNames{m}).fiberLength = curr_muscle.fiberLength;
    muscle.(muscleNames{m}).fiberVelocity = curr_muscle.fiberVelocity;
    muscle.(muscleNames{m}).force = curr_muscle.force;
    muscle.(muscleNames{m}).torque = curr_muscle.torque;
    muscle.(muscleNames{m}).power = curr_muscle.power;
    muscle.(muscleNames{m}).work = curr_muscle.work;
    muscle.(muscleNames{m}).pennation = curr_muscle.pennation;
    
end

end
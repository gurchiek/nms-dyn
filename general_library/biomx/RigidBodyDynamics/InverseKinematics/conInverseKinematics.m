function trial = conInverseKinematics(model,trial,options)

% constrained inverse kinematics
% see anderson et al 2009

% INPUTS
% model - nms model struct
% trial - nms trial struct with marker data
% options - struct
%           options.coordinateSystem = char, coordinate system name
%           options.constrainedAnalysisName = char, analysis name for constrained inv kin (does unconstrained also)
%           options.unconstrainedAnalysisName = char, analysis name for unconstrained kinematics (initialized constrained analysis with this)
%           options.lowPassCutoff = butterworth filter low pass cutoff

% updates following fields in trial:
%   (1) trial.(constrainedAnalysisName).body.optimization
%   (2) trial.(constrainedAnalysisName).body.generalizedCoordinateNames
%   (3) trial.(constrainedAnalysisName).body.generalizedCoordinates.(cs).position
%   (4) trial.(constrainedAnalysisName).body.generalizedCoordinates.(cs).velocity
%   (5) trial.(constrainedAnalysisName).body.generalizedCoordinates.(cs).acceleration

% also contains output from unconstrained inverse kinematics in
% trial.(unconstrainedAnalysisName).body

% unpack
unc = options.unconstrainedAnalysisName;
con = options.constrainedAnalysisName;
cs = options.coordinateSystem;

% num frames
nframes = trial.nMarkerFrames;

% unconstrained inverse kinematics as first estimate
trial = uncInverseKinematics(model,trial,struct('coordinateSystem',cs,'analysisName',unc,'lowPassCutoff',options.lowPassCutoff));

% convert model struct to generalized coordinates
% serves as initial guess
[q,qnames] = modelStruct2GeneralizedCoordinates(model,trial.(unc).body,cs);
optimization(nframes) = struct();
trial.(unc).body.generalizedCoordinates.(cs).position = q;
trial.(unc).body.generalizedCoordinateNames = qnames;

% start at first frame with no NaNs
hasnan = any(isnan(q));
firstFrame = find(~hasnan); 
firstFrame = firstFrame(1);
    
% start by assuming firstFrame is not first (due to NaNs)
% work backwards from firstFrame until finished frame 1
% then work forwards from firstFrame until finished last frame
% for each frame
frame = firstFrame-1;
direction = -1;
while frame <= nframes
    
    % forward or backwards
    if frame == 0
        direction = -direction;
        frame = firstFrame;
        q0 = q(:,firstFrame);
    else
        q0 = q(:,frame - direction);
    end
    
    % optimize
    opt = optimoptions('fmincon','Algorithm','interior-point','SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true,'CheckGradients',false,'ConstraintTolerance',1e-6,'Display','off','HessianFcn',@modelLagrangianHessian);
    [q(:,frame),fval,exitflag,output,lambda,grad] = fmincon(@modelObjectiveFunction,q0,[],[],[],[],[],[],@multibodySystemConstraints,opt,model,trial,frame,cs);
    optimization(frame).cost = fval;
    optimization(frame).exitflag = exitflag;
    optimization(frame).output = output;
    optimization(frame).lambda = lambda.eqnonlin;
    optimization(frame).objectiveGradient = grad;
    [~,~,objhess,errvec,errjac,~,W] = modelObjectiveFunction(q(:,frame),model,trial,frame,cs);
    optimization(frame).objectiveHessian = objhess;
    optimization(frame).objectiveErrorVector = errvec;
    optimization(frame).objectiveErrorVectorJacobian = errjac;
    optimization(frame).objectiveErrorVectorWeightMatrix = W;
    [~,ceq,~,ceq_grad,ceq_grad_jac] = multibodySystemConstraints(q(:,frame),model,trial,frame,cs);
    optimization(frame).constraints = ceq;
    optimization(frame).constraintGradient = ceq_grad;
    optimization(frame).constraintHessian = modelConstraintsHessian(lambda,ceq_grad_jac);
    
    % increment
    frame = frame + direction;
    
end

% convert generalized coordinates to body
trial.(con).body.generalizedCoordinates.(cs).position = q;
trial.(con).body.generalizedCoordinateNames = qnames;
trial.(con).body.optimization = optimization;

% generalized velocity
qdot = fdiff(q,1/trial.samplingFrequency,5);
qddot = fdiff(qdot,1/trial.samplingFrequency,5);
trial.(con).body.generalizedCoordinates.(cs).velocity = qdot;
trial.(con).body.generalizedCoordinates.(cs).acceleration = qddot;

end

function [hessian] = modelLagrangianHessian(x,lambda,model,trial,frame,cs)

% hessian function for use in fmincon

[~,~,objhess] = modelObjectiveFunction(x,model,trial,frame,cs);
[~,~,~,~,ceq_deriv2] = multibodySystemConstraints(x,model,trial,frame,cs);
conhess = modelConstraintsHessian(lambda,ceq_deriv2);
hessian = objhess + conhess;

end
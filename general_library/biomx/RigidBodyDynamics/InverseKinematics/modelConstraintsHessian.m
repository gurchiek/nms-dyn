function conhess = modelConstraintsHessian(lambda,ceq_jac2)
n = size(ceq_jac2,1);
conhess = zeros(n);
for i = 1:n
    for j = i:n
        conhess(i,j) = lambda.eqnonlin' * ceq_jac2(i,j).vec;
        if j ~= i; conhess(j,i) = conhess(i,j); end
    end
end
end
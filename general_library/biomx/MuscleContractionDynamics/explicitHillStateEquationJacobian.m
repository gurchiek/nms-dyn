function dvm_dlm = explicitHillStateEquationJacobian(t,lm,muscle,time,k)

% interpolate inputs
if isempty(k)
    lmtu = interp1(time,muscle.mtu.length,t,'pchip');
    a = interp1(time, muscle.activation,t,'pchip');
else
    lmtu = muscle.mtu.length(k);
    a = muscle.activation(k);
end

[~,dvm_dlm] = muscle.inverseForceVelocityFunction(lm,a,lmtu,muscle);

end
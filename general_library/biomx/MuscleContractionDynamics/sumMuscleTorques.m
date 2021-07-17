function body = sumMuscleTorques(body,muscles,dof)

% updates emg driven torques for each each joint dof specified in the
% the input cell array dof as per {'jointName1','dofName1'} by summing the
% contributing torques from each muscle in the input cell array muscles.
% EMG driven torque is stored as per:
% body.joint.(joints{i}).(dofs{k}).emdtorque

% example: to get torques for knee flexion and ankle flexion set:
% dof = {'knee','flexion'; 'ankle','flexion'};
% that is, each row corresponds to a unique dof where column 1 indicates
% the joint name and column 2 indicates the degree of freedom name

% contraction dynamics for each muscle in body.muscle.(muscles{m}) must 
% have already been simulated. Fields

% preallocation
n = length(body.muscle.(muscles{1}).torque.(dof{1,1}).(dof{1,2}));
for d =  1:size(dof,1)
    body.joint.(dof{d,1}).(dof{d,2}).emdtorque = zeros(1,n);
end
for m = 1:length(muscles)
    for d = 1:size(dof,1)
        body.joint.(dof{d,1}).(dof{d,2}).emdtorque = body.joint.(dof{d,1}).(dof{d,2}).emdtorque + body.muscle.(muscles{m}).torque.(dof{d,1}).(dof{d,2});
    end
end
function index = modelJoint2Index(model,joint)
index = model.Indices(strcmp(joint,model.jointNames));
end
function joint = modelIndex2Joint(model,index)
joint = model.jointNames{model.jointIndices == index};
end
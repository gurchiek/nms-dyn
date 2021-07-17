function alpha = patellarLigamentAngle(flexion)

% data from fig 3 in van Eijden et al. (1985)
% see vanEijden1985_imageProcesser and
% vanEijden85_patellarLigamentMechanicsData.mat
y = [20.6161   19.1943   15.8768   13.7441   11.6114    8.2938    4.9763    1.8957   -1.8957   -6.6351   -9.7156  -13.7441  -17.2986];
x = 0:10:120;
alpha = interp1(x,y,flexion,'linear','extrap');

end
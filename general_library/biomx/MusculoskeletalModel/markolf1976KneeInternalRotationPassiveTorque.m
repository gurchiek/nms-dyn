function t = markolf1976KneeInternalRotationPassiveTorque(i)

% a cubic approximation to the torque angle relationship for internal
% rotation of the knee from fig. 6 of Markolf et al. 1976 "Stiffness and
% laxity of the knee - the contributions of the supporting structures".
% based on 35 cadaver knees. 

% input i - internal rotation in radians

% output t - internal rotation torque in Nm

% assumes a positive value of i is an internal rotation angle for which t
% will be negative (which means as the tibia internally rotates, ligaments
% resist this motion, acting to torque the knee in the external rotation
% direction)

% data points used to fit the cubic from fig. 6
% x = [0,2,4,6,8,11,12.5,14,15,16]*pi/180; % internal rotation angles
% y = -[0,0.05,0.2,0.5,1,2,3,4.5,6,8]; % torque in Nm
% p = polyfit(x,y,6);
% scatter(x*180/pi,y)
% hold on
% plot(0:0.5:16,polyval(p,(0:0.5:16)*pi/180))

p = [6.894534903960539  -7.232883134444033   2.397380905092140  -0.346272538276930   0.016478705672860  -0.000393466610768   0.000000013893491]*1e4;

t = polyval(p,i);


end
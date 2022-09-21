% compare walker, rajagopal, laiArnold knees

clear
clc

% knee angle
fd = 0:160;
f = fd * pi / 180;

% walker, assuming eqs were expressed in tibia frame and thus are rotated
% (by Rj) to express in thigh frame
[aw,iw,yw,xw,zw,~,~,~,~,~,Rj] = walkerKnee(f,1);

% rajagopal spline (will show this is the original, unrotated walker eqs
% with an offset)
[ar,ir,yr,xr,zr] = rajagopalKnee(f);

% lai arnold spline (will more closesly align with walker knee above,
% they simply rotated rajagopal's translation using the joint rotation
% matrix
[al,il,yl,xl,zl] = laiarnoldKnee(f);

% rajagopal spline then rotated to femur using joint rotation matrix (this
% aligns perfectly with lai arnold showing this is how they generated their
% spline
[arr,irr,yrr,xrr,zrr] = rotatedRajagopalKnee(f);

% rotate walker translations back to tibia, this will be nearly aligned
% with rajagopal knee showing this is how they generated their spline
% (original, unrotated walker eqs)
r = [xw;yw;zw];
rtibia = dcmrot(Rj,r,'inverse');

% 2392
[yd,xd,zd] = delpKnee(f);

% plot
fig = figure;
fig.Position = [904 700 335 259];

sp = subplot(3,1,1);
plot(fd, 1000 * xw,'k')
hold on
plot(fd, 1000 * xr,'b')
plot(fd, 1000 * xrr,'g')
plot(fd, 1000 * rtibia(1,:),'m')
plot(fd, 1000 * xl,'r--')
plot(fd, 1000 * xd,'c')
sp.Box = 'off';

sp = subplot(3,1,2);
plot(fd, 1000 * yw,'k')
hold on
plot(fd, 1000 * yr,'b')
plot(fd, 1000 * yrr,'g')
plot(fd, 1000 * rtibia(2,:),'m')
plot(fd, 1000 * yl,'r--')
plot(fd, 1000 * yd,'c')
sp.Box = 'off';

sp = subplot(3,1,3);
plot(fd, 1000 * zw,'k')
hold on
plot(fd, 1000 * zr,'b')
plot(fd, 1000 * zrr,'g')
plot(fd, 1000 * rtibia(3,:),'m')
plot(fd, 1000 * zl,'r--')
plot(fd, 1000 * zd,'c')
sp.Box = 'off';

% labels
subplot(3,1,1)
title('Knee Joint Translation Models')
ylabel('X [mm]')
subplot(3,1,2)
ylabel('Y [mm]')
subplot(3,1,3)
ylabel('Z [mm]')
xlabel('Knee Flexion (\circ)')
leg = legend('walker-original','rajagopal-original','rajagopal-rotated','walker-rotated','laiArnold','2392-zeroed');
leg.Box = 'off';
leg.Location = 'southwest';


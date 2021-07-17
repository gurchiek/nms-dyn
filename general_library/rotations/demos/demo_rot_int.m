%% demo_rot_int
% demos different rotator integration methods:
% (1) rectezoidal: r_next = r_now + dt * r_dot
%       where r_dot is based on w_now or mean(w_now,w_next) (midpoint)
% (2) exp: r_next = expm(A*dt) * r_now where r_dot = A * r_now
%       only valid for direction cosines and quaternions
% (3) ode45: runge kutta
%
% data (rot_int_vars.mat) includes quaternions (q), body fixed angular rate
% (w), and time for S0040 Force Plate Walk 1 shank segment and q was
% computed using constrained inverse kinematics (hinge knee, universal
% ankle, ball hip, non-dislocating joints)
%
% q is s.t. v_world = q * v_body * q_conj
% w was determined by differentiating q using 5-point central difference
% and smoothed

clear
close all
clc

% load 
load('rot_int_vars.mat')
n = size(q,2);

% euler sequence
seq = 'xzy';

% euler angles
e = convq(q,seq);
edeg = e*180/pi;

% ode45 options
options = odeset('RelTol',1e-6);

% angular rate in world frame
w_w = qrot(q,w);

% quaternion s.t. v_body = q * v_world * q_conj
q_w = qconj(q);

% inital/end quaternions
qi = q(:,1);
qf = q(:,end);
qi_w = q_w(:,1);
qf_w = q_w(:,end);

%% quaternion rectezoidal forward vs backward + zoh vs midpoint

% quaternion, b2w, inbody, zoh, forward
tic;
qrectf = intqrect(qi,w,t,1,1,0,1);
trectf = toc;

% quaternion, b2w, inbody, midpoint, forward
tic;
qtrpf = intqrect(qi,w,t,1,1,1,1);
ttrpf = toc;

% quaternion, b2w, inbody, midpoint, backward
tic;
qtrpb = intqrect(qi,w,t,1,1,1,0);
ttrpb = toc;

% midpint approximation
tic;
qmidf = intqmid(qi,w,t,1,1,1);
tmidf = toc;

% exp
tic;
qexpf = intqexp(qi,w,t,1,1,1,1);
texpf = toc;

% RK
tic;
q45f = intqode45(qi,w,t,1,1,1,options);
t45f = toc;

% compare
figure
subplot(4,2,1)
plot(q(1,:),'k')
hold on
plot(qrectf(1,:),'Color',softred)
plot(qtrpf(1,:),'Color',softblue)
plot(qtrpb(1,:),'Color',softpurple)
plot(qmidf(1,:),'Color',softgreen)
plot(qexpf(1,:),'Color',softlightblue)
plot(q45f(1,:),'Color',softorange)
ylabel('qx')
subplot(4,2,2)
hold on
plot(qrectf(1,:)-q(1,:),'Color',softred)
plot(qtrpf(1,:)-q(1,:),'Color',softblue)
plot(qtrpb(1,:)-q(1,:),'Color',softpurple)
plot(qmidf(1,:)-q(1,:),'Color',softgreen)
plot(qexpf(1,:)-q(1,:),'Color',softlightblue)
plot(q45f(1,:)-q(1,:),'Color',softorange)
ylabel('errors')
legend('rect-zoh-forward','rect-midpoint-forward','rect-midpoint-backward','midpoint-approx-forward','expm-forward','runge-kutta')

subplot(4,2,3)
plot(q(2,:),'k')
hold on
plot(qrectf(2,:),'Color',softred)
plot(qtrpf(2,:),'Color',softblue)
plot(qtrpb(2,:),'Color',softpurple)
plot(qmidf(2,:),'Color',softgreen)
plot(qexpf(2,:),'Color',softlightblue)
plot(q45f(2,:),'Color',softorange)
ylabel('qy')
subplot(4,2,4)
hold on
plot(qrectf(2,:)-q(2,:),'Color',softred)
plot(qtrpf(2,:)-q(2,:),'Color',softblue)
plot(qtrpb(2,:)-q(2,:),'Color',softpurple)
plot(qmidf(2,:)-q(2,:),'Color',softgreen)
plot(qexpf(2,:)-q(2,:),'Color',softlightblue)
plot(q45f(2,:)-q(2,:),'Color',softorange)
ylabel('errors')

subplot(4,2,5)
plot(q(3,:),'k')
hold on
plot(qrectf(3,:),'Color',softred)
plot(qtrpf(3,:),'Color',softblue)
plot(qtrpb(3,:),'Color',softpurple)
plot(qmidf(3,:),'Color',softgreen)
plot(qexpf(3,:),'Color',softlightblue)
plot(q45f(3,:),'Color',softorange)
ylabel('qz')
subplot(4,2,6)
hold on
plot(qrectf(3,:)-q(3,:),'Color',softred)
plot(qtrpf(3,:)-q(3,:),'Color',softblue)
plot(qtrpb(3,:)-q(3,:),'Color',softpurple)
plot(qmidf(3,:)-q(3,:),'Color',softgreen)
plot(qexpf(3,:)-q(3,:),'Color',softlightblue)
plot(q45f(3,:)-q(3,:),'Color',softorange)
ylabel('errors')

subplot(4,2,7)
plot(q(4,:),'k')
hold on
plot(qrectf(4,:),'Color',softred)
plot(qtrpf(4,:),'Color',softblue)
plot(qtrpb(4,:),'Color',softpurple)
plot(qmidf(4,:),'Color',softgreen)
plot(qexpf(4,:),'Color',softlightblue)
plot(q45f(4,:),'Color',softorange)
ylabel('qw')
subplot(4,2,8)
hold on
plot(qrectf(4,:)-q(4,:),'Color',softred)
plot(qtrpf(4,:)-q(4,:),'Color',softblue)
plot(qtrpb(4,:)-q(4,:),'Color',softpurple)
plot(qmidf(4,:)-q(4,:),'Color',softgreen)
plot(qexpf(4,:)-q(4,:),'Color',softlightblue)
plot(q45f(4,:)-q(4,:),'Color',softorange)
ylabel('errors')

type = {'rect-zoh-forward','rect-midpoint-forward','midpoint-approx-forward','expm-forward','runge-kutta'};
comptimes = [trectf ttrpf tmidf texpf t45f];
err = [rms(qrectf-q,2),...
       rms(qtrpf-q,2),...
       rms(qmidf-q,2),...
       rms(qexpf-q,2),...
       rms(q45f-q,2)];
   
[ct,i] = sort(comptimes,'ascend');
fprintf('Computational Times: Quaternion Integrators (%d samples)\n',n)
for k = 1:length(i)
    fprintf('     (%d) %s: time = %4.2f ms\n',k,type{i(k)},ct(k)*1000)
end

figure
subplot(1,5,1)
bar(reordercats(categorical(type(i)),type(i)),ct*1000)
title('Efficiency')
ylabel('Computation Time (ms)')
dirs = {'x','y','z','w'};
for k = 1:4
    subplot(1,5,k+1)
    [errsorted,i] = sort(err(k,:),'ascend');
    bar(reordercats(categorical(type(i)),type(i)),errsorted)
    title(['q' dirs{k}])
    ylabel('Error')
end
    

%% compare forward rect, exp, ode45

% q
qtrp = intqrect(qi,w,t,1,1,1,1);
qexp = intqexp(qi,w,t,1,1,1,1);
q45 = intqode45(qi,w,t,1,1,1,options);
qmid = intqmid(qi,w,t,1,1,1);

eqtrp = convq(qtrp,seq) * 180/pi;
eqexp = convq(qexp,seq) * 180/pi;
eq45 = convq(q45,seq) * 180/pi;
eqmid = convq(qmid,seq) * 180/pi;

% dcm (r)
dcmi = convq(qi,'dcm');
dci = dcm2dc(dcmi);
dcexp = intdcexp(dci,w,t,1,1,1,1);
rtrp = intdcmrect(dcmi,w,t,1,1,1,1);
r45 = intdcmode45(dcmi,w,t,1,1,1,options);
rmid = intdcmmid(dcmi,w,t,1,1,1);
dcmid = intdcmid(dci,w,t,1,1,1);

edcexp = convdcm(dc2dcm(dcexp),seq) * 180/pi;
ertrp = convdcm(rtrp,seq) * 180/pi;
er45 = convdcm(r45,seq) * 180/pi;
ermid = convdcm(rmid,seq) * 180/pi;
edcmid = convdcm(dc2dcm(dcmid),seq) * 180/pi;

% euler angles
ei = e(:,1);
etrp = inteulerrect(ei,seq,w,t,1,1,1,1) * 180/pi;
e45 = inteulerode45(ei,seq,w,t,1,1,1,options) * 180/pi;

% compare
figure
subplot(3,2,1)
plot(edeg(1,:),'Color',softblack)
hold on
plot(eqtrp(1,:),'Color','k')
plot(eqexp(1,:),'Color','r')
plot(eq45(1,:),'Color','b')
plot(eqmid(1,:),'Color','c')
plot(ertrp(1,:),'Color',softred)
plot(edcexp(1,:),'Color',softblue)
plot(er45(1,:),'Color',softgreen)
plot(ermid(1,:),'Color','m')
plot(edcmid(1,:),'Color',softorange)
plot(etrp(1,:),'Color',softpurple)
plot(e45(1,:),'Color',softlightblue)
ylabel('Roll (degrees)')
subplot(3,2,2)
hold on
plot(eqtrp(1,:)-edeg(1,:),'Color','k')
plot(eqexp(1,:)-edeg(1,:),'Color','r')
plot(eq45(1,:)-edeg(1,:),'Color','b')
plot(eqmid(1,:)-edeg(1,:),'Color','c')
plot(ertrp(1,:)-edeg(1,:),'Color',softred)
plot(edcexp(1,:)-edeg(1,:),'Color',softblue)
plot(er45(1,:)-edeg(1,:),'Color',softgreen)
plot(ermid(1,:)-edeg(1,:),'Color','m')
plot(edcmid(1,:)-edeg(1,:),'Color',softorange)
plot(etrp(1,:)-edeg(1,:),'Color',softpurple)
plot(e45(1,:)-edeg(1,:),'Color',softlightblue)
ylabel('Error (int - true)')
legend('q-trap','q-exp','q-RK','q-mid','dcm-trap','dc-exp','dcm-RK','dcm-mid','dc-mid','euler-trap','euler-RK')

subplot(3,2,3)
plot(edeg(2,:),'Color',softblack)
hold on
plot(eqtrp(2,:),'Color','k')
plot(eqexp(2,:),'Color','r')
plot(eq45(2,:),'Color','b')
plot(eqmid(2,:),'Color','c')
plot(ertrp(2,:),'Color',softred)
plot(edcexp(2,:),'Color',softblue)
plot(er45(2,:),'Color',softgreen)
plot(ermid(2,:),'Color','m')
plot(edcmid(2,:),'Color',softorange)
plot(etrp(2,:),'Color',softpurple)
plot(e45(2,:),'Color',softlightblue)
ylabel('Pitch (degrees)')
subplot(3,2,4)
hold on
plot(eqtrp(2,:)-edeg(2,:),'Color','k')
plot(eqexp(2,:)-edeg(2,:),'Color','r')
plot(eq45(2,:)-edeg(2,:),'Color','b')
plot(eqmid(2,:)-edeg(2,:),'Color','c')
plot(ertrp(2,:)-edeg(2,:),'Color',softred)
plot(edcexp(2,:)-edeg(2,:),'Color',softblue)
plot(er45(2,:)-edeg(2,:),'Color',softgreen)
plot(ermid(2,:)-edeg(2,:),'Color','m')
plot(edcmid(2,:)-edeg(2,:),'Color',softorange)
plot(etrp(2,:)-edeg(2,:),'Color',softpurple)
plot(e45(2,:)-edeg(2,:),'Color',softlightblue)
ylabel('Error (int - true)')

subplot(3,2,5)
plot(edeg(3,:),'Color',softblack)
hold on
plot(eqtrp(3,:),'Color','k')
plot(eqexp(3,:),'Color','r')
plot(eq45(3,:),'Color','b')
plot(eqmid(3,:),'Color','c')
plot(ertrp(3,:),'Color',softred)
plot(edcexp(3,:),'Color',softblue)
plot(er45(3,:),'Color',softgreen)
plot(ermid(3,:),'Color','m')
plot(edcmid(3,:),'Color',softorange)
plot(etrp(3,:),'Color',softpurple)
plot(e45(3,:),'Color',softlightblue)
ylabel('Yaw (degrees)')
subplot(3,2,6)
hold on
plot(eqtrp(3,:)-edeg(3,:),'Color','k')
plot(eqexp(3,:)-edeg(3,:),'Color','r')
plot(eq45(3,:)-edeg(3,:),'Color','b')
plot(eqmid(3,:)-edeg(3,:),'Color','c')
plot(ertrp(3,:)-edeg(3,:),'Color',softred)
plot(edcexp(3,:)-edeg(3,:),'Color',softblue)
plot(er45(3,:)-edeg(3,:),'Color',softgreen)
plot(ermid(3,:)-edeg(3,:),'Color','m')
plot(edcmid(3,:)-edeg(3,:),'Color',softorange)
plot(etrp(3,:)-edeg(3,:),'Color',softpurple)
plot(e45(3,:)-edeg(3,:),'Color',softlightblue)
ylabel('Error (int - true)')

% stats
type = {'q-trap','q-exp','q-RK','q-mid','dcm-trap','dc-exp','dcm-RK','dcm-mid','dc-mid','euler-trap','euler-RK'};
rmse = [rms(eqtrp-edeg,2),...
        rms(eqexp-edeg,2),...
        rms(eq45-edeg,2),...
        rms(eqmid-edeg,2),...
        rms(ertrp-edeg,2),...
        rms(edcexp-edeg,2),...
        rms(er45-edeg,2),...
        rms(ermid-edeg,2),...
        rms(edcmid-edeg,2),...
        rms(etrp-edeg,2),...
        rms(e45-edeg,2)];
    
% roll
fprintf('\nDOF: Roll\n')
[err,i] = sort(rmse(1,:),'ascend');
figure
bar(reordercats(categorical(type(i)),type(i)),err)
ylabel('RMSE (degrees)')
title('Roll')
for k = 1:length(i)
    fprintf('     (%d) %s: RMSE = %3.2f degrees\n',k,type{i(k)},err(k))
end
fprintf('\n')

% pitch
fprintf('\nDOF: Pitch\n')
[err,i] = sort(rmse(2,:),'ascend');
figure
bar(reordercats(categorical(type(i)),type(i)),err)
ylabel('RMSE (degrees)')
title('Pitch')
for k = 1:length(i)
    fprintf('     (%d) %s: RMSE = %3.2f degrees\n',k,type{i(k)},err(k))
end
fprintf('\n')

% yaw
fprintf('\nDOF: Yaw\n')
[err,i] = sort(rmse(3,:),'ascend');
figure
bar(reordercats(categorical(type(i)),type(i)),err)
ylabel('RMSE (degrees)')
title('Yaw')
for k = 1:length(i)
    fprintf('     (%d) %s: RMSE = %3.2f degrees\n',k,type{i(k)},err(k))
end
fprintf('\n')



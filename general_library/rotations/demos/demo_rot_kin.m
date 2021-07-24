

% demo script

% demos differentiation of multiple parametrizations and mapping to
% cartesian velocities (through jacobians)

clear; close all; clc

% set sequence for all euler angle decompositions here
seq = 'yzx';

% time to pause for looking at figures
global tpause;
tpause = 1;

% load vars
load('rot_kin_vars.mat','q','t');

%% get different parametrizations and angular rates

% convert to dcm, dc, and euler angles
dcm = convq(q,'dcm');
dc = dcm2dc(dcm);
e = convq(q,seq);

% differentiate and get angular rate
[~,wbd] = diffdcm(dcm,1,t,5);
[~,wbe] = diffeuler(e,seq,1,t,5);
[~,wbq] = diffq(q,1,t,5);

% will show all are same, pick one as true
wb = wbd;

% rotate wb to world frame
wwd = dcmrot(dcm,wb);
wwq = qrot(q,wb);
wwe = eulerot(e,seq,wb);

% will show all are same, pick one as true
ww = wwd;

%% diff_ and _rot test

questdlg('Show the body frame ang rate is same for all diff_ fxns','diff_ test','ok','ok');

% compare
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(wbd(k,:))
    hold on
    plot(wbe(k,:),'r--')
    plot(wbq(k,:),'b.')
end
legend('w body dcm','w body euler','w body q')
pause(tpause); close (f);

questdlg('Show the world frame ang rate is same using any rotator (_rot fxns)','_rot test','ok','ok');

% compare
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(wwd(k,:))
    hold on
    plot(wwe(k,:),'r--')
    plot(wwq(k,:),'b.')
end
legend('w world dcm from dcmrot','w world euler from eulerot','w world q from qrot')
pause(tpause); close (f);

%% _jac tests

% _jac fxns map generalized to cartesian velocities
% first use body to world rotators and jacobian so that generalized
% velocities are mapped to cartesian (inverse jacobian flag does opposite)

%% case 1

b2w = 1; % body to world
inbody = 0; % w in world
invertJ = 0; % gen to cartesian

% test
jactest(ww,wb,q,dcm,e,seq,t,b2w,inbody,invertJ,1)

%% case 2

b2w = 1; % body to world
inbody = 1; % w in body
invertJ = 0; % gen to cartesian

% test
jactest(ww,wb,q,dcm,e,seq,t,b2w,inbody,invertJ,2)

%% case 3

b2w = 1; % body to world
inbody = 1; % w in body
invertJ = 1; % cartesian to gen

% test
jactest(ww,wb,q,dcm,e,seq,t,b2w,inbody,invertJ,3)

%% case 4

b2w = 1; % body to world
inbody = 0; % w in world
invertJ = 1; % cartesian to gen

% test
jactest(ww,wb,q,dcm,e,seq,t,b2w,inbody,invertJ,4)

%% case 5

b2w = 0; % world to body
inbody = 0; % w in world
invertJ = 0; % gen to cartesian

% test
jactest(ww,wb,qconj(q),invdcm(dcm),inveuler(e,seq),flip(seq),t,b2w,inbody,invertJ,5)

%% case 6

b2w = 0; % world to body
inbody = 0; % w in world
invertJ = 0; % gen to cartesian

% test
jactest(ww,wb,qconj(q),invdcm(dcm),inveuler(e,seq),flip(seq),t,b2w,inbody,invertJ,6)

%% case 7

b2w = 0; % world to body
inbody = 1; % w in body
invertJ = 1; % cartesian to gen

% test
jactest(ww,wb,qconj(q),invdcm(dcm),inveuler(e,seq),flip(seq),t,b2w,inbody,invertJ,7)

%% case 8

b2w = 0; % world to body
inbody = 0; % w in world
invertJ = 1; % cartesian to gen

% test
jactest(ww,wb,qconj(q),invdcm(dcm),inveuler(e,seq),flip(seq),t,b2w,inbody,invertJ,8)


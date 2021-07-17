%% demo_rot_kin

clear
close all
clc

seq = 'yzx';

%%

% load vars
load('rot_kin_vars.mat')

% plot noisy quaternions
f = figure;
plot(q(1,:),'k')
hold on
plot(q(2,:),'k')
plot(q(3,:),'k')
plot(q(4,:),'k')

% convert to euler, smooth, convert back
e = convq(q,'yzx');
ef = bwfilt(e,6,100,'low',4);
q = conveuler(ef,'yzx','q');

% compare
plot(q(1,:),'r-')
hold on
plot(q(2,:),'r-')
plot(q(3,:),'r-')
plot(q(4,:),'r-')

waitfor(f)

%% 

% convert
dcm = convq(q,'dcm');
dc = dcm2dc(dcm);
e = convq(q,seq);

% get w
[~,wbd,~,dcdot] = diffdcm(dcm,1,t,5);
[edot,wbe] = diffeuler(e,seq,1,t,5);
[qdot,wbq] = diffq(q,1,t,5);

ok = questdlg('Next shows the body frame ang rate is same for all diff_ fxns','diff_ test','ok','ok');

% compare
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(wbd(k,:))
    hold on
    plot(wbe(k,:))
    plot(wbq(k,:),'k')
end
legend('w body dcm','w body euler','w body q')
waitfor(f)

% all are same, now pick one as true
wb = wbd;

% rotate wb to world frame
wwd = dcmrot(dcm,wb);
wwq = qrot(q,wb);
wwe = eulerot(e,seq,wb);

ok = questdlg('Next shows the world frame ang rate is same using any rotator (_rot fxns)','_rot test','ok','ok');

% compare
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(wwd(k,:))
    hold on
    plot(wwe(k,:))
    plot(wwq(k,:),'k')
end
legend('w world dcm','w world euler','w world q')
waitfor(f)

% all are same, now pick one as true
ww = wwd;

%% test all jacobian matrices (and inverses) for b2w rotators

b2w = 1;
n = size(ww,2);

%% case 1: rotator is b2w, deriv to ww

inbody = 0;
invertJ = 0;

Jq = qjac(q,b2w,inbody,invertJ);
Jd = dcjac(dc,b2w,inbody,invertJ);
Je = eulerjac(e,seq,b2w,inbody,invertJ);

wwq = zeros(3,n);
wwd = wwq;
wwe = wwq;
for k = 1:n
    wwq(:,k) = Jq(:,:,k) * qdot(:,k);
    wwd(:,k) = Jd(:,:,k) * dcdot(:,k);
    wwe(:,k) = Je(:,:,k) * edot(:,k);
end

ok = questdlg('Case 1, quaternion: b2w, deriv to world','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwq(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 1, direction cosines: b2w, deriv to world','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwd(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 1, euler angles: b2w, deriv to world','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwe(k,:),'r--')
end
waitfor(f)

%% case 2: rotator is b2w, deriv to wb

inbody = 1;
invertJ = 0;

Jq = qjac(q,b2w,inbody,invertJ);
Jd = dcjac(dc,b2w,inbody,invertJ);
Je = eulerjac(e,seq,b2w,inbody,invertJ);

ok = questdlg('Case 2, quaternion: b2w, deriv to body','jacobian test','ok','ok');

wbq = zeros(3,n);
wbd = wbq;
wbe = wbq;
for k = 1:n
    wbq(:,k) = Jq(:,:,k) * qdot(:,k);
    wbd(:,k) = Jd(:,:,k) * dcdot(:,k);
    wbe(:,k) = Je(:,:,k) * edot(:,k);
end

% compare quaternion
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbq(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 2, direction cosines: b2w, deriv to body','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbd(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 2, euler angles: b2w, deriv to body','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbe(k,:),'r--')
end
waitfor(f)

%% case 3: rotator is b2w, wb to deriv

inbody = 1;
invertJ = 1;

Jq = qjac(q,b2w,inbody,invertJ);
Jd = dcjac(dc,b2w,inbody,invertJ);
Je = eulerjac(e,seq,b2w,inbody,invertJ);

qdotj = zeros(4,n);
dcdotj = zeros(9,n);
edotj = zeros(3,n);
for k = 1:n
    qdotj(:,k) = Jq(:,:,k) * wb(:,k);
    dcdotj(:,k) = Jd(:,:,k) * wb(:,k);
    edotj(:,k) = Je(:,:,k) * wb(:,k);
end

ok = questdlg('Case 3, quaternion: b2w, body to deriv','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:4
    subplot(4,1,k)
    plot(qdot(k,:),'k')
    hold on
    plot(qdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 3, direction cosines: b2w, body to deriv','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:9
    subplot(3,3,k)
    plot(dcdot(k,:),'k')
    hold on
    plot(dcdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 3, euler angles: b2w, body to deriv','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(edot(k,:),'k')
    hold on
    plot(edotj(k,:),'r--')
end
waitfor(f)

%% case 4: rotator is b2w, ww to deriv

inbody = 0;
invertJ = 1;

Jq = qjac(q,b2w,inbody,invertJ);
Jd = dcjac(dc,b2w,inbody,invertJ);
Je = eulerjac(e,seq,b2w,inbody,invertJ);

qdotj = zeros(4,n);
dcdotj = zeros(9,n);
edotj = zeros(3,n);
for k = 1:n
    qdotj(:,k) = Jq(:,:,k) * ww(:,k);
    dcdotj(:,k) = Jd(:,:,k) * ww(:,k);
    edotj(:,k) = Je(:,:,k) * ww(:,k);
end

ok = questdlg('Case 4, quaternion: b2w, world to deriv','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:4
    subplot(4,1,k)
    plot(qdot(k,:),'k')
    hold on
    plot(qdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 4, direction cosines: b2w, world to deriv','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:9
    subplot(3,3,k)
    plot(dcdot(k,:),'k')
    hold on
    plot(dcdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 4, euler angles: b2w, world to deriv','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(edot(k,:),'k')
    hold on
    plot(edotj(k,:),'r--')
end
waitfor(f)

%% test all jacobian matrices (and inverses) for w2b rotators

b2w = 0;

% invert rotators
q_ = qconj(q);
dcm_ = invdcm(dcm);
dc_ = invdc(dc);
[e_,seq_] = inveuler(e,seq);

% get derivs
qdot_ = diffq(q_,b2w,t,5);
[~,~,~,dcdot_] = diffdcm(dcm_,b2w,t,5);
edot_ = diffeuler(e_,seq_,b2w,t,5);

%% case 5: rotator is w2b, deriv to ww

inbody = 0;
invertJ = 0;

Jq = qjac(q_,b2w,inbody,invertJ);
Jd = dcjac(dc_,b2w,inbody,invertJ);
Je = eulerjac(e_,seq_,b2w,inbody,invertJ);

wwq = zeros(3,n);
wwd = wwq;
wwe = wwq;
for k = 1:n
    wwq(:,k) = Jq(:,:,k) * qdot_(:,k);
    wwd(:,k) = Jd(:,:,k) * dcdot_(:,k);
    wwe(:,k) = Je(:,:,k) * edot_(:,k);
end

ok = questdlg('Case 5, quaternion: w2b, deriv to world','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwq(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 5, direction cosines: w2b, deriv to world','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwd(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 5, euler angles: w2b, deriv to world','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(ww(k,:),'k')
    plot(wwe(k,:),'r--')
end
waitfor(f)

%% case 6: rotator is w2b, deriv to wb

inbody = 1;
invertJ = 0;

Jq = qjac(q_,b2w,inbody,invertJ);
Jd = dcjac(dc_,b2w,inbody,invertJ);
Je = eulerjac(e_,seq_,b2w,inbody,invertJ);

wbq = zeros(3,n);
wbd = wbq;
wbe = wbq;
for k = 1:n
    wbq(:,k) = Jq(:,:,k) * qdot_(:,k);
    wbd(:,k) = Jd(:,:,k) * dcdot_(:,k);
    wbe(:,k) = Je(:,:,k) * edot_(:,k);
end

ok = questdlg('Case 6, quaternion: w2b, deriv to body','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbq(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 6, direction cosines: w2b, deriv to body','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbd(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 6, euler angles: w2b, deriv to body','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    hold on
    plot(wb(k,:),'k')
    plot(wbe(k,:),'r--')
end
waitfor(f)

%% case 7: rotator is w2b, wb to deriv

inbody = 1;
invertJ = 1;

Jq = qjac(q_,b2w,inbody,invertJ);
Jd = dcjac(dc_,b2w,inbody,invertJ);
Je = eulerjac(e_,seq_,b2w,inbody,invertJ);

qdotj = zeros(4,n);
dcdotj = zeros(9,n);
edotj = zeros(3,n);
for k = 1:n
    qdotj(:,k) = Jq(:,:,k) * wb(:,k);
    dcdotj(:,k) = Jd(:,:,k) * wb(:,k);
    edotj(:,k) = Je(:,:,k) * wb(:,k);
end

ok = questdlg('Case 7, quaternion: w2b, body to deriv','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:4
    subplot(4,1,k)
    plot(qdot_(k,:),'k')
    hold on
    plot(qdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 7, direction cosines: w2b, body to deriv','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:9
    subplot(3,3,k)
    plot(dcdot_(k,:),'k')
    hold on
    plot(dcdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 7, euler angles: w2b, body to deriv','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(edot_(k,:),'k')
    hold on
    plot(edotj(k,:),'r--')
end
waitfor(f)

%% case 8: rotator is w2b, ww to deriv

inbody = 0;
invertJ = 1;

Jq = qjac(q_,b2w,inbody,invertJ);
Jd = dcjac(dc_,b2w,inbody,invertJ);
Je = eulerjac(e_,seq_,b2w,inbody,invertJ);

qdotj = zeros(4,n);
dcdotj = zeros(9,n);
edotj = zeros(3,n);
for k = 1:n
    qdotj(:,k) = Jq(:,:,k) * ww(:,k);
    dcdotj(:,k) = Jd(:,:,k) * ww(:,k);
    edotj(:,k) = Je(:,:,k) * ww(:,k);
end

ok = questdlg('Case 8, quaternion: w2b, world to deriv','jacobian test','ok','ok');

% compare quaternion
f = figure;
for k = 1:4
    subplot(4,1,k)
    plot(qdot_(k,:),'k')
    hold on
    plot(qdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 8, direction cosines: w2b, world to deriv','jacobian test','ok','ok');

% compare dc
f = figure;
for k = 1:9
    subplot(3,3,k)
    plot(dcdot_(k,:),'k')
    hold on
    plot(dcdotj(k,:),'r--')
end
waitfor(f)

ok = questdlg('Case 8, euler angles: w2b, world to deriv','jacobian test','ok','ok');

% compare euler
f = figure;
for k = 1:3
    subplot(3,1,k)
    plot(edot_(k,:),'k')
    hold on
    plot(edotj(k,:),'r--')
end
waitfor(f)

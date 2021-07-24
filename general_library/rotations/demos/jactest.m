function [] = jactest(ww,wb,q,dcm,e,seq,t,b2w,inbody,invertJ,caseno)

% function used in demo_rot_kin

global tpause;

% reporting
sb2w = 'body-to-world';
if ~b2w; sb2w = 'world-to-body'; end
sinbody = 'cartesian in body';
w = wb;
if ~inbody; sinbody = 'cartesian in world'; w = ww; end
sinvertJ = ['generalized velocity to ', sinbody];
if invertJ; sinvertJ = [sinbody, ' to generalized velocity']; end

% differentiate
n = length(t);
dc = dcm2dc(dcm);
[~,~,~,dcdot] = diffdcm(dcm,b2w,t,5);
edot = diffeuler(e,seq,b2w,t,5);
qdot = diffq(q,b2w,t,5);

% get jacobians
Jq = qjac(q,b2w,inbody,invertJ);
Jd = dcjac(dc,b2w,inbody,invertJ);
Je = eulerjac(e,seq,b2w,inbody,invertJ);

% map to cartesian
if ~invertJ
    
    xq = zeros(3,n);
    xd = xq;
    xe = xq;
    for k = 1:n
        xq(:,k) = Jq(:,:,k) * qdot(:,k);
        xd(:,k) = Jd(:,:,k) * dcdot(:,k);
        xe(:,k) = Je(:,:,k) * edot(:,k);
    end
    
    xqtrue = w;
    xdtrue = w;
    xetrue = w;

% map to gen vel
elseif invertJ
    
    xq = zeros(4,n);
    xd = zeros(9,n);
    xe = zeros(3,n);
    for k = 1:n
        xq(:,k) = Jq(:,:,k) * w(:,k);
        xd(:,k) = Jd(:,:,k) * w(:,k);
        xe(:,k) = Je(:,:,k) * w(:,k);
    end
    
    xqtrue = qdot;
    xdtrue = dcdot;
    xetrue = edot;
    
end

% compare quaternion
questdlg(['Case ', num2str(caseno),': quaternion: ', sb2w, ', ' sinvertJ],'_jac test','ok','ok');
f = figure;
for k = 1:size(xqtrue,1)
    subplot(size(xqtrue,1),1,k)
    hold on
    plot(xqtrue(k,:),'k')
    plot(xq(k,:),'r--')
    if k == 1
        legend('true','est')
    end
    title(['Case ' num2str(caseno) ': quaternion'])
end
pause(tpause); close(f);

% compare dc
questdlg(['Case ', num2str(caseno),': direction cosines: ', sb2w, ', ' sinvertJ],'_jac test','ok','ok');
f = figure;
for k = 1:size(xdtrue,1)
    nc = 1;
    if size(xdtrue,1) == 9; nc = 3; end
    subplot(3,nc,k)
    hold on
    plot(xdtrue(k,:),'k')
    plot(xd(k,:),'r--')
    if k == 1
        legend('true','est')
    end
    title(['Case ' num2str(caseno) ': direction cosines'])
end
pause(tpause); close(f);

% compare euler
questdlg(['Case ', num2str(caseno),': euler angles (', seq, '): ', sb2w, ', ' sinvertJ],'_jac test','ok','ok');
f = figure;
for k = 1:size(xetrue,1)
    subplot(size(xetrue,1),1,k)
    hold on
    plot(xetrue(k,:),'k')
    plot(xe(k,:),'r--')
    if k == 1
        legend('true','est')
    end
    title(['Case ' num2str(caseno) ': euler angles'])
end
pause(tpause); close(f);

end
function [fig] = plotBody(model,body,frame,options)

% option fields: markers, muscles, segments, joints, currentAxesView,
% transfer matrix, showFibers

defshowfibers = false;
if nargin == 1
    body = model;
    frame = 1;
    options.muscles = {'all'};
    options.showFibers = defshowfibers;
end
if nargin == 2
    frame = 1;
    options.muscles = {'all'};
    options.showFibers = defshowfibers;
end
if nargin == 3
    options.muscles = {'all'};
    options.showFibers = defshowfibers;
end
if ~isfield(options,'currentAxesView'); options.currentAxesView = [0.3 0.6]; end
if ~isfield(options,'transferMatrix'); options.transferMatrix = [1 0 0; 0 0 -1; 0 1 0]; end
if ~isfield(options,'showFibers'); options.showFibers = defshowfibers; end

% some constants
m = options.transferMatrix;
femheadradius = 0.026;
femneckradius = 0.0367/2;
trochneck = 0.0444;
femshaftradius = 0.01;
tibshaftradius = 0.01;
footradius = 0.01;
d = 0.05;
grey = [0.9 0.9 0.9];
mscred = [0.6350 0.0780 0.1840];
tdngrey = [0.5 0.5 0.5];
mscwidth = 4.0;
tdnwidth = 2.0;
c = m*body.segment.right_shank.mechanical.position(:,frame);

% init figure
fig=figure;
grid off
hold on
xlim([c(1)-0.51 c(1)+0.51])
ylim([c(2)-0.51 c(2)+0.51])
zlim([0 1.2]);

% markers
if isfield(options,'markers')
    if strcmpi(options.markers{1},'all'); mkrNames = model.markerNames;
    else; mkrNames = options.markers;
    end
    marker = generalizedCoordinates2MarkerPositions(model,body.generalizedCoordinates.mechanical.position,mkrNames,'mechanical');
    for k = 1:length(mkrNames) 
        p1 = m * marker.(mkrNames{k}).position(:,frame);
        scatter3(p1(1),p1(2),p1(3),'k.')
    end
end

% JCS
if isfield(options,'joints')
    if strcmpi(options.joints{1},'all'); jnt = model.jointNames;
    else; jnt = options.joints;
    end
    for j = 1:length(jnt)
        cseg = model.joint.(jnt{j}).child.segment;
        qc = body.segment.(cseg).mechanical.orientation(:,frame);
        posc = m * body.segment.(cseg).mechanical.position(:,frame);
        posj = model.segment.(cseg).parent.jointPosition.mechanical;
        posj = posc + m * qrot(qc,posj);
        jaxes = model.joint.(jnt{j}).rotationName;
        zerovec = [0 0 0]';
        axislength = 0.1;
        for jj = 1:length(jaxes)
            qjj = model.joint.(jnt{j}).child.mechanical.orientation;
            axisjj = zerovec; axisjj(jj) = 1;
            axisjj = m * qrot(qc,qrot(qjj,axisjj));
            p2 = posj + axisjj * axislength;
            plot3([posj(1) p2(1)],[posj(2) p2(2)],[posj(3) p2(3)],'k','LineWidth',2.0)
        end
    end
end

% femur points
hipjc = m * body.segment.right_thigh.mechanical.position(:,frame);
trochnotch = hipjc + trochneck * m * qrot(body.segment.right_thigh.mechanical.orientation(:,frame),[0 0 1]');
cond = m * body.bodyContour.right_femoralCondyle.position(:,frame);
condaxis = m * body.bodyContour.right_femoralCondyle.axis(:,frame);
condradius = model.bodyContour.right_femoralCondyle.radius;

% femoral head
[x,y,z] = ellipsoid(hipjc(1),hipjc(2),hipjc(3),femheadradius,femheadradius,femheadradius);
surf(x,y,z,'EdgeColor','none','FaceColor',grey);

% femoral neck
p1 = trochnotch;
p2 = hipjc;
longBone(p1,p2,femneckradius,grey);

% femoral condyle
p1 = cond;
p2 = p1 + condaxis * model.joint.right_knee.width * 0.5;
longBone(p1,p2,condradius,grey);

% femur long axis
p1 = mean([p1,p2],2);
p2 = trochnotch;
longBone(p1,p2,femshaftradius,grey);

if isfield(options,'segments')
    if strcmpi(options.segments{1},'all'); options.segments = model.segmentNames; end
    
    % for each segment
    for s = 1:numel(options.segments)
        
        seg = options.segments{s};
        p1 = m * (qrot(body.segment.(seg).mechanical.orientation(:,frame),qrot(model.segment.(seg).mechanical.orientation,model.segment.(seg).principal.position - model.segment.(seg).mechanical.position,'inverse')) + body.segment.(seg).mechanical.position(:,frame));
        scatter3(p1(1),p1(2),p1(3),'bx')
        x = m*qrot(body.segment.(seg).mechanical.orientation(:,frame),[1 0 0]');
        p2 = p1 + d * x;
        plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'g')
        y = m*qrot(body.segment.(seg).mechanical.orientation(:,frame),[0 1 0]');
        p2 = p1 + d * y;
        plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'r')
        z = m*qrot(body.segment.(seg).mechanical.orientation(:,frame),[0 0 1]');
        p2 = p1 + d * z;
        plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'b')
        
    end
    
end

% % knee joint center and axis
% z = m*qrot(body.segment.shank.mechanical.orientation(:,frame),[0 0 1]');
% p1 = kneejc - z * model.joint.right_knee.width/2;
% p2 = kneejc + z * model.joint.right_knee.width/2;
% plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'b','LineWidth',1.5)

% shank points
prox = m * (qrot(body.segment.right_shank.mechanical.orientation(:,frame),qrot(model.segment.right_shank.mechanical.orientation,model.segment.right_shank.principal.endpoint.proximal - model.segment.right_shank.mechanical.position,'inverse')) + body.segment.right_shank.mechanical.position(:,frame));
dist = m * (qrot(body.segment.right_shank.mechanical.orientation(:,frame),qrot(model.segment.right_shank.mechanical.orientation,model.segment.right_shank.principal.endpoint.distal - model.segment.right_shank.mechanical.position,'inverse')) + body.segment.right_shank.mechanical.position(:,frame));
anklejc = m * body.segment.right_foot.mechanical.position(:,frame);
ankleradius = model.joint.right_ankle.width/4;

% ankle joint center and flexion axis
% p1 = anklejc - z * model.joint.right_ankle.width/2;
% p2 = anklejc + z * model.joint.right_ankle.width/2;
% plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'b','LineWidth',1.5)

% tibial condyle
p1 = prox - m * qrot(body.segment.right_shank.anatomical.orientation(:,frame),[0 0 1]') * model.joint.right_knee.width * 0.25;
p2 = prox + m * qrot(body.segment.right_shank.anatomical.orientation(:,frame),[0 0 1]') * model.joint.right_knee.width * 0.25;
longBone(p1,p2,tibshaftradius,grey);

% tibia long axis
p1 = dist;
p2 = prox;
longBone(p1,p2,tibshaftradius,grey);

% ankle
[x,y,z] = ellipsoid(anklejc(1),anklejc(2),anklejc(3),ankleradius,ankleradius,ankleradius);
surf(x,y,z,'EdgeColor','none','FaceColor',grey);

% foot points
prox1 = m * (qrot(body.segment.right_foot.mechanical.orientation(:,frame),qrot(model.segment.right_foot.mechanical.orientation,model.segment.right_foot.principal.endpoint.proximal - model.segment.right_foot.mechanical.position,'inverse')) + body.segment.right_foot.mechanical.position(:,frame));
dist1 = m * (qrot(body.segment.right_foot.mechanical.orientation(:,frame),qrot(model.segment.right_foot.mechanical.orientation,model.segment.right_foot.principal.endpoint.distal - model.segment.right_foot.mechanical.position,'inverse')) + body.segment.right_foot.mechanical.position(:,frame));
v = dist1 - prox1;
prox = m * body.muscle.right_lateralGastrocnemius.insertion.position(:,frame);
dist = prox + v;

% foot long axis
longBone(prox,dist,footradius,grey);

% patellar ligament
% p1 = m*body.ligament.right_patellar.insertion.position(:,frame);
% p2 = m*body.ligament.right_patellar.origin.position(:,frame);
% plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'k','LineWidth',mscwidth/2)

% muscles
if isfield(options,'muscles')
    if ~isempty(options.muscles)
        if strcmpi(options.muscles{1},'all'); options.muscles = fieldnames(body.muscle); end
        msc = options.muscles;
        for k = 1:length(msc)
            p = [m*body.muscle.(msc{k}).origin.position(:,frame) m*body.muscle.(msc{k}).insertion.position(:,frame)];
            if model.muscle.(msc{k}).nViaPoints > 0
                p = [p(:,1) zeros(3,model.muscle.(msc{k}).nViaPoints) p(:,2)];
                for v = 1:model.muscle.(msc{k}).nViaPoints
                    p(:,v+1) = m*body.muscle.(msc{k}).viaPoint(v).position(:,frame);
                end
            elseif ~isempty(model.muscle.(msc{k}).bodyContour)
                if ~isempty(body.muscle.(msc{k}).contourViaPoints(frame).position)
                    p = [p(:,1) m*body.muscle.(msc{k}).contourViaPoints(frame).position p(:,2)];
                else
                    p = [p(:,1) p(:,2)];
                end
            end
            tissueColor = repmat(mscred',[1 size(p,2)-1]);
            tissueWidth = repmat(mscwidth,[1 size(p,2)-1]);
            if options.showFibers
                if isfield(body.muscle.(msc{k}),'fiberLength')
                    if body.muscle.(msc{k}).fiberLength(frame) ~= 0
                        tissueColor = repmat(tdngrey',[1 size(p,2)+1]);
                        tissueWidth = repmat(tdnwidth,[1 size(p,2)+1]);

                        lm = body.muscle.(msc{k}).fiberLength(frame);

                        d = vecnorm(diff(p,1,2));
                        lmtu = sum(d);
                        lt = lmtu - lm;
                        pt = model.muscle.(msc{k}).proximalMTUTendonPercentage;
                        t1 = pt * lt;

                        i1 = 0;
                        s = 0;
                        while t1 > s
                            i1 = i1+1;
                            s = s + d(i1);
                        end
                        s = s - d(i1);
                        res = t1 - s;
                        v = p(:,i1+1) - p(:,i1);
                        part = vecnorm(v);
                        perc = res/part;
                        pm1 = p(:,i1) + perc * v;
                        p = [p(:,1:i1) pm1 p(:,i1+1:end)];

                        t2 = t1 + lm;
                        d = vecnorm(diff(p,1,2));
                        i2 = 0;
                        s = 0;
                        while t2 > s
                            i2 = i2+1;
                            s = s + d(i2);
                        end
                        s = s - d(i2);
                        res = t2 - s;
                        v = p(:,i2+1) - p(:,i2);
                        part = vecnorm(v);
                        perc = res/part;
                        pm2 = p(:,i2) + perc * v;
                        p = [p(:,1:i2) pm2 p(:,i2+1:end)];

                        tissueColor(:,i1+1:i2) = repmat(mscred',[1,i2-i1]);
                        tissueWidth(i1+1:i2) = repmat(mscwidth',[1,i2-i1]);

                    end
                end
            end
            for j = 2:size(p,2)
                p1 = p(:,j-1);
                p2 = p(:,j);
                plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'Color',tissueColor(:,j-1)','LineWidth',tissueWidth(j-1));
            end
        end
    end
end

fig.CurrentAxes.View = options.currentAxesView;

end
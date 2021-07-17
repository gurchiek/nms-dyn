%% VISUALIZATION SCRIPT 4
% plot ensemble average knee joint moment (ID, OMCFull, IMCGP), power, 
% force, moment, and activtion. Must have already ran 
% s6_forward_dynamics_marker. Compares ID, OMCFull and IMCGP only for last
% three trials (test trials, see manuscript).

clear; close all; clc;

% load nms-dyn struct
load(replace(cd,'s7_visualization','nmsdyn_S0040'))

% subject id
subid = session.subject.ID;
data.subject = subid;

% for normalization
data.mass = model.mass;
data.height = session.subject.height;

% trial names
tnames = fieldnames(trial);
k = 1;
while k <= length(tnames)
    if isfield(trial.(tnames{k}),'imcTime')
        k = k+1;
    else
        tnames(k) = [];
    end
end
data.trialNames = tnames;

% allocation
data.imcgp.knee_flexion_moment.data = zeros(length(tnames),101);
data.id.knee_flexion_moment = zeros(length(tnames),101);
data.omcfull.knee_flexion_moment = zeros(length(tnames),101);

% muscles (first four to be compared/statistically analyzed)
msc = {'right_vastusLateralis','right_rectusFemoris','right_bicepsFemorisLong','right_semimembranosus','right_vastusMedialis','right_vastusIntermedius','right_bicepsFemorisShort','right_semitendinosus','right_medialGastrocnemius','right_lateralGastrocnemius'};
abbmsc = {'VL','RF','BFL','SM','VM','VI','BFS','ST','MG','LG'};
camelmsc = {'vastusLateralis','rectusFemoris','bicepsFemorisLong','semimembranosus','vastusMedialis','vastusIntermedius','bicepsFemorisShort','semitendinosus','medialGastrocnemius','lateralGastrocnemius'};

% allocate mtu dynamics vars
emdtype = {'imcgp','omcfull'};
for j = 1:2
    for k = 1:length(msc)
        data.(emdtype{j}).(msc{k}).power.data = zeros(length(tnames),101);
        data.(emdtype{j}).(msc{k}).activation.data = zeros(length(tnames),101);
        data.(emdtype{j}).(msc{k}).force.data = zeros(length(tnames),101);
        data.(emdtype{j}).(msc{k}).moment.data = zeros(length(tnames),101);
        data.(emdtype{j}).(msc{k}).work.eccentric.data = zeros(1,length(tnames));
        data.(emdtype{j}).(msc{k}).work.concentric.data = zeros(1,length(tnames));
    end
end

%% store stance normalized data

% for each trial
perc = 0:100;
pfc = zeros(1,length(tnames));
for k = 1:length(tnames)
    
    % simulation time and as percentage stance
    imcgptime = trial.(tnames{k}).imcgp.time.simulation;
    stime = trial.(tnames{k}).imcgp.time.excitation;
    
    % omcfull time
    omcfulltime = trial.(tnames{k}).omcfull.time.simulation;
    
    % inverse dynamics time
    idtime = trial.(tnames{k}).markerTime;
    
    % global time for synchronization
    tstart = max([imcgptime(1) omcfulltime(1)]);
    tend = min([imcgptime(end) omcfulltime(end)]);
    time = tstart:0.01:tend;
    x = linspace(0,100,length(time));
    
    % get torques during stride and resample for imcgp
    imcgptrq = trial.(tnames{k}).imcgp.body.joint.right_knee.flexion.emdtorque;
    imcgptrq = interp1(imcgptime,imcgptrq,time,'pchip');
    data.imcgp.knee_flexion_moment.data(k,:) = interp1(x,imcgptrq,perc,'pchip');
    
    % now omcfull
    omcfulltrq = trial.(tnames{k}).omcfull.body.joint.right_knee.flexion.emdtorque;
    omcfulltrq = interp1(omcfulltime,omcfulltrq,time,'pchip');
    data.omcfull.knee_flexion_moment(k,:) = interp1(x,omcfulltrq,perc,'pchip');
    
    % now inverse dynamics
    idtrq = trial.(tnames{k}).constrained.body.joint.right_knee.flexion.torque;
    idtrq = interp1(idtime,idtrq,time,'pchip');
    data.id.knee_flexion_moment(k,:) = interp1(x,idtrq,perc,'pchip');
    
    % correlation/rmse
    data.imcgp.knee_flexion_moment.IDcomparison.r(k) = corr(data.id.knee_flexion_moment(k,:)',data.imcgp.knee_flexion_moment.data(k,:)');
    data.imcgp.knee_flexion_moment.IDcomparison.rmse(k) = rms(data.id.knee_flexion_moment(k,:) - data.imcgp.knee_flexion_moment.data(k,:));
    data.imcgp.knee_flexion_moment.IDcomparison.rmse_bwh(k) = data.imcgp.knee_flexion_moment.IDcomparison.rmse(k) / data.mass / 9.81 / data.height * 100;
    data.imcgp.knee_flexion_moment.OMCFULLcomparison.r(k) = corr(data.omcfull.knee_flexion_moment(k,:)',data.imcgp.knee_flexion_moment.data(k,:)');
    data.imcgp.knee_flexion_moment.OMCFULLcomparison.rmse(k) = rms(data.omcfull.knee_flexion_moment(k,:) - data.imcgp.knee_flexion_moment.data(k,:));
    data.imcgp.knee_flexion_moment.OMCFULLcomparison.rmse_bwh(k) = data.imcgp.knee_flexion_moment.OMCFULLcomparison.rmse(k) / data.mass / 9.81 / data.height * 100;
    
    % now for each muscle and plot
    for m = 1:length(msc)
        
        % muscle contraction vars
        imom = trial.(tnames{k}).imcgp.body.muscle.(msc{m}).torque.right_knee.flexion;
        omom = trial.(tnames{k}).omcfull.body.muscle.(msc{m}).torque.right_knee.flexion;
        iforce = trial.(tnames{k}).imcgp.body.muscle.(msc{m}).force;
        oforce = trial.(tnames{k}).omcfull.body.muscle.(msc{m}).force;
        ipower = trial.(tnames{k}).imcgp.body.muscle.(msc{m}).power;
        opower = trial.(tnames{k}).omcfull.body.muscle.(msc{m}).power;
        iact = trial.(tnames{k}).imcgp.body.muscle.(msc{m}).activation;
        oact = trial.(tnames{k}).omcfull.body.muscle.(msc{m}).activation;
        
        % moment
        imom = interp1(imcgptime,imom,time,'pchip');
        imom = interp1(x,imom,perc,'pchip');
        omom = interp1(omcfulltime,omom,time,'pchip');
        omom = interp1(x,omom,perc,'pchip');
        data.imcgp.(msc{m}).moment.data(k,:) = imom;
        data.omcfull.(msc{m}).moment.data(k,:) = omom;
        
        % force
        iforce = interp1(imcgptime,iforce,time,'pchip');
        iforce = interp1(x,iforce,perc,'pchip');
        oforce = interp1(omcfulltime,oforce,time,'pchip');
        oforce = interp1(x,oforce,perc,'pchip');
        data.imcgp.(msc{m}).force.data(k,:) = iforce;
        data.omcfull.(msc{m}).force.data(k,:) = oforce;
        
        % power & work
        ipower = interp1(imcgptime,ipower,time,'pchip');
        opower = interp1(omcfulltime,opower,time,'pchip');
        iwork = computeCumulativeMuscleWork_v2(ipower,time);
        owork = computeCumulativeMuscleWork_v2(opower,time);
        ipower = interp1(x,ipower,perc,'pchip');
        opower = interp1(x,opower,perc,'pchip');
        data.imcgp.(msc{m}).power.data(k,:) = ipower;
        data.omcfull.(msc{m}).power.data(k,:) = opower;
        data.imcgp.(msc{m}).work.eccentric.data(k) = iwork.eccentric;
        data.imcgp.(msc{m}).work.concentric.data(k) = iwork.concentric;
        data.omcfull.(msc{m}).work.eccentric.data(k) = owork.eccentric;
        data.omcfull.(msc{m}).work.concentric.data(k) = owork.concentric;
        
        % activation
        iact = interp1(stime,iact,time,'pchip');
        iact = interp1(x,iact,perc,'pchip');
        oact = interp1(stime,oact,time,'pchip');
        oact = interp1(x,oact,perc,'pchip');
        data.imcgp.(msc{m}).activation.data(k,:) = iact;
        data.omcfull.(msc{m}).activation.data(k,:) = oact;
        
    end
    
end

%% plot

% initialize figures
alpha = 0.25;
mscvars = {'activation','force','power','moment'};
ylabs = {'Act. (%MVC)','Force (N)','Power(W)','Mom. (Nm)'};
fig.knee_flexion_moment = figure(1);
fig.knee_flexion_moment.Position = [964 346 325 201];
for k = 1:length(mscvars)
    fig.(mscvars{k}) = figure(k+1);
    fig.(mscvars{k}).Position =  [652 348 1029 391];
end

% knee flexion moment plot
figure(fig.knee_flexion_moment)
hold on
[iens,iub,ilb] = ensavg(data.imcgp.knee_flexion_moment.data(end-2:end,:),'median','quantile',1.0);
[oens,oub,olb] = ensavg(data.omcfull.knee_flexion_moment(end-2:end,:),'median','quantile',1.0);
[idens,idub,idlb] = ensavg(data.id.knee_flexion_moment(end-2:end,:),'median','quantile',1.0);

plot(perc,iens,'Color',softred,'LineWidth',2.0);
shade(perc,iub,ilb,softred,alpha)

plot(perc,oens,'Color',softblue,'LineWidth',2.0);
shade(perc,oub,olb,softblue,alpha)

plot(perc,idens,'Color',[0 0 0],'LineWidth',2.0);
shade(perc,idub,idlb,[0 0 0],alpha)

set(gca,'FontSize',14)
xlim([0 100])
xlabel('% Stance')
ylabel('Moment (Nm)')

% for each contraction dynamics variable
for k = 1:length(mscvars)
    
    % make figure current
    figure(fig.(mscvars{k}))
    
    % for each muscle
    for m = 1:10
        
        subplot(2,5,m)
        hold on
        
        [iens,iub,ilb] = ensavg(data.imcgp.(msc{m}).(mscvars{k}).data(end-2:end,:),'mean','std',1.0);
        [oens,oub,olb] = ensavg(data.omcfull.(msc{m}).(mscvars{k}).data(end-2:end,:),'mean','std',1.0);
        
        plot(perc,iens,'Color',softred,'LineWidth',2.0)
        shade(perc,iub,ilb,softred,alpha)
        
        plot(perc,oens,'Color',softblue,'LineWidth',2.0)
        shade(perc,oub,olb,softblue,alpha)
        
        title(abbmsc{m})
        xlim([0 100])
        xlabel('% Stance')
        ylabel(ylabs{k})
        
        
    end
    
end
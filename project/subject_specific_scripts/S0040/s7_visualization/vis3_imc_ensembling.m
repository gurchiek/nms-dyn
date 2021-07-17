%% VISUALIZATION SCRIPT 3
% plot ensemble average knee/ankle joint angles, normalized MTU lengths and
% knee flexion moment arms. Compares to omc.

clear; close all; clc;

% load nms-dyn struct
load(replace(cd,'s7_visualization','nmsdyn_S0040'))

% subject id
subid = session.subject.ID;
data.subject = subid;

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
data.knee_flexion_angle = zeros(length(tnames),101);
data.ankle_flexion_angle = zeros(length(tnames),101);

% muscles
msc = {'right_vastusMedialis','right_vastusLateralis','right_vastusIntermedius','right_rectusFemoris','right_bicepsFemorisLong','right_bicepsFemorisShort','right_semitendinosus','right_semimembranosus','right_medialGastrocnemius','right_lateralGastrocnemius'};
abbmsc = {'VM','VL','VI','RF','BFL','BFS','ST','SM','MG','LG'};
camelmsc = {'vastusMedialis','vastusLateralis','vastusIntermedius','rectusFemoris','bicepsFemorisLong','bicepsFemorisShort','semitendinosus','semimembranosus','medialGastrocnemius','lateralGastrocnemius'};

% allocate ref MTU lengths
for k = 1:length(msc)
    data.(msc{k}).normalizedMTULength = zeros(length(tnames),101);
    data.(msc{k}).kneeFlexionMomentArm = zeros(length(tnames),101);
end

% allocate same for omc reference
omc = data;

% initialize figure
fig1 = figure(1);
fig1.Position = [805 350 797 313];
fig2 = figure(2);
fig2.Position = [652 551 1029 391];
fig3 = figure(3);
fig3.Position = [652 82 1029 391];

% for each trial
perc = 0:100;
pfc = zeros(1,length(tnames));
for k = 1:length(tnames)
    
    % time synced with IMC stance phase + marker time
    stime = trial.(tnames{k}).imcTime;
    mtime = trial.(tnames{k}).markerTime;
    
    % get knee/ankle angle during stride
    knee_angle = trial.(tnames{k}).imc.body.joint.right_knee.flexion.angle;
    ankle_angle = trial.(tnames{k}).imc.body.joint.right_ankle.flexion.angle;
    x = linspace(0,100,length(knee_angle));
    
    % store interpolated result
    data.knee_flexion_angle(k,:) = interp1(x,knee_angle,perc,'pchip');
    data.ankle_flexion_angle(k,:) = interp1(x,ankle_angle,perc,'pchip');
    
    % now for omc
    knee_angle = trial.(tnames{k}).constrained.body.joint.right_knee.flexion.angle;
    ankle_angle = trial.(tnames{k}).constrained.body.joint.right_ankle.flexion.angle;
    knee_angle = interp1(mtime,knee_angle,stime,'pchip');
    ankle_angle = interp1(mtime,ankle_angle,stime,'pchip');
    omc.knee_flexion_angle(k,:) = interp1(x,knee_angle,perc,'pchip');
    omc.ankle_flexion_angle(k,:) = interp1(x,ankle_angle,perc,'pchip');
    
    % plot knee angle
    figure(1)
    subplot(1,2,1)
    hold on
    plot(perc,data.knee_flexion_angle(k,:),'Color',softblack)
    
    % plot ankle angle
    subplot(1,2,2)
    hold on
    plot(perc,data.ankle_flexion_angle(k,:),'Color',softblack)
    
    % now for each muscle and plot
    for m = 1:length(msc)
        
        % mtu length and plot
        mtulength = trial.(tnames{k}).imc.body.muscle.(msc{m}).mtu.length / model.muscle.(msc{m}).mtu.length;
        data.(msc{m}).normalizedMTULength(k,:) = interp1(x,mtulength,perc,'pchip');
        figure(2)
        subplot(2,5,m)
        hold on
        plot(perc,data.(msc{m}).normalizedMTULength(k,:),'Color',softblack)
        
        % store omc
        mtulength = trial.(tnames{k}).constrained.body.muscle.(msc{m}).mtu.length / model.muscle.(msc{m}).mtu.length;
        mtulength = interp1(mtime,mtulength,stime,'pchip');
        omc.(msc{m}).normalizedMTULength(k,:) = interp1(x,mtulength,perc,'pchip');
        
        % moment arm and plot
        momentarm = trial.(tnames{k}).imc.body.muscle.(msc{m}).momentArm.right_knee.flexion;
        data.(msc{m}).kneeFlexionMomentArm(k,:) = interp1(x,momentarm,perc,'pchip');
        figure(3)
        subplot(2,5,m)
        hold on
        plot(perc,data.(msc{m}).kneeFlexionMomentArm(k,:)*100,'Color',softblack)
        
        % store omc
        momentarm = trial.(tnames{k}).constrained.body.muscle.(msc{m}).momentArm.right_knee.flexion;
        momentarm = interp1(mtime,momentarm,stime,'pchip');
        omc.(msc{m}).kneeFlexionMomentArm(k,:) = interp1(x,momentarm,perc,'pchip');
        
    end
    
end

% xticks and labels
ticks = [0 25 50 75 100];
ticklabs = {'0' '25' '50' '75' '100'};

% plot mean knee angle
figure(1)
subplot(1,2,1)
hold on
p1 = plot(perc,mean(data.knee_flexion_angle,1),'k','LineWidth',2.0);
p2 = plot(perc,mean(omc.knee_flexion_angle,1),'r','LineWidth',1.5);
grid on
xlabel('% Stance')
ylabel('Angle (deg)')
title('Knee Flexion Angle')
set(gca,'FontSize',14)
xticks(ticks)
xticklabels(ticklabs)
legend([p1 p2],'IMC','OMC')

% plot mean ankle angle
subplot(1,2,2)
hold on
p1 = plot(perc,mean(data.ankle_flexion_angle,1),'k','LineWidth',2.0);
p2 = plot(perc,mean(omc.ankle_flexion_angle,1),'r','LineWidth',1.5);
grid on
xlabel('% Stance')
ylabel('Angle (deg)')
title('Ankle Flexion Angle')
set(gca,'FontSize',14)
xticks(ticks)
xticklabels(ticklabs)
legend([p1 p2],'IMC','OMC')

% plot mtu lengths/moment arms
for m = 1:10   
    figure(2)
    subplot(2,5,m)
    hold on
    p1 = plot(perc,mean(data.(msc{m}).normalizedMTULength),'k','LineWidth',2.0);
    p2 = plot(perc,mean(omc.(msc{m}).normalizedMTULength,1),'r','LineWidth',1.5);
    
    grid on
    xlabel('% Stance')
    ylabel('Norm. MTU Length')
    title(abbmsc{m})
    set(gca,'FontSize',10)
    xticks(ticks)
    xticklabels(ticklabs)
    if m == 1; legend([p1 p2],'IMC','OMC'); end
    
    figure(3)
    subplot(2,5,m)
    hold on
    p1 = plot(perc,mean(data.(msc{m}).kneeFlexionMomentArm)*100,'k','LineWidth',2.0);
    p2 = plot(perc,mean(omc.(msc{m}).kneeFlexionMomentArm)*100,'r','LineWidth',1.5);
    
    grid on
    xlabel('% Stance')
    ylabel('Knee Mom. Arm (cm)')
    title(abbmsc{m})
    set(gca,'FontSize',10)
    xticks(ticks)
    xticklabels(ticklabs)
    if m == 1; legend([p1 p2],'IMC','OMC'); end
    
end

%% uncomment to save figures and ensemble data

% % save figures
% savefig(fig1,[data.subject '_imc_invkin_ensemble_jointAngles'])
% savefig(fig2,[data.subject '_imc_invkin_ensemble_mtuLengths'])
% savefig(fig3,[data.subject '_imc_invkin_ensemble_momentArms'])
% 
% % save ensemble data
% imc = data;
% save([data.subject '_imc_invkin_ensemble_timeseries.mat'],'imc','omc')

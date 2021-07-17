%% VISUALIZATION SCRIPT 1
% this script visualizes the musculoskeletal system for the
% last walking trial (walk_10) computed using IMC at three instants:
%   figure 1: foot contact
%   figure 2: mid-stance
%   figure 3: foot off

clear; close all; clc;

% load nms-dyn struct
load(replace(cd,'s7_visualization','nmsdyn_S0040'))

% get the body field for the trial and analysis to visualize
body = trial.walk_10.imc.body;

% get the foot off instant
frame1 = trial.walk_10.imc.events.footContact;
frame3 = trial.walk_10.imc.events.footOff;
frame2 = round(mean([frame1 frame3]));

% set options
options.muscles = {'all'}; % show all muscles
options.markers = {'all'}; % show all markers
options.segments = {'all'}; % show all segment frames
options.joints = {'all'}; % show all joint axes

% to not display a particular item, simply remove the field: e.g., options = rmfield(options,'joints');

% plot body
plotBody(model,body,frame1,options);
plotBody(model,body,frame2,options);
plotBody(model,body,frame3,options);


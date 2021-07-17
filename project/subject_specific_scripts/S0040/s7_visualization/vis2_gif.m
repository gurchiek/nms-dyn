%% VISUALIZATION SCRIPT 2
% this script creates a gif that animates the movement of the 
% musculoskeletal system for the stance phase of the last walking trial 
% (walk_10) computed using IMC

clear; close all; clc;

% load nms-dyn struct
load(replace(cd,'s7_visualization','nmsdyn_S0040'))

% get the body field for the walk_10 trial and imc analysis
body = trial.walk_10.imc.body;

% name the gif file
filename = 'walk_10.gif';

% set the frame rate
% to play at exact frame rate use 1/trial.walk_10.samplingFrequency
% slow it down here: set to half the exact frame rate
rate = 0.5 / trial.walk_10.samplingFrequency;

% set the starting and ending indices for the animation
istart = trial.walk_10.imc.events.footContact; % foot contact
iend = trial.walk_10.imc.events.footOff;

% set options: same options as for plot body
options.muscles = {'all'}; % show all muscles

% create gif
simGif(model,body,filename,rate,istart,iend,options)
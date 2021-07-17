function body = getVelocityMTU(body,options)

% updates mtu velocity for each mtu in nms body struct via 5 point central
% difference differentiation of mtu lengths, thus mtu lengths must already
% have been computed. Velocities are low pass filtered at the user
% requested input frequency (options.lowPassCutoff). Also need to specify
% sampling rate (options.samplingFrequency).

% update is: body.muscle.(muscleName).mtu.velocity in m/s

sf = options.samplingFrequency;
lpc = options.lowPassCutoff;
muscleNames = fieldnames(body.muscle);
for k = 1:length(muscleNames)
    body.muscle.(muscleNames{k}).mtu.velocity = bwfilt(fdiff(body.muscle.(muscleNames{k}).mtu.length,1/sf,5),lpc,sf,'low',4);
end
function [] = writeTRC(data)

% write marker data to .trc

% INPUT
% data - struct, trial level of output struct from importTRC(), e.g., data = output.trial.static for output = importTRC(struct('trialname','static'))
%           data.filename = directory + filename + .trc
%           data.samplingFrequency = specifies DataRate, CameraRate, OrigDataRate in output .trc
%           data.nFrames = NumFrames in output .trc
%           data.nMarkers = NumMarkers in output .trc
%           data.firstFrame
%           data.markerNames = 1 x nMarkers cell of marker names in data.marker
%           data.time = 1 x nFrames time data
%           data.marker.(markerName).position = 3 x nFrames marker data,
%               marker data should be as it is when imported, IN METERS, will
%               be converted to mm here
%
%--------------------------------------------------------------------------
%% writeTRC

% convert to mm
for k = 1:data.nMarkers; data.marker.(data.markerNames{k}).position = data.marker.(data.markerNames{k}).position * 1000; end

% write
f = fopen(data.filename,'w');
fprintf(f,'PathFileType\t4\t(X/Y/Z)\t%s\n',data.filename);
fprintf(f,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(f,'%f\t%f\t%d\t%d\tmm\t%f\t%d\t%d\n',data.samplingFrequency,data.samplingFrequency,data.nFrames,data.nMarkers,data.samplingFrequency,data.firstFrame,data.nFrames);
fprintf(f,'Frame#\tTime\t');
for k = 1:data.nMarkers; fprintf(f,'%s\t\t\t',data.markerNames{k}); end
fprintf(f,'\n\t\t');
for k = 1:data.nMarkers; fprintf(f,'X%d\tY%d\tZ%d\t',k,k,k); end
fprintf(f,'\n');
for k = 1:data.nFrames
    fprintf(f,'%d\t',data.firstFrame + k - 1);
    fprintf(f,'%f',data.time(k));
    for j = 1:data.nMarkers
        fprintf(f,'\t%f',data.marker.(data.markerNames{j}).position(1,k));
        fprintf(f,'\t%f',data.marker.(data.markerNames{j}).position(2,k));
        fprintf(f,'\t%f',data.marker.(data.markerNames{j}).position(3,k));
    end
    fprintf(f,'\n');
end
fclose(f);

end
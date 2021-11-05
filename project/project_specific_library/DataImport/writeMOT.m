function [] = writeMOT(data)

% write force plate data to .trc

% INPUT
% data - struct, trial level of output struct from importMOT(), e.g., data = output.trial.static for output = importMOT(struct('trialname','static'))
%           data.filename = directory + filename + .mot
%           data.nSamples = nRows in output .mot
%           data.nForcePlates = 3*3*nForcePlates + 1 = nColumns in output .trc
%           data.time = 1 x nSamples time data
%           data.forcePlate(k).force = 3 x nSamples GRF data in Newtons
%           data.forcePlate(k).cop = 3 x nSamples COP data in meters
%           data.forcePlate(k).torque = 3 x nSamples GRM data in NM
%
%--------------------------------------------------------------------------
%% writeMOT

% write
f = fopen(data.filename,'w');
fprintf(f,'nColumns=%d\n',1 + data.nForcePlates*3*3);
fprintf(f,'nRows=%d\n',data.nSamples);
fprintf(f,'DataType=double\n');
fprintf(f,'version=3\n');
fprintf(f,'endheader\n');
fprintf(f,'time');
for k = 1:data.nForcePlates
    fprintf(f,'\t%s\t%s\t%s',['ground_force_' num2str(k) '_vx'],['ground_force_' num2str(k) '_vy'],['ground_force_' num2str(k) '_vz']); % GRF
    fprintf(f,'\t%s\t%s\t%s',['ground_force_' num2str(k) '_px'],['ground_force_' num2str(k) '_py'],['ground_force_' num2str(k) '_pz']); % COP
    fprintf(f,'\t%s\t%s\t%s',['ground_moment_' num2str(k) '_mx'],['ground_moment_' num2str(k) '_my'],['ground_moment_' num2str(k) '_mz']); % GRM
end
fprintf(f,'\n');
for k = 1:data.nSamples
    fprintf(f,'%f',data.time(k));
    for j = 1:data.nForcePlates
        fprintf(f,'\t%f\t%f\t%f',data.forcePlate(j).force(1,k),data.forcePlate(j).force(2,k),data.forcePlate(j).force(3,k)); % GRF
        fprintf(f,'\t%f\t%f\t%f',data.forcePlate(j).cop(1,k),data.forcePlate(j).cop(2,k),data.forcePlate(j).cop(2,k)); % COP
        fprintf(f,'\t%f\t%f\t%f',data.forcePlate(j).torque(1,k),data.forcePlate(j).torque(2,k),data.forcePlate(j).torque(3,k)); % GRM
    end
    fprintf(f,'\n');
end
fclose(f);

end
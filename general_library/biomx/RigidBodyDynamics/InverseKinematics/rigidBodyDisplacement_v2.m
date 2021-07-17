function [disp_q,disp_origin_world] = rigidBodyDisplacement_v2(ref_q,ref_origin_world,ref_markers_world,disp_markers_world)

% same as rigidBodyDisplacement_v1 except: disp_q  and disp_origin_world
% both determined according to method in spoor and veldpaus 1980

% see also rbd1980

%% initialization

% marker names, num markers, num frames for displaced configuration
mkr = fieldnames(disp_markers_world);
nmkr = length(mkr);
nframes = size(disp_markers_world.(mkr{1}).position,2);

% allocation
disp_q = zeros(4,nframes);
disp_origin_world = zeros(3,nframes);

%% get markers relative to rigid body frame in reference configuration

% for each marker
ref_markers_body = zeros(3,nmkr);
for i = 1:nmkr
    % these are the 'a' vectors in spoor and veldpaus 79
    ref_markers_body(:,i) = qrot(ref_q,ref_markers_world.(mkr{i}).position - ref_origin_world,'inverse');
end

%% get rigid body displacement

% for each frame
for f = 1:nframes
    
    % temporize ref_markers_body and disp_markers so can remove NaNs
    a = ref_markers_body;
    
    % displaced markers in world and relative to referene origin
    p = zeros(3,nmkr);
    m = zeros(3,nmkr);
    
    % for each marker
    i = 1;
    for j = 1:nmkr
        
        % if NaN, then remove
        if any(isnan(disp_markers_world.(mkr{j}).position(:,f)))
            a(:,i) = [];
            p(:,i) = [];
            m(:,i) = [];
            
        % otherwise, save
        else
            p(:,i) = disp_markers_world.(mkr{j}).position(:,f) - ref_origin_world;
            m(:,i) = disp_markers_world.(mkr{j}).position(:,f);
            i = i + 1;
        end
    end 
    
    % assign NaNs if less than 3 ref markers available for frame
    if size(p,2) < 3
        disp_q(:,f) = [NaN; NaN; NaN; NaN];
        disp_origin_world(:,f) = [NaN; NaN; NaN];
        
    else
        
        % get optimal quaternions, weight by squared magnitude of ref vec
        [disp_dcm,disp_translational] = rbd1980(a,p);
        disp_q(:,f) = convdcm(disp_dcm,'q');
        if 2*acos(disp_q(4,f)) > pi; disp_q(:,f) = -disp_q(:,f); end
        
        % get displaced origin in world frame
        disp_origin_world(:,f) = ref_origin_world + disp_translational; % spoor and veldpaus eq 10
    end
end

end
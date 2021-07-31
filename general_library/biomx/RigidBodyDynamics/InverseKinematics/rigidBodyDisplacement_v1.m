function [disp_q,disp_origin_world] = rigidBodyDisplacement_v1(ref_q,ref_origin_world,ref_markers_world,disp_markers_world)

% determines orientation of a rigid body (disp_q) displaced from some
% reference configuration specified by the orientation of the rigid body in
% the ref config (ref_q), the location of the origin of the rigid body in
% the ref conf (ref_origin_world, global representation), and the positions
% of markers fixed to the rigid body in the ref config (ref_markers_world)
% and given the positions of the same markers in the displaced
% configuration (disp_markers_world)

% disp_q determined according to method in Markley or Shuster/Oh 81
% disp_origin world as in Spoor and Veldpaus

% INPUTS
% ref_q - 4x1 quaternion s.t. v_world = q * v_body * q_conf in ref config
% ref_origin_world - 3x1 position of rigid body origin in world frame
% ref_markers_world - struct, fields are 3x1 vectors of marker positions in world frame in reference configuration, fieldnames are marker names
% disp_markers_world - struct, fields, are 3xn vectors of marker positions in world frame in displaced configurations, fieldnames are marker names

%% initialization

% marker names, num markers, num frames for displaced configuration
mkr = fieldnames(disp_markers_world);
nmkr = length(mkr);
nframes = size(disp_markers_world.(mkr{1}).position,2);

% pre-allocation
disp_q = zeros(4,nframes);
disp_origin_world = zeros(3,nframes);

%% get markers relative to rigid body frame in reference configuration

% for each marker
ref_markers_body = zeros(3,nmkr);
for i = 1:nmkr
    ref_markers_body(:,i) = qrot(ref_q,ref_markers_world.(mkr{i}).position - ref_origin_world,'inverse');
end

%% get reference vectors and displaced vectors

% indices of markers defining every unique reference vector
ind = nchoosek(1:nmkr,2);

% for each two marker combo
ref_vec = zeros(3,size(ind,1));
ref_mag = zeros(1,size(ind,1));
disp_vec = zeros(3,size(ind,1),nframes); % page k contains reference vector i (corresponding to the column in ref_vec) for displaced configuration k
for i = 1:size(ind,1)
    
    % ref vec
    ref_vec(:,i) = qrot(ref_q,ref_markers_world.(mkr{ind(i,2)}).position - ref_markers_world.(mkr{ind(i,1)}).position,'inverse'); % representation of ref vec i in body frame
    ref_mag(i) = vecnorm(ref_vec(:,i));
    ref_vec(:,i) = normalize(ref_vec(:,i),1,'norm');
    
    % disp vec
    temp_disp_vec = disp_markers_world.(mkr{ind(i,2)}).position - disp_markers_world.(mkr{ind(i,1)}).position;
    for col = 1:size(temp_disp_vec,2)
        if ~any(isnan(temp_disp_vec(:,col)))
            temp_disp_vec(:,col) = normalize(temp_disp_vec(:,col),1,'norm');
        end
    end
    disp_vec(:,i,:) = permute(temp_disp_vec,[1 3 2]); % make what was columns now be pages
    
end

%% get rigid body displacement

% for each frame
for f = 1:nframes
    
    % init temp vars so can remove those with NaNs (missing data points)
    temp.ref_vec = ref_vec;
    temp.ref_mag = ref_mag;
    temp.ref_markers_body = ref_markers_body;
    temp.disp_vec = disp_vec(:,:,f); % page corresponding to this frame
    temp.disp_markers_world = zeros(3,nmkr);
    
    % for each marker
    i = 1;
    for m = 1:nmkr
        
        % if NaN, then remove, cant help in locating origin
        if any(isnan(disp_markers_world.(mkr{m}).position(:,f)))
            temp.disp_markers_world(:,i) = [];
            temp.ref_markers_body(:,i) = [];
            
        % otherwise, save
        else
            temp.disp_markers_world(:,i) = disp_markers_world.(mkr{m}).position(:,f);
            i = i + 1;
        end
    end 
    
    % for each reference vector
    i = 1;
    while i <= size(temp.ref_vec,2)
        
        % if disp vec is NaN (eg due to missing marker), then remove from all
        if any(isnan(temp.disp_vec(:,i)))
            temp.ref_vec(:,i) = [];
            temp.ref_mag(i) = [];
            temp.disp_vec(:,i) = [];

        else
            % otherwise next
            i = i + 1;
        end
    end
    
    % assign NaNs if only 1 or less ref vec available for frame (then no solution)
    if size(temp.ref_vec,2) < 2
        disp_q(:,f) = [NaN; NaN; NaN; NaN];
        disp_origin_world(:,f) = [NaN; NaN; NaN];
        
    else

        % get optimal quaternions, weight by squared magnitude of ref vec
        disp_q(:,f) = getq(temp.disp_vec,temp.ref_vec,temp.ref_mag.^2);
        if 2*acos(disp_q(4,f)) > pi; disp_q(:,f) = -disp_q(:,f); end
        
        % get displaced origin in world frame
        disp_origin_world(:,f) = mean(temp.disp_markers_world - qrot(disp_q(:,f),temp.ref_markers_body),2); % spoor and veldpaus eq 10
    end
end

end
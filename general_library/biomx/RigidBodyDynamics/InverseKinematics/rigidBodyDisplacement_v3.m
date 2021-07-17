function [disp_q,disp_origin_world] = rigidBodyDisplacement_v3(ref_q,ref_origin_world,ref_markers_world,disp_markers_world)

% see rigidBodyDisplacement_v3

% differs from rigidBodyDisplacement_v1 in that v1 uses every possible
% two-marker combination which contains redundancy. For example, with three
% markers there are three-possible two-marker sets, but one of them can be
% written as the sum of the other two. Instead, in v3, none of these
% redundancies are present. Thus, only N-1 reference vectors are used for a
% set of N available marker positions

% in my experience, _v1 and _v3 give same answer, but _v3 is barely faster
% because it uses less reference vectors

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

% for each marker
ref_vec = zeros(3,nmkr-1,nmkr); % page k contains reference vector from 'base' marker k to all other markers
ref_mag = zeros(nmkr-1,nmkr);
disp_vec = cell(1,nframes);
for k = 1:nframes
    disp_vec{k} = zeros(3,nmkr-1,nmkr);
end
for k = 1:nmkr
    
    % for each other marker
    ind = 1:nmkr;
    ind(k) = [];
    for j = 1:nmkr-1
    
        % ref vec
        ref_vec(:,j,k) = qrot(ref_q,ref_markers_world.(mkr{ind(j)}).position - ref_markers_world.(mkr{k}).position,'inverse'); % representation of ref vec i in body frame
        ref_mag(j,k) = vecnorm(ref_vec(:,j,k));
        ref_vec(:,j,k) = normc(ref_vec(:,j,k));

        % disp vec
        temp_disp_vec = disp_markers_world.(mkr{ind(j)}).position - disp_markers_world.(mkr{k}).position;
        for f = 1:nframes
            if ~any(isnan(temp_disp_vec(:,f)))
                temp_disp_vec(:,f) = normc(temp_disp_vec(:,f));
            end
            disp_vec{f}(:,j,k) = temp_disp_vec(:,f);
        end
    
    end
    
end

% now rearrange so that markers that are most distant are first
mean_ref_mag = mean(ref_mag);
[~,marker_order] = sort(mean_ref_mag,'descend');
mkr = mkr(marker_order);
ref_markers_body = ref_markers_body(:,marker_order);
ref_vec = ref_vec(:,:,marker_order);
ref_mag = ref_mag(:,marker_order);
for k = 1:nframes
    disp_vec{k} = disp_vec{k}(:,:,marker_order);
end

%% get rigid body displacement

% for each frame
for f = 1:nframes
    
    % init temp vars so can remove those with NaNs (missing data points)
    temp.ref_vec = ref_vec;
    temp.ref_mag = ref_mag;
    temp.ref_markers_body = ref_markers_body;
    temp.disp_vec = disp_vec{f};
    temp.disp_markers_world = zeros(3,nmkr);
    
    % for each marker
    for k = 1:nmkr
        if ~any(isnan(disp_markers_world.(mkr{k}).position(:,f)))
            % exits once index of first marker with no NaNs identified
            % this will index the page of ref_vec and disp_vec to use as
            % the 'base' marker
            break;
        end
    end
    
    % must have at least three markers
    if k <= nmkr - 2
    
        % this loop handles markers for locating origin
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
        
        % must have at least three markers
        if size(temp.disp_markers_world,2) > 2
    
            % this next loops handles ref vecs for reconstructing orientation
            % get ref vecs for base marker k
            temp.ref_vec = temp.ref_vec(:,:,k);
            temp.ref_mag = temp.ref_mag(:,k);
            temp.disp_vec = temp.disp_vec(:,:,k);

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

            % get optimal quaternions, weight by squared magnitude of ref vec
            disp_q(:,f) = getq(temp.disp_vec,temp.ref_vec,temp.ref_mag.^2);
            if 2*acos(disp_q(4,f)) > pi; disp_q(:,f) = -disp_q(:,f); end

            % get displaced origin in world frame
            disp_origin_world(:,f) = mean(temp.disp_markers_world - qrot(disp_q(:,f),temp.ref_markers_body),2); % spoor and veldpaus eq 10
            
        % if only 2 or less markers then assign NaNs
        else
            
            disp_q(:,f) = [NaN; NaN; NaN; NaN];
            disp_origin_world(:,f) = [NaN; NaN; NaN];
            
        end
    
    % assign NaNs if only 1 or less ref vec available for frame (then no solution)
    else
        disp_q(:,f) = [NaN; NaN; NaN; NaN];
        disp_origin_world(:,f) = [NaN; NaN; NaN];
    end
end

end
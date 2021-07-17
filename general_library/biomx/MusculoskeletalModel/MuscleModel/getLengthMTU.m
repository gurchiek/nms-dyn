function body = getLengthMTU(model,muscle,body,options)

% model and body are nms model/body structs, muscle a char array specifying
% the muscle to calculate mtu length for, e.g. 'right_soleus'. nms body
% struct may specify multiple configurations (frames), mtu length is
% computed for each

% requires global body contour geometry be specified in nms body struct

% mtu length stored as body.muscle.(muscle).mtu.length

% options enable low pass filtering at options.lowPassCutoff and sampling
% frequency must be given as options.samplingFrequency

% default options
if nargin == 3
    options = struct();
end

% get muscle struct in reference configuration and in body configuration
ref = model.muscle.(muscle);
msc = body.muscle.(muscle);

% num via points and elements
nvp = ref.nViaPoints;
nel = ref.nElements;

% if has via points
if nvp > 0
    
    % get origin to first vp
    msc.mtu.length = vecnorm(msc.origin.position - msc.viaPoint(1).position);
    
    % add lengths for each of the rest of the vps
    if nvp > 1
        for v = 2:nvp
            msc.mtu.length = msc.mtu.length + vecnorm(msc.viaPoint(v-1).position - msc.viaPoint(v).position);
        end
    end
    
    % add length from last vp to insertion
    msc.mtu.length = msc.mtu.length + vecnorm(msc.viaPoint(end).position - msc.insertion.position);
    
    % filter?
    if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
        msc.mtu.length = bwfilt(msc.mtu.length,options.lowPassCutoff,options.samplingFrequency,'low',4);
    end
    
    % now do same for each element
    for e = 1:nel
        msc.element(e).mtu.length = vecnorm(msc.element(e).origin.position - msc.viaPoint(1).position);
        if nvp > 1
            for v = 2:nvp
                msc.element(e).mtu.length = msc.element(e).mtu.length + vecnorm(msc.viaPoint(v-1).position - msc.viaPoint(v).position);
            end
        end
        msc.element(e).mtu.length = msc.element(e).mtu.length + vecnorm(msc.viaPoint(end).position - msc.element(e).insertion.position);
    
        % filter?
        if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
            msc.element(e).length = bwfilt(msc.element(e).mtu.length,options.lowPassCutoff,options.samplingFrequency,'low',4);
        end
        
    end
  
% if body contour defined for wrapping
elseif ~isempty(ref.bodyContour)
    
    % if cylinder
    ref_contour = model.bodyContour.(ref.bodyContour);
    body_contour = body.bodyContour.(ref.bodyContour);
    if strcmp(ref_contour.type,'cylinder')
        
        % for each frame
        msc.mtu.length = zeros(1,size(msc.origin.position,2));
        msc.contourViaPoints(size(msc.origin.position,2)).position = [];
        for k = 1:size(msc.origin.position,2)
            
            % get cylindrical path
            [msc.mtu.length(k),msc.contourViaPoints(k).position] = musclePathAroundCylinder_v4(msc.origin.position(:,k),msc.insertion.position(:,k),body_contour.axis(:,k),body_contour.position(:,k),ref_contour.radius);
            
        end
    
        % filter?
        if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
            msc.mtu.length = bwfilt(msc.mtu.length,options.lowPassCutoff,options.samplingFrequency,'low',4);
        end
        
        
    end
    
% otherwise straight line segment
else
    
    % distance origin to insertion
    msc.mtu.length = vecnorm(msc.origin.position - msc.insertion.position);
    
    % filter?
    if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
        msc.mtu.length = bwfilt(msc.mtu.length,options.lowPassCutoff,options.samplingFrequency,'low',4);
    end
    
    % each element
    for e = 1:nel
        
        % distance origin to insertion
        msc.element(e).mtu.length = vecnorm(msc.element(e).origin.position - msc.element(e).insertion.position);
    
        % filter?
        if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
            msc.element(e).length = bwfilt(msc.element(e).mtu.length,options.lowPassCutoff,options.samplingFrequency,'low',4);
        end
        
    end
    
    
end

% store
body.muscle.(muscle) = msc;

end
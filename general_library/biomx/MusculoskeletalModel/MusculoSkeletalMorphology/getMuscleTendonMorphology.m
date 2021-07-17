function model = getMuscleTendonMorphology(model,refMuscle,refMTU)

% refMuscle and refMTU describe ranges of normalized fiber and mtu lengths
% respectively during gait. optimal fiber length/tendon slack length is
% scaled s.t. the range of norm fiber length specified in refMuscle is
% maintained for the range of norm mtu lengths in refMTU

% MTU ranges are normalized by mtu length during static pose, so input nms
% model struct must have mtu lengths in static pose

% two normalized fiber length range datasets during gait are available
% the ranges were estimated visually

% the first is by Arnold and Delp 2011 Phil Trans R Soc B.
% the second is by Arnold et al. 2013 J Exp Biol

% only muscle crossing knee and ankle joint were characterized

% Arnold et al. 2013 dataset had no data for peroneus longus nor
% semimembransosus, these were taken from Arnold and Delp 2011

% range for VI was set equal to that for VM

%% getMuscleTendonMorphology

% load
mscref = load(refMuscle);
mturef = load(refMTU);

% these are not right/left differentiated
% add right/left for each
mscrefNames = fieldnames(mscref.muscle);
for m = 1:length(mscrefNames)
    mscref.muscle.(['right_' mscrefNames{m}]) = mscref.muscle.(mscrefNames{m});
    mscref.muscle.(['left_' mscrefNames{m}]) = mscref.muscle.(mscrefNames{m});
end
mturefNames = fieldnames(mturef.mtu);
for m = 1:length(mturefNames)
    mturef.mtu.(['right_' mturefNames{m}]) = mturef.mtu.(mturefNames{m});
    mturef.mtu.(['left_' mturefNames{m}]) = mturef.mtu.(mturefNames{m});
end

% for each muscle
msc = fieldnames(model.muscle);
for m = 1:length(msc)
    
    % pennation and lopt
    phi0 = model.muscle.(msc{m}).phi0;
    
    % mtu length in static
    lmtu_static = model.muscle.(msc{m}).mtu.length;
    
    % min and max normalized fiber lengths and mtu lengths
    lmtu_max = lmtu_static * mean(mturef.mtu.(msc{m}).maxNormalizedMTULength);
    lmtu_min = lmtu_static * mean(mturef.mtu.(msc{m}).minNormalizedMTULength);
    lm_max = mscref.muscle.(msc{m}).maxNormalizedFiberLength;
    lm_min = mscref.muscle.(msc{m}).minNormalizedFiberLength;
    
    % cosine of pennation angle at lm_min and lm_max
    cos_max = cos(asin(1/lm_max * sin(phi0)));
    cos_min = cos(asin(1/lm_min * sin(phi0)));
    
    % solve system
    b = [lmtu_max; lmtu_min];
    A = [1 cos_max*lm_max; 1 cos_min*lm_min];
    x = A\b;
    model.muscle.(msc{m}).tendonSlackLength = x(1);
    model.muscle.(msc{m}).optimalFiberLength = x(2);
    
end

end
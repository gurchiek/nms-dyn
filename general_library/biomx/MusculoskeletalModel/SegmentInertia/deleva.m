function [ val ] = deleva( segment, parameter, sex )
%Reed Gurchiek, 2018
%   deleva is a lookup table of the inertial properties of human segments
%   determined from table 4 in de Leva 1996.  If an alternate segment
%   definition is used (bottom half of table 4) then segment name will end
%   with the number of the alternate (e.g. 'head' is the first head
%   definition and 'head2' is the second defined in the bottom half)
%
%   other custom segment definitions may be included which are determined
%   based on combining segments from those defined in de Leva 96.
%
%   it is unclear what the sagittal and transverse columns are in de Leva
%   96 table 4. One would assume sagittal is for the axis normal to the
%   sagittal plane and the transverse is the axis normal to the transverse
%   plane, but this is not the case since the longitudinal column is
%   certainly the axis  normal to the transverse plane. So either sagittal
%   is normal to sagittal plane and transverse is normal to frontal plane
%   or vice versa. Based on other data (eg,Damavandi et al 2011 TBME:58(5))
%   one would expect the frontal plane moments of inertia be larger for the
%   trunk segment. Based on this observation, the sagittal column in de
%   Leva 96 table 4 appears to be associated with axis normal to the
%   frontal plane which would leave the transverse column corresponding
%   to axis normal to the sagittal plane. However, just by the term
%   'sagittal' one may expect the opposite (as did Ren et al. 2008). In
%   either case, the differences between the sagittal and frontal plane
%   moments of inertia are minimal. In fact, Horsman et al. 2007 only
%   specify two moments of inertia, longitudinal and transverse, where it
%   is assumed any two orthogonal axes in the transverse plane have the
%   same moments of inertia and will suffice as principal axes.
%
%   note also that one would expect the moment of inertia of the hand to be
%   larger about the axis normal to the frontal plane and in de Leva 96
%   table 4, the sagittal column has larger radii of gyration than the
%   transverse. Likewise, intuitively one may expect larger moment of
%   inertia about the axis normal to the sagittal plane for the head (given
%   the shape of the brain/skull) and in de Leva 96 table 4, the transverse
%   column has larger radii of gyration than the sagittal. For these
%   reasons, in this function, the sagittal column is assumed to specify
%   the radii of gyration for the axis normal to the frontal plane and the
%   transverse column is assumed to specify the radii of gyration for the
%   axis normal to the sagittal plane. In most cases, the difference is
%   negligible.
%
%---------------------------INPUTS-----------------------------------------
%
%   segment:
%       string, segment name, camelCase:
%   
%   parameter:
%       string, inertial parameter to look up:
%           -length
%           -mass
%           -com
%           -x
%           -y
%           -z
%
%       NOTE: x,y,z are radii of gyration about those axes according to ISB
%       standard (x forward, y up, z right)
%
%   sex:
%       string, 'male' or 'female'. If left blank then default is male   
%
%--------------------------OUTPUTS-----------------------------------------
%
%   y:
%       value of requested parameter       
%
%--------------------------------------------------------------------------
%% deleva

%default to male
female = 0;
if nargin > 2
    if any(strcmpi(sex,{'female' 'f'}))
        female = 1;
    end
end

%whole body
if any(strcmpi(segment,{'wholeBody' 'whole_body' 'body'}))
    
    %height
    if any(strcmpi(parameter,{'height' 'length'}))
        val = 1.741;
        if female; val = 1.735; end
    
    %body mass
    elseif strcmpi(parameter,'mass')
        val = 73;
        if female; val = 61.9; end
    
    end
    
%head, top of head to mid gonion
elseif strcmpi(segment,'head')

    %length
    if strcmpi(parameter,'length')
        val = 0.2033;
        if female; val = 0.2002; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0694;
        if female; val = 0.0668; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5976;
        if female; val = 0.5894; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.362;
        if female; val = 0.33; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.312;
        if female; val = 0.318; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.376;
        if female; val = 0.359; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%trunk, suprasternale to mid hip jc
elseif strcmpi(segment,'trunk')

    %length
    if strcmpi(parameter,'length')
        val = 0.5319;
        if female; val = 0.5293; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.4346;
        if female; val = 0.4257; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4486;
        if female; val = 0.4151; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.372;
        if female; val = 0.357; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.191;
        if female; val = 0.171; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.347;
        if female; val = 0.339; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%upper trunk, suprasternale to xiphoid 
elseif any(strcmpi(segment,{'upperTrunk' 'upper_trunk' 'upt'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.1707;
        if female; val = 0.1425; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.1596;
        if female; val = 0.1545; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.2999;
        if female; val = 0.2077; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.716;
        if female; val = 0.746; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.659;
        if female; val = 0.718; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.454;
        if female; val = 0.502; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%mid trunk, xiphoid to omphalion
elseif any(strcmpi(segment,{'midTrunk' 'middleTrunk' 'mid_trunk' 'middle_trunk' 'mpt'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.2155;
        if female; val = 0.2053; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.1633;
        if female; val = 0.1465; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4502;
        if female; val = 0.4512; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.482;
        if female; val = 0.433; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.468;
        if female; val = 0.415; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.383;
        if female; val = 0.354; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%lower trunk, omphalion to mid hip jc
elseif any(strcmpi(segment,{'lowerTrunk' 'lower_trunk' 'lpt'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.1457;
        if female; val = 0.1815; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.1117;
        if female; val = 0.1247; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.6115;
        if female; val = 0.4920; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.615;
        if female; val = 0.433; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.587;
        if female; val = 0.444; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.551;
        if female; val = 0.402; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%upper arm, shoulder jc to elbow jc
elseif any(strcmpi(segment,{'upperArm' 'upper_arm' 'humerus'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.2817;
        if female; val = 0.2751; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0271;
        if female; val = 0.0255; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5772;
        if female; val = 0.5754; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.285;
        if female; val = 0.278; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.158;
        if female; val = 0.148; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.269;
        if female; val = 0.26; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%forearm, elbow jc to wrist jc
elseif strcmpi(segment,'forearm')

    %length
    if strcmpi(parameter,'length')
        val = 0.2689;
        if female; val = 0.2643; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0162;
        if female; val = 0.0138; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4574;
        if female; val = 0.4559; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.276;
        if female; val = 0.261; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.121;
        if female; val = 0.094; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.265;
        if female; val = 0.257; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%hand, wrist jc to 3rd metacarpal
elseif strcmpi(segment,'hand')

    %length
    if strcmpi(parameter,'length')
        val = 0.0862;
        if female; val = 0.078; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0061;
        if female; val = 0.0056; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.79;
        if female; val = 0.7474; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.628;
        if female; val = 0.531; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.401;
        if female; val = 0.335; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.513;
        if female; val = 0.454; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%thigh, hip jc to knee jc
elseif any(strcmpi(segment,{'thigh' 'upperLeg' 'upper_leg'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.4222;
        if female; val = 0.3685; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.1416;
        if female; val = 0.1478; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4095;
        if female; val = 0.3612; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.329;
        if female; val = 0.369; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.149;
        if female; val = 0.162; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.329;
        if female; val = 0.364; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%shank, knee jc to lateral malleolus
elseif any(strcmpi(segment,{'shank' 'lowerLeg' 'lower_leg'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.434;
        if female; val = 0.4323; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0433;
        if female; val = 0.0481; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4459;
        if female; val = 0.4416; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.255;
        if female; val = 0.271; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.103;
        if female; val = 0.093; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.249;
        if female; val = 0.267; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%foot, heel to toe tip
elseif strcmpi(segment,'foot')

    %length
    if strcmpi(parameter,'length')
        val = 0.2581;
        if female; val = 0.2283; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0137;
        if female; val = 0.0129; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4415;
        if female; val = 0.4014; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.257;
        if female; val = 0.299; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.124;
        if female; val = 0.139; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.245;
        if female; val = 0.279; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd head, top of head to C7
elseif strcmpi(segment,'head2')

    %length
    if strcmpi(parameter,'length')
        val = 0.2429;
        if female; val = 0.2437; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0694;
        if female; val = 0.0668; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5002;
        if female; val = 0.4841; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.303;
        if female; val = 0.271; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.261;
        if female; val = 0.261; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.315;
        if female; val = 0.295; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd trunk, C7 to mid hip jc
elseif strcmpi(segment,'trunk2')

    %length
    if strcmpi(parameter,'length')
        val = 0.6033;
        if female; val = 0.6148; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.4346;
        if female; val = 0.4257; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5138;
        if female; val = 0.4964; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.328;
        if female; val = 0.307; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.169;
        if female; val = 0.147; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.306;
        if female; val = 0.292; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%3rd trunk, mid shoulder to mid hip jc
elseif strcmpi(segment,'trunk3')

    %length
    if strcmpi(parameter,'length')
        val = 0.5155;
        if female; val = 0.4979; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.4346;
        if female; val = 0.4257; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.431;
        if female; val = 0.3782; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.384;
        if female; val = 0.379; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.197;
        if female; val = 0.182; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.358;
        if female; val = 0.361; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd upper trunk, C7 to xiphoid
elseif any(strcmpi(segment,{'upperTrunk2' 'upper_trunk2' 'upt2'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.2421;
        if female; val = 0.228; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.1596;
        if female; val = 0.1545; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5066;
        if female; val = 0.5050; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.505;
        if female; val = 0.466; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.465;
        if female; val = 0.449; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.32;
        if female; val = 0.314; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd forearm, elbow jc to radial styloid
elseif strcmpi(segment,'forearm2')

    %length
    if strcmpi(parameter,'length')
        val = 0.2669;
        if female; val = 0.2624; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0162;
        if female; val = 0.0138; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4608;
        if female; val = 0.4592; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.278;
        if female; val = 0.263; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.122;
        if female; val = 0.095; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.267;
        if female; val = 0.259; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd hand, wrist jc to tip of middle finger
elseif strcmpi(segment,'hand2')

    %length
    if strcmpi(parameter,'length')
        val = 0.1879;
        if female; val = 0.1701; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0061;
        if female; val = 0.0056; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.3624;
        if female; val = 0.3427; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.288;
        if female; val = 0.244; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.184;
        if female; val = 0.154; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.235;
        if female; val = 0.208; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%3rd hand, radial styloid to tip of middle finger
elseif strcmpi(segment,'hand3')

    %length
    if strcmpi(parameter,'length')
        val = 0.1899;
        if female; val = 0.172; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0061;
        if female; val = 0.0056; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.3691;
        if female; val = 0.3502; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.285;
        if female; val = 0.241; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.182;
        if female; val = 0.152; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.233;
        if female; val = 0.206; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%4th hand, radial styloid to 3rd metacarpal
elseif strcmpi(segment,'hand4')

    %length
    if strcmpi(parameter,'length')
        val = 0.0882;
        if female; val = 0.0799; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0061;
        if female; val = 0.0056; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.7948;
        if female; val = 0.7534; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.614;
        if female; val = 0.519; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.392;
        if female; val = 0.327; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.502;
        if female; val = 0.443; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%2nd shank, knee jc to ankle jc
elseif any(strcmpi(segment,{'shank2' 'lowerLeg2' 'lower_leg2'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.4403;
        if female; val = 0.4386; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0433;
        if female; val = 0.0481; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4395;
        if female; val = 0.4352; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.251;
        if female; val = 0.267; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.102;
        if female; val = 0.092; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.246;
        if female; val = 0.263; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

%3rd shank, knee jc to distal tip of tibia (sphyrion)
elseif any(strcmpi(segment,{'shank3' 'lowerLeg3' 'lower_leg3'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.4277;
        if female; val = 0.426; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.0433;
        if female; val = 0.0481; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.4524;
        if female; val = 0.4481; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.258;
        if female; val = 0.275; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.105;
        if female; val = 0.094; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.253;
        if female; val = 0.271; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end
    
%custom lower trunk defined by combination of lower trunk and middle trunk
%from de leva.  Defined only for male
elseif any(strcmpi(segment,{'customLowerTrunk1' 'customPelvis1'}))

    %length
    if strcmpi(parameter,'length')
        val = 0.3612;
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.275;
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.5022;
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.6093;
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.2628;
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.5385;
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end
    
%custom upper body defined by combination of middle trunk, upper trunk,
%head2, upper arms, forearms, and hands.  Is used to model upper body given
%only markers to model a trunk segment (thus the inertial properties
%represent those from the rest of the body).  Inertial params determined by
%considering upper body in anatomical position with arms straight down at
%side.  the center of mass location is from the trunk distal endpoint
%(midpoint between suprasternale and T2, see LBM1)
elseif strcmpi(segment,'customUpperBodyLBM1')

    %length
    if strcmpi(parameter,'length')
        val = 0.3862;
        if female; val = 0.3478; end
    %mass
    elseif strcmpi(parameter,'mass')||strcmpi(parameter,'m')
        val = 0.4911;
        if female; val = 0.4576; end
    %com
    elseif strcmpi(parameter,'com')||strcmpi(parameter,'cm')
        val = 0.3845;
        if female; val = 0.3538; end
    %x, forward (frontal plane)
    elseif strcmpi(parameter,'x')||strcmpi(parameter,'rx')
        val = 0.4915;
        if female; val = 0.5611; end
    %y, up (transverse plane)
    elseif strcmpi(parameter,'y')||strcmpi(parameter,'ry')
        val = 0.2791;
        if female; val = 0.2970; end
    %z, right (sagittal plane)
    elseif strcmpi(parameter,'z')||strcmpi(parameter,'rz')
        val = 0.4313;
        if female; val = 0.5078; end
    else
        error('prog:input','Requested parameter ''%s'' is not an acceptable input',parameter);
    end

else
    error('prog:input','Requested segment ''%s'' is not an acceptable input',segment);
end





end
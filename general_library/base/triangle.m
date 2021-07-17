function [ o1, o2, o3 ] = triangle( s1,s2,s3,a1,a2,a3,unit )
%Reed Gurchiek, 2017
%   triangle determines the three sides and three angles which make up a
%   triangle if three side lengths, or 2 side lengths and one angle, or 2
%   angles and one side length are known (SSS, SAS, ASA respectively).
%
%-------------------------------INPUTS-------------------------------------
%
%   s1,s2,s3:
%       side lengths for side 1, 2, and 3 respectively.  If one is unknown
%       then = 0.
%
%   a1,a2,a3:
%       angles for between s1 & s2, s2 & s3, and s3 & s1 respectively.  If
%       one is unknown then = 0.
%
%   unit:
%       'deg' or 'degree' for degrees.  If left blank, default is radian
%
%-------------------------------OUTPUTS------------------------------------
%
%   o1,o2,o3:
%       outputs which complete the triangle.
%
%--------------------------------------------------------------------------

%% triangle

%create side (S) and angle (A) vectors
S = [s1 s2 s3];
A = [a1 a2 a3];

%if sss
if all(S) && all(~A)
    
    %then get 3 angles
    o1 = acos((s1^2 + s2^2 - s3^2)/(2*s1*s2));
    o2 = acos((s2^2 + s3^2 - s1^2)/(2*s2*s3));
    o3 = acos((s3^2 + s1^2 - s2^2)/(2*s3*s1));
    
    %convert?
    if nargin == 7
        if strcmpi(unit,'deg')||strcmpi(unit,'degree')||strcmpi(unit,'degrees')
            o1 = o1*180/pi;
            o2 = o2*180/pi;
            o3 = o3*180/pi;
        end
    end
    
%if sas
elseif all(S(1:2)) && ~S(3) && A(1) && all(~A(2:3))
    
    %then first find s3
    o1 = sqrt(s1^2 - s2^2 - 2*s1*s2*cos(a1));
    
    %get other angles
    o2 = asin(sin(a1)/s1*s3);
    o3 = 180 - a1 - o2;
    
    %convert?
    if nargin == 7
        if strcmpi(unit,'deg')||strcmpi(unit,'degree')||strcmpi(unit,'degrees')
            o2 = o2*180/pi;
            o3 = o3*180/pi;
        end
    end
    
%if asa
elseif S(1) && all(~S(2:3)) && all(A(1:2)) && ~A(3)
    
    %get third angle
    o3 = pi - a1 - a2;
    
    %and other sides
    o1 = s1/sin(o3)*sin(a2);
    o2 = s1/sin(o3)*sin(a1);
    
    %convert?
    if nargin == 7
        if strcmpi(unit,'deg')||strcmpi(unit,'degree')||strcmpi(unit,'degrees')
            o3 = o3*180/pi;
        end
    end
    
end
        
    
    
end



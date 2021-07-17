function [c1,c2] = fjcscore(r1,r2,p1,p2)
%   
%   functional joint center estimator: SCORE method, Ehrig et al. 2006
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations
%   througout the movement are defined by the dcms r1 and r2 for segment 1
%   and 2 respectively and given body origins p1 and p2 which are relative
%   to a global frame
%
%   method very similar to pivot method in Siston and Delp 2006 where body
%   2 points are transformed to body 1 whereas in score, body 2 and body 1
%   points are both transformed to global coordinates.
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       of frame 1 in the world frame
%   p2:
%       3xn array of column vectors specifying the location of the origin
%       of frame 2 in the world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   c1,c2:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1 and frame 2 respectively
%
%--------------------------------------------------------------------------
%% fjcscore

% setup/solve linear system
x = lsqlin([tower(r1) -tower(r2)],tower(p2-p1));
c1 = x(1:3);
c2 = x(4:6);

end
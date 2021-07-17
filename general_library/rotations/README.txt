Toolbox: rotations
Author: Reed Gurchiek
Contact: rgurchiek@gmail.com
References: Shuster (1993), Kuipers

The rotations toolbox is used to rotate vectors from one frame to another, convert between different rotators, integrate rotators, and much more. Rotators are either direction cosine matrices (dcm), quaternions (q), or Euler angles specified by the rotation sequence (zyx, zxy, xyz, xzy, yzx, yxz, zyz, zxz, yzy, yxy, xzx, xyx).

Rotators are completely specified by a set of numeric values (r) and a character array (rtype) specifying the type of rotator. A rotator is used to rotate a vector expressed relative to basis B such that it is expressed relative to the basis A as per vA = rot(r,rtype,vB). Likewise, the following would be true, vB = rot(r,rtype,vA,'inv'). Alternatively, the inverse could also be performed by, [rinv,invtype] = invrot(r,rtype) and then it would be true that vB = rot(rinv,invtype,vA).

Quaternions are four element column vectors, r = [r1 r2 r3 r4]', and their type is specified by 'q'. The scalar part of the quaternion is fourth indexed and the vector part (x,y,z) are the 1,2,3 indices respectively. Rotating vectors using a quaternion is done using quaternion products as per q * v * q_conj, where q_conj is the quaternion conjugate. 

Euler angles are stored as a three element column vector, r = [r1 r2 r3]', and their type is specified by a character array specifying the sequence of rotations (e.g. 'zyx'). In this formulation, r1 corresponds to the angle (in radians) of the first rotation about the axis specified as the first character in the rotator type, r2 is the same for the second rotation and so on for r3. For example if the rotation sequence were z -> y -> x then the rotator type would be 'zyx' where z = [0 0 1]', y = [0 1 0]', and x = [1 0 0]'.

Direction cosine matrices are stored as three by three matrices and their type is specified by the character array 'dcm'.

Vectors are rotated using the rot function and allow the rotation of v1 to v2 where v1 is expressed in frame 1 and v2 is expressed in frame 2. For dcms this amounts to v2 = dcm * v1. For quaternions this amounts to v2 = q * v1 * q_conj. For Euler angles this amounts to v2 = R(e3) * R(e2) * R(e1) where R(ei) is the direction cosine matrix corresponding to the Euler angle in row i of the Euler angle vector (e). For example, R(z) = [cos(angle) sin(angle) 0; -sin(angle) cos(angle) 0; 0 0 1].
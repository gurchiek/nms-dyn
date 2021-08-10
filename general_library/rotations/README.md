# rotations

Author: Reed Gurchiek

Contact: rgurchiek@gmail.com

Dependencies: Matlab

# Description

The rotations toolbox is used to rotate vectors from one frame to another (change of basis operation), convert between different rotators, integrate rotators, and much more. Currently supported rotator types are direction cosine matrices (dcm), quaternions (q), or Euler angles specified by the rotation sequence (zyx, zxy, xyz, xzy, yzx, yxz, zyz, zxz, yzy, yxy, xzx, xyx).

Rotators are completely specified by a set of numeric values and a character array organized as a Matlab struct as per rotator.(type) = [numeric values]. For example, if the orientation is described using the quaternion then, rotator.q = [4xn array]. Likewise, one would use rotator.dcm [3x3xn array] for dcm and rotator.(Euler sequence) = [3xn array] for Euler angles where Euler sequence specifies the sequence of rotation axes (e.g., rotator.xyz). Note that rotator here is just the name given to the rotator variable. One could just as easily use, r.q, r.dcm, etc. A rotator is used to determine the representation of a vector with respect to some basis A given its representation with respect to some other basis B as per vA = rot(r,vB). Likewise, the following would be true, vB = rot(r,vA,'inv'). Alternatively, the inverse could also be performed by, rinv = invrot(r) and then it would be true that vB = rot(rinv,vA).

Quaternions are four element column vectors, q = [q1 q2 q3 q4]', and their type is specified by 'q'. The scalar part of the quaternion is fourth indexed and the vector part (x,y,z) are the 1,2,3 indices respectively. Rotating vectors using a quaternion is done using quaternion products, qprod(), as per q * v * qconj(q), where qconj(q) returns the quaternion conjugate. 

Euler angles are stored as a three element column vector, e = [e1 e2 e3]', and their type is specified by a character array specifying the sequence of rotations (e.g. 'zyx'). In this formulation, e1 corresponds to the angle (in radians) of the first rotation about the axis specified as the first character in the rotator type, e2 is the same for the second rotation and so on for e3. For example if the rotation sequence were z -> y -> x then the rotator type would be 'zyx' where z = [0 0 1]', y = [0 1 0]', and x = [1 0 0]'.

Direction cosine matrices are stored as three by three matrices and their type is specified by the character array 'dcm'.

Vectors are rotated using the rot function and allow the rotation of v1 to v2 where v1 is expressed in frame 1 and v2 is expressed in frame 2. For dcms this is computed using the matrix product v2 = dcm * v1. For quaternions this computed using quaternion products, qprod(), as per v2 = q * v1 * qconj(q). For Euler angles this is computed using matrix products as per v2 = R(e3) * R(e2) * R(e1) where R(ei) is given using Rodriguez formula. For example, if the zyx sequence is used where z = [0 0 1]' then e1 corresponds to the angle associated with the first rotation about z and R(e1) = eye(3) - sin(e1) * skew(z) + (1-cos(e1)) * skew(z) * skew(z) where skew() is a function returning the skew-symmetric matrix form of the vector argument such that, for example, y = skew(z) * x (since y = cross(z,x)).

Functions are available to integrate rotator parameters given angular velocity that may be expressed in the world or body frame. Several integration schemes are available. Jacobians may be computed that map generalized velocities (rotator parameter time derivatives) to Cartesian angular velocities and vice versa. Rotator parameters may be time differentiated, inverted, and converted between types. Functions are available to determine the quaternion or dcm that solves the weighted Wahba's problem (optimal orientation given a set of reference vectors and measurements of the same in a weighted least squares sense).

# Reading Material

**1. Best reference for attitude parametrizations:** Shuster (1993) A survey of attitude representations, The Journal of the Astronautical Sciences, 41(4).

**2. DCM solution to Wahba's problem:** Markley (1988) Attitude determination using vector observations and the singular value decomposition, The Journal of the Astronautical Sciences, 38(3).

**3. Quaternion solution to Wahba's problem and TRIAD algorithm:** Shuster and Oh (1981) Three-axis attitude determination from vector observations, Journal of Guidance and Control, 4(1).

**4. See the appendices of my dissertation for quaternion algebra, quaternion-based vector rotation operation and parametrization of the corresponding rotation matrix, quaternion kinematics, and quaternion use in optimization-based optical motion capture:** [Gurchiek (2021) Towards remote gait analysis: Combining physics and probabilistic models for estimating human joint mechanics](https://scholarworks.uvm.edu/graddis/1350/).

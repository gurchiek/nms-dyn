% demo_rot

clear
clc

x = [1 0 0]';
y = [0 1 0]';
z = [0 0 1]';

%% quaternion product

% two quaternions
a1 = pi/3;
a2 = pi/4;
n1 = [1;1;1]/sqrt(3);
n2 = [1;0;0];
q1 = [sin(a1/2) * n1; cos(a1/2)];
q2 = [sin(a2/2) * n2; cos(a2/2)];

% their product can be equivalently computed as per
p1 = qprod(q1,q2);
q1mat = qprodmat(q1,1);
q2mat = qprodmat(q2,2);
p2 = q1mat*q2;
p3 = q2mat*q1;
[p1-p2 p1-p3 p2-p3]

%% conversions

ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'zyx');

r1 = [cos(ea(1)) sin(ea(1)) 0; -sin(ea(1)) cos(ea(1)) 0; 0 0 1];
r2 = [cos(ea(2)) 0 -sin(ea(2)); 0 1 0; sin(ea(2)) 0 cos(ea(2))];
r3 = [1 0 0; 0 cos(ea(3)) sin(ea(3)); 0 -sin(ea(3)) cos(ea(3))];
r.dcm = r3*r2*r1;

re = convrot(e,'dcm');
er = convrot(r,typerot(e));
qe = convrot(e,'q');
qr = convrot(r,'q');
rq = convrot(qr,'dcm');
eq = convrot(qe,typerot(e));

unpackrot(r)-unpackrot(re)
unpackrot(e)-unpackrot(er)
unpackrot(qe)-unpackrot(qr)
unpackrot(e)-unpackrot(eq)
unpackrot(r)-unpackrot(rq)

%% conversions

ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'xzy');

r2 = [cos(ea(2)) sin(ea(2)) 0; -sin(ea(2)) cos(ea(2)) 0; 0 0 1];
r3 = [cos(ea(3)) 0 -sin(ea(3)); 0 1 0; sin(ea(3)) 0 cos(ea(3))];
r1 = [1 0 0; 0 cos(ea(1)) sin(ea(1)); 0 -sin(ea(1)) cos(ea(1))];
r.dcm = r3*r2*r1;

re = convrot(e,'dcm');
er = convrot(r,typerot(e));
qe = convrot(e,'q');
qr = convrot(r,'q');
rq = convrot(qr,'dcm');
eq = convrot(qe,typerot(e));

unpackrot(r)-unpackrot(re)
unpackrot(e)-unpackrot(er)
unpackrot(qe)-unpackrot(qr)
unpackrot(e)-unpackrot(eq)
unpackrot(r)-unpackrot(rq)

%% conversions

ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'yxy');

r1 = [cos(ea(1)) 0 -sin(ea(1)); 0 1 0; sin(ea(1)) 0 cos(ea(1))];
r2 = [1 0 0; 0 cos(ea(2)) sin(ea(2)); 0 -sin(ea(2)) cos(ea(2))];
r3 = [cos(ea(3)) 0 -sin(ea(3)); 0 1 0; sin(ea(3)) 0 cos(ea(3))];
r.dcm = r3*r2*r1;

re = convrot(e,'dcm');
er = convrot(r,typerot(e));
qe = convrot(e,'q');
qr = convrot(r,'q');
rq = convrot(qr,'dcm');
eq = convrot(qe,typerot(e));

unpackrot(r)-unpackrot(re)
unpackrot(e)-unpackrot(er)
unpackrot(qe)-unpackrot(qr)
unpackrot(e)-unpackrot(eq)
unpackrot(r)-unpackrot(rq)

%% conversions

ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'xzx');

r1 = [1 0 0; 0 cos(ea(1)) sin(ea(1)); 0 -sin(ea(1)) cos(ea(1))];
r2 = [cos(ea(2)) sin(ea(2)) 0; -sin(ea(2)) cos(ea(2)) 0; 0 0 1];
r3 = [1 0 0; 0 cos(ea(3)) sin(ea(3)); 0 -sin(ea(3)) cos(ea(3))];
r.dcm = r3*r2*r1;

re = convrot(e,'dcm');
er = convrot(r,typerot(e));
qe = convrot(e,'q');
qr = convrot(r,'q');
rq = convrot(qr,'dcm');
eq = convrot(qe,typerot(e));

unpackrot(r)-unpackrot(re)
unpackrot(e)-unpackrot(er)
unpackrot(qe)-unpackrot(qr)
unpackrot(e)-unpackrot(eq)
unpackrot(r)-unpackrot(rq)

%% conversions

r.dcm = orth(rand(3,3));
euler = 'xyx';

er = convrot(r,euler);
qr = convrot(r,'q');
eq = convrot(qr,euler);
unpackrot(er)-unpackrot(eq)
qe = convrot(eq,'q');
unpackrot(qr)-unpackrot(qe)
re = convrot(er,'dcm');
rq = convrot(qr,'dcm');
unpackrot(rq)-unpackrot(r)
unpackrot(re)-unpackrot(r)

%% rotation

n1=[1;1;1]/sqrt(3);

r.dcm = orth(rand(3,3));
n2r = rot(r,n1);
q = convrot(r,'q');
n2q = rot(q,n1);
e = convrot(r,'zyx');
n2e = rot(e,n1);

[n2r n2q n2e]

n2r-n2q
n2r-n2e
n2r-n2e

%% show that rot(q,v) = q * v * q_conj

q = unpackrot(q);
n2qq = qprod(q,qprod([n1;0],qconj(q)));
n2q-n2qq(1:3)

%% show that convrot(q,'dcm') = upper left 3x3 of q * v * q_conj

R = convq(q,'dcm');
Rq = qprodmat(q,1) * qprodmat(qconj(q),2);
R-Rq(1:3,1:3)

%% inverse method 1
n1r = rot(r,n2r,'inv');
n1e = rot(e,n2e,'inv');
q = packrot(q,'q');
n1q = rot(q,n2q,'inv');

[n1 n1r n1e n1q]

n1-n1r
n1-n1e
n1-n1q

%% inverse method 2

qi = invrot(q);
ei = invrot(e);
ri = invrot(r);

n1q = rot(qi,n2q);
n1r = rot(ri,n2r);
n1e = rot(ei,n2e);

[n1 n1r n1e n1q]

n1-n1r
n1-n1q
n1-n1e

%% rotations

% imagine body frame got to its current position by starting aligned with
% world and then rotating about z through 45 deg
q.q = [sin(pi/4/2) * z; cos(pi/4/2)];

% q will express x in body as seen in world
% answer should be x' = rot(q,x) = [sqrt(2)/2; sqrt(2)/2; 0]
rot(q,x)





% demo script

% demonstrates rotation function of different rotator types, conversion
% between types, and inversion of different types

% each section explores a different demonstration, all outputs should be
% near zero

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

% or
q1mat = qprodmat(q1,1);
q2mat = qprodmat(q2,2);
p2 = q1mat*q2;

% or
p3 = q2mat*q1;
disp([p1-p2 p1-p3 p2-p3])

%% conversions: asymmetric euler sequence: zyx

% euler angles, zyx sequence
ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'zyx');

% euler angle parametrization of dcm (by hand here to compare with convrot)
r1 = [cos(ea(1)) sin(ea(1)) 0; -sin(ea(1)) cos(ea(1)) 0; 0 0 1];
r2 = [cos(ea(2)) 0 -sin(ea(2)); 0 1 0; sin(ea(2)) 0 cos(ea(2))];
r3 = [1 0 0; 0 cos(ea(3)) sin(ea(3)); 0 -sin(ea(3)) cos(ea(3))];
r.dcm = r3*r2*r1;

% euler to dcm
re = convrot(e,'dcm');

% euler to quaternion
qe = convrot(e,'q');

% dcm to euler
er = convrot(r,typerot(e));

% dcm to quaternion
qr = convrot(r,'q');

% quaternion to dcm
rq = convrot(qr,'dcm');

% quaternion to euler
eq = convrot(qe,typerot(e));

% compare
disp(unpackrot(r)-unpackrot(re))
disp(unpackrot(e)-unpackrot(er))
disp(unpackrot(qe)-unpackrot(qr))
disp(unpackrot(e)-unpackrot(eq))
disp(unpackrot(r)-unpackrot(rq))

%% conversions: asymmetric euler sequence: xzy

% euler angles, xzy
ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'xzy');

% dcm
r2 = [cos(ea(2)) sin(ea(2)) 0; -sin(ea(2)) cos(ea(2)) 0; 0 0 1];
r3 = [cos(ea(3)) 0 -sin(ea(3)); 0 1 0; sin(ea(3)) 0 cos(ea(3))];
r1 = [1 0 0; 0 cos(ea(1)) sin(ea(1)); 0 -sin(ea(1)) cos(ea(1))];
r.dcm = r3*r2*r1;

% euler to dcm
re = convrot(e,'dcm');

% dcm to euler
er = convrot(r,typerot(e));


% euler to quaternion
qe = convrot(e,'q');

% dcm to quaternion
qr = convrot(r,'q');

% quaternion to dcm
rq = convrot(qr,'dcm');

% quaternion to euler
eq = convrot(qe,typerot(e));

% compare
disp(unpackrot(r)-unpackrot(re))
disp(unpackrot(e)-unpackrot(er))
disp(unpackrot(qe)-unpackrot(qr))
disp(unpackrot(e)-unpackrot(eq))
disp(unpackrot(r)-unpackrot(rq))

%% conversions: symmetric euler sequence: yxy

% euler angles, yxy
ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'yxy');

% dcm
r1 = [cos(ea(1)) 0 -sin(ea(1)); 0 1 0; sin(ea(1)) 0 cos(ea(1))];
r2 = [1 0 0; 0 cos(ea(2)) sin(ea(2)); 0 -sin(ea(2)) cos(ea(2))];
r3 = [cos(ea(3)) 0 -sin(ea(3)); 0 1 0; sin(ea(3)) 0 cos(ea(3))];
r.dcm = r3*r2*r1;

% euler to dcm
re = convrot(e,'dcm');

% dcm to euler
er = convrot(r,typerot(e));


% euler to quaternion
qe = convrot(e,'q');

% dcm to quaternion
qr = convrot(r,'q');

% quaternion to dcm
rq = convrot(qr,'dcm');

% quaternion to euler
eq = convrot(qe,typerot(e));

% compare
disp(unpackrot(r)-unpackrot(re))
disp(unpackrot(e)-unpackrot(er))
disp(unpackrot(qe)-unpackrot(qr))
disp(unpackrot(e)-unpackrot(eq))
disp(unpackrot(r)-unpackrot(rq))

%% conversions: symmetric euler sequence: xzx

% euler angles xzx
ea = [30*pi/180;  60*pi/180; 45*pi/180];
e = packrot(ea,'xzx');

% dcm
r1 = [1 0 0; 0 cos(ea(1)) sin(ea(1)); 0 -sin(ea(1)) cos(ea(1))];
r2 = [cos(ea(2)) sin(ea(2)) 0; -sin(ea(2)) cos(ea(2)) 0; 0 0 1];
r3 = [1 0 0; 0 cos(ea(3)) sin(ea(3)); 0 -sin(ea(3)) cos(ea(3))];
r.dcm = r3*r2*r1;

% euler to dcm
re = convrot(e,'dcm');

% dcm to euler
er = convrot(r,typerot(e));


% euler to quaternion
qe = convrot(e,'q');

% dcm to quaternion
qr = convrot(r,'q');

% quaternion to dcm
rq = convrot(qr,'dcm');

% quaternion to euler
eq = convrot(qe,typerot(e));

% compare
disp(unpackrot(r)-unpackrot(re))
disp(unpackrot(e)-unpackrot(er))
disp(unpackrot(qe)-unpackrot(qr))
disp(unpackrot(e)-unpackrot(eq))
disp(unpackrot(r)-unpackrot(rq))

%% conversions: from random dcm

% generate random dcm
r.dcm = orth(rand(3,3));
eulerseq = 'xyx';

% dcm to euler
er = convrot(r,eulerseq);

% dcm to quaternion
qr = convrot(r,'q');

% quaternion to euler
eq = convrot(qr,eulerseq);

% euler back to quaternion
qe = convrot(eq,'q');

% euler back to dcm
re = convrot(er,'dcm');

% quaternion back to dcm
rq = convrot(qr,'dcm');

% compare
disp(unpackrot(er)-unpackrot(eq))
disp(unpackrot(qr)-unpackrot(qe))
disp(unpackrot(rq)-unpackrot(r))
disp(unpackrot(re)-unpackrot(r))

%% rotation

% unit vec
n1=[1;1;1]/sqrt(3);

% random dcm
r.dcm = orth(rand(3,3));

% rotate n1 using dcm
n2r = rot(r,n1);

% dcm to quaternion
q = convrot(r,'q');

% rotate n1 using quaternion
n2q = rot(q,n1);

% dcm to euler
e = convrot(r,'zyx');

% rotate n1 using euler angles
n2e = rot(e,n1);

% compare
disp(n2r-n2q)
disp(n2r-n2e)

%% show that rot(q,v) = q * v * q_conj

q = unpackrot(q);
n2qq = qprod(q,qprod([n1;0],qconj(q)));
disp(n2q-n2qq(1:3))

%% show that convq(q,'dcm') = upper left 3x3 of q * v * q_conj

R = convq(q,'dcm');
Rq = qprodmat(q,1) * qprodmat(qconj(q),2);
disp(R-Rq(1:3,1:3))

%% inverse method 1

% rotate n2 back to n1 with dcm
n1r = rot(r,n2r,'inv');

% rotate n2 back to n1 with euler
n1e = rot(e,n2e,'inv');

% rotate n2 back to n1 with quaternion
q = packrot(q,'q');
n1q = rot(q,n2q,'inv');

% compare
disp(n1-n1r)
disp(n1-n1e)
disp(n1-n1q)

%% inverse method 2

% invert quaternion, euler angles, and dcm using invrot
qi = invrot(q);
ei = invrot(e);
ri = invrot(r);

% rotate n2 back to n1 using inverted rotators
n1q = rot(qi,n2q);
n1r = rot(ri,n2r);
n1e = rot(ei,n2e);

% compare
disp(n1-n1r)
disp(n1-n1q)
disp(n1-n1e)





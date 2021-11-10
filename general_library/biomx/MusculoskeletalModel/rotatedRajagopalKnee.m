function [a,i,y,x,z] = rotatedRajagopalKnee(f)

% same as rajagopalKnee except rotated so expressed in femur frame

% rotation order: flexion, adduction, internal rotation

% currently works for right leg only

% knee angles for interpolation
u = [0 0.174533 0.349066 0.523599 0.698132 0.872665 1.0472 1.22173 1.39626 1.5708 1.74533 1.91986 2.0944];

% adduction
v = [0 0.0126809 0.0226969 0.0296054 0.0332049 0.0335354 0.0308779 0.0257548 0.0189295 0.011407 0.00443314 -0.00050475 -0.0016782];
a = interp1(u,v,f,'pchip');

% internal rotation (NEGATE for left leg)
v = [0 0.059461 0.109399 0.150618 0.18392 0.210107 0.229983 0.24435 0.254012 0.25977 0.262428 0.262788 0.261654];
i =  interp1(u,v,f,'pchip');

% superior inferior
v = [0 0.000479 0.000835 0.001086 0.001251 0.001346 0.001391 0.001403 0.0014 0.0014 0.001421 0.001481 0.001599];
y = interp1(u,v,f,'pchip');

% antero posterior (anterior positive), NEGATE for left leg
v = [0 0.000988 0.001899 0.002734 0.003492 0.004173 0.004777 0.005305 0.005756 0.00613 0.006427 0.006648 0.006792];
x = interp1(u,v,f,'pchip');

% null medio lateral translation
z = zeros(1,length(f));

% init rot mat
Rf = zeros(3,3,length(f));
Ra = zeros(3,3,length(f));
Ri = zeros(3,3,length(f));
Rj = zeros(3,3,length(f));

% some constants
I = eye(3);
e1 = skew(I(:,1));
e2 = skew(I(:,2));
e3 = skew(I(:,3));

% tibia represented joint translations
r0 = [x; y; z];

% femur represented joint translations
r = zeros(3,length(f));

% construct joint rotation transform and express r0 in femur
for k = 1:length(f)
    
    Rf(:,:,k) = I - sin(f(k)) * e3 + (1 - cos(f(k))) * e3*e3; % equivalent to I + sin(-f) * e3 + (1 - cos(-f)) * e3*e3
    Ra(:,:,k) = I + sin(a(k)) * e1 + (1 - cos(a(k))) * e1*e1;
    Ri(:,:,k) = I + sin(i(k)) * e2 + (1 - cos(i(k))) * e2*e2;
    Rj(:,:,k) = Rf(:,:,k)  * Ra(:,:,k)  * Ri(:,:,k) ;
    
    r(:,k) = Rj(:,:,k) * r0(:,k);
end

x = r(1,:);
y = r(2,:);
z = r(3,:);

end
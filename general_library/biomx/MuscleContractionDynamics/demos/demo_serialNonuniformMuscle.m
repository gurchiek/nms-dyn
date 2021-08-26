% simulate hamstring strain during late swing phase of sprint. MTU length
% and activation data taken from Fiorentino 2014. This example models
% serial heterogeneity in muscle architecture which allows simulation of
% nonuniform strains (a characteristic of the hamstrings in
% sprinting)

function [m,anim,t,sf] = demo_serialNonuniformMuscle()

clear; close all; clc;

%% SETTINGS

% set number of fibers in series
nm = 100;

% simulation time
sf = 250; % sampling frequency
tf = 0.35/2; % final time, swing time ~ 0.35 s (Weyand '10, table 2), this half of that (late swing = mid swing to foot contact)
t = 0:1/sf:tf;
n = length(t);

% muscle properties
lts = 0.341; % tendon slack length, delp 90
l0 = 0.109; % optimal fiber length, delp 90
f0_mid = 720; % max force, delp 90
f0_dist = 3.6/5.2 * f0_mid; % at distal end, fiorentino 14
f0_prox = 2.3/5.2 * f0_mid; % at proximal end, fiorentino 14
phi0_mid = 20 * pi/180; % pennation angle at optimal length, fiorentino 14
phi0_dist = 1.0 * phi0_mid; % at distal end
phi0_prox = 1.0 * phi0_mid; % at proximal end
e0_mid = 0.55; % muscle strain at max force
e0_dist = 1.0 * e0_mid; % at distal end
e0_prox = 1.0 * e0_mid; % at proximal end
ft0 = f0_mid; % scales normalized tendon force-length in hill model
et0 = 0.04; % tendon strain when tendon force = ft0 (default = 0.04);
fv = @fvdegroote; % force velocity function
beta = 0.5; % damping coef

% muscle excitation
exc = zeros(1,n); % excitation time series
y = [0.1 0.3 0.6 0.5];
x = [0 0.5 0.75 1.0] * tf;
exc(t>=0) = interp1(x,y,t(t>=0),'pchip');
minexc = 0.01; % min excitation

%% MTU length

% set MTU kinematics (is an input to dynamics)
s0 = l0 * cos(phi0_mid);
lmtu0 = lts + s0;

% following was found to reproduce that by fiorentino 2014 late swing
y = [0 0.085 0.04];
x = [0 tf/2 tf];
y = interp1(x,y,t(t>=0));
y = bwfilt(y,10,sf,'low',4);
lmtu(t>=0) = lmtu0 + lmtu0 * y;

%% model serial heterogeneity

% init muscle
m(nm) = defaultMuscleModel;
for k = 1:nm-1; m(k) = m(nm); end

% do mid muscle first
imid = ceil(nm/2);

% set mid muscle
m(imid).minExcitation = minexc;
m(imid).excitation = exc;
m(imid).maxForce = f0_mid;
m(imid).tendonSlackLength = lts;
m(imid).optimalFiberLength = l0/nm;
m(imid).phi0 = phi0_mid;
m(imid).mtu.length = bwfilt(lmtu,6,sf,'low',4);
m(imid).mtu.velocity = fdiff(m(imid).mtu.length,t,5);
m(imid).implicitSolverOptions = odeset('RelTol',1e-6,'MaxStep',0.01,'Jacobian',@impdynjac);
m(imid).maxTendonForce = ft0;
m(imid).maxForceMuscleStrain = e0_mid;
m(imid).maxForceTendonStrain = et0;
m(imid).forceVelocityFunction = fv;
m(imid).coefDamping = beta;

% initialize count, indices, and handle even number comparments
imid1 = imid;

% odd
if mod(nm,2) == 1
    
    imid2 = imid;
    count = 1;
 
% even    
else

    % set mid muscle, element 2
    m(imid+1) = m(imid);
    
    % increment count
    imid2 = imid + 1;
    count = 2;
    
end

% continue?
if count < nm
    
    iprox = 1;
    idist = nm;
    
    while count < nm
        
        % init with mid
        m(iprox) = m(imid);
        m(idist) = m(imid);
        
        % update region specific muscle properties
        m(iprox).maxForce = f0_prox + ((iprox - 1) / (imid1 - 1))^(1/1.5) * (f0_mid - f0_prox);
        m(iprox).phi0 = phi0_prox + (iprox - 1) / (imid1 - 1) * (phi0_mid - phi0_prox);
        m(iprox).maxForceMuscleStrain = e0_prox + (iprox - 1) / (imid1 - 1) * (e0_mid - e0_prox);
        
        m(idist).maxForce = f0_dist + ((nm - idist) / (nm - imid2))^(1/1.5) * (f0_mid - f0_dist);
        m(idist).phi0 = phi0_dist + (nm - idist) / (nm - imid2) * (phi0_mid - phi0_dist);
        m(idist).maxFoceMuscleStrain = e0_dist + (nm - idist) / (nm - imid2) * (e0_mid - e0_dist);
        
        % increment
        iprox = iprox + 1;
        idist = idist - 1;
        count = count + 2;
        
    end
    
end

%% SIMULATE

m = sim(m,t);

%% movie

anim = getMovie(m,t,m(imid).maxForce);
movie(anim,3,sf);
movie(anim,2,sf/2);
movie(anim,1,sf/4);
movie(anim,1,sf/8);
movie(anim,1,sf/16);
movie(anim,1,sf/32);

%% plots

figure
for k = [1 imid nm]
    subplot(1,2,1)
    hold on
    plot(t(t>=0),m(k).fiberLength(t>=0)/m(k).optimalFiberLength)
    subplot(1,2,2)
    hold on
    plot(t(t>=0),m(k).muscleForce(t>=0))
end
subplot(1,2,1)
xlabel('Time (s)')
ylabel('Norm Fib Len')
subplot(1,2,2)
xlabel('Time (s)')
ylabel('Fib Force (N)')

end

%% SIMULATION

function m = sim(m,t)

% get num muscles
nm = length(m);

% activation dynamics
for k = 1:nm
    m(k).activation = m(k).activationDynamics(t,m(k).excitation,m(k));
end

% initialize muscle state
[l,v] = initstate(m,t);

% integrate
[xt,x] = ode15i(@impdyn,t,l,v,m(1).implicitSolverOptions,m,t);

% interpolate and get velocity
x = interp1(xt,x,t,'pchip');
if nm > 1
    x = x';
end
v = fdiff(x,t,5);

% store fib len and vel
for k = 1:nm
    m(k).fiberLength = x(k,:);
    m(k).fiberVelocity = v(k,:);
end

% get muscle force
muscleForce = zeros(nm,length(t));
for k = 1:length(t); [~,~,~,muscleForce(:,k)] = impdyn(t(k),x(:,k),v(:,k),m,t); end
for k = 1:nm; m(k).muscleForce = muscleForce(k,:); end

end

%% IMPLICIT DYNAMICS

function [f,df_dlm,df_dvm,muscleForce] = impdyn(tk,l,v,m,t)

% unpack
nm = length(m);
a = zeros(1,nm);
F0 = zeros(1,nm);
vmax = zeros(1,nm);
ft0 = m(1).maxTendonForce;

% get vmax and max force
for k = 1:nm
    vmax(k) = m(k).normalizedMaxVelocity * m(k).optimalFiberLength;
    F0(k) = m(k).maxForce;
end

% interpolate inputs
lmtu = interp1(t,m(1).mtu.length,tk,'pchip');
for k = 1:nm; a(k) = interp1(t, m(k).activation,tk,'pchip'); end

% activation nonlinearity
for k = 1:nm; a(k) = m(k).activationNonlinearityFunction(a(k),m(k)); end

% tendon force
[ft,dft_dlm] = tenforce(l,lmtu,m);
muscleForce = ft0 * ft;

% pennation angle
phi = zeros(nm,1);
dphi_dlm = zeros(1,nm);
fphi = phi;
dfphi_dlm = phi;
for k = 1:nm
    [phi(k),dphi_dlm(k)] = m(k).pennationFunction(l(k),m(k));
    fphi(k) = cos(phi(k));
    dfphi_dlm(k) = -sin(phi(k)) * dphi_dlm(k);
end

% active muscle force length
afl = zeros(nm,1);
adfl_dlm = afl;
for k = 1:nm
    [afl(k),adfl_dlm(k)] = m(k).activeForceLengthFunction(l(k),a(k),m(k));
end

% passive muscle force length
fp = zeros(nm,1);
dfp_dlm = fp;
for k = 1:nm
    [fp(k),dfp_dlm(k)] = m(k).passiveForceLengthFunction(l(k),m(k));
end

% force velocity
fv = zeros(nm,1);
dfv_dvm = zeros(nm,1);
for k = 1:nm
    [fv(k),dfv_dvm(k)] = m(k).forceVelocityFunction(v(k),m(k));
end

% equilibrium equation
d = m(1).coefDamping;
f = zeros(nm,1);
for k = 1:nm
    f(k) = F0(k) * (fv(k) * afl(k) + fp(k) + d * v(k) / vmax(k)) * fphi(k) - ft0 * ft;
end

% derivatives
df_dvm = zeros(nm,nm);
df_dlm = zeros(nm,nm);
for k = 1:nm
    df_dvm(k,k) = F0(k) * (dfv_dvm(k) .* afl(k) + d / vmax(k)) .* fphi(k);
    for j = 1:nm
        if k == j
            df_dlm(k,k) = F0(k) * (fv(k) .* adfl_dlm(k) + dfp_dlm(k)) .* fphi(k) + F0(k) * (fv(k) .* afl(k) + fp(k) + d * v(k) / vmax(k)) * dfphi_dlm(k) - ft0 * dft_dlm(k);
        else
            df_dlm(k,j) = -ft0 * dft_dlm(j);
        end
    end
end

end

function [f,df_dlm] = tenforce(lm,lmtu,m)

% see tflexpc, in TendonForceLength folder, modified here to handle df_dlm
% (now depends on multiple fiber lengths for multicompartment model)

% ten force-len function params
s0 = m(1).maxForceTendonStrain;
E = m(1).tendonElasticModulus;
ls = m(1).tendonSlackLength;

% num compartments
nm = length(m);

% pennation angle
phi = zeros(1,nm);
fphi = phi;
dphi_dlm = phi;
for k = 1:nm
    [phi(k),dphi_dlm(k)] = m(k).pennationFunction(lm(k),m(k));
    fphi(k) = cos(phi(k));
end

% get tendon length
lt = lmtu;
dlt_dlm = zeros(nm,1);
for k = 1:nm
    lt = lt - lm(k) .* fphi(k);
    dlt_dlm(k) = lm(k) .* sin(phi(k)) .* dphi_dlm(k) - fphi(k);
end

s = (lt - ls) / ls;
ds_dlm = dlt_dlm / ls;

c = exp(-E*s0);
eks = exp(E*s);
f = c * (eks - 1);
df_dlm = E * c * eks .* ds_dlm;

end

%% IMPLICIT DYNAMICS JACOBIAN

function [df_dlm,df_dvm] = impdynjac(tk,l,v,m,t); [~,df_dlm,df_dvm] = impdyn(tk,l,v,m,t); end

%% INIT STATE

function [lm,vm] = initstate(m,t)

% init fib len, vel, force
n = length(t);
nm = length(m);
for k = 1:nm
    m(k).fiberLength = zeros(1,n);
    m(k).fiberVelocity = zeros(1,n);
    m(k).force = zeros(1,n);
end

% assume rigid tendon and evenly divided
lmtu = m(1).mtu.length(1);
lt = m(1).tendonSlackLength + 0.001; % slightly strained
s = lmtu - lt;
si = s / nm;
lm = zeros(1,nm);
vm = lm;
for k = 1:nm
    l0 = m(k).optimalFiberLength;
    phi0 = m(k).phi0;
    h = l0*sin(phi0);
    lm(k) = sqrt(si*si + h*h);
    vm(k) = si/lm(k) * m(1).mtu.velocity(1);
end

% call decic
options = m(1).implicitSolverOptions;
[lm,vm] = decic(@impdyn,t(1),lm,[],vm,[],options,m,t);

% for k = 1:nm
%     m(k).fiberLength(1) = lm(k);
%     m(k).fiberVelocity(1) = vm(k);
% end

end

%% CREAT MOVIE

function anim = getMovie(m,t,f0)

% only after t = 0
tm = t(t>=0);
n = length(tm);
maxl = max(m(1).mtu.length(t>=0)) * 1.1; % width of figure

minwidth = 2.0;
maxwidth = 25.0;
diffwidth = maxwidth - minwidth;

anim(n) = struct('cdata',[],'colormap',[]);
figure;
for k = 1:n
    ind = find(t == tm(k));
	x2 = 0;
    plot([x2 x2],0.01 * [-1 1],'k','LineWidth',1.0)
    hold on
    for j = 1:length(m)
        x1 = x2;
        x2 = x1 + m(j).fiberLength(ind) * cos(m(j).pennationFunction(m(j).fiberLength(ind),m(j)));
        width = minwidth + diffwidth * m(j).maxForce / f0;
        [red, green, blue] = rgb(m(j).fiberLength(ind)/m(j).optimalFiberLength);
        plot([x1 x2],[0 0],'Color',[red, green, blue],'LineWidth',width)
    end
    x1 = x2;
    x2 = m(1).mtu.length(ind);
    plot([x1 x2],[0 0],'k','LineWidth',2.0)
    
    ylim([-0.025 0.025])
    xlim([-0.025 maxl])
    pause(0.01)
    drawnow;
    anim(k) = getframe;
    hold off
end

end

function [r,g,b] = rgb(l)

mn = 1; % minimum strain
mx = 1.5; % maximum strain

if l > mx
    l = mx;
elseif l < mn
    l = mn;
end

range = mx-mn;
diff = l-mn;
x = 1 - diff / range;
if x > 1; x = 1; elseif x < 0; x = 0; end

c = hsv2rgb([x*0.675,0.9,0.9]);

r = c(1);
g = c(2);
b = c(3);

end

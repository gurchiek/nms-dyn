% demo showing the need to halve the order and adjust the cutoff frequency
% when determining coefs a,b from butter() for use in filtfilt. If these
% adjutments not made, then the equivalent system does not have th expected
% 3dB bandwidth (low pass cutoff frequency)

clear
clc

% sampling frequency
fs = 100;

% sampling time
Ts = 1/fs;

% low pass cutoff frequency (desired 3dB bandwidth(
cf = 6;

% desired order of filter
order = 4;

% forward-backward pass = 2 passes (for zero phase low pass)
passes = 2;

% adjust cutoff
cf_adjust = cf * 1 / ((2^(1/passes) - 1)^(1/4)); % Robertson and Dowling (2003) eq (1)

% 4th order, cf @ 6
[b1,a1] = butter(order,cf/(fs/2));
sys1 = tf(b1,a1,Ts);

% 2nd order, cf @ 6: desired system characteristics
[b2,a2] = butter(order/2,cf/(fs/2));
sys2 = tf(b2,a2,Ts);

% zero phase filtering: without adjustment, with halving order
% system characteristics are equivalent to filtfilt
sys2sys2 = sys2*sys2;

% 2nd order, cf @ 6
[b3,a3] = butter(order/2,cf_adjust/(fs/2));
sys3 = tf(b3,a3,Ts);

% zero phase filtering: with adjustment, with halving order
% system characteristics are equivalent to filtfilt
sys3sys3 = sys3*sys3;

% 4nd order, cf @ 6
[b4,a4] = butter(order,cf/(fs/2));
sys4 = tf(b4,a4,Ts);

% zero phase filtering: without adjustment, without halving order
% system characteristics are equivalent to filtfilt
sys4sys4 = sys4*sys4;

% 2nd order, cf @ 6 + forward-backward adjustment
[b5,a5] = butter(order,cf_adjust/(fs/2));
sys5 = tf(b5,a5,Ts);

% zero phase filtering: with adjustment, without halving order
% system characteristics are equivalent to filtfilt
sys5sys5 = sys5*sys5;

% 3db frequencies
wsys1 = bandwidth(sys1);
wsys2 = bandwidth(sys2);
wsys2sys2 = bandwidth(sys2sys2);
wsys3 = bandwidth(sys3);
wsys3sys3 = bandwidth(sys3sys3);
wsys4 = bandwidth(sys4);
wsys4sys4 = bandwidth(sys4sys4);
wsys5 = bandwidth(sys5);
wsys5sys5 = bandwidth(sys5sys5);

fprintf('Actual (n = 4, cf = 6): w3dB = %f\n',wsys1/2/pi);
fprintf('Filter prior to filtfilt in zero-phase filtering: without adjustment, without halving order (n = 4, cf = 6): w3dB = %f\n',wsys4/2/pi);
fprintf('Zero-phase filtering: without adjustment, without halving order  (n = 8, cf = 6): w3dB = %f\n',wsys4sys4/2/pi);
fprintf('Filter prior to filtfilt in zero-phase filtering: without adjustment, with halving order  (n = 2, cf = 6): w3dB = %f\n',wsys2/2/pi);
fprintf('Zero-phase filtering: without adjustment, with halving order (n = 4, cf = 6): w3dB = %f\n',wsys2sys2/2/pi);
fprintf('Filter prior to filtfilt in zero-phase filtering: with adjustment, without halving order (n = 4, cf = 6 + adjustment): w3dB = %f\n',wsys5/2/pi);
fprintf('Zero-phase filtering: with adjustment, without halving order  (n = 8, cf = 6 + adjustment): w3dB = %f\n',wsys5sys5/2/pi);
fprintf('Filter prior to filtfilt in zero-phase filtering: with adjustment, with halving order (n = 2, cf = 6 + adjustment): w3dB = %f\n',wsys3/2/pi);
fprintf('Zero-phase filtering: with adjustment, with halving order  (n = 4, cf = 6 + adjustment): w3dB = %f\n',wsys3sys3/2/pi);

bode(sys1)
hold on
bode(sys4sys4)
bode(sys2sys2)
bode(sys5sys5)
bode(sys3sys3)




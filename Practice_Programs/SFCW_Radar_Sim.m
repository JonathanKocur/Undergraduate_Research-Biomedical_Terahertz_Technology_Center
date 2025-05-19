% This program simulates the frequency steps included in the SFCW radar.
% The purpose of this is to better understand the functionality of the SFCW
% radar

bandwidth = 1;
fstart = 1;
fend = fstart+bandwidth;
freqsteps = 2;
stepsize = bandwidth/freqsteps;

fs = 1000;
dt = 1/fs;
StopTime = 2;
t = (0:dt:StopTime - dt);

for i = 0:1:freqsteps
   freq = fstart + i*stepsize;
   x = sin(2*pi*t*freq);

   figure(1)
   plot(t,x)
end
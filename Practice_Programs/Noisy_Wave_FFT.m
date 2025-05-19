% This is a demonstration of the FFT of a sample wave with noise. The
% purpose of this is to analyze the FFT of a noisy wave and be able to
% distinguish host frequency and noise.

clc;
clear all;
close all;

% Here is where all of the variables of generated wave are initialized
fs = 1000;
dt = 1/fs;
StopTime = 1;
t = (0:dt:StopTime - dt);
f = 100;
A = 1;
Wave = A*sin(2*pi*f*t);
len = length(Wave);

% Here we are adding noise to the wave to simulate a noisy signal then
% plotting it
noise = 3*rand(size(t));
NoiseWave = (noise + Wave);

figure(1);
plot(t, NoiseWave);
title('Noisy Signal')
xlabel('Time(s)')
ylabel('Magnitude')

% Here we are taking the fft of the noisy wave and plotting it
ff = fft(NoiseWave);
freqspace = (0:len - 1) * fs/len;

figure(2)
plot(freqspace,abs(ff));
title('FFT of Noisy Signal')
xlabel('Frequency(Hz)')
ylabel('Amplitude')

% Finally we are taking the fft frequency shift to align the signal with
% the proper frequencies
ffs = fftshift(ff);
shiftfreqspace = (-len/2:len/2 - 1)*(fs/len);

figure(3)
plot(shiftfreqspace, abs(ffs))
title('Frequency Shift of Noisy Signal FFT')
xlabel('Frequency(Hz)')
ylabel('Amplitude')




% This program is a simulation of returned radar waves with NO ROTATION to
% create an simulated ISAR image for our radar system. Since there is no
% rotation, we can only create a one dimensional image, so the heatmap will
% just display a solid line

clc;
close all;
clear variables;

% Here all of the constants and equations used in the simulation are set.
% Many of these constants refer to our specific radar system's parameters
% and its functionality as a SFCW radar.
c = physconst('lightspeed');
steps_across_bandwidth = 512;
sample_rate = 625000;
sample_time = 1 / sample_rate;
number_of_samples = 62500;
stop_time = sample_time * number_of_samples;
bw = 1000;
range_res = c / (2 * bw);
unamb_range = range_res * steps_across_bandwidth;
step_size = bw / steps_across_bandwidth;
f_x = 100;
f_x_array = linspace(f_x,f_x + bw, steps_across_bandwidth);
target_distance = 21211111;
t = 0:sample_time:stop_time-sample_time;
steps_across_bandwidth_index = 0:steps_across_bandwidth - 1;
index_to_bandwidth = f_x + (steps_across_bandwidth_index * step_size);
freq_after_fft = linspace(0,1,number_of_samples).* sample_rate;
amp = 1;
omega = (f_x_array .* 2 .* pi)';
index_to_distance = steps_across_bandwidth_index * range_res;
phase = 0;
az_steps = 3;


% This equation is our clean transmitted wave
transmit_wave = amp .* cos((omega .* t) + phase);


% This while loop controls the plotted figures for each azimuth step of the
% radar simulation, we will plot the transmitted and recieved wave, the
% FFT, the IQ signals, Range Profile, and the Isar Image

iqaraaz = zeros(steps_across_bandwidth,az_steps);
iqabaz = zeros(steps_across_bandwidth,az_steps);
bigloop_index = 1;

while az_steps >= bigloop_index

    % Here the recieved wave is calculated based on the specified target
    % distance
    rec_amp = 1;
    tau = (2 * target_distance) / c;
    rec_wave = (rec_amp .* cos((omega .* (t - tau)) + phase))';
    
    % This figure is the plotted transmitted and recieved wave, where the
    % recieved wave is returned with a phase due to the distance tranvelled
    figure
    plot(t,transmit_wave(511,:));
    hold on
    plot(t,rec_wave(:,511));
    title('Waves at ' + string(f_x_array(1,511)) + ' Hz');
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend('Transmitted Wave','Recieved Wave');
    hold off
    
    
    % This figure plots the FFT of waves at specific frequencies in the
    % frequency steps, the I and Q portions are also plotted
    rec_wave_fft = 2 .* (fft(rec_wave) ./ number_of_samples);
    figure
    plot(freq_after_fft,real(rec_wave_fft(:,50)));
    hold on
    plot(freq_after_fft,imag(rec_wave_fft(:,50)));
    plot(freq_after_fft,abs(rec_wave_fft(:,50)));
    title('FFT on Waves at ' + string(f_x_array(1,50)) + ' Hz');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    legend('I','Q','Amplitude');
    hold off

    % THIS IS THE SECTION WHERE I GRAB THE RIGHT FREQUENCY ON EACH OF THE WAVES
    % TO GET THE AMPLITUDES OF ALL OF THE WAVES IN I AND Q
    loop_index = 1;
    iq_at_step = zeros(steps_across_bandwidth,1);
    
    while loop_index <= steps_across_bandwidth
        
        [~,step] = min(abs(freq_after_fft - index_to_bandwidth(loop_index)));
        iq_at_step(loop_index) = rec_wave_fft(step,loop_index);
    
        loop_index = loop_index + 1;
    end
    
    % This figure plots the I and Q signals at each frequency of the
    % frequency step
    figure
    plot(index_to_bandwidth,real(iq_at_step));
    hold on
    plot(index_to_bandwidth,imag(iq_at_step));
    plot(index_to_bandwidth,abs(iq_at_step));
    title('I and Q Across Bandwidth');
    xlabel('Bandwidth (Hz)');
    ylabel('Amplitude');
    legend('I','Q','Amplitude');
    hold off
    
    
    range = ifft(iq_at_step);
    
    % This figure plots the range profile using the ifft of the IQ signals
    % at each step
    figure
    plot(index_to_distance,abs(range));
    hold on
    title('Amplitude Across Range');
    xlabel('Range (m)');
    ylabel('Amplitude');
    hold off

    % THIS IS THE SECTION WHERE I GET I AND Q INFORMATION FROM THE RECIEVED
    % WAVE (USING OMEGA AND TAU)
    
    rec_i = cos(-omega .* tau);
    rec_q = sin(-omega .* tau);
    figure
    plot(index_to_bandwidth,rec_i);
    hold on
    plot(index_to_bandwidth,rec_q);
    plot(index_to_bandwidth,abs(complex(rec_i,rec_q)));
    title('I and Q Across Bandwidth');
    xlabel('Bandwidth (Hz)');
    ylabel('Amplitude');
    legend('I','Q','Amplitude');
    hold off

    iqabaz(1:steps_across_bandwidth,bigloop_index) = flip(complex(rec_i,rec_q));



    % THIS IS THE SECTION WHERE I DO AN IFFT ON THE I AND Q ACROSS THE
    % BANDWIDTH OF THE RECIEVED WAVE TO GET THE DISTANCE OF THE OBJECT IN SCENE
    iqar = ifft(complex(rec_i,rec_q));
    
    figure
    plot(index_to_distance,abs(iqar));
    hold on
    plot(index_to_distance,real(iqar));
    plot(index_to_distance,imag(iqar));
    title('Amplitude Across Range');
    xlabel('Range (m)');
    ylabel('Amplitude');
    legend('Amplitude','I','Q');
    hold off


    iqaraaz(1:steps_across_bandwidth, bigloop_index) = iqar;
    bigloop_index = bigloop_index + 1;
end

% This is a heatmap of the range across the azimuth steps to simulate an
% ISAR image which uses two dimensional FFTs of waves and color to give a
% birds-eye view of relection strength of a reflected radar wave
h = heatmap(abs(iqaraaz),'CellLabelColor','auto');
h.GridVisible = 'off';
h.YLabel = 'Range Steps';
h.XLabel = 'Azimuth Steps';
h.Title = 'Heatmap';

% Here are custom labels used for
YLabels = 1:512;
% Convert each number in the array into a string
CustomYLabels = string(YLabels);
% Replace all but the fifth elements by spaces
CustomYLabels(mod(YLabels,50) ~= 0) = " ";
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.YDisplayLabels = CustomYLabels;
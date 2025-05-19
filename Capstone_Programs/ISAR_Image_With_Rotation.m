% This program simulates a simple radar target system where create an ideal
% range profile and ISAR image. This program includes azimuth rotation 
% which allows to create an accurate ISAR image using the heatmap function.

clc;
close all;
clear variables;

% Here all of our variables and functions are initialized
c = physconst('lightspeed');
steps_across_bandwidth = 512;
sample_rate = 625000;
sample_time = 1 / sample_rate;
number_of_samples = 62500;
stop_time = sample_time * number_of_samples;
bw = 8*10^9;
range_res = c / (2 * bw);
f_x = 7.1*10^10;
f_x_array = linspace(f_x,f_x + bw,steps_across_bandwidth);
omega = (f_x_array .* 2 .* pi)';
az_steps = 16;
az_steps_index = 0:az_steps-1;
point_number = 5;
target_distance = zeros(az_steps,point_number);
target_distance(1,:) = (1:point_number)/2;
az_steps_index_centered = az_steps_index - ((az_steps - 1)/2);
tau = zeros(1,point_number);
rec_i = zeros(steps_across_bandwidth,point_number);
rec_q = zeros(steps_across_bandwidth,point_number);

loop_index = 2;
while loop_index <= az_steps
    target_distance(loop_index,:) = target_distance(loop_index - 1,:) + 0.01;
    loop_index = loop_index + 1;
end
iqabaz = zeros(steps_across_bandwidth,az_steps);

% This while loop is used to calculate tau, the time difference with the
% target reflection, and the recieved IQ signals
bigloop_index = 1;
while az_steps >= bigloop_index
    
    rec_amp = 1;
    loop_index = 1;
    while loop_index <= point_number
        
        % Here tau and the recieved I and Q signals are calculated based on
        % the specified target distance
        tau(1,:) = (2 .* target_distance(bigloop_index,:)) ./ c;
        rec_i(:,loop_index) = rec_amp .* cos(-omega .* tau(loop_index));
        rec_q(:,loop_index) = rec_amp .* sin(-omega .* tau(loop_index));

        iqabaz(1:steps_across_bandwidth,bigloop_index) = complex(rec_i(:,loop_index),rec_q(:,loop_index));
        loop_index = loop_index + 1;
    end
    bigloop_index = bigloop_index + 1;
end

newwav = fftshift(fft2(iqabaz));


% Below is the plot for the heatmap and the custom labels that allow us to
% show the azimuth steps and bandwidth steps
figure(1)
h = heatmap(log10(abs(newwav)),'CellLabelColor','auto');
h.GridVisible = 'off';
h.YLabel = 'Range Steps';
h.XLabel = 'Azimuth Steps'; 
h.Title = 'Simulated ISAR Image of Radar Target';
YLabels = 1:steps_across_bandwidth;
CustomYLabels = string(YLabels);
CustomXLabels = az_steps_index_centered;
CustomYLabels(mod(YLabels,50) ~= 0) = " ";
CustomYLabels = str2double(CustomYLabels);
CustomYLabels = CustomYLabels * range_res;
CustomYLabels = string(CustomYLabels);
h.YDisplayLabels = CustomYLabels;
h.XDisplayLabels = CustomXLabels;

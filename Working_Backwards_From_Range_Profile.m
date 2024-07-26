% This program begins with a basic range profile and works backwards from
% that range profile to create the IQ signals from its data.

% IMPORTANT NOTE ABOUT THIS PROGRAM -> This program was made only as a
% simulation of creating a IQ signals from a range profile. Remember that
% millimeter waves cannot be sampled as their frequency is too high. So,
% some of the variables for this program have been altered for the purpose
% of creating plots and showing the process of going from IQ signals to a
% range profile.

clc;
close all;
clear variables;

% Here all of the local variables and constants are initialized
c = physconst('lightspeed');
Steps_Across_Bandwidth = 512;
Sample_Rate = 10000;
Sample_Time = 1 / Sample_Rate;
Number_of_Samples = 10000;
Stop_Time = Sample_Time * Number_of_Samples;
Bandwidth = 8;
Range_Resolution = c / (2 * Bandwidth);
Step_Size = Bandwidth / Steps_Across_Bandwidth;
f_0 = 71;
Target_Distance = 2000000000;
t = 0:Sample_Time:Stop_Time - Sample_Time;

% Here we are creating arrays for the plots
Steps_Across_Bandwidth_Index = 0:Steps_Across_Bandwidth - 1;
Index_to_Distance = Steps_Across_Bandwidth_Index * Range_Resolution;
IQ_Across_Range = zeros(1, Steps_Across_Bandwidth);

% Here we are locating the bin the step across the bandwidth that
% correlates with our set target distance and setting the amplitude
[~,Step_at_Target] = min(abs(Index_to_Distance - Target_Distance));
IQ_Across_Range(Step_at_Target) = complex(1,0);

% Now we are plotting the indices accross the range giving us a simple
% range profile of a radar target at our specified distance
figure
plot(Index_to_Distance,abs(IQ_Across_Range));
hold on
plot(Index_to_Distance,real(IQ_Across_Range));
plot(Index_to_Distance,imag(IQ_Across_Range));
title('Amplitudes Across Range');
xlabel('Distance (m)');
ylabel('Amplitude');
hold off

% Now perform the fourier tranform on this to get the iq's across the
% bandwidth
IQ_Across_Bandwidth = fft(IQ_Across_Range);
IQ_Across_Freq = zeros(Number_of_Samples / 2,Steps_Across_Bandwidth);
freq_after_fft = linspace(0, 1, Number_of_Samples) .* Sample_Rate;
loop_index = 1;

% Here a while loop is used to make sure the sample rate and number of
% samples do not interfere.
while loop_index <= Steps_Across_Bandwidth
    [~,step_at_loc_freq] = min(abs(freq_after_fft - (f_0 + (Step_Size * (loop_index - 1)))));
    IQ_Across_Freq(step_at_loc_freq, loop_index) = IQ_Across_Bandwidth(loop_index);
    if step_at_loc_freq > Sample_Rate / 2
        error("Pick a smaller frequency or a larger sample rate")
    end
    loop_index = loop_index + 1;
end


% Here we are performing the inverse FFT to get our IQ signals in a time
% domain
Flip_IQ_Across_Freq = flip(IQ_Across_Freq);
IQ_Across_Freq = [IQ_Across_Freq; Flip_IQ_Across_Freq];
IQ_Across_Time = ifft(IQ_Across_Freq);
loop_index = 1;

% Now we are using a while loop to plot the IQ signals in a time domain at
% a few different bins across our 512 steps
while loop_index <= Steps_Across_Bandwidth

    if rem(loop_index,100) == 0
        
        IQ_Acorss_Time_Moment = IQ_Across_Time(:,loop_index);
        figure
        plot(t, real(IQ_Acorss_Time_Moment));
        hold on
        plot(t, imag(IQ_Acorss_Time_Moment));
        title('Signal Over Time at Bin #' + string(loop_index));
        xlabel('Time (s)');
        ylabel('Amplitude');
        legend('I','Q');
        hold off

    end

    IQ_Across_Time(:,loop_index) = complex(real(IQ_Across_Time(:,loop_index)),imag(IQ_Across_Time(:,loop_index)));
    loop_index = loop_index + 1;
end

loop_index = 1;

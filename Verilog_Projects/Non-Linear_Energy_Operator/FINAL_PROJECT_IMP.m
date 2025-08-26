clc; clear;

% Parameters
N = 256;
Fs = 1000;
t = (0:N-1)/Fs;
% Preallocate signal
ecg_like_signal = zeros(1, N);
% Spike parameters
spike_interval = 40;
spike_width = 5;

for i = 1:spike_interval:N-spike_width
    pulse = gausswin(spike_width)' * 1.5;  % Sharp positive pulse
    ecg_like_signal(i:i+spike_width-1) = ecg_like_signal(i:i+spike_width-1) + pulse;
end
% Add small noise
noise = 0.05 * randn(1, N);
noisy_signal = ecg_like_signal + noise;
% Scale and convert to int8
scaled_signal = int8(noisy_signal * 50);  % Lower scale if needed
% Write HEX values
fid = fopen('input_data.hex', 'w');
for i = 1:N
    fprintf(fid, '%02X\n', typecast(scaled_signal(i), 'uint8'));
end
fclose(fid);
% Plot
plot(t, scaled_signal);
title('ECG-like Signal');
xlabel('Time (s)');
ylabel('Amplitude');

clc

% Load Verilog output
RAW_output = readmatrix('output_data.txt');
output = double(int16(RAW_output));

% Truncate input to same length
input = double(scaled_signal(1:length(output)));

% Normalize for visual comparison (reduce distortions)
input_norm = input / max(abs(input)); % Normalizes the input
output_norm = output / max(abs(output)); % Normalizes the output

% Plot
plot(input_norm, 'b'); hold on; % Plots both norm inputs/outputs on same graph
plot(output_norm, 'r');
legend('Noisy Input (AM SIGNAL)', 'NEO Output');
xlabel('Sample Index'); ylabel('Normalized Amplitude');
title('NEO Filtering of Noisy AM SIGNAL');




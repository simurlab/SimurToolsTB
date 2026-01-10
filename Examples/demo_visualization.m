%% SimurToolsTB - Cool Visualization Demo
% A visually striking demonstration of IMU gait analysis
% Generates synthetic walking data and creates beautiful visualizations

clear; clc; close all;

%% Generate Synthetic Walking Data
fs = 100;                    % Sampling frequency (Hz)
duration = 10;               % Duration (seconds)
t = (0:1/fs:duration)';      % Time vector
n = length(t);

% Walking parameters
cadence = 1.8;               % Steps per second
step_freq = cadence;         % Fundamental frequency

% Generate realistic accelerometer signals (vertical axis - walking pattern)
% Vertical acceleration during gait has characteristic double-bump pattern
acc_v = 9.81 + ...                                          % Gravity
        2.5*sin(2*pi*step_freq*t) + ...                     % Fundamental
        1.8*sin(2*pi*2*step_freq*t + pi/4) + ...           % 2nd harmonic (heel strike)
        0.8*sin(2*pi*3*step_freq*t - pi/6) + ...           % 3rd harmonic
        0.3*randn(n,1);                                     % Noise

% Anteroposterior acceleration (forward-backward)
acc_ap = 1.2*sin(2*pi*step_freq*t - pi/3) + ...
         0.6*sin(2*pi*2*step_freq*t + pi/2) + ...
         0.15*randn(n,1);

% Mediolateral acceleration (side-to-side sway)
acc_ml = 0.8*sin(2*pi*step_freq/2*t) + ...                  % Half step freq (sway)
         0.3*sin(2*pi*step_freq*t + pi/2) + ...
         0.1*randn(n,1);

% Gyroscope signals (angular velocity)
gyro_v = 20*sin(2*pi*step_freq*t) + 5*randn(n,1);           % Yaw
gyro_ap = 80*sin(2*pi*step_freq*t - pi/4) + 8*randn(n,1);   % Pitch (leg swing)
gyro_ml = 30*sin(2*pi*step_freq*t + pi/3) + 4*randn(n,1);   % Roll

%% Detect Events (Simulated Initial Contacts)
% Find peaks in vertical acceleration (heel strikes)
[~, ic_locs] = findpeaks(acc_v, 'MinPeakHeight', 12, 'MinPeakDistance', fs/3);
ic_times = t(ic_locs);

%% Create Visualization
fig = figure('Position', [50 50 1400 900], 'Color', 'w', 'Name', 'SimurToolsTB - Gait Analysis');

% Color scheme
colors = struct();
colors.primary = [0.2 0.4 0.8];      % Blue
colors.secondary = [0.9 0.3 0.2];    % Red
colors.accent = [0.2 0.7 0.4];       % Green
colors.purple = [0.6 0.3 0.7];       % Purple
colors.orange = [0.95 0.5 0.1];      % Orange
colors.dark = [0.15 0.15 0.2];       % Dark background
colors.light = [0.95 0.95 0.97];     % Light

%% Panel 1: 3D Trajectory Visualization
subplot(2,3,1);
% Integrate accelerations to get pseudo-trajectory (simplified)
pos_ap = cumtrapz(t, cumtrapz(t, acc_ap)) * 0.01;
pos_ml = cumtrapz(t, cumtrapz(t, acc_ml)) * 0.005;
pos_v = 0.03 * sin(2*pi*2*step_freq*t);  % Vertical oscillation

% Create colormap based on time
c = linspace(0, 1, n);
scatter3(pos_ap, pos_ml, pos_v, 15, c, 'filled', 'MarkerFaceAlpha', 0.7);
hold on;
plot3(pos_ap, pos_ml, pos_v, 'Color', [colors.primary 0.3], 'LineWidth', 0.5);

% Mark heel strikes
plot3(pos_ap(ic_locs), pos_ml(ic_locs), pos_v(ic_locs), 'ro', ...
      'MarkerSize', 10, 'MarkerFaceColor', colors.secondary, 'LineWidth', 2);

colormap(gca, parula);
cb = colorbar('Location', 'southoutside');
cb.Label.String = 'Time (normalized)';
xlabel('AP (m)'); ylabel('ML (m)'); zlabel('V (m)');
title('3D CoG Trajectory', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
view(45, 25);
set(gca, 'FontSize', 9);

%% Panel 2: Vertical Acceleration with Events
subplot(2,3,2);
plot(t, acc_v, 'Color', colors.primary, 'LineWidth', 1.2);
hold on;
% Mark initial contacts
for i = 1:length(ic_locs)
    xline(ic_times(i), '--', 'Color', [colors.secondary 0.6], 'LineWidth', 1);
end
scatter(ic_times, acc_v(ic_locs), 60, colors.secondary, 'filled', 'MarkerEdgeColor', 'k');

xlabel('Time (s)'); ylabel('Acceleration (m/s²)');
title('Vertical Acceleration & Heel Strikes', 'FontSize', 12, 'FontWeight', 'bold');
legend('Acc_V', 'Initial Contact', 'Location', 'northeast');
grid on; box on;
set(gca, 'FontSize', 9);
xlim([0 5]);

%% Panel 3: Polar/Radial Acceleration Pattern
subplot(2,3,3);
% Create polar representation of horizontal accelerations
theta_polar = atan2(acc_ml, acc_ap);
r_polar = sqrt(acc_ap.^2 + acc_ml.^2);

% Use a subset for clarity
idx = 1:5:n;
polarscatter(theta_polar(idx), r_polar(idx), 20, t(idx), 'filled', 'MarkerFaceAlpha', 0.6);
hold on;

% Draw mean direction per step cycle
colormap(gca, cool);
title('Horizontal Acc. Direction', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 9);

%% Panel 4: Normalized Step Pattern (Butterfly Plot)
subplot(2,3,4);
% Extract individual steps and normalize
n_steps = length(ic_locs) - 1;
step_length = 100;  % Normalize to 100 points

if n_steps >= 2
    steps_matrix = zeros(step_length, n_steps);

    for i = 1:n_steps
        step_data = acc_v(ic_locs(i):ic_locs(i+1));
        steps_matrix(:,i) = interp1(linspace(0,1,length(step_data)), step_data, linspace(0,1,step_length));
    end

    % Plot all steps with transparency
    x_norm = linspace(0, 100, step_length);
    hold on;
    for i = 1:n_steps
        plot(x_norm, steps_matrix(:,i), 'Color', [colors.purple 0.3], 'LineWidth', 1);
    end

    % Plot mean and std bands
    mean_step = mean(steps_matrix, 2);
    std_step = std(steps_matrix, 0, 2);

    fill([x_norm fliplr(x_norm)], [mean_step'+2*std_step' fliplr(mean_step'-2*std_step')], ...
         colors.accent, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(x_norm, mean_step, 'Color', colors.dark, 'LineWidth', 2.5);

    xlabel('Gait Cycle (%)'); ylabel('Acceleration (m/s²)');
    title('Step Pattern Analysis', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Individual Steps', 'Mean ± 2σ', 'Mean', 'Location', 'northeast');
end
grid on; box on;
set(gca, 'FontSize', 9);

%% Panel 5: Spectrogram / Time-Frequency
subplot(2,3,5);
% Compute spectrogram
window = round(fs * 1);    % 1 second window
noverlap = round(window * 0.9);
nfft = 256;

[S, F, T_spec] = spectrogram(acc_v - mean(acc_v), window, noverlap, nfft, fs);
S_db = 10*log10(abs(S) + eps);

imagesc(T_spec, F, S_db);
axis xy;
colormap(gca, hot);
cb = colorbar;
cb.Label.String = 'Power (dB)';
ylim([0 10]);
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('Time-Frequency Analysis', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 9);

% Mark cadence frequency
hold on;
yline(cadence, '--w', 'LineWidth', 2);
yline(2*cadence, '--w', 'LineWidth', 1.5);
text(0.5, cadence + 0.3, 'Cadence', 'Color', 'w', 'FontWeight', 'bold');

%% Panel 6: 3D Acceleration Space
subplot(2,3,6);
% Plot acceleration in 3D space
scatter3(acc_ap(1:3:end), acc_ml(1:3:end), acc_v(1:3:end) - 9.81, ...
         15, t(1:3:end), 'filled', 'MarkerFaceAlpha', 0.5);
hold on;

% Draw principal axes (PCA)
acc_matrix = [acc_ap, acc_ml, acc_v - 9.81];
[coeff, ~, latent] = pca(acc_matrix);

% Scale eigenvectors by sqrt of eigenvalues
origin = mean(acc_matrix);
for i = 1:3
    vec = coeff(:,i)' * sqrt(latent(i)) * 0.5;
    quiver3(origin(1), origin(2), origin(3), vec(1), vec(2), vec(3), ...
            'LineWidth', 3, 'MaxHeadSize', 0.5, 'Color', [0.9 0.1 0.1], 'AutoScale', 'off');
end

colormap(gca, parula);
xlabel('AP (m/s²)'); ylabel('ML (m/s²)'); zlabel('V (m/s²)');
title('3D Acceleration Space + PCA', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
view(135, 20);
set(gca, 'FontSize', 9);

%% Add main title
sgtitle({'{\bf\fontsize{16}SimurToolsTB - IMU Gait Analysis Visualization}', ...
         '\fontsize{10}Synthetic walking data demonstration'}, ...
         'Color', colors.dark);

%% Export figure
print(gcf, fullfile(fileparts(mfilename('fullpath')), '..', 'img', 'demo_visualization.png'), '-dpng', '-r150');
fprintf('✓ Visualization saved to img/demo_visualization.png\n');
fprintf('✓ Figure displayed - explore the interactive 3D plots!\n');

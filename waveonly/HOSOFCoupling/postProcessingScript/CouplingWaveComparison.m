%% Code to Evaluate the Coupling outcome in long term cases
% MOdify the Experiment data location, HOS location and waveFoam and waveIsoFoam locations
% Run the code or modify the code to add more cases for parametric studies 

clc
close all
clear

% --- PLOT OPTION --- 
plot_option = 'Experiment HOS waveFoam waveIsoFoam';  % Choose between 'Experiment', 'HOS', 'waveFoam', 'Experiment HOS waveFoam waveIsoFoam'
probe_number = 3;
indexing = 0.9;
timeEnd = 600;  % New parameter to cut data based on time

% Define folder names for different cases
folders = {
    'M:\SPAR\Experimental_Data\SOFTWIND_Project_Data\NewData_Dec\03_Data\Irregular_Wave_Tests',
    'M:\SPAR\foamStar_Data\Irregularwaves\LC2.2\HOS\bin\Results',
    'Q:\WTD\REC\F3\Sithik_OFCases\longtermCases\testingCoupling\LC22\waveFoam\Relax07\postProcessing\surfaceElevation\0',
    'Q:\WTD\REC\F3\Sithik_OFCases\longtermCases\testingCoupling\LC22\waveIsoFoam\postProcessing\surfaceElevation\0'
};

% Load experimental data
file_exp = fullfile(folders{1}, 'Export_SW_SPAR_Group_EI_3_irregular_wave_01.mat');
data_exp = load(file_exp);
dt_exp = data_exp.data.wave.time(:);
wp_exp = data_exp.data.wave.elevation(:, probe_number);

% Load HOS data
file_hos = fullfile(folders{2}, 'probes1.txt');
data_hos = readmatrix(file_hos, 'FileType', 'text', 'NumHeaderLines', 0);
dt_hos = data_hos(:, 1);
wp_hos = data_hos(:, probe_number + 1);

% Load wave data (wave1 & wave2)
file_wave1 = fullfile(folders{3}, 'surfaceElevation.dat');
data_wave1 = readmatrix(file_wave1,'NumHeaderLines', 4);
dt_wave1 = data_wave1(:, 1);
wp_wave1 = data_wave1(:, probe_number - 1);

file_wave2 = fullfile(folders{4}, 'surfaceElevation.dat');
data_wave2 = readmatrix(file_wave2,'NumHeaderLines', 4);
dt_wave2 = data_wave2(:, 1);
wp_wave2 = data_wave2(:, probe_number - 1);

% Calculate the delta t (time step) from the first two time points
dt_exp_calc = dt_exp(2) - dt_exp(1);  % Experimental delta t
dt_hos_calc = dt_hos(2) - dt_hos(1);  % HOS delta t

% Find the index corresponding to timeEnd
index_exp_end = find(dt_exp <= timeEnd, 1, 'last');
index_hos_end = find(dt_hos <= timeEnd, 1, 'last');

% Slice the data based on timeEnd
dt_exp_cut = dt_exp(1:index_exp_end);
wp_exp_cut = wp_exp(1:index_exp_end);
dt_hos_cut = dt_hos(1:index_hos_end);
wp_hos_cut = wp_hos(1:index_hos_end);

% Plot setup
figure;
fnt = 16;
tiledlayout(3, 1);

% Time Series Plot
nexttile;
hold on;
if contains(plot_option, 'Experiment')
    plot(dt_exp_cut+1, wp_exp_cut, 'b', 'LineWidth', 1.2, 'DisplayName', 'Experiment');
end
if contains(plot_option, 'HOS')
    plot(dt_hos_cut, wp_hos_cut, 'r', 'LineWidth', 1.2, 'DisplayName', 'HOS');
end
if contains(plot_option, 'waveFoam')
    plot(dt_wave1, wp_wave1, 'k', 'LineWidth', 1.2, 'DisplayName', 'waveFoam');
end
if contains(plot_option, 'waveIsoFoam')
    plot(dt_wave2, wp_wave2, 'g', 'LineWidth', 1.2, 'DisplayName', 'waveIsoFoam');
end
grid on;
xlabel('Time (s)','Interpreter', 'latex', 'FontSize', fnt);
ylabel('Wave Elevation (m)','Interpreter', 'latex', 'FontSize', fnt);
xlim([0 100]);
set(gca, 'FontSize', fnt);


% Spectrum Plot

% Calculate the frequency spectrum
[f_exp, ~, s_exp] = freqSpectrum(dt_exp_cut, wp_exp_cut, 0);
[f_hos, ~, s_hos] = freqSpectrum(dt_hos_cut, wp_hos_cut, 0);
[f_wave1, ~, s_wave1] = freqSpectrum(dt_wave1, wp_wave1, 0);
[f_wave2, ~, s_wave2] = freqSpectrum(dt_wave2, wp_wave2, 0);

% Simple Moving Average Smoothing
window_size = 10;  % Size of the smoothing window
s_exp_smooth = filter(ones(1, window_size) / window_size, 1, s_exp);
s_hos_smooth = filter(ones(1, window_size) / window_size, 1, s_hos);
s_wave1_smooth = filter(ones(1, window_size) / window_size, 1, s_wave1);
s_wave2_smooth = filter(ones(1, window_size) / window_size, 1, s_wave2);

% Spectrum Plot
nexttile;
hold on;
if contains(plot_option, 'Experiment')
    plot(f_exp, s_exp_smooth, 'b', 'LineWidth', 1.2, 'DisplayName', 'Experiment (Smoothed)');
end
if contains(plot_option, 'HOS')
    plot(f_hos, s_hos_smooth, 'r', 'LineWidth', 1.2, 'DisplayName', 'HOS (Smoothed)');
end
if contains(plot_option, 'waveFoam')
    plot(f_wave1, s_wave1_smooth, 'k', 'LineWidth', 1.2, 'DisplayName', 'waveFoam (Smoothed)');
end
if contains(plot_option, 'waveIsoFoam')
    plot(f_wave2, s_wave2_smooth, 'g', 'LineWidth', 1.2, 'DisplayName', 'waveIsoFoam (Smoothed)');
end
grid on;
xlabel('Frequency (Hz)', 'Interpreter', 'latex', 'FontSize', fnt);
ylabel('Power Spectral Density', 'Interpreter', 'latex', 'FontSize', fnt);
xlim([0 2]);
set(gca, 'FontSize', fnt);

% Exceedance Probability Plot
nexttile;
hold on;
t_min = 0.1;

% Plot for Experiment data
if contains(plot_option, 'Experiment')
    [peaks_Elevation, prob_Elevation] = peaks_prob(dt_exp_cut, wp_exp_cut, t_min);
    plot(peaks_Elevation, prob_Elevation, 'DisplayName', 'Experiment', 'LineStyle', '-', 'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'LineWidth', 1.5);
end

% Plot for HOS data
if contains(plot_option, 'HOS')
    [peaks_Elevation, prob_Elevation] = peaks_prob(dt_hos_cut, wp_hos_cut, t_min);
    plot(peaks_Elevation, prob_Elevation, 'DisplayName', 'HOS', 'LineStyle', '-', 'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'LineWidth', 1.5);
end

% Plot for waveFoam data
if contains(plot_option, 'waveFoam')
    [peaks_Elevation, prob_Elevation] = peaks_prob(dt_wave1, wp_wave1, t_min);
    plot(peaks_Elevation, prob_Elevation, 'DisplayName', 'waveFoam', 'LineStyle', '-', 'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);
end

% Plot for waveFoam data
if contains(plot_option, 'waveIsoFoam')
    [peaks_Elevation, prob_Elevation] = peaks_prob(dt_wave2, wp_wave2, t_min);
    plot(peaks_Elevation, prob_Elevation, 'DisplayName', 'waveIsoFoam', 'LineStyle', '-', 'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', 'g', 'Color', 'g', 'LineWidth', 1.5);
end

xlim([0 Inf]);
grid on;
xlabel('Wave Elevation (m)','Interpreter', 'latex', 'FontSize', fnt);
ylabel('Exc. Prob.','Interpreter', 'latex', 'FontSize', fnt);
set(gca,'yscale','log');
set(gca, 'FontSize', fnt);

% Create one legend at the top center of the figure
legend_handle = legend('show');
legend_position = [0.4, 0.95, 0, 0];  % Position the legend at the top center
set(legend_handle, 'Position', legend_position, 'Orientation', 'horizontal');
set(gca, 'FontSize', fnt);

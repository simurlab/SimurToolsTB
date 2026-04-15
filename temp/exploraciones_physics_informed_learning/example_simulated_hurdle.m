clear; close all; clc;

%% Parámetros generales
fs = 500;              % Hz
dt = 1/fs;
t  = (0:dt:4)';         % 4 segundos
N  = numel(t);
g  = 9.81;

%% Inicializar señal de aceleración vertical cruda
a_z = -g * ones(N,1);   % gravedad dominante

%% Función auxiliar para generar vuelo balístico
addFlight = @(t0, Tf, v0) ...
    (t >= t0 & t <= t0+Tf) .* (-g);

%% --- Vuelos de pasos (cortos) ---
flightSteps = [
    0.8,  0.11;
    1.2,  0.10;
    1.6,  0.12;
];

for i = 1:size(flightSteps,1)
    t0 = flightSteps(i,1);
    Tf = flightSteps(i,2);
    a_z = a_z + addFlight(t0, Tf, 2.0);
end

%% --- Vuelo de valla (más largo y dominante) ---
t0_valla = 2.2;
Tf_valla = 0.24;        % ~240 ms (realista)
a_z = a_z + addFlight(t0_valla, Tf_valla, 3.5);

%% --- Ruido IMU ---
noiseLevel = 0.3;       % m/s^2
a_z = a_z + noiseLevel * randn(N,1);

%% --- Visualización señal cruda ---
figure;
plot(t, a_z);
xlabel('Tiempo [s]');
ylabel('a_z [m/s^2]');
title('Aceleración vertical simulada (cruda)');
grid on;

%% --- Estimar tiempo de vuelo de valla ---
[T_valla, info] = estimateHurdleFlightTime(a_z, fs);

fprintf('Tiempo de vuelo sobre la valla estimado: %.3f s\n', T_valla);

%% --- Mostrar vuelos detectados ---
fprintf('\nVuelos detectados:\n');
disp(table((1:numel(info.flightDurations))', ...
           info.flightDurations, ...
           info.flightHeights, ...
           info.flightVz0, ...
           'VariableNames', ...
           {'Vuelo','Duracion_s','Altura_rel','Vz0'}));
% [Fecha de última actualización]: 19/06/2025

% *******************************************************************************************************
% Automatización de la carga de datos y cálculo de estadísticas para los datasets del proyecto Innovaim *
% *******************************************************************************************************

clc, clear, close all;

% Define the experiment identifier
id_experimento = {'a1','a2', 'a3', 'a4', 'a5', 'a6', 'b1','b2', 'b3', 'b4', 'b5', ...
                  'c5', 'd1', 'e1', 'e2', 'e3', 'f1', 'f2'};
% id_experimento={'a1'};

% En los experimentos 'b6' y 'd1' el IMU1 se ha desconectado antes de su
% respectiva finalización. Se puede testear el IMU2.

tabla_resumen_todos_los_experimentos = table();

for i=1:numel(id_experimento)
    identificador = id_experimento{i};
    % Load calibration data from the specified experiment (ISB)
    [a_cal, g_cal, Intervalos] = carga_calibra(identificador, 1, 'N');
    % Function to perform statistical analysis on experiment data
    estadisticas_experimento
end


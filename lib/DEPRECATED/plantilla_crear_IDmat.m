%% Generamos un unico ID.mat con los datos y las condiciones de cada experimento.
%  Debería ejecutarse una sola vez para crear la BD.
%

clear, clc
datos_totales = {load('matlab.mat'), fileread(fullfile('condiciones.m')) };
save a1.mat

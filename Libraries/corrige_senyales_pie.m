%% corrige_senyales_pie
%
% Utilidad para testear NaNs en la deteccion de eventos de un experimento,
% y sustitucion por "valores razonables".
%

function [gyroml, gyroap]=corrige_senyales_pie(gyroml, gyroap, freq)
% ***********************************************************************
% ********** DETECCIÓN Y ELIMINACIÓN DE VALORES NAN DE gyroml ***********
% En el vector informacion_NaN almacenamos:
% - El número de valores NaN detectados en el giroscopio
% mediolateral (variable cantidad_NaN_gyroml).
% - Los índices asociados a cada valor NaN
% (variable indices_NaN_gyroml).
indices_NaN_gyroml = find(isnan(gyroml));
cantidad_NaN_gyroml = length(indices_NaN_gyroml);
informacion_NaN_gyroml = [cantidad_NaN_gyroml, indices_NaN_gyroml];
gyroml = gyroml(~isnan(gyroml)); % Eliminación de todos los valores NaN
%
indices_NaN_gyroant = find(isnan(gyroap));
cantidad_NaN_gyroant = length(indices_NaN_gyroant);
informacion_NaN_gyroant = [cantidad_NaN_gyroant, indices_NaN_gyroant];
gyroap = gyroap(~isnan(gyroap)); % Eliminación de todos los valores NaN
% ***********************************************************************

%% Medidas de la calidad en señales y detecciones crudas:
%
ccalidad(1)=cantidad_NaN_gyroml;
ccalidad(2)=cantidad_NaN_gyroant;

% Volcado de resultados para cortar y pegar en una hoja de cálculo:
%
% fprintf('\n NaNs eliminados del giroML y giroAP : '); 
% fprintf('%.0f \t  %.0f  \n', ccalidad');

assignin('base', 'cal_senyales', ccalidad);  % Guarda ccalidad en el workspace base


end
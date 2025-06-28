%% corrige_senyales_pie
%
% Utilidad para testear NaNs en la deteccion de eventos de un experimento,
% y sustitucion por "valores razonables".
%

function [gyroml, gyroap, ccalidad]=corrige_senyales_pie(gyroml, gyroap)
% ***********************************************************************
% ********** DETECCIÓN Y ELIMINACIÓN DE VALORES NAN DE gyroml ***********
% En el vector informacion_NaN almacenamos:
% - El número de valores NaN detectados en el giroscopio
% mediolateral (variable cantidad_NaN_gyroml).
% - Los índices asociados a cada valor NaN
% (variable indices_NaN_gyroml).
indices_NaN_gyroml = find(isnan(gyroml));
cantidad_NaN_gyroml = length(indices_NaN_gyroml);
informacion_NaN_gyroml = [cantidad_NaN_gyroml, indices_NaN_gyroml]; %#ok<NASGU>

%En caso de que el primer o el último valor sean NaN los reemplazamos por 0
if isnan(gyroml(1))
    gyroml(1)=0;
    indices_NaN_gyroml=indices_NaN_gyroml(2:end);
end
if isnan(gyroml(end))
    gyroml(end)=0;
    indices_NaN_gyroml=indices_NaN_gyroml(1:end-1);
end
% Reemplazamos los valores de NaN por una interpolación del anterior y
%posterior
for indice=indices_NaN_gyroml
    desplaza=1;
    while isnan(gyroml(indice+desplaza))
        desplaza=desplaza+1;
    end
    salto=gyroml(indice+desplaza)-gyroml(indice-1);
    paso=salto/(desplaza+1);
    gyroml(indice)=gyroml(indice-1)+paso;
end

%
indices_NaN_gyroant = find(isnan(gyroap));
cantidad_NaN_gyroant = length(indices_NaN_gyroant);
informacion_NaN_gyroant = [cantidad_NaN_gyroant, indices_NaN_gyroant]; %#ok<NASGU>

%En caso de que el primer o el último valor sean NaN los reemplazamos por 0
if isnan(gyroap(1))
    gyroap(1)=0;
    indices_NaN_gyroant=indices_NaN_gyroant(2:end);
end
if isnan(gyroap(end))
    gyroap(end)=0;
    indices_NaN_gyroant=indices_NaN_gyroant(1:end-1);
end
% Reemplazamos los valores de NaN por una interpolación del anterior y
%posterior
for indice=indices_NaN_gyroant
    desplaza=1;
    while isnan(gyroap(indice+desplaza))
        desplaza=desplaza+1;
    end
    salto=gyroap(indice+desplaza)-gyroap(indice-1);
    paso=salto/(desplaza+1);
    gyroap(indice)=gyroap(indice-1)+paso;
end




% ***********************************************************************

%% Medidas de la calidad en señales y detecciones crudas:
%
ccalidad(1)=cantidad_NaN_gyroml;
ccalidad(2)=cantidad_NaN_gyroant;

% Volcado de resultados para cortar y pegar en una hoja de cálculo:
%
% fprintf('\n NaNs eliminados del giroML y giroAP : '); 
% fprintf('%.0f \t  %.0f  \n', ccalidad');

%assignin('base', 'cal_senyales', ccalidad);  % Guarda ccalidad en el workspace base


end
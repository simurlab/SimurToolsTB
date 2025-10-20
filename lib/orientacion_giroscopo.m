function angulo = orientacion_giroscopo(vel_giro, angulo0, freq)
%ORIENTACION_GIROSCOPO Calcula la orientación a partir de un giróscopo en el COG.
%
%   angulo = orientacion_giroscopo(vel_giro, angulo0, freq)
%
%   Esta función estima la orientación acumulada integrando la velocidad de
%   giro en el eje vertical. Conserva entre llamadas el ángulo y la
%   frecuencia de muestreo, de modo que no es necesario volver a
%   proporcionarlos en cada invocación.
%
% INPUT:
%   vel_giro : vector con la velocidad de giro respecto al eje vertical
%              (rad/s) en cada periodo de muestreo.
%   angulo0  : (opcional) valor inicial del ángulo en radianes. Por defecto 0.
%              Se conserva entre llamadas.
%   freq     : (opcional) frecuencia de muestreo en Hz. Por defecto 100 Hz.
%              Se conserva entre llamadas.
%
% OUTPUT:
%   angulo : vector con el ángulo acumulado en radianes correspondiente a
%            cada muestra del vector vel_giro.
%
% EJEMPLO:
%   vel = [ones(1,100) zeros(1,100)] * 0.1; % velocidad angular 0.1 rad/s
%   ang = orientacion_giroscopo(vel, 0, 100);
%   plot(rad2deg(ang)), ylabel('Ángulo [°]'), xlabel('Muestras')
%
% See also: orientacion_compas, orientacion_kalman
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           13.12.2007   adaptado para uso online y documentado
%           30.09.2025   normalizada y modernizada

    % --- Variables persistentes ---
    persistent estado
    if isempty(estado)
        estado.angulo0 = 0;
        estado.freq = 100;
    end

    % --- Actualizar parámetros si se proporcionan ---
    if nargin > 1
        estado.angulo0 = angulo0;
        if nargin > 2
            estado.freq = freq;
        else
            estado.freq = 100;
        end
    end

    % --- Integración de la velocidad angular ---
    angulo = cumsum(vel_giro) / estado.freq;

    % --- Ajuste con ángulo inicial acumulado ---
    angulo = angulo + estado.angulo0;

    % --- Guardar último ángulo para próximas llamadas ---
    estado.angulo0 = angulo(end);
end

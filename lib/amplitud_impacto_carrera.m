function [impact_acc, impact_acc_moda] = amplitud_impacto_carrera(IC, acc_vertical)
% AMPLITUD_IMPACTO_CARRERA Calcula la aceleración vertical (impacto) durante foot-strike.
%
%   [impact_acc, impact_acc_moda] = amplitud_impacto_carrera(IC, acc_vertical)
%
% INPUT:
%   IC             - Array de celdas con las muestras de los eventos 
%                    de foot-strike (talonazo).
%   acc_vertical   - Vector con la aceleración en el eje vertical (Z).
%
% OUTPUT:
%   impact_acc       - Vector con los valores de aceleración vertical
%                      en los eventos de foot-strike, normalizados en unidades G.
%   impact_acc_moda  - Valor más frecuente (moda) de la aceleración de impacto.
%
% EXAMPLE:
%   % A partir de señales de aceleración y eventos:
%   [impact, impact_moda] = amplitud_impacto_carrera(IC, acc_vertical);
%
% Author:   Alejandro
% History:  01.07.25    creación del archivo
%           29.09.25    normalizada y modernizada
%

    % Convertimos IC de celda a matriz para acceder a los valores
    IC = cell2mat(IC);

    % Guardamos los índices de los eventos de foot-strike en una variable
    muestras_footstrike = IC;

    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;

    % Extraemos los valores de aceleración en el eje vertical
    % en los eventos de foot-strike y los normalizamos en unidades de Gs
    impact_acc = acc_vertical(muestras_footstrike) / g_teorica;

    % Calculamos la moda de la aceleración de impacto
    impact_acc_moda = mode(impact_acc);

    % Representación gráfica de la aceleración de impacto en cada foot-strike
    figure
    plot(impact_acc, 'r*')  % Se usa '*' para marcar cada punto
    title('Impact Gs Amplitude')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración de impacto (Gs)')

end

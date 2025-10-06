function [braking_acc, braking_acc_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior)
% AMPLITUD_FRENADO_CARRERA Calcula la aceleración anteroposterior (braking) durante foot-strike.
%
%   [braking_acc, braking_acc_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior)
%
% INPUT:
%   IC                   - Array de celdas con las muestras de los eventos 
%                          de foot-strike (talonazo).
%   acc_antero_posterior - Vector con la aceleración en el eje anteroposterior.
%
% OUTPUT:
%   braking_acc       - Vector con los valores de aceleración anteroposterior
%                       en los eventos de foot-strike, normalizados en unidades G.
%   braking_acc_moda  - Valor más frecuente (moda) de la aceleración de frenado.
%
% EXAMPLE:
%   % A partir de señales de aceleración y eventos:
%   [brake, brake_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior);
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

    % Extraemos los valores de aceleración en el eje anteroposterior
    % en los eventos de foot-strike y los normalizamos en unidades de Gs
    braking_acc = acc_antero_posterior(muestras_footstrike) / g_teorica;

    % Calculamos la moda de la aceleración de frenado
    braking_acc_moda = mode(braking_acc);

    % Representación gráfica de la aceleración de frenado en cada foot-strike
    figure
    plot(braking_acc, 'g*')  % Se usa '*' para marcar cada punto
    title('Braking Gs Amplitude')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración de frenado (Gs)')

end

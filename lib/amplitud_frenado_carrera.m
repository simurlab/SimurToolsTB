function [braking_acc, braking_acc_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior, plot_graph)
% AMPLITUD_FRENADO_CARRERA Calcula la aceleración anteroposterior (braking) durante foot-strike.
%
%   [braking_acc, braking_acc_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior)
%   [braking_acc, braking_acc_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior, plot_graph)
%
% INPUT:
%   IC                   - Array de celdas con las muestras de los eventos 
%                          de foot-strike (talonazo).
%   acc_antero_posterior - Vector con la aceleración en el eje anteroposterior.
%   plot_graph (opcional)- Booleano: si es true, muestra el gráfico. (por defecto = false)
%
% OUTPUT:
%   braking_acc       - Vector con los valores de aceleración anteroposterior
%                       en los eventos de foot-strike, normalizados en unidades G.
%   braking_acc_moda  - Valor más frecuente (moda) de la aceleración de frenado.
%
% EXAMPLE:
%   % A partir de señales de aceleración y eventos:
%   [brake, brake_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior);
%   [brake, brake_moda] = amplitud_frenado_carrera(IC, acc_antero_posterior, true); % con gráfico
%
% Author:   Alejandro
% History:  01.07.25    creación del archivo
%           29.09.25    normalizada y modernizada
%           06.10.25    añadido parámetro opcional plot_graph
%

    % ------------------ Valores por defecto ------------------
    if nargin < 3
        plot_graph = false;
    end

    % ------------------ Procesamiento ------------------
    % Convertimos IC de celda a matriz para acceder a los valores
    IC = cell2mat(IC);

    % Guardamos los índices de los eventos de foot-strike
    muestras_footstrike = IC;

    % Definimos la aceleración de la gravedad [m/s^2]
    g_teorica = 9.81;

    % Extraemos la aceleración en los eventos de foot-strike y la normalizamos
    braking_acc = acc_antero_posterior(muestras_footstrike) / g_teorica;

    % Calculamos la moda de la aceleración de frenado
    braking_acc_moda = mode(braking_acc);

    % ------------------ Gráfico opcional ------------------
    if plot_graph
        figure
        plot(braking_acc, 'g*', 'DisplayName', 'Braking Gs Amplitude');
        title('Braking Gs Amplitude');
        xlabel('Eventos de foot-strike');
        ylabel('Aceleración de frenado (Gs)');
        grid on
    end
end

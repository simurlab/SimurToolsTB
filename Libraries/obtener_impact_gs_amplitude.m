function [impact_acc, impact_acc_moda] = obtener_impact_gs_amplitude(IC, accz)
    % **************************************************************************************************
    % Función que calcula la aceleración en el eje vertical (impacto) 
    % durante los eventos de foot-strike.
    %
    % Parámetros de entrada:
    % --------------------------------------------------------------
    % * IC: muestras correspondientes a los eventos de foot-strike.
    %       (Debe ser un array de celdas con los índices de los eventos).
    % * accz: aceleración en el eje vertical.
    %       (Vector con los valores de aceleración en el eje z).
    %
    % Variables de salida devueltas:
    % --------------------------------------------------------------
    % * impact_acc: vector con los valores de aceleración en el eje vertical 
    %   en los eventos de foot-strike, normalizados en unidades de gravedad (Gs).
    % * impact_acc_moda: valor más frecuente de la aceleración de impacto.
    % **************************************************************************************************

    % Convertimos IC de celda a matriz para acceder a los valores
    IC = cell2mat(IC);

    % Guardamos los índices de los eventos de foot-strike en una variable
    muestras_footstrike = IC;

    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;

    % Extraemos los valores de aceleración en el eje vertical (z)
    % en los eventos de foot-strike y los normalizamos en unidades de Gs
    impact_acc = accz(muestras_footstrike) / g_teorica;

    % Calculamos la moda de la aceleración de impacto
    impact_acc_moda = mode(impact_acc);

    % Representación gráfica de la aceleración de impacto en cada foot-strike
    figure
    plot(impact_acc, 'r*')  % Se usa '*' para marcar cada punto
    title('Impact Gs Amplitude')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración de impacto (Gs)')

end

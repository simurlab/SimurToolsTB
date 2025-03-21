function [braking_acc, braking_acc_moda] = obtener_braking_gs_amplitude(IC, accx)
    % **************************************************************************************************
    % Función que calcula la aceleración en el eje anteroposterior (braking)
    % durante los eventos de foot-strike.
    %
    % Parámetros de entrada:
    % --------------------------------------------------------------
    % * IC: muestras correspondientes a los eventos de foot-strike.
    %       (Debe ser un array de celdas con los índices de los eventos).
    % * accx: aceleración en el eje anteroposterior.
    %       (Vector con los valores de aceleración en el eje x).
    %
    % Variables de salida devueltas:
    % --------------------------------------------------------------
    % * braking_acc: vector con los valores de aceleración anteroposterior 
    %   en los eventos de foot-strike, normalizados en unidades de gravedad (Gs).
    % * braking_acc_moda: valor más frecuente de la aceleración de frenado.
    % **************************************************************************************************

    % Convertimos IC de celda a matriz para acceder a los valores
    IC = cell2mat(IC);

    % Guardamos los índices de los eventos de foot-strike en una variable
    muestras_footstrike = IC;

    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;

    % Extraemos los valores de aceleración en el eje anteroposterior (x)
    % en los eventos de foot-strike y los normalizamos en unidades de Gs
    braking_acc = accx(muestras_footstrike) / g_teorica;

    % Calculamos la moda de la aceleración de frenado
    braking_acc_moda = mode(braking_acc);

    % Representación gráfica de la aceleración de frenado en cada foot-strike
    figure
    plot(braking_acc, 'g*')  % Se usa '*' para marcar cada punto
    title('Braking Gs Amplitude')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración de frenado (Gs)')

end

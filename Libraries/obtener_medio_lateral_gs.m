function [acc_medio_lateral_footstrike, acc_medio_lateral_footstrike_moda] = obtener_medio_lateral_gs(IC, acc_medio_lateral)
    % **************************************************************************************************
    % Función que calcula la aceleración en el eje medio-lateral durante
    % cada heel-strike.
    %
    % Parámetros de entrada:
    % --------------------------------------------------------------
    % * IC: muestras correspondientes a los eventos de foot-strike.
    %       (Debe ser un array de celdas que contiene índices de los eventos).
    % * acc_medio_lateral: aceleración en el eje medio-lateral.
    %       (Vector con los valores de aceleración en el eje medio-lateral).
    %
    % Variables de salida devueltas:
    % --------------------------------------------------------------
    % * acc_medio_lateral_footstrike: vector de aceleración medida en el
    %   eje mediolateral durante los eventos de foot-strike.
    % * acc_medio_lateral_footstrike_moda: valor más frecuente de la aceleración
    %   medio-lateral en los eventos de foot-strike.
    % **************************************************************************************************
    
    % Convertimos IC de celda a matriz para facilitar el acceso a los datos
    IC = cell2mat(IC);
    
    % Guardamos los índices de los eventos de foot-strike en una variable
    muestras_footstrike = IC;
    
    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;  
    
    % Extraemos los valores de aceleración en el eje medio-lateral en los eventos de foot-strike
    % y los normalizamos dividiéndolos por la gravedad para obtener unidades en [Gs]
    acc_medio_lateral_footstrike = acc_medio_lateral(muestras_footstrike) / g_teorica;  
    
    % Calculamos la moda de la aceleración medio-lateral en los eventos de foot-strike
    acc_medio_lateral_footstrike_moda = mode(acc_medio_lateral_footstrike);  

    % Representación gráfica de la aceleración medio-lateral en cada foot-strike
    figure
    plot(acc_medio_lateral_footstrike, 'b*')  % Se usa '*' para marcar cada punto
    title('Medio lateral Gs de lado a lado - Gs pico en FootStrike')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración medio-lateral (Gs)')

end
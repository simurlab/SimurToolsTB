function [rms_acc_frenado_segmentos, rms_acc_frenado_moda] = obtener_rms_acc_frenado(IC, FC, acc_antero_posterior, gyr_medio_lateral)
    % **************************************************************************************************
    % Función que calcula la aceleración de frenado en segmentos específicos
    % usando la raíz cuadrática media (RMS) basada en eventos de foot-strike y toe-off.
    %
    % Parámetros de entrada:
    % --------------------------------------------------------------
    % * IC: muestras correspondientes a los eventos de foot-strike.
    %       (Debe ser un array de celdas con los índices de los eventos).
    % * FC: muestras correspondientes a los eventos de toe-off.
    %       (Debe ser un array de celdas con los índices de los eventos).
    % * acc_antero_posterior: aceleración en el eje anteroposterior.
    %       (Vector con los valores de aceleración en el eje de la dirección 
    %        de avance del movimiento, anteroposterior).
    % * gyr_medio_lateral: velocidad angular en el eje medio-lateral.
    %       (Vector con los valores de velocidad angular medio-lateral en °/s).
    %
    % Variables de salida devueltas:
    % --------------------------------------------------------------
    % * rms_acc_frenado_segmentos: vector con los valores RMS de la aceleración de frenado
    %   en los segmentos definidos entre el foot-strike y el punto de máxima velocidad 
    %   angular mediolateral.
    % * rms_acc_frenado_moda: valor más frecuente de los RMS de aceleración de frenado.
    % **************************************************************************************************

    % Convertimos IC y FC de celda a matriz para acceder a los valores
    IC = cell2mat(IC);
    FC = cell2mat(FC);

    % Guardamos los índices de los eventos en variables más descriptivas
    muestras_footstrike = IC;
    muestras_toe_off = FC;

    % Inicializamos variables para almacenar los segmentos de aceleración de frenado
    acc_frenado_segmentos = {};      % Usamos celdas porque los segmentos pueden tener diferente longitud
    rms_acc_frenado_segmentos = [];  % Vector para almacenar los valores RMS

    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;

    % Recorremos cada evento de foot-strike para calcular la aceleración de frenado en su segmento correspondiente
    for i = 1:length(muestras_footstrike)
        % Extraemos la señal del giroscopio en el eje medio-lateral para el segmento entre foot-strike y toe-off
        gyr_medio_lateral_segmento = gyr_medio_lateral(muestras_footstrike(i):muestras_toe_off(i));           % [°/s]

        % Encontramos el valor máximo de la velocidad angular y su índice dentro del segmento
        [max_giroscopio_mediolateral, indice_max_giroscopio_mediolateral] = max(gyr_medio_lateral_segmento);  % [°/s]

        % Extraemos la señal de aceleración de frenado desde el foot-strike hasta el índice del máximo giroscopio en el eje medio-lateral
        acc_frenado_segmentos{i} = acc_antero_posterior(muestras_footstrike(i):muestras_footstrike(i) + indice_max_giroscopio_mediolateral) / g_teorica;  % [Gs]

        % Calculamos la raíz cuadrática media (RMS) del segmento de aceleración de frenado
        rms_acc_frenado_segmentos(i) = rms(acc_frenado_segmentos{i});  % [Gs]
    end

    % Calculamos la moda de los valores RMS obtenidos
    rms_acc_frenado_moda = mode(rms_acc_frenado_segmentos);            % [Gs]

    % Representación gráfica de los valores RMS de aceleración de frenado
    figure
    plot(rms_acc_frenado_segmentos, 'k*')  % Se usa '*' para marcar cada punto
    title('RMS de frenado e impacto desaceleración')
    xlabel('Eventos de foot-strike')
    ylabel('RMS de aceleración de frenado (Gs)')

end

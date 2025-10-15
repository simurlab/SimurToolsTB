%% Septiembre 2025
%
% Implementación en MATLAB de una versión simplificada del método Stepcount.
% Se elimina la parte correspondiente al modelo de clasificación.
%
% Suposición: los datos (X_PMP) corresponden a la actividad "caminar usual speed"
% del dataset PMP.

function numero_de_pasos = stepcount(X_PMP, identificacion_dataset)
    % Implementación manual del algoritmo Stepcount para la contabilización del número de pasos.
    %
    % Entradas:
    %   X_PMP: matriz de dimensiones (muestras, número de características, tamaño de ventana)
    %           Contiene datos de acelerometría.
    %   identificacion_dataset: cadena con el identificador del dataset.
    %
    % Salida:
    %   numero_de_pasos: número total de pasos detectados.
    %

    % --------------------------------------------
    % 1. Extracción de la componente vertical (eje Z)
    % --------------------------------------------
    X_subset_PMP_acelerometro_eje_z = [];
    for i = 1:size(X_PMP, 1)
        X_subset_PMP_acelerometro_eje_z(i, :) = squeeze(X_PMP(i, 3, :));  % Eje Z del acelerómetro
    end

    fprintf('Dimensiones de los datos X_subset_PMP_acelerometro_eje_Z: [%d, %d]\n', ...
        size(X_subset_PMP_acelerometro_eje_z, 1), size(X_subset_PMP_acelerometro_eje_z, 2));

    % Convertir a vector columna
    acc_z_PMP = reshape(X_subset_PMP_acelerometro_eje_z.', [], 1);

    % --------------------------------------------
    % 2. Gráfica señal original
    % --------------------------------------------
    figure('Name','Stepcount Algorithm','NumberTitle','off');
    subplot(2,1,1);
    plot(acc_z_PMP);
    xlabel('Sample [-]');
    ylabel('Accelerometer data [g]. Z axis');
    grid on;
    title(['Acc Z. ', identificacion_dataset, ' dataset']);

    % --------------------------------------------
    % 3. Fase 1: Filtrado paso-bajo Butterworth
    % --------------------------------------------
    fs = 25;                             % Frecuencia de muestreo [Hz]
    fc = 2;                              % Frecuencia de corte [Hz]
    Wn = fc / fs;                        % Frecuencia de corte normalizada (0-1)
    orden = 4;                           % Orden del filtro

    [b, a] = butter(orden, Wn, 'low');
    acc_z_PMP_filtrada = filtfilt(b, a, acc_z_PMP);

    % --------------------------------------------
    % 4. Fase 2: Detección de picos
    % --------------------------------------------
    [maximos, ~] = findpeaks(acc_z_PMP_filtrada);

    % Diferencia entre índices consecutivos
    diff_maximos = diff(maximos);
    distancia_minima_entre_maximos = 20;

    mask = diff_maximos < distancia_minima_entre_maximos;
    idx_eliminar = find(mask) + 1;
    maximos_sin_falsos = maximos;
    maximos_sin_falsos(idx_eliminar) = [];

    % Cálculo de prominencias
    [prominencias, ~, ~] = findpeaks(acc_z_PMP_filtrada, 'SortStr', 'none');
    umbral_prominencia = 0.1;
    maximos_filtrados = maximos_sin_falsos(prominencias >= umbral_prominencia);

    % --------------------------------------------
    % 5. Fase 3: Representación gráfica resultados
    % --------------------------------------------
    subplot(2,1,2);
    plot(acc_z_PMP_filtrada);
    hold on;
    for idx = 1:length(maximos_filtrados)
        xline(maximos_filtrados(idx), '--r', 'LineWidth', 1);
    end
    plot(maximos_filtrados, acc_z_PMP_filtrada(maximos_filtrados), 'ro', 'MarkerFaceColor', 'r');
    xlabel('Sample [-]');
    ylabel('Accelerometer data filtered [g]. Z axis');
    grid on;
    title(['Vertical component of acceleration (FILTERED). ', identificacion_dataset, ' dataset']);

    % --------------------------------------------
    % 6. Resultado final
    % --------------------------------------------
    numero_de_pasos = length(maximos_filtrados);
    fprintf('\nEl número de pasos dados por el sujeto del dataset %s durante la actividad es: %d pasos.\n', ...
        identificacion_dataset, numero_de_pasos);

    % Texto informativo en la gráfica
    texto = sprintf('Número de pasos contabilizados: %d', numero_de_pasos);
    text(length(acc_z_PMP_filtrada)*0.5, mean(acc_z_PMP_filtrada), texto, ...
        'Color','blue','FontSize',12,'HorizontalAlignment','center');

    hold off;
end

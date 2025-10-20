function [num_pasos, indices_pasos] = contar_pasos_muneca_fusion(ax, ay, az, gx, gy, gz, fs)
% CONTAR_PASOS_FUSION
% Cuenta pasos a partir de datos de acelerómetro y giroscopio
% de una IMU ubicada en la muñeca.
%
% Sintaxis:
%   [num_pasos, indices_pasos] = contar_pasos_fusion(ax, ay, az, gx, gy, gz, fs)
%
% Entradas:
%   ax, ay, az : aceleraciones (en g)
%   gx, gy, gz : velocidades angulares (en °/s)
%   fs          : frecuencia de muestreo (Hz)
%
% Salidas:
%   num_pasos      : número de pasos detectados
%   indices_pasos  : índices (muestras) donde se detectaron pasos

    % 1. Magnitud total de la aceleración
    a_mag = sqrt(ax.^2 + ay.^2 + az.^2);

    % 2. Eliminación de la gravedad
    a_suave = movmean(a_mag, round(fs)); 
    a_sin_gravedad = a_mag - a_suave;

    % 3. Filtrado pasa banda para aislar frecuencia de caminata
    fc_baja = 0.8;  % Hz
    fc_alta = 3.0;  % Hz
    [b, a] = butter(2, [fc_baja fc_alta]/(fs/2), 'bandpass');
    a_filt = filtfilt(b, a, a_sin_gravedad);

    % 4. Normalización
    a_norm = a_filt / max(abs(a_filt));

    % 5. Magnitud del giroscopio
    g_mag = sqrt(gx.^2 + gy.^2 + gz.^2);

    % 6. Detección de picos en la aceleración
    umbral_acc = 0.15;
    [picos, locs] = findpeaks(a_norm, ...
                              'MinPeakHeight', umbral_acc, ...
                              'MinPeakDistance', 0.4*fs);

    % 7. Validación con giroscopio
    % Se acepta un paso solo si hay suficiente energía de rotación cerca del pico
    pasos_validos = [];
    ventana_tiempo = round(0.25 * fs);  % ±0.25 s alrededor del pico
    umbral_giro = 20;                   % °/s promedio mínimo

    for i = 1:length(locs)
        idx_ini = max(1, locs(i) - ventana_tiempo);
        idx_fin = min(length(g_mag), locs(i) + ventana_tiempo);
        if mean(g_mag(idx_ini:idx_fin)) > umbral_giro
            pasos_validos(end+1) = locs(i);
        end
    end

    % 8. Resultados
    num_pasos = length(pasos_validos);
    indices_pasos = pasos_validos;

    % 9. Visualización opcional
    figure;
    t = (0:length(a_norm)-1)/fs;
    subplot(2,1,1);
    plot(t, a_norm, 'b');
    hold on;
    plot(t(pasos_validos), a_norm(pasos_validos), 'ro', 'MarkerFaceColor', 'r');
    xlabel('Tiempo (s)');
    ylabel('Aceleración normalizada');
    title(['Pasos detectados (fusión A+G): ', num2str(num_pasos)]);
    grid on;

    subplot(2,1,2);
    plot(t, g_mag, 'k');
    xlabel('Tiempo (s)');
    ylabel('Magnitud giroscopio (°/s)');
    grid on;
end

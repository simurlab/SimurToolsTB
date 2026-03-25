function [num_pasos, indices_pasos] = contar_pasos_muneca(ax, ay, az, fs)
% CONTAR_PASOS_MUNECA - Cuenta pasos a partir de señales de acelerometría 
% de una IMU ubicada en la muñeca.
%
% Sintaxis:
%   [num_pasos, indices_pasos] = contar_pasos_muneca(ax, ay, az, fs)
%
% Entradas:
%   ax, ay, az : vectores con las componentes del acelerómetro (en g)
%   fs          : frecuencia de muestreo en Hz
%
% Salidas:
%   num_pasos      : número total de pasos detectados
%   indices_pasos  : índices donde se detectaron pasos

    % 1. Magnitud total de la aceleración
    a_mag = sqrt(ax.^2 + ay.^2 + az.^2);
    
    % 2. Eliminación del componente de gravedad mediante suavizado
    a_suave = movmean(a_mag, round(fs));     % promedio móvil de 1 s
    a_sin_gravedad = a_mag - a_suave;
    
    % 3. Filtro pasa banda para aislar la frecuencia típica de los pasos
    fc_baja = 0.8;   % Hz
    fc_alta = 3.0;   % Hz
    [b, a] = butter(2, [fc_baja fc_alta]/(fs/2), 'bandpass');
    a_filt = filtfilt(b, a, a_sin_gravedad);

    % 4. Normalización
    a_norm = a_filt / max(abs(a_filt));

    % 5. Detección de picos
    umbral = 0.15;   % Umbral de detección
    [picos, locs] = findpeaks(a_norm, ...
                              'MinPeakHeight', umbral, ...
                              'MinPeakDistance', 0.4*fs);

    % 6. Eliminación de falsos positivos
    amplitudes_validas = picos > 0.5 * median(picos);
    locs = locs(amplitudes_validas);
    picos = picos(amplitudes_validas);

    % 7. Resultados finales
    num_pasos = length(locs);
    indices_pasos = locs;

    % 8. Visualización opcional
    figure;
    t = (0:length(a_norm)-1)/fs;
    plot(t, a_norm, 'b');
    hold on;
    plot(t(locs), picos, 'ro', 'MarkerFaceColor', 'r');
    xlabel('Tiempo (s)');
    ylabel('Aceleración normalizada');
    title(['Pasos detectados (IMU en muñeca): ', num2str(num_pasos)]);
    grid on;
end
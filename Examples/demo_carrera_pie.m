%% =========================================================================
%  DEMO: Análisis de carrera con IMU en el pie
%  SiMuR Tools TB — ejemplo de uso
% ==========================================================================
%
%  Este script muestra el flujo completo de análisis de carrera a partir
%  de los datos de IMUs colocadas en los pies (pie derecho y/o izquierdo).
%
%  PIPELINE:
%    1. Carga de señales en coordenadas anatómicas    → carga_IMUstd
%    2. Corrección de NaNs en señales de giro         → corrige_seniales_pie
%    3. Detección de eventos del ciclo de zancada     → eventos_pie_carrera
%    4. Corrección de NaNs en eventos                 → corrige_eventos_pie
%    5. Patrones de señal por paso                    → mostrar_patrones
%    6. Tiempos de fase del ciclo                     → tiempos_eventos_carrera
%    7. Cadencia                                      → cadencia
%    8. Amplitud de impacto y frenado                 → amplitud_impacto_pie_carrera
%                                                        amplitud_frenado_pie_carrera
%    9. RMS de aceleración de impacto y frenado       → aceleracion_vert_impacto_pie_carrera
%                                                        aceleracion_vert_frenado_pie_carrera
%   10. Tabla resumen de resultados
%
%  FORMATO DE DATOS:
%    Los archivos de intento deben seguir el formato IMUstd.
%    Los sensores de pie deben estar guardados con los identificadores
%    'FR_1' (pie derecho) y 'FL_1' (pie izquierdo).
%
%  SiMuR Lab — Universidad de Oviedo, 2025
%
%  EJEMPLO DE USO:
%    Ejecutar directamente — el script carga el archivo de ejemplo incluido:
%    >> demo_carrera_pie
%
%    Para usar tus propios datos, sustituye 'archivo' en la sección de
%    configuración (línea 36) por la ruta a tu archivo .mat.
% ==========================================================================

clear; clc;

%% ── 1. CONFIGURACIÓN  ────────────────────────────────────────────────────

% Ruta al archivo de datos. Por defecto usa el ejemplo incluido.
archivo  = fullfile(fileparts(mfilename('fullpath')), 'data', 'ejemplo_carrera.mat');

sensores = {'FR_1', 'FL_1'};   % Sensores a procesar (pie derecho e izquierdo)
freq     = 120;                % Frecuencia de muestreo [Hz]
th       = 150;                % Umbral mínimo de velocidad angular para detección [°/s]

% Pasos a excluir en los extremos (aceleración/deceleración del corredor)
pasos_excluir_inicio = 1;
pasos_excluir_final  = 1;


%% ── 2. CARGA DEL ARCHIVO  ────────────────────────────────────────────────

if ~isfile(archivo)
    error('Archivo de datos no encontrado:\n  %s', archivo);
end

fprintf('── Procesando: %s\n', archivo);


%% ── 3. PROCESAMIENTO  ───────────────────────────────────────────────────

resultados = {};

for p = 1:numel(sensores)

    sensor_id = sensores{p};

    % ------------------------------------------------------------------
    % 3.1  Carga de señales en sistema de referencia anatómico {V, ML, AP}
    %      carga_IMUstd devuelve aceleraciones y giros ya calibrados y
    %      reorientados: columna 1 = Vertical, 2 = MedioLateral,
    %      3 = AnteroPosterior.
    % ------------------------------------------------------------------
    try
        [a_cal, g_cal] = carga_IMUstd(archivo, sensor_id);
    catch
        fprintf('   Sensor %s no disponible. Se omite.\n', sensor_id);
        continue;
    end

    acc_v  = a_cal(:,1);   % Aceleración vertical
    acc_ml = a_cal(:,2);   % Aceleración mediolateral
    acc_ap = a_cal(:,3);   % Aceleración anteroposterior

    gyr_ml = g_cal(:,2);   % Giro mediolateral  (base para detección de eventos)
    gyr_ap = g_cal(:,3);   % Giro anteroposterior (pronación)

    % ------------------------------------------------------------------
    % 3.2  Corrección de NaNs en las señales de giro
    %      corrige_seniales_pie sustituye NaNs por interpolación lineal
    %      y devuelve el nº de muestras corregidas en cada señal.
    % ------------------------------------------------------------------
    [gyr_ml, gyr_ap, cal_seniales] = corrige_seniales_pie(gyr_ml, gyr_ap);

    if any(cal_seniales > 0)
        fprintf('   %s: NaNs corregidos → ML: %d, AP: %d\n', ...
            sensor_id, cal_seniales(1), cal_seniales(2));
    end

    % ------------------------------------------------------------------
    % 3.3  Detección de eventos del ciclo de zancada
    %      eventos_pie_carrera detecta, a partir del giro mediolateral,
    %      los seis eventos principales del ciclo:
    %        ic    — Initial Contact (foot-strike)
    %        fc    — Final Contact (toe-off)
    %        max_s — Máximo swing (pie hacia adelante)
    %        min_s — Mínimo swing (pie hacia atrás)
    %        mvp   — Máxima velocidad de pronación
    %        mp    — Máxima pronación
    % ------------------------------------------------------------------
    [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr_ml, th, freq, gyr_ap);

    if isempty(ic) || isempty(fc)
        warning('No se detectaron eventos para el sensor %s. Se omite.', sensor_id);
        continue;
    end

    fprintf('   %s: %d pasos detectados\n', sensor_id, numel(ic));

    % ------------------------------------------------------------------
    % 3.4  Corrección de NaNs en los eventos detectados
    %      corrige_eventos_pie estima por interpolación los eventos que
    %      no pudieron detectarse correctamente (NaN en la matriz).
    %      La matriz de eventos tiene una fila por tipo de evento.
    % ------------------------------------------------------------------
    mat_eventos = [ic; mvp; mp; fc; min_s; max_s];
    [mat_eventos, ~] = corrige_eventos_pie(mat_eventos, freq);

    ic    = mat_eventos(1,:);
    mvp   = mat_eventos(2,:);
    mp    = mat_eventos(3,:);
    fc    = mat_eventos(4,:);
    min_s = mat_eventos(5,:);
    max_s = mat_eventos(6,:);

    % ------------------------------------------------------------------
    % 3.5  Patrones de señal por paso
    %      mostrar_patrones superpone el perfil de cada paso normalizado
    %      y representa la media ± 2·σ.
    %      Se genera una figura por señal; ajusta la lista según interés.
    % ------------------------------------------------------------------
    mostrar_patrones(ic, acc_v,  pasos_excluir_inicio, pasos_excluir_final);
    mostrar_patrones(ic, acc_ml, pasos_excluir_inicio, pasos_excluir_final);
    mostrar_patrones(ic, acc_ap, pasos_excluir_inicio, pasos_excluir_final);
    mostrar_patrones(ic, gyr_ml, pasos_excluir_inicio, pasos_excluir_final);

    % ------------------------------------------------------------------
    % 3.6  Tiempos de fase del ciclo de zancada
    %      tiempos_eventos_carrera calcula, para cada paso, los intervalos
    %      temporales entre eventos. Los promedios globales están en
    %      tiempos.medias (campos: fs_to, vuelo, pct_vuelo, ic_ic...).
    % ------------------------------------------------------------------
    tiempos = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq);

    % ------------------------------------------------------------------
    % 3.7  Cadencia global
    %      cadencia devuelve los pasos/min del intento completo.
    %      Con 'ciclo' devuelve un vector paso a paso.
    % ------------------------------------------------------------------
    cad = cadencia(ic, freq, 'global');

    % ------------------------------------------------------------------
    % 3.8  Amplitud de impacto y frenado
    %      Pico de aceleración vertical (impacto) y anteroposterior
    %      (frenado) en el momento del foot-strike, en unidades G.
    %      Nota: estas funciones reciben ic como array de celdas {ic}.
    % ------------------------------------------------------------------
    [~, impact_moda]  = amplitud_impacto_pie_carrera({ic}, acc_v,  false);
    [~, braking_moda] = amplitud_frenado_pie_carrera( {ic}, acc_ap, false);

    % ------------------------------------------------------------------
    % 3.9  RMS de aceleración de impacto y frenado
    %      RMS calculada en el segmento IC → máxima velocidad de giro ML,
    %      que corresponde a la fase de carga del pie tras el contacto.
    % ------------------------------------------------------------------
    [~, rms_impacto_moda] = aceleracion_vert_impacto_pie_carrera(ic, fc, acc_v,  gyr_ml);
    [~, rms_frenado_moda] = aceleracion_vert_frenado_pie_carrera(ic, fc, acc_ap, gyr_ml);

    % ------------------------------------------------------------------
    % 3.10  Acumular resultados
    % ------------------------------------------------------------------
    resultados(end+1, :) = { ...
        sensor_id, numel(ic), ...
        round(tiempos.medias.fs_to    * 1000, 1), ...  % Contacto IC→FC [ms]
        round(tiempos.medias.vuelo    * 1000, 1), ...  % Vuelo FC→IC [ms]
        round(tiempos.medias.pct_vuelo,        2), ... % Vuelo [%]
        round(tiempos.medias.ic_ic    * 1000, 1), ...  % Ciclo IC→IC [ms]
        round(cad, 1), ...                              % Cadencia [pasos/min]
        round(impact_moda,       3), ...                % Impacto [G]
        round(braking_moda,      3), ...                % Frenado [G]
        round(rms_impacto_moda,  3), ...                % RMS impacto [G]
        round(rms_frenado_moda,  3)};                   % RMS frenado [G]

end % for sensores

fprintf('\n');


%% ── 4. TABLA RESUMEN  ────────────────────────────────────────────────────

if isempty(resultados)
    disp('No se generaron resultados. Revisa la estructura del archivo .mat.');
    return;
end

T = cell2table(resultados, 'VariableNames', { ...
    'Pie', 'N_pasos', ...
    'Contacto_ms', 'Vuelo_ms', 'Vuelo_pct', 'Ciclo_ms', ...
    'Cadencia_ppm', ...
    'Impacto_G', 'Frenado_G', 'RMS_impacto_G', 'RMS_frenado_G'});

fprintf('===== Tabla resumen =====\n');
disp(T);

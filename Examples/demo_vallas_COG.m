%% =========================================================================
%  DEMO: Análisis de carrera de vallas con IMU en el COG
%  SiMuR Tools TB — ejemplo de uso
% ==========================================================================
%
%  Este script muestra el flujo básico de análisis de una carrera de vallas
%  a partir de los datos de una IMU colocada en el centro de gravedad (COG).
%
%  PIPELINE:
%    1. Carga de señales IMU en coordenadas anatómicas  → carga_IMUstd
%    2. Detección automática de eventos de valla        → eventos_COG_vallas
%    3. Visualización de eventos sobre la señal         → mostrar_eventos
%    4. Superposición de patrones paso a paso           → mostrar_patrones
%
%  FORMATO DE DATOS:
%    Los archivos de intento deben seguir el formato IMUstd.
%    El sensor COG debe estar guardado con el identificador 'COG_1'.
%
%  SiMuR Lab — Universidad de Oviedo, 2025
%
%  EJEMPLO DE USO:
%    Ejecutar directamente — el script carga el archivo de ejemplo incluido:
%    >> demo_vallas_COG
%
%    Para usar tus propios datos, sustituye 'archivo' en la sección de
%    configuración (línea 32) por la ruta a tu archivo .mat.
% ==========================================================================

clear; clc;

%% ── 1. CONFIGURACIÓN  ────────────────────────────────────────────────────

% Ruta al archivo de datos. Por defecto usa el ejemplo incluido.
archivo   = fullfile(fileparts(mfilename('fullpath')), 'data', 'ejemplo_vallas.mat');

sensor_id = 'COG_1';   % Identificador del sensor en los archivos .mat
freq      = 120;       % Frecuencia de muestreo [Hz]

% Pasos a excluir en los extremos del intento
% (los primeros y últimos pasos suelen ser de aceleración/desaceleración)
pasos_excluir_inicio = 1;
pasos_excluir_final  = 3;


%% ── 2. CARGA DEL ARCHIVO  ────────────────────────────────────────────────

if ~isfile(archivo)
    error('Archivo de datos no encontrado:\n  %s', archivo);
end

fprintf('── Procesando: %s\n', archivo);


%% ── 3. PROCESAMIENTO  ───────────────────────────────────────────────────

% ------------------------------------------------------------------
% 3.1  Carga de señales en sistema de referencia anatómico {V, ML, AP}
%      carga_IMUstd devuelve aceleraciones y giros ya calibrados y
%      reorientados: columna 1 = Vertical, 2 = MedioLateral,
%      3 = AnteroPosterior.
% ------------------------------------------------------------------
[a_cal, ~] = carga_IMUstd(archivo, sensor_id);

acc_v   = a_cal(:,1);                               % Aceleración vertical
acc_ml  = a_cal(:,2);                               % Aceleración mediolateral
acc_tot = sqrt(sum(a_cal.^2, 2));                   % Módulo total

% ------------------------------------------------------------------
% 3.2  Detección de eventos de valla
%      Salidas:
%        MaxAcc — índices de los máximos de aceleración (un por paso)
%        saltos — posición de MaxAcc correspondiente a cada salto
%        caidas — posición de MaxAcc correspondiente a cada aterrizaje
%        ic     — Initial Contact (índices de muestra)
%        fc     — Final Contact   (índices de muestra)
% ------------------------------------------------------------------
[MaxAcc, saltos, caidas, ic, fc] = eventos_cog_vallas(acc_v, acc_tot);

if isempty(ic) || isempty(fc)
    error('No se detectaron eventos en el archivo de datos.');
end

fprintf('   Pasos detectados: %d  |  Saltos: %d  |  Caídas: %d\n', ...
    numel(ic), numel(saltos), numel(caidas));

% ------------------------------------------------------------------
% 3.3  Visualización de eventos sobre la señal de aceleración total
%
%      mostrar_eventos recibe una matriz donde cada fila es un tipo
%      de evento (índices de muestra). Aquí usamos:
%        Fila 1 → IC   (Initial Contact)
%        Fila 2 → FC   (Final Contact)
%        Fila 3 → MaxAcc (máximos de aceleración)
%
%      Los parámetros 3 y 4 recortan el rango mostrado:
%        pasos_excluir_inicio → nº de IC desde el inicio a partir del cual se marca el rango
%        pasos_excluir_final  → nº de IC desde el final hasta el que llega el rango
% ------------------------------------------------------------------
mat_eventos = [ic; fc; MaxAcc];

mostrar_eventos(mat_eventos, acc_tot, pasos_excluir_inicio, pasos_excluir_final);
title('Eventos — ejemplo vallas', 'Interpreter', 'none');

% ------------------------------------------------------------------
% 3.4  Patrones de aceleración por paso
%
%      mostrar_patrones superpone el perfil de cada paso y muestra la
%      media ± 2·σ. Permite valorar la consistencia del movimiento.
%
%      Se generan dos figuras: aceleración vertical y mediolateral.
% ------------------------------------------------------------------
mostrar_patrones(ic, acc_v,  pasos_excluir_inicio, pasos_excluir_final);
mostrar_patrones(ic, acc_ml, pasos_excluir_inicio, pasos_excluir_final);

% ------------------------------------------------------------------
% 3.5  Duración de cada paso
%      diff(ic)/freq convierte la diferencia en muestras a segundos.
% ------------------------------------------------------------------
duraciones_ms = diff(ic) / freq * 1000;   % milisegundos

figure;
bar(duraciones_ms);
xlabel('Paso');
ylabel('Duración (ms)');
title('Duración de cada paso — ejemplo vallas', 'Interpreter', 'none');
grid on;

fprintf('\n');

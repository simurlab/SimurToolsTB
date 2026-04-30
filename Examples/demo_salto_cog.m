%% =========================================================================
%  DEMO: Análisis de salto vertical con tres métodos de medida
%  SiMuR Tools TB — ejemplo de uso
% ==========================================================================
%
%  Este script estima el instante y la altura de tres saltos verticales
%  comparando los resultados obtenidos con tres sistemas de medida:
%
%    1. Cámara de movimiento          → posición vertical del marcador
%    2. Plataforma de fuerzas         → fuerza de reacción del suelo
%    3. IMU en el COG (acelerómetro)  → eventos_cog_salto
%
%  PIPELINE (sección IMU):
%    1. Carga de señales del acelerómetro  (formato Xsens .log)
%    2. Detección de eventos de salto      → eventos_cog_salto
%    3. Cálculo de duración y altura       (modelo caída libre)
%    4. Tabla comparativa de los tres métodos
%
%  ARCHIVOS DE DATOS (en Examples/data/):
%    ejemplo_salto_camara.trc     — posición vertical del marcador [mm], col 4, 100 Hz
%    ejemplo_salto_plataforma.xls — fuerza de reacción por pie [N], cols 2-3, 100 Hz
%    ejemplo_salto_imu.log        — aceleraciones Xsens en COG, cols 2-4, 100 Hz
%
%  SiMuR Lab — Universidad de Oviedo, 2025
%
%  EJEMPLO DE USO:
%    Ejecutar directamente — el script carga los tres archivos de ejemplo incluidos:
%    >> demo_salto_cog
%
%    Para usar tus propios datos, sustituye las rutas en la sección de
%    configuración (líneas 40-42) por las rutas a tus archivos.
% ==========================================================================

clear; clc;

%% ── 1. CONFIGURACIÓN  ────────────────────────────────────────────────────

data_dir = fullfile(fileparts(mfilename('fullpath')), 'data');

archivo_camara      = fullfile(data_dir, 'ejemplo_salto_camara.trc');
archivo_plataforma  = fullfile(data_dir, 'ejemplo_salto_plataforma.xls');
archivo_imu         = fullfile(data_dir, 'ejemplo_salto_imu.log');

freq = 100;   % Frecuencia de muestreo común [Hz]


%% ── 2. CÁMARA DE MOVIMIENTO  ─────────────────────────────────────────────
%
%  La columna 4 contiene el desplazamiento vertical del marcador [mm].
%  Los tres saltos se producen entre las muestras 201 y 1400.

if ~isfile(archivo_camara)
    error('Archivo no encontrado:\n  %s', archivo_camara);
end

datoscam   = load(archivo_camara);
vertcam    = datoscam(201:1400, 4);
baseline   = mean(vertcam(1:50));          % posición en reposo [mm]

figure;
plot(vertcam);
xlabel('Muestra');  ylabel('Posición vertical (mm)');
title('Cámara — desplazamiento vertical', 'Interpreter', 'none');
grid on;

% Máximos de cada salto
maximos_cam = busca_maximos_umbral(vertcam, 100);
ind_max_cam = find(maximos_cam == 1);

% Inicio y fin de cada salto (cruce por la línea base)
ind_ini_cam = zeros(1, numel(ind_max_cam));
ind_fin_cam = zeros(1, numel(ind_max_cam));

for i = 1:numel(ind_max_cam)
    for j = ind_max_cam(i):-1:ind_max_cam(i)-200
        if vertcam(j) < baseline
            ind_ini_cam(i) = j;
            break;
        end
    end
    for j = ind_max_cam(i):ind_max_cam(i)+200
        if vertcam(j) < baseline
            ind_fin_cam(i) = j;
            break;
        end
    end
end

% Visualización de los tres saltos segmentados
figure;
for i = 1:numel(ind_max_cam)
    subplot(1, numel(ind_max_cam), i);
    plot(vertcam(ind_ini_cam(i):ind_fin_cam(i)));
    title(sprintf('Salto %d', i));
    xlabel('Muestra');  ylabel('Posición (mm)');
    grid on;
end
sgtitle('Cámara — saltos segmentados');

alturaCam  = (vertcam(ind_max_cam) - baseline) / 1000;   % mm → m
tiemposCam = (ind_fin_cam - ind_ini_cam) / freq;          % muestras → s


%% ── 3. PLATAFORMA DE FUERZAS  ────────────────────────────────────────────
%
%  Las columnas 2 y 3 contienen la fuerza de cada pie [N].
%  Los tres saltos se producen entre las muestras 100 y 1500.
%  El vuelo corresponde a los intervalos donde la fuerza total cae a 0.

if ~isfile(archivo_plataforma)
    error('Archivo no encontrado:\n  %s', archivo_plataforma);
end

datospf  = load(archivo_plataforma);
fuerzas  = sum(datospf(100:1500, 2:3), 2);

figure;
plot(fuerzas);
xlabel('Muestra');  ylabel('Fuerza total (N)');
title('Plataforma de fuerzas — fuerza de reacción', 'Interpreter', 'none');
grid on;

% Despegue: fuerza baja de 70 N → aterrizaje: fuerza sube de 70 N
eventos_pf  = diff(fuerzas > 70);
ind_ini_pf  = find(eventos_pf == -1);
ind_fin_pf  = find(eventos_pf ==  1);

tiemposPF   = (ind_fin_pf - ind_ini_pf) / freq;
alturaPF    = 9.81 * tiemposPF.^2 / 8;


%% ── 4. IMU EN EL COG  ────────────────────────────────────────────────────
%
%  Las columnas 2-4 contienen las aceleraciones [m/s²].
%  La aceleración vertical (col 2) está invertida en este sensor → se niega.
%  Los tres saltos se producen entre las muestras 400 y 1600.

if ~isfile(archivo_imu)
    error('Archivo no encontrado:\n  %s', archivo_imu);
end

datosxs  = load(archivo_imu);
acc      = datosxs(400:1600, 2:4);
acc_v    = -acc(:, 1);   % negada: convención +g en apoyo

% ------------------------------------------------------------------
% 4.1  Detección de eventos de salto
%      eventos_cog_salto devuelve una matriz donde cada columna marca
%      un tipo de evento:
%        col 2 → inicio del salto (mínimo de aceleración)
%        col 3 → contacto inicial (paso por g)
%        col 4 → fin del salto (máximo de impacto)
%        col 5 → preparación para el contacto (mínimo previo al impacto)
% ------------------------------------------------------------------
eventos_imu = eventos_cog_salto(acc_v, freq);

inicios_imu = find(eventos_imu(:, 2));
finales_imu = find(eventos_imu(:, 4));

fprintf('   Saltos detectados por IMU: %d\n\n', numel(inicios_imu));

% Visualización de las aceleraciones durante cada salto
figure;
for i = 1:numel(inicios_imu)
    subplot(1, numel(inicios_imu), i);
    plot(acc_v(inicios_imu(i):finales_imu(i)));
    title(sprintf('Salto %d', i));
    xlabel('Muestra');  ylabel('Acc vertical (m/s²)');
    grid on;
end
sgtitle('IMU — aceleración vertical por salto');

% ------------------------------------------------------------------
% 4.2  Cálculo de duración, altura y energía
%      evalua_cog_salto encapsula las tres métricas a partir de la
%      matriz de eventos. El peso por defecto es 75 kg; ajústalo en
%      la sección de configuración si es necesario.
% ------------------------------------------------------------------
[tiemposxs, alturaxs, energiaxs] = evalua_cog_salto(eventos_imu, freq);


%% ── 5. TABLA COMPARATIVA  ────────────────────────────────────────────────

fprintf('===== Duración de cada salto (s) =====\n');
T_tiempos = array2table([tiemposPF(:), tiemposxs(:), tiemposCam(:)], ...
    'VariableNames', {'Plataforma_s', 'IMU_s', 'Camara_s'}, ...
    'RowNames', {'Salto_1', 'Salto_2', 'Salto_3'});
disp(T_tiempos);

fprintf('===== Altura de cada salto (m) =====\n');
T_alturas = array2table([alturaPF(:), alturaxs(:), alturaCam(:)], ...
    'VariableNames', {'Plataforma_m', 'IMU_m', 'Camara_m'}, ...
    'RowNames', {'Salto_1', 'Salto_2', 'Salto_3'});
disp(T_alturas);

fprintf('===== Energía por salto — IMU (J) =====\n');
T_energia = array2table(energiaxs(:), ...
    'VariableNames', {'Energia_J'}, ...
    'RowNames', {'Salto_1', 'Salto_2', 'Salto_3'});
disp(T_energia);

fprintf('── Listo.\n');

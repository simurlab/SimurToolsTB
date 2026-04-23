%% =========================================================================
%  DEMO: Localización en 2D a partir de IMU en L3
%  SiMuR Tools TB — ejemplo de uso
% ==========================================================================
%
%  Este script reconstruye la posición (x, y) de una persona que lleva un
%  sensor inercial en el cinturón a la altura de la vértebra L3.
%
%  PIPELINE:
%    1. Carga de señales del sensor (formato Xsens .log)
%    2. Detección de eventos del paso en tiempo real  → eventos_cog_tiempo_real_caminar
%    3. Estimación de la distancia de cada paso       → distancia_pendulo_cog_caminar
%    4. Estimación de la orientación                  → azimut_giroscopo
%    5. Cálculo de la posición 2D
%
%  FORMATO DE DATOS:
%    Archivo de texto con una muestra por fila y las siguientes columnas:
%    [ Tiempo | Acc_V  Acc_ML  Acc_AP | Gyr_V  Gyr_ML  Gyr_AP | Mag_V  Mag_ML  Mag_AP ]
%    Sensor Xsens, frecuencia de muestreo 100 Hz.
%
%  SiMuR Lab — Universidad de Oviedo, 2025
%
%  EJEMPLO DE USO:
%    Ejecutar directamente — el script carga el archivo de ejemplo incluido:
%    >> demo_caminar_posicion2D
%
%    Para usar tus propios datos, sustituye 'archivo' en la sección de
%    configuración (línea 31) por la ruta a tu archivo .log.
% ==========================================================================

clear; clc;

%% ── 1. CONFIGURACIÓN  ────────────────────────────────────────────────────

% Ruta al archivo de datos. Por defecto usa el ejemplo incluido.
archivo = fullfile(fileparts(mfilename('fullpath')), 'data', 'ejemplo_caminar_posicion2D.log');

freq        = 100;   % Frecuencia de muestreo [Hz]
long_pierna = 1;     % Longitud del arco de la pierna para el modelo de péndulo [m]

% Corrección de offset del giróscopo vertical.
% Se calcula a partir de un segmento con un número conocido de giros.
% Para el archivo de ejemplo: 12 giros de 180° entre las muestras 1000 y 25000.
ref_giros       = 12 * pi;          % Ángulo total de referencia [rad]
ref_muestra_ini = 1000;             % Muestra de inicio del segmento de referencia
ref_muestra_fin = 25000;            % Muestra de fin del segmento de referencia

% Longitud máxima de un paso válido [muestras]
% Pasos con más separación entre HS se descartan (persona detenida)
max_duracion_paso = 200;


%% ── 2. CARGA DEL ARCHIVO  ────────────────────────────────────────────────

if ~isfile(archivo)
    error('Archivo de datos no encontrado:\n  %s', archivo);
end

fprintf('── Procesando: %s\n', archivo);

data = load(archivo);

acc_v  = data(:,2);   % Aceleración vertical
acc_ap = data(:,4);   % Aceleración anteroposterior
gyr_v  = data(:,5);   % Velocidad de giro vertical

fprintf('   Muestras cargadas: %d (%.1f s)\n\n', size(data,1), size(data,1)/freq);


%% ── 3. DETECCIÓN DE EVENTOS DEL PASO  ───────────────────────────────────
%
%  eventos_cog_tiempo_real_caminar procesa las señales muestra a muestra,
%  simulando el modo tiempo real. Devuelve el retardo (en muestras) al evento más reciente.
%    hs — HeelStrike (contacto del talón)
%    to — ToeOff     (despegue del pie)

eventos_cog_tiempo_real_caminar(0, 0, true);

eventosHS = zeros(size(acc_ap));
eventosTO = zeros(size(acc_ap));

for k = 1:length(acc_ap)
    [hs, to] = eventos_cog_tiempo_real_caminar(acc_ap(k), acc_v(k));
    if hs ~= 0
        eventosHS(k - hs) = 1;
    end
    if to ~= 0
        eventosTO(k - to) = 1;
    end
end

indicesHS = find(eventosHS);
fprintf('   Eventos detectados — HS: %d  |  TO: %d\n\n', ...
    numel(indicesHS), sum(eventosTO));

% Visualización de eventos sobre las señales de aceleración
figure;
plot(acc_ap(1000:1300));
hold on;
plot(acc_v(1000:1300), 'r');
plot(eventosHS(1000:1300) * 10, 'c');
plot(eventosTO(1000:1300) * 10, 'k');
legend('Acc AP', 'Acc V', 'HeelStrike', 'ToeOff');
xlabel('Muestra');  ylabel('Aceleración (g)');
title('Eventos del paso — detalle', 'Interpreter', 'none');
grid on;


%% ── 4. ESTIMACIÓN DE LA DISTANCIA POR PASO  ─────────────────────────────
%
%  distancia_pendulo_cog_caminar calcula la longitud de cada paso a partir de la
%  aceleración vertical usando el modelo del péndulo invertido.
%  Se aplica solo a pasos cuya duración sea menor que max_duracion_paso.

distancias = zeros(size(acc_v));

for k = 2:length(indicesHS)
    ini = indicesHS(k-1);
    fin = indicesHS(k);
    if fin - ini < max_duracion_paso
        distancias(fin) = distancia_pendulo_cog_caminar(acc_v(ini:fin), freq, long_pierna);
    end
end

% Distancia total acumulada
figure;
plot(cumsum(distancias));
xlabel('Muestra');  ylabel('Distancia acumulada (m)');
title('Distancia total recorrida', 'Interpreter', 'none');
grid on;

fprintf('   Distancia total estimada: %.2f m\n\n', sum(distancias));


%% ── 5. ESTIMACIÓN DE LA ORIENTACIÓN  ────────────────────────────────────
%
%  Se corrige el offset del giróscopo vertical comparando la integral
%  en un segmento conocido con el ángulo real de referencia.
%  Después, azimut_giroscopo integra la velocidad de giro corregida.

offset_giro = (ref_giros - sum(gyr_v(ref_muestra_ini:ref_muestra_fin)) / freq) / ...
              ((ref_muestra_fin - ref_muestra_ini) / freq);

gyr_v_corr  = gyr_v + offset_giro;
orientacion = azimut_giroscopo(gyr_v_corr, 0, freq);

figure;
plot(orientacion * 180/pi);
xlabel('Muestra');  ylabel('Orientación (°)');
title('Orientación estimada (giróscopo)', 'Interpreter', 'none');
grid on;


%% ── 6. CÁLCULO DE LA POSICIÓN 2D  ───────────────────────────────────────
%
%  Combinando la distancia de cada paso y la orientación en ese instante
%  se obtiene el desplazamiento incremental en x e y.

posx = zeros(size(acc_v));
posy = zeros(size(acc_v));

for k = 2:length(posx)
    posx(k) = posx(k-1) + distancias(k) * cos(orientacion(k));
    posy(k) = posy(k-1) + distancias(k) * sin(orientacion(k));
end

figure;
plot(posx, posy);
axis([-15, 15, -15, 15]);
xlabel('x (m)');  ylabel('y (m)');
title('Posición 2D estimada', 'Interpreter', 'none');
grid minor;

fprintf('── Listo.\n');

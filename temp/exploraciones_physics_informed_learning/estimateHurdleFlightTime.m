function [T_valla, info] = estimateHurdleFlightTime(a_z_raw, fs)
%--------------------------------------------------------------------------
% estimateHurdleFlightTime
%
% Estima el tiempo de vuelo correspondiente al sobrepaso de la valla
% a partir de aceleración vertical cruda del COG (IMU).
%
% La función:
%   1) Filtra la señal cruda
%   2) Detecta automáticamente ventanas candidatas con fases aéreas
%   3) Identifica el vuelo de valla mediante criterios físicos
%
% INPUTS:
%   a_z_raw : Nx1 aceleración vertical cruda [m/s^2]
%             (marco inercial, gravedad incluida)
%   fs      : frecuencia de muestreo [Hz]
%
% OUTPUTS:
%   T_valla : tiempo de vuelo sobre la valla [s]
%   info    : estructura con información interna (debug/análisis)
%
%--------------------------------------------------------------------------

%% Parámetros físicos y numéricos
g = 9.81;

% Filtrado
fc      = 20;       % frecuencia de corte [Hz] (biomecánica COG)
filterN = 4;

% Detección de vuelo
tolAcc  = 0.5;      % tolerancia alrededor de -g [m/s^2]
varWin  = 0.04;     % ventana varianza [s]

% Ventanas
minFlightT = 0.08;  % duración mínima vuelo plausible [s]

dt = 1/fs;
N  = numel(a_z_raw);

%% 1. Filtrado de la aceleración cruda
[b,a] = butter(filterN, fc/(fs/2));
a_z = filtfilt(b,a,a_z_raw);

%% 2. Detección global de fases aéreas (sin ventanear aún)
isFlight = abs(a_z + g) < tolAcc;
isFlight = isFlight & movvar(a_z, round(varWin*fs), ...
                             'Endpoints','shrink') < 0.3;

%% 3. Segmentación en vuelos candidatos
CC = bwconncomp(isFlight);
flightIdx = CC.PixelIdxList;
nFlights  = numel(flightIdx);

if nFlights == 0
    error('No se han detectado fases aéreas en la señal.');
end

%% 4. Análisis físico de cada vuelo candidato
T    = nan(nFlights,1);
zMax = nan(nFlights,1);
vz0  = nan(nFlights,1);

for k = 1:nFlights
    idx = flightIdx{k};

    % Duración
    Tk = numel(idx) * dt;
    if Tk < minFlightT
        continue
    end

    % Reconstrucción vertical (forma relativa)
    vz = cumtrapz(a_z(idx)) * dt;
    z  = cumtrapz(vz) * dt;

    T(k)    = Tk;
    zMax(k) = max(z);
    vz0(k)  = vz(min(3,end));   % velocidad inicial suavizada
end

valid = ~isnan(T);
if sum(valid) == 0
    error('No hay vuelos válidos tras el filtrado.');
end

%% 5. Selección physics-informed del vuelo de valla
Tn  = normalize(T(valid));
Zn  = normalize(zMax(valid));
Vn  = normalize(vz0(valid));

% Score físico: la valla domina simultáneamente
score = Tn + Zn + Vn;

idxValid = find(valid);
[~, imax] = max(score);
idxValla = idxValid(imax);

%% 6. Resultado final
T_valla = T(idxValla);

%% 7. Información adicional
info.filteredSignal     = a_z;
info.flightDurations    = T;
info.flightHeights      = zMax;
info.flightVz0          = vz0;
info.hurdleFlightIndex  = idxValla;
info.numFlightsDetected = nFlights;

end
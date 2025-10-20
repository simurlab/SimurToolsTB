function angulo = orientacion_kalman(vel_giro, campo_x, campo_y, campo_z, angulo0, freq, reset)
%ORIENTACION_KALMAN Estima la orientación usando filtro de Kalman (giroscopio + compás).
%
%   angulo = orientacion_kalman(vel_giro, campo_x, campo_y, campo_z, angulo0, freq, reset)
%
%   Esta función fusiona los datos de un giróscopo y de un compás mediante
%   un filtro de Kalman para obtener una estimación robusta de la
%   orientación. Los datos del compás se validan con base en:
%       - La desviación vertical del campo magnético.
%       - La diferencia con el ángulo estimado por el giroscopio.
%
%   Cuando el compás no es fiable, el resultado se aproxima a la integración
%   pura del giróscopo. Si la discrepancia entre giroscopio y compás vuelve
%   a ser pequeña (<2°), se reinicia la covarianza del filtro.
%
% INPUT:
%   vel_giro : vector con velocidad angular en el eje vertical (rad/s).
%   campo_x  : componente X del campo magnético (antero-posterior).
%   campo_y  : componente Y del campo magnético (medio-lateral).
%   campo_z  : componente Z del campo magnético (vertical).
%   angulo0  : (opcional) ángulo inicial en radianes. Por defecto 0.
%   freq     : (opcional) frecuencia de muestreo en Hz. Por defecto 100 Hz.
%   reset    : (opcional) si vale 1 reinicia el filtro de Kalman.
%
% OUTPUT:
%   angulo   : vector con el ángulo estimado (rad) para cada instante.
%
% MODELO DEL FILTRO DE KALMAN:
%   Estado: [angulo, velocidad, bias]'
%
%   x(k) = A * x(k-1) + ruido_proceso
%   y(k) = C * x(k)   + ruido_medida
%
%   Donde:
%       A = [1 T 0; 0 1 0; 0 0 1]
%       C = [1 0 0; 0 1 1]
%
% EJEMPLO:
%   vel = [0.1*ones(1,200) zeros(1,200)]; % velocidad angular
%   bx = randn(1,400)*0.01; by = randn(1,400)*0.01; bz = ones(1,400);
%   ang = orientacion_kalman(vel, bx, by, bz, 0, 100, 1);
%   plot(rad2deg(ang)), ylabel('Ángulo [°]'), xlabel('Muestras')
%
% See also: orientacion_giroscopo, orientacion_compas
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           13.12.2007   adaptado para uso online
%           30.09.2025   normalizada y modernizada

    % --- Variables persistentes ---
    persistent estado
    if nargin < 7
        reset = 0;
    end
    if isempty(estado) || reset == 1
        estado.freq = 100;
        % Inicializar compás con valor actual
        orientacion_compas(campo_x, campo_y, campo_z, orientacion_compas(campo_x, campo_y, campo_z));
        % Matrices iniciales
        estado.P = 1 * eye(3);        % covarianza inicial
        estado.X = [0; 0; 0];         % estado: ángulo, velocidad, bias
        estado.ruido_compas = 10;     % varianza inicial del compás
    end

    % --- Inicializar con parámetros ---
    if nargin > 4
        angulo = orientacion_compas(campo_x(1), campo_y(1), campo_z(1), 0);
        orientacion_compas(campo_x(1), campo_y(1), campo_z(1), angulo - angulo0);
        estado.X = [angulo0; 0; 0];
        if nargin > 5
            estado.freq = freq;
        else
            estado.freq = 100;
        end
    end

    % --- Obtener ángulo y fiabilidad del compás ---
    [angulo_compas, fiable_compas] = orientacion_compas(campo_x, campo_y, campo_z);
    angulo_k = zeros(size(angulo_compas));

    % --- Matrices del modelo ---
    A = [1 1/estado.freq 0; 0 1 0; 0 0 1];
    C = [1 0 0; 0 1 1];
    V = [0 0 0; 0 0.1 0; 0 0 1e-6]; % ruido proceso

    % --- Filtro de Kalman ---
    for k = 1:length(angulo_k)
        % Validación del compás
        if fiable_compas(k) == 0
            estado.ruido_compas = 1e10;
        else
            dif_ang = angulo_compas(k) - estado.X(1);
            if abs(dif_ang) > deg2rad(5)
                estado.ruido_compas = 1e10;
            end
            % Reset cuando vuelve a ser consistente
            if abs(dif_ang) < deg2rad(2) && estado.ruido_compas > 1e9
                estado.P = 1e-3 * eye(3);
                estado.ruido_compas = 10;
            end
        end

        % Ruido de medida
        N = [estado.ruido_compas 0; 0 0.1];
        % Medida
        Y = [angulo_compas(k); vel_giro(k)];
        % Predicción
        X_pred = A * estado.X;
        Q = A * estado.P * A' + V;
        % Corrección
        E = Y - C * X_pred;
        K = Q * C' / (C * Q * C' + N);
        estado.X = X_pred + K * E;
        estado.P = (eye(3) - K * C) * Q;
        % Salida
        angulo_k(k) = estado.X(1);
    end

    angulo = angulo_k;
end

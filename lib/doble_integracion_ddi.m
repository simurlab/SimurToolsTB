function pos = doble_integracion_ddi(aceleracion, freq)
% DOBLE_INTEGRACION_DDI Doble integración de la aceleración con método DDI.
%
%   pos = doble_integracion_ddi(aceleracion, freq)
%
%   Esta función estima la posición a partir de la aceleración aplicando
%   doble integración con el método DDI (Drift Detection and Integration).
%   El método supone:
%       1) La aceleración tiene media cero (velocidad final ≈ inicial).
%       2) La aceleración inicial (4% inicial) y final (2% final) son ≈ 0.
%       3) La velocidad final debería ser cero (se corrige con los últimos 5 valores).
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo en Hz.
%
% OUTPUT:
%   pos : vector con la señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:2;                                % tiempo
%   a = [zeros(1,10) 2*ones(1,100) zeros(1,90)]; % impulso
%   p = doble_integracion_ddi(a, 100);
%   plot(t, p), xlabel('Tiempo [s]'), ylabel('Posición [u]')
%
% Author:   Diego
% History:  30.11.2019   renombrada (JC)
%           29.09.2025   normalizada y modernizada
%

    n = length(aceleracion);

    % -------------------- Estimar drift de aceleración --------------------
    k_inicio = round(n * 0.04);
    k_fin = round(n * 0.02);
    y0 = mean(aceleracion(1:k_inicio));
    y1 = mean(aceleracion(end-k_fin+1:end));

    % Función de drift interpolada
    drift_acc = [ y0*ones(k_inicio,1); ...
                  linspace(y0,y1,n-k_inicio-k_fin)'; ...
                  y1*ones(k_fin,1) ];

    % -------------------- Aceleración compensada --------------------
    acc_corr = aceleracion - drift_acc;

    % -------------------- Integración trapezoidal → velocidad --------------------
    vel = cumtrapz(acc_corr / freq);

    % Corregir drift de velocidad final
    vel_drift_final = mean(vel(end-4:end));
    drift_vel = linspace(0, vel_drift_final, n)';
    vel_corr = vel - drift_vel;

    % -------------------- Integración trapezoidal → posición --------------------
    pos = cumtrapz(vel_corr / freq);
end

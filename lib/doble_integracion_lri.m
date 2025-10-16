function pos = doble_integracion_lri(aceleracion, freq)
% DOBLE_INTEGRACION_LRI Doble integración de la aceleración con método LRI.
%
%   pos = doble_integracion_lri(aceleracion, freq)
%
%   Esta función estima el desplazamiento a partir de una señal de
%   aceleración mediante el método LRI (según Sabatini, 2005). El método:
%       1) Integra la aceleración para obtener la velocidad.
%       2) Aplica una corrección lineal para forzar que la velocidad final
%          sea cero.
%       3) Integra de nuevo la velocidad corregida para obtener posición.
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo en Hz.
%
% OUTPUT:
%   pos : vector con la señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:1;                     % tiempo en segundos
%   a = [2*ones(1,50) zeros(1,51)];   % aceleración con parada final
%   p = doble_integracion_lri(a, 100);
%   plot(t, p), xlabel('Tiempo [s]'), ylabel('Posición [u]')
%
%
% Author:   Diego
% History:  30.11.2019   renombrada (JC)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Integración trapezoidal → velocidad --------------------
    veloc = cumtrapz(aceleracion / freq);

    % -------------------- Corrección lineal para forzar velocidad final = 0 --------------------
    factor = linspace(1, 0, length(veloc))';
    vel = factor .* veloc;

    % -------------------- Segunda integración trapezoidal → posición --------------------
    pos = cumtrapz(vel / freq);
end

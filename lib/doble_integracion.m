function pos = doble_integracion(aceleracion, freq)
% DOBLE_INTEGRACION Realiza la doble integración de una señal de aceleración.
%
%   pos = doble_integracion(aceleracion, freq)
%
%   Esta función integra dos veces una señal de aceleración discreta para
%   obtener la posición estimada, asumiendo frecuencia de muestreo fija.
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo en Hz.
%
% OUTPUT:
%   pos : vector con la señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:1;                % tiempo en segundos
%   a = 2*ones(size(t));         % aceleración constante = 2 m/s²
%   p = doble_integracion(a, 100) % integra con freq=100 Hz
%
% Author:   Diego
% History:  30.11.2019   renombrada (JC)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Integración discreta → velocidad --------------------
    velocidad = cumsum(aceleracion / freq);

    % -------------------- Segunda integración → posición --------------------
    pos = cumsum(velocidad / freq);
end

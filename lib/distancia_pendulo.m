function distancia = distancia_pendulo(acc_vert, freq, pierna, correccion)
% DISTANCIA_PENDULO Calcula la distancia de un paso con el modelo del péndulo invertido.
%
%   distancia = distancia_pendulo(acc_vert, freq, pierna, correccion)
%
%   Esta función estima la distancia recorrida en un paso aplicando el
%   modelo del péndulo invertido desde el centro de gravedad (COG). Puede
%   aplicar opcionalmente una corrección eliminando la media de la señal
%   para reducir el drift.
%
% INPUT:
%   acc_vert   : vector con la aceleración vertical del paso.
%   freq       : frecuencia de muestreo (Hz). Opcional, por defecto 100 Hz.
%   pierna     : longitud de la pierna (m). Opcional, por defecto 0.8 m.
%   correccion : 1 = eliminar media (por defecto), 0 = sin corrección.
%
% OUTPUT:
%   distancia : distancia recorrida estimada (m).
%
% EXAMPLE:
%   acc_vert = [zeros(1,10) -9.5*ones(1,80) zeros(1,10)];
%   d = distancia_pendulo(acc_vert, 100, 0.9, 1)
%
% See also: distancia_pendulo_parcial, distancia_arco, distancia_raiz_cuarta
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           12.12.2007   adaptado a paso único online
%           03.01.2007   corregida frecuencia por defecto
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Parámetros persistentes --------------------
    persistent params
    if isempty(params)
        params.freq = 100;      % frecuencia por defecto
        params.pierna = 0.8;    % longitud pierna por defecto
        params.correccion = 1;  % aplicar corrección por defecto
    end

    % -------------------- Actualizar parámetros si se proporcionan --------------------
    if nargin > 1
        params.freq = freq;
        if nargin > 2
            params.pierna = pierna;
            if nargin > 3
                params.correccion = correccion;
            end
        end
    end

    % -------------------- Preprocesado de señal --------------------
    aceleracion = acc_vert;
    aceleracion = aceleracion - params.correccion * mean(aceleracion);

    % Integración → velocidad
    velocidad = cumsum(aceleracion) / params.freq;
    velocidad = velocidad - params.correccion * mean(velocidad);

    % Integración → desplazamiento vertical
    vertical_tiempo = cumsum(velocidad) / params.freq;
    vertical = max(vertical_tiempo) - min(vertical_tiempo);

    % -------------------- Modelo del péndulo invertido --------------------
    distancia = 2 * sqrt(max(0, 2*params.pierna*vertical - vertical^2));
end

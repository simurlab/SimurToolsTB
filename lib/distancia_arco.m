function distancia = distancia_arco(acc_vert, freq, pierna)
% DISTANCIA_ARCO Calcula la distancia recorrida en un paso usando el modelo de arco.
%
%   distancia = distancia_arco(acc_vert, freq, pierna)
%
%   Esta función estima la distancia recorrida en un paso aplicando el
%   modelo de movimiento angular a velocidad constante. El método relaciona
%   la distancia recorrida con la aceleración vertical mínima observada en
%   el instante de "foot flat". Basado en trabajos del VTI.
%
% INPUT:
%   acc_vert : vector con la aceleración vertical del paso.
%              Debe incluir 0.1 s antes y después del paso.
%   freq     : frecuencia de muestreo (Hz). Opcional, por defecto 100 Hz.
%   pierna   : longitud de la pierna (m). Opcional, por defecto 1 m.
%
% OUTPUT:
%   distancia : distancia recorrida estimada (m).
%
% EXAMPLE:
%   % Señal ficticia de aceleración vertical para un paso
%   acc_vert = [zeros(1,10) -9.5*ones(1,80) zeros(1,10)];
%   d = distancia_arco(acc_vert, 100, 0.9)
%
% See also: distancia_raiz_cuarta, distancia_pendulo, distancia_pendulo_parcial
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           12.12.2007   adaptado a paso único online
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Parámetros persistentes --------------------
    persistent params
    if isempty(params)
        params.freq = 100;   % frecuencia por defecto (Hz)
        params.pierna = 1;   % longitud pierna por defecto (m)
    end

    % Actualizar parámetros si se proporcionan
    if nargin > 1
        params.freq = freq;
        if nargin > 2
            params.pierna = pierna;
        end
    end

    % -------------------- Filtrado --------------------
    % Media móvil con ventana de freq/10 muestras
    b = ones(1, ceil(params.freq/10)) / ceil(params.freq/10);
    acc_vert = filter(b, 1, acc_vert);

    % -------------------- Cálculo de distancia --------------------
    % Aceleración mínima
    minima = min(acc_vert);

    % Velocidad estimada
    velocidad = sqrt(params.pierna) * sqrt(9.81 - minima);

    % Duración del paso (s)
    tiempo = length(acc_vert) / params.freq;

    % Distancia recorrida
    distancia = velocidad * tiempo;
end

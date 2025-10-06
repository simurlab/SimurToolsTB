function distancia = distancia_pendulo_parcial(acc_vert, TO, freq, h_sensor, pie, KSP)
% DISTANCIA_PENDULO_PARCIAL Distancia de un paso con el modelo de péndulo invertido parcial.
%
%   distancia = distancia_pendulo_parcial(acc_vert, TO, freq, h_sensor, pie, KSP)
%
%   Esta función estima la distancia recorrida en un paso aplicando el
%   modelo del péndulo invertido durante la fase de single stance y
%   suponiendo un desplazamiento adicional constante durante la fase de
%   double stance (tamaño del pie). Puede usarse para un único paso o para
%   una zancada completa.
%
% INPUT:
%   acc_vert : vector con la aceleración vertical.
%   TO       : índice(s) de toe-off:
%                 * escalar → un paso.
%                 * vector de 3 elementos → zancada completa
%                   [TOc_final, TOc_inicial, TOi_final].
%   freq     : frecuencia de muestreo (Hz).
%   h_sensor : altura del sensor desde el maléolo (m). Opcional,
%              por defecto 0.8 m.
%   pie      : longitud del pie (m). Opcional, por defecto 0.15 m.
%   KSP      : factor de corrección geométrica. Opcional, por defecto 1.
%
% OUTPUT:
%   distancia : estimación de la distancia recorrida (m).
%
% EXAMPLE:
%   acc = randn(1,200);  % señal ficticia
%   d = distancia_pendulo_parcial(acc, 50, 100, 0.8, 0.15, 1)
%
% See also: distancia_pendulo, distancia_arco, distancia_raiz_cuarta
%
% Author:   Diego Álvarez, Rafael C. González de los Reyes
% History:  ??.??.200?   creado
%           04.12.2007   adaptado a paso único online (Rafa)
%           12.12.2007   adaptación final a toolbox
%           03.01.2008   frecuencia por defecto = 100 Hz
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Valores persistentes --------------------
    persistent params
    if isempty(params)
        params.freq = 100;      % frecuencia por defecto
        params.h_sensor = 0.8;  % altura del sensor por defecto
        params.pie = 0.15;      % longitud de pie por defecto
        params.KSP = 1;         % factor corrección por defecto
    end

    % -------------------- Actualizar parámetros si se proporcionan --------------------
    if nargin > 2
        params.freq = freq;
        if nargin > 3
            params.h_sensor = h_sensor;
            if nargin > 4
                params.pie = pie;
                if nargin > 5
                    params.KSP = KSP;
                end
            end
        end
    end

    % -------------------- Preprocesado de señal --------------------
    acc_corr = acc_vert - mean(acc_vert);

    % Integración → velocidad
    vel = cumsum(acc_corr) / params.freq;

    % Eliminar media de velocidad (condición altura inicial=final)
    vel = vel - mean(vel);

    % Integración → desplazamiento vertical
    vertical_tiempo = cumsum(vel) / params.freq;

    % -------------------- Cálculo de distancia --------------------
    if numel(TO) == 1
        % Un paso
        vertical = max(vertical_tiempo(TO:end)) - min(vertical_tiempo(TO:end));
        if params.h_sensor ~= 0
            distancia = params.KSP * 2*sqrt(2*params.h_sensor*vertical - vertical.^2) ...
                        + params.pie;
        else
            distancia = params.pie;
        end
    else
        % Zancada completa (dos verticales)
        vertical = [max(vertical_tiempo(TO(1):TO(2))) - min(vertical_tiempo(TO(1):TO(2))), ...
                    max(vertical_tiempo(TO(3):end))   - min(vertical_tiempo(TO(3):end))];
        if params.h_sensor ~= 0
            distancia = params.KSP * 2*sqrt(2*params.h_sensor*vertical - vertical.^2) ...
                        + params.pie;
        else
            distancia = params.pie * ones(size(vertical));
        end
    end
end

function [ic, fc] = eventosPieCarreraOLD(gyr, th, freq)
%EVENTOSPIEOLD [OBSOLETA] Versión básica de detección IC/FC a partir de giro mediolateral.
%
%   [ic, fc] = eventosPieOld(gyr, th, freq)
%
%    Esta función está obsoleta y se mantiene únicamente por compatibilidad
%   con código anterior. Se recomienda utilizar en su lugar:
%
%       >> eventosPieCarrera
%
%   que además de IC y FC también devuelve MaxS, MinS, MVP y MP.
%
%   INPUT:
%       gyr  : vector con la velocidad angular en el eje mediolateral.
%       th   : umbral mínimo de velocidad para detectar un paso (ej. 150).
%       freq : frecuencia de muestreo en Hz.
%
%   OUTPUT:
%       ic : índices de contacto inicial.
%       fc : índices de final de contacto.
%
%   EJEMPLO:
%       gyr = sin(0:0.01:10) * 200;
%       [ic, fc] = eventosPieOld(gyr, 150, 100);
%       plot(gyr); hold on;
%       plot(ic, gyr(ic), 'ro'); % IC
%       plot(fc, gyr(fc), 'go'); % FC
%
%   See also: eventosPieCarrera, eventosCogMarcha, eventosCogCarrera
%
% Author:   Diego
% History:  xx.yy.zz    creación del archivo
%           29.09.2025  renombrada como OLD (compatibilidad)

    % --- Filtrado ---
    orden = 5;
    corte = 6 / freq;
    gyr = filtro0(gyr, orden, corte);

    % --- Señal de pulsos ---
    datos2 = diff(gyr) >= 0;
    datos2 = datos2(1:end-1) - datos2(2:end);
    maximos = find(datos2 == 1) + 1;
    minimos = find(datos2 == -1) + 1;
    minimos = minimos(gyr(minimos) < 0);

    % --- Inicialización ---
    ic = [];
    fc = [];
    maxPaso = maximos(1);

    % --- Detección de eventos ---
    for i = 2:length(maximos)
        if gyr(maximos(i)) >= th
            minsPaso = minimos(minimos > maxPaso(end) & minimos < maximos(i));
            if length(minsPaso) >= 2
                maxPaso = [maxPaso, maximos(i)];
                [~, idxFc] = min(gyr(minsPaso));
                fc = [fc, minsPaso(idxFc)];
                ic = [ic, minsPaso(1)];
            end
        end
    end
end

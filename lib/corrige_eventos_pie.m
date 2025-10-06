function [eventos_corregidos, calidad_deteccion] = corrige_eventos_pie(matriz_eventos, freq)
% CORRIGE_EVENTOS_PIE Corrige NaNs en la detección de eventos de un experimento.
%
%   [eventos_corregidos, calidad_deteccion] = corrige_eventos_pie(matriz_eventos, freq)
%
%   Esta función revisa la matriz de eventos detectados en un experimento y
%   sustituye los valores perdidos (NaN) por estimaciones razonables basadas
%   en los eventos adyacentes. Además, devuelve medidas de calidad de las
%   detecciones.
%
% INPUT:
%   matriz_eventos : matriz de eventos detectados (puede contener NaN).
%   freq           : frecuencia de muestreo (no utilizada en esta versión,
%                    se incluye por compatibilidad).
%
% OUTPUT:
%   eventos_corregidos : matriz corregida, con NaNs sustituidos.
%   calidad_deteccion  : vector con el número de NaNs por fila y el total de eventos.
%
% EXAMPLE:
%   M = [10 20 NaN; 12 22 32; 15 NaN 35];
%   [Mc, calidad] = corrige_eventos_pie(M, 100);
%
% Author:   Diego
% History:  xx.yy.zz    creación del archivo
%           21.01.2008  documentada
%           30.09.2019  adaptada a la nueva documentación
%           29.09.2025  normalizada y modernizada
%

    % Número total de NaNs en toda la matriz
    num_nan = sum(isnan(matriz_eventos), 'all'); %#ok<NASGU>

    % Número de NaNs por fila + total de columnas (eventos detectados)
    v_num_nan = sum(isnan(matriz_eventos)', 1);
    v_num_nan = [v_num_nan size(matriz_eventos, 2)];

    % Copia de trabajo
    m = matriz_eventos;

    % Buscar posiciones con NaN
    [row, col] = find(isnan(m));
    if ~isempty(row)
        for i = 1:length(row)
            if col(i) == 1
                % Si el NaN está en la primera columna, aproximar con salto siguiente
                salto_siguiente = m(row(i), col(i)+1) - m(row(i)+1, col(i)+1);
                m(row(i), col(i)) = m(row(i)-1, col(i)) + salto_siguiente;
            else
                % Si no, aproximar con salto anterior
                salto_anterior = m(row(i), col(i)-1) - m(row(i)-1, col(i)-1);
                m(row(i), col(i)) = m(row(i)-1, col(i)) + salto_anterior;
            end
        end
        matriz_eventos = m;
    end

    % Salidas
    eventos_corregidos = matriz_eventos;
    calidad_deteccion = v_num_nan;
end

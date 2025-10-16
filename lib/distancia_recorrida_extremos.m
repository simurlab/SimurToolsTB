function resultados = distancia_recorrida_extremos(matriz, columnas)
% DISTANCIA_RECORRIDA_EXTREMOS Calcula la distancia recorrida entre extremos en un eje.
%
%   resultados = distancia_recorrida_extremos(matriz, columnas)
%
%   Esta función calcula la distancia recorrida entre los valores máximos
%   y mínimos en las columnas especificadas de una matriz de datos. Es útil
%   para estimar el desplazamiento de un marcador o sólido rígido en un
%   eje.
%
% INPUT:
%   matriz   : matriz de datos previamente cargada.
%   columnas : índice(s) de las columnas a analizar.
%
% OUTPUT:
%   resultados : tabla con los valores máximo, mínimo y la distancia
%                entre extremos para cada columna.
%
% EXAMPLE:
%   M = rand(100, 20); % datos ficticios
%   T = distancia_recorrida_extremos(M, [5 17])
%
% See also: max, min, table
%
% Author:   Diego
% History:  ??.??.20??   creado
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Inicialización --------------------
    n_col = length(columnas);
    max_vals = zeros(1, n_col);
    min_vals = zeros(1, n_col);
    dist_vals = zeros(1, n_col);

    % -------------------- Cálculo por columnas --------------------
    for i = 1:n_col
        datos_columna = matriz(:, columnas(i));
        max_vals(i) = max(datos_columna);
        min_vals(i) = min(datos_columna);
        dist_vals(i) = max_vals(i) - min_vals(i);
    end

    % -------------------- Tabla de resultados --------------------
    clases = ["Máximo"; "Mínimo"; "Distancia entre extremos"];
    datos = [max_vals; min_vals; dist_vals];

    resultados = array2table(datos, ...
        'RowNames', cellstr(clases), ...
        'VariableNames', compose("Columna%d", columnas));
end

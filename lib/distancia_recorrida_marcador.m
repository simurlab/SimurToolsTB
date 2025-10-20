function distancia = distancia_recorrida_marcador(matriz, columna)
% DISTANCIA_RECORRIDA_MARCADOR Calcula la distancia recorrida en un eje de un marcador o sólido rígido.
%
%   distancia = distancia_recorrida_marcador(matriz, columna)
%
%   Esta función estima la distancia total recorrida en un eje sumando las
%   diferencias absolutas entre muestras consecutivas en la columna
%   especificada. Solo se consideran valores positivos.
%
% INPUT:
%   matriz  : matriz con los datos.
%   columna : índice de la columna a analizar.
%
% OUTPUT:
%   distancia : distancia recorrida en las mismas unidades de los datos.
%
% EXAMPLE:
%   M = abs(randn(100, 3)); % datos ficticios
%   d = distancia_recorrida_marcador(M, 2)
%
% See also: distancia_recorrida_extremos
%
% Author:   Diego
% History:  ??.??.20??   creado
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Selección de serie --------------------
    serie = matriz(:, columna);

    % -------------------- Filtrado de valores positivos --------------------
    mascara = (serie(1:end-1) > 0) & (serie(2:end) > 0);

    % -------------------- Diferencias absolutas --------------------
    difs = abs(diff(serie));

    % -------------------- Distancia recorrida --------------------
    distancia = sum(difs(mascara));
end

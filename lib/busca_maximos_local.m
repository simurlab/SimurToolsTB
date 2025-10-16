function indices = busca_maximos_local(datos, N)
%BUSCA_MAXIMOS_LOCAL Encuentra máximos locales en una señal.
%
%   indices = busca_maximos_local(datos, N)
%
%   Esta función determina los puntos que son máximos locales en un vector
%   de datos, comprobando que el valor sea mayor o igual que sus N vecinos
%   a cada lado.
%
% INPUT:
%   datos : vector con la señal donde se buscan los máximos.
%   N     : número de muestras a cada lado que deben ser menores para
%           considerar un punto como máximo local.
%
% OUTPUT:
%   indices : vector con los índices de los máximos locales.
%
% EJEMPLO:
%   x = [0 1 3 7 6 2 5 4 2];
%   idx = busca_maximos_local(x, 1)
%   % devuelve 4 y 7
%
% See also: busca_maximos, busca_maximos_umbral
%
% Author:   Javi
% History:  xx.yy.zz    creación inicial
%           04.01.2008  incorporada a la toolbox v0.4
%           21.01.2008  documentada
%           30.09.2025  normalizada y modernizada

    indices = [];
    contador = 1;

    for i = N+1:length(datos)-N
        if datos(i) == max(datos((i-N):(i+N)))
            indices(contador) = i; %#ok<AGROW>
            contador = contador + 1;
        end
    end
end

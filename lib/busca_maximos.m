function maximos = buscaMaximos(datos)
%BUSCAMAXIMOS Detecta todos los máximos locales de una señal discreta.
%
%   maximos = buscaMaximos(datos)
%
%   INPUT:
%       datos : vector con la señal en la que se buscan los máximos.
%
%   OUTPUT:
%       maximos : vector lógico del mismo tamaño que datos, con true (1)
%                 en cada posición de máximo y false (0) en el resto.
%
%   EJEMPLO:
%       x = 0:0.01:2*pi;
%       y = sin(x);
%       m = buscamaximos(y);
%       plot(x,y); hold on;
%       plot(x(m), y(m), 'ro')   % marca los máximos
%
%   See also: buscaMaximosTh
%
% Autor:     Diego
% Historial: xx.yy.zz    Diego  creación del archivo
%            JC          añade comentarios
%            19.12.07    incorporada a la toolbox
%            21.01.08    documentada
%            30.09.19    adaptada a la nueva documentación
%            29.09.25    normalizada

    % Derivada discreta (primera derivada)
    d1 = conv(datos, [1 -1], 'same') >= 0;

    % Segunda derivada (detecta cambios creciente → decreciente)
    d2 = conv(d1, [-1 1], 'same');

    % Los máximos son los pulsos positivos
    maximos = d2 > 0;
end

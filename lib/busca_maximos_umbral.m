function maximos = busca_maximos_umbral(datos, th)
% BUSCA_MAXIMOS_UMBRAL Detecta máximos locales de una señal aplicando un umbral.
%
%   maximos = busca_maximos_umbral(datos, th)
%
% INPUT:
%   datos - Vector con la señal en la que se buscan los máximos.
%   th    - Umbral. Solo los máximos con amplitud mayor a este valor
%           serán detectados.
%
% OUTPUT:
%   maximos - Vector lógico del mismo tamaño que datos, con true (1)
%             en cada posición de máximo que supere el umbral y false (0) en el resto.
%
% EXAMPLE:
%   x = 0:0.01:2*pi;
%   y = sin(x) + 0.2*randn(size(x));   % señal ruidosa
%   m = busca_maximos_umbral(y, 0.5);
%   plot(x, y); hold on;
%   plot(x(m), y(m), 'ro')   % marca máximos por encima del umbral
%
% See also: busca_maximos, findpeaks
%
% Author:   Diego
% History:  xx.yy.zz    Diego  creación del archivo
%           JC          añade comentarios
%           19.12.07    incorporada a la toolbox
%           21.01.08    documentada
%           30.09.19    adaptada a la nueva documentación
%           29.09.25    normalizada y modernizada
%

    % Longitud de la señal
    n = numel(datos);

    % Primera derivada -> señal rectangular (pendiente positiva = 1, negativa = 0)
    d1 = datos(2:n) - datos(1:n-1);
    d1 = d1 >= 0;

    % Segunda derivada -> pulsos +1 (máximos) y -1 (mínimos)
    d2 = d1(1:n-2) - d1(2:n-1);

    % Inicializar salida
    maximos = false(1, n);

    % Detectar máximos: pulso positivo y valor mayor que el umbral
    for i = 1:n-2
        if (d2(i) > 0) && (datos(i+1) > th)
            maximos(i+1) = true;
        end
    end
end

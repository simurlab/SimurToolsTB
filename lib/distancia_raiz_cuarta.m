function distancia = distancia_raiz_cuarta(acc_vert)
% DISTANCIA_RAIZ_CUARTA Estima la distancia de un paso con el modelo empírico de raíz cuarta.
%
%   distancia = distancia_raiz_cuarta(acc_vert)
%
%   Esta función estima la distancia recorrida en un paso aplicando el
%   modelo empírico que relaciona la distancia con la raíz cuarta de la
%   amplitud de la aceleración vertical.
%
%   IMPORTANTE: la señal de entrada debe estar previamente filtrada con un
%   filtro pasa-bajo a 3 Hz (por ejemplo: filtro0(acc_vert, 26, 0.06) en
%   uso offline).
%
% INPUT:
%   acc_vert : vector con la aceleración vertical del paso.
%
% OUTPUT:
%   distancia : distancia estimada (m, en escala relativa).
%
% EXAMPLE:
%   acc = filtro0(randn(1,200), 26, 0.06); % señal filtrada
%   d = distancia_raiz_cuarta(acc)
%
% See also: distancia_arco, distancia_pendulo, distancia_pendulo_parcial
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           12.12.2007   adaptado a paso único online
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Amplitud vertical --------------------
    vertical = max(acc_vert) - min(acc_vert);

    % -------------------- Modelo empírico raíz cuarta --------------------
    distancia = vertical.^0.25;
end

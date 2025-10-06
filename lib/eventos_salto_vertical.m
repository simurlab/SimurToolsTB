function tiempos = eventos_salto_vertical(aceleracion_vert, freq)
%EVENTOS_SALTO_VERTICAL Detecta eventos principales de un salto a partir de aceleraciones verticales.
%
%   tiempos = eventos_salto_vertical(aceleracion_vert, freq)
%
%   Esta función detecta automáticamente los eventos principales durante
%   un salto a partir de la aceleración vertical del centro de gravedad (COG).
%   Detecta 4 eventos:
%       - Inicio de salto (mínimo profundo).
%       - Precontacto (paso por g).
%       - Fin de salto (máximo fuerte).
%       - Preparación para el contacto (mínimo cercano al aterrizaje).
%
% INPUT:
%   aceleracion_vert : vector con la aceleración vertical (puede contener varios saltos).
%                      Debe incluir saltos completos (no medios saltos).
%   freq             : frecuencia de muestreo en Hz (opcional, por defecto 100).
%
% OUTPUT:
%   tiempos : matriz Nx5 con:
%       tiempos(:,1) = aceleración vertical original
%       tiempos(:,2) = inicio de salto (mínimo profundo)
%       tiempos(:,3) = precontacto (paso por g)
%       tiempos(:,4) = fin de salto (máximo fuerte)
%       tiempos(:,5) = preparación para el contacto (mínimo cercano)
%
% EJEMPLO:
%   t = 0:0.01:2;
%   acc = [zeros(1,30) -12*ones(1,20) 15*ones(1,20) -9.8*ones(1,20) zeros(1,90)];
%   tiempos = eventos_salto_vertical(acc, 100);
%   plot(acc); hold on;
%   plot(find(tiempos(:,2)), acc(tiempos(:,2)==1), 'ro'); % inicio
%   plot(find(tiempos(:,4)), acc(tiempos(:,4)==1), 'go'); % fin
%
%
% Author:   Alberto Castañón
% History:  24.01.2007   Diego - adaptación a siloptoolbox
%           18.12.2007   Diego - adaptación v0.3
%           29.09.2025   normalizada y modernizada
%

    if nargin < 2
        freq = 100;
    end

    % --- Detectar mínimos iniciales ---
    minimos = buscaMaximosTh(-aceleracion_vert, 1.5);
    ind_min = find(minimos == 1);
    num = numel(ind_min);

    % Eliminar mínimos muy cercanos (<1 s)
    inicio = ind_min(1);
    for i = 2:num
        if ind_min(i) - inicio <= freq
            minimos(ind_min(i)) = 0;
        else
            inicio = ind_min(i);
        end
    end
    ind_min = find(minimos == 1);
    num_saltos = numel(ind_min);

    % --- Detectar máximos (>20) tras cada mínimo ---
    maximos = buscaMaximosTh(aceleracion_vert, 20);
    ind_max = find(maximos);

    ind_max2 = [];
    j = 1;
    for i = 1:numel(ind_max)
        if ind_max(i) > ind_min(j)
            ind_max2(j) = ind_max(i); %#ok<AGROW>
            j = j + 1;
        end
        if j > num_saltos
            break;
        end
    end
    ind_max = ind_max2;

    % --- Detectar mínimos cercanos al máximo (<9.81) ---
    ind_min_cerc = [];
    for i = 1:num_saltos
        datos_tramo = -aceleracion_vert(ind_min(i)+1 : ind_max(i)+1);
        min_loc = buscaMaximosTh(datos_tramo, -9.81);
        indices = find(min_loc == 1);
        ind_min_cerc(i) = indices(end) + ind_min(i); %#ok<AGROW>
    end

    % --- Detectar paso por g (9.81) ---
    ind_paso_g = [];
    for i = 1:num_saltos
        datos_tramo = -abs(aceleracion_vert(ind_min_cerc(i)+1 : ind_max(i)+1) - 9.81);
        paso_g = buscaMaximos(datos_tramo);
        indices = find(paso_g == 1);
        ind_paso_g(i) = indices(1) + ind_min_cerc(i); %#ok<AGROW>
    end

    % --- Construir matriz de salida ---
    n = length(aceleracion_vert);
    tiempos = zeros(n, 5);
    tiempos(:,1) = aceleracion_vert;
    tiempos(ind_min,2) = 1;
    tiempos(ind_paso_g,3) = 1;
    tiempos(ind_max,4) = 1;
    tiempos(ind_min_cerc,5) = 1;
end

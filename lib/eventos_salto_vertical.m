function tiempos = eventosSalto(aceleracionVert, frecuencia)
%EVENTOSSALTO Detecta eventos principales a partir de aceleraciones verticales.
%
%   tiempos = eventosSalto(aceleracionVert, frecuencia)
%
%   Esta función detecta automáticamente los eventos principales durante
%   un salto a partir de la aceleración vertical del centro de gravedad (COG).
%   Detecta 4 eventos: inicio, preparación, precontacto y fin.
%
%   INPUT:
%       aceleracionVert : vector con la aceleración vertical (puede contener varios saltos).
%                         Debe contener saltos completos (no medios saltos).
%       frecuencia      : frecuencia de muestreo en Hz (por defecto 100).
%
%   OUTPUT:
%       tiempos : matriz Nx5 con:
%           tiempos(:,1) = aceleracionVert
%           tiempos(:,2) = inicio de salto (mínimo profundo)
%           tiempos(:,3) = precontacto (paso por g)
%           tiempos(:,4) = fin de salto (máximo fuerte)
%           tiempos(:,5) = preparación para el contacto (mínimo cercano)
%
%
% Author:   Alberto Castañón
% History:  24.01.2007   Diego - adaptación a siloptoolbox
%           18.12.2007   Diego - adaptación v0.3
%           29.09.2025   normalizada y modernizada

    if nargin < 2
        frecuencia = 100;
    end

    % --- Detectar mínimos iniciales ---
    minimos = buscaMaximosTh(-aceleracionVert, 1.5);
    indMin = find(minimos == 1);
    num = numel(indMin);

    % Eliminar mínimos muy cercanos (<1s)
    inicio = indMin(1);
    for i = 2:num
        if indMin(i) - inicio <= frecuencia
            minimos(indMin(i)) = 0;
        else
            inicio = indMin(i);
        end
    end
    indMin = find(minimos == 1);
    numSaltos = numel(indMin);

    % --- Detectar máximos (>20) tras cada mínimo ---
    maximos = buscaMaximosTh(aceleracionVert, 20);
    indMax = find(maximos);

    indMax2 = [];
    j = 1;
    for i = 1:numel(indMax)
        if indMax(i) > indMin(j)
            indMax2(j) = indMax(i); %#ok<AGROW>
            j = j + 1;
        end
        if j > numSaltos
            break;
        end
    end
    indMax = indMax2;

    % --- Detectar mínimos cercanos al máximo (<9.81) ---
    indMinCerc = [];
    for i = 1:numSaltos
        datosTramo = -aceleracionVert(indMin(i)+1 : indMax(i)+1);
        minLoc = buscaMaximosTh(datosTramo, -9.81);
        indices = find(minLoc == 1);
        indMinCerc(i) = indices(end) + indMin(i); %#ok<AGROW>
    end

    % --- Detectar paso por g (9.81) ---
    indPasoG = [];
    for i = 1:numSaltos
        datosTramo = -abs(aceleracionVert(indMinCerc(i)+1 : indMax(i)+1) - 9.81);
        pasoG = buscaMaximos(datosTramo);
        indices = find(pasoG == 1);
        indPasoG(i) = indices(1) + indMinCerc(i); %#ok<AGROW>
    end

    % --- Construir matriz de salida ---
    n = length(aceleracionVert);
    tiempos = zeros(n, 5);
    tiempos(:,1) = aceleracionVert;
    tiempos(indMin,2) = 1;
    tiempos(indPasoG,3) = 1;
    tiempos(indMax,4) = 1;
    tiempos(indMinCerc,5) = 1;
end

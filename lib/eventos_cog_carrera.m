function [ic, fc] = eventos_cog_carrera(aceleracion)
%EVENTOS_COG_CARRERA Detecta eventos de carrera (IC y FC) a partir de la aceleración.
%
%   [ic, fc] = eventos_cog_carrera(aceleracion)
%
%   Esta función detecta los eventos de contacto inicial (IC, Initial Contact)
%   y contacto final (FC, Final Contact) durante la carrera, usando una señal
%   de aceleración 3D del centro de gravedad (COG).
%
%   Algoritmo:
%       1) Calcula la aceleración resultante (norma de las 3 componentes).
%       2) Aplica un filtrado de media móvil para suavizar la señal.
%       3) Obtiene una señal rectangular de derivadas para detectar cambios
%          de pendiente.
%       4) Identifica candidatos a IC y FC mediante un umbral dinámico.
%       5) Elimina duplicados garantizando la secuencia IC–FC–IC–FC.
%       6) Ajusta IC y FC al mínimo local dentro de cada intervalo detectado.
%
% INPUT:
%   aceleracion : matriz Nx3 con la señal de aceleración cruda.
%
% OUTPUT:
%   ic : índices de contacto inicial (Initial Contact).
%   fc : índices de contacto final (Final Contact).
%
% EJEMPLO:
%   acc = randn(1000,3); % aceleración ficticia
%   [ic, fc] = eventos_cog_carrera(acc);
%   plot(sqrt(sum(acc.^2,2))); hold on;
%   plot(ic, sqrt(sum(acc(ic,:).^2,2)), 'go'); % IC
%   plot(fc, sqrt(sum(acc(fc,:).^2,2)), 'ro'); % FC
%
% See also: eliminar_duplicados, filtfilt
%
% Author:   Diego
% History:  xx.yy.zz    creación del archivo
%           29.09.2025  normalizada y modernizada
%

    % -------------------- Aceleración resultante --------------------
    acc_res = sqrt(sum(aceleracion.^2, 2));

    % -------------------- Filtrado de media móvil --------------------
    window_size = 10;
    b = (1/window_size)*ones(1, window_size);
    a = 1;
    acc_filt = filtfilt(b, a, acc_res - acc_res(1)) + acc_res(1);

    n = size(acc_filt, 1);

    % -------------------- Señal rectangular --------------------
    datos2 = acc_filt(2:n) - acc_filt(1:n-1);
    datos2 = datos2 >= 0;
    datos2 = datos2(1:n-2) - datos2(2:n-1);

    ultimos_min = [];
    ultimos_max = [];
    min_aux = zeros(1,n);
    max_aux = zeros(1,n);

    % -------------------- Detección preliminar --------------------
    for i = 51:(n-2)
        umbral = (max(acc_filt(i-50:i)) + min(acc_filt(i-50:i))) / 2;

        if datos2(i) < 0  % posible IC
            ultimos_min = [ultimos_min i];
        end
        if datos2(i) > 0  % posible FC
            ultimos_max = [ultimos_max i];
        end

        if datos2(i) > 0 && acc_filt(i) > umbral
            if ~isempty(ultimos_min)
                min_aux(ultimos_min(end)) = 1;
                ultimos_min = [];
            end
            if ~isempty(ultimos_max)
                max_aux(ultimos_max(end)) = 1;
                ultimos_max = [];
            end
        end
    end

    min_cand = find(min_aux == 1) + 1;
    max_cand = find(max_aux == 1) + 1;

    % -------------------- Eliminar duplicados --------------------
    [min_cand, max_cand] = eliminar_duplicados(min_cand, max_cand);

    % -------------------- Ajuste fino de IC y FC --------------------
    ic = [];
    fc = [];
    for i = 1:length(min_cand)
        [~, ic_temp] = min(acc_res(min_cand(i):max_cand(i)));
        ic_temp = ic_temp + min_cand(i) - 1;
        ic = [ic, ic_temp];

        if i < length(min_cand)
            [~, fc_temp] = min(acc_res(max_cand(i):min_cand(i+1)));
        else
            [~, fc_temp] = min(acc_res(max_cand(i):end));
        end
        fc_temp = fc_temp + max_cand(i) - 1;
        fc = [fc, fc_temp];
    end
end

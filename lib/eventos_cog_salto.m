function eventos = eventos_cog_salto(acc_vert, freq)
%EVENTOS_COG_SALTO Detecta los eventos de salto vertical desde la aceleración del COG.
%
%   eventos = eventos_cog_salto(acc_vert, freq)
%
%   Detecta hasta cuatro eventos por salto a partir de la aceleración
%   vertical del centro de gravedad (COG). La señal puede contener uno o
%   varios saltos, con o sin periodos estáticos entre ellos. No debe
%   contener medio salto al inicio ni al final.
%
% INPUT:
%   acc_vert : vector con la aceleración vertical del COG [g o m/s²].
%              La señal debe estar orientada de forma que en vuelo libre
%              el valor sea próximo a 0 y en apoyo próximo a +9.81 (m/s²)
%              o +1 (g). Si viene invertida, negar antes de llamar.
%   freq     : frecuencia de muestreo [Hz]. Por defecto 100 Hz.
%
% OUTPUT:
%   eventos : matriz del mismo número de filas que acc_vert, con columnas:
%               col 1 — acc_vert (señal original)
%               col 2 — inicio del salto (mínimo de aceleración previo al despegue)
%               col 3 — contacto inicial (paso por g tras el vuelo)
%               col 4 — fin del salto (máximo de impacto tras aterrizaje)
%               col 5 — preparación para el contacto (mínimo entre vuelo e impacto)
%
% EJEMPLO:
%   datos = load('ejemplo_salto_imu.log');
%   acc_v = datos(400:1600, 2);
%   ev = eventos_cog_salto(-acc_v, 100);
%   inicios = find(ev(:,2));
%   finales = find(ev(:,4));
%
% See also: busca_maximos_umbral, busca_maximos
%
% Author:   Alberto Castañon, Diego Álvarez
% History:  24.01.2007  adaptación a siloptoolbox
%           18.12.2007  adaptación a v0.3
%           29.09.2025  normalizada: buscamaximosth → busca_maximos_umbral,
%                       buscamaximos → busca_maximos

    if nargin < 2
        freq = 100;
    end

    % ── 1. Localizar un mínimo por salto (aceleración < -1.5 g) ──────────
    minimos = busca_maximos_umbral(-acc_vert, 1.5);
    ind_min = find(minimos == 1);

    % Conservar solo un mínimo por salto (separación mínima: 1 s)
    inicio = ind_min(1);
    for i = 2:length(ind_min)
        if ind_min(i) - inicio <= freq
            minimos(ind_min(i)) = 0;
        else
            inicio = ind_min(i);
        end
    end
    ind_min     = find(minimos == 1);
    num_saltos  = length(ind_min);

    % ── 2. Máximo de impacto (> 20 m/s²) después de cada mínimo ─────────
    maximos  = busca_maximos_umbral(acc_vert, 20);
    ind_max_all = find(maximos);

    j = 1;
    ind_max = zeros(1, num_saltos);
    for i = 1:length(ind_max_all)
        if ind_max_all(i) > ind_min(j)
            ind_max(j) = ind_max_all(i);
            j = j + 1;
        end
        if j > num_saltos
            break;
        end
    end

    % ── 3. Mínimo más cercano a g entre el mínimo inicial y el máximo ────
    ind_min_cerc = zeros(1, num_saltos);
    for i = 1:num_saltos
        tramo   = -acc_vert(ind_min(i)+1 : ind_max(i)+1);
        m       = busca_maximos_umbral(tramo, -9.81);
        idx     = find(m == 1);
        ind_min_cerc(i) = idx(end) + ind_min(i);
    end

    % ── 4. Paso por g (punto más próximo a 9.81 entre min_cerc y máximo) ─
    ind_paso_g = zeros(1, num_saltos);
    for i = 1:num_saltos
        tramo   = -abs(acc_vert(ind_min_cerc(i)+1 : ind_max(i)+1) - 9.81);
        pg      = busca_maximos(tramo);
        idx     = find(pg == 1);
        ind_paso_g(i) = idx(1) + ind_min_cerc(i);
    end

    % ── 5. Construir matriz de salida ─────────────────────────────────────
    n = length(acc_vert);
    eventos = [acc_vert, zeros(n,1), zeros(n,1), zeros(n,1), zeros(n,1)];

    for k = ind_min,       eventos(k, 2) = 1; end
    for k = ind_paso_g,    eventos(k, 3) = 1; end
    for k = ind_max,       eventos(k, 4) = 1; end
    for k = ind_min_cerc,  eventos(k, 5) = 1; end

end

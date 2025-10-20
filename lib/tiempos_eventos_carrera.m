function resultados = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq)
%TIEMPOS_EVENTOS_CARRERA Calcula intervalos temporales entre eventos de carrera.
%
%   resultados = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq)
%
%   INPUT:
%       ic      : índices de contacto inicial (IC / FS)
%       fc      : índices de contacto final (FC / TO)
%       max_s   : índices de máximo swing
%       min_s   : índices de mínimo swing
%       mvp     : índices de máxima velocidad de pronación
%       mp      : índices de máxima pronación
%       freq    : frecuencia de muestreo [Hz]
%
%   OUTPUT:
%       resultados : estructura con:
%           .tiempos -> vectores de intervalos por ciclo (s)
%           .medias  -> promedios de cada intervalo (s)
%
%   EVENTOS CONSIDERADOS:
%       1) IC → FC
%       2) MaxSwing → IC
%       3) IC → MVP
%       4) MVP → MP
%       5) MP → FC
%       6) FC → MinSwing
%       7) MaxSwing → MinSwing
%       8) IC → IC (duración de ciclo)
%       9) FC → IC siguiente (vuelo)
%      10) %Vuelo respecto a contacto
%
%   Versión: 08/10/2025 - SiMuR Toolbox v1.6.1
% -------------------------------------------------------------------------

    n = length(ic);

    % Prealocación
    t_fs_to      = NaN(1,n);
    t_maxs_fs    = NaN(1,n);
    t_fs_mvp     = NaN(1,n);
    t_mvp_mp     = NaN(1,n);
    t_mp_to      = NaN(1,n);
    t_to_mins    = NaN(1,n);
    t_maxs_mins  = NaN(1,n);
    t_ic_ic      = NaN(1,n-1);
    t_vuelo      = NaN(1,n-1);
    pct_vuelo    = NaN(1,n-1);

    for i = 1:n
        % 1) IC -> FC (contacto)
        if i <= length(fc)
            t_fs_to(i) = (fc(i) - ic(i)) / freq;
        end

        % 2) MaxSwing -> IC (asegurando que MaxSwing precede al IC)
        if i < length(max_s) && ~isnan(max_s(i))
            if max_s(i) < ic(i)
                t_maxs_fs(i) = (ic(i) - max_s(i)) / freq;
            else
                % si MaxSwing ocurre después, usar el siguiente
                if i+1 <= length(ic)
                    t_maxs_fs(i) = (ic(i+1) - max_s(i)) / freq;
                end
            end
        end

        % 3) IC -> MVP
        if i <= length(mvp) && ~isnan(mvp(i))
            t_fs_mvp(i) = (mvp(i) - ic(i)) / freq;
        end

        % 4) MVP -> MP
        if i <= length(mvp) && i <= length(mp) && ~isnan(mvp(i)) && ~isnan(mp(i))
            t_mvp_mp(i) = (mp(i) - mvp(i)) / freq;
        end

        % 5) MP -> FC
        if i <= length(mp) && i <= length(fc) && ~isnan(mp(i))
            t_mp_to(i) = (fc(i) - mp(i)) / freq;
        end

        % 6) FC -> MinSwing
        if i <= length(min_s) && i <= length(fc) && ~isnan(min_s(i))
            t_to_mins(i) = (min_s(i) - fc(i)) / freq;
        end

        % 7) MaxSwing -> MinSwing
        if i <= length(max_s) && i <= length(min_s) && ~isnan(max_s(i)) && ~isnan(min_s(i))
            t_maxs_mins(i) = (max_s(i) - min_s(i)) / freq;
        end

        % 8) IC -> IC siguiente (duración de ciclo)
        if i < length(ic)
            t_ic_ic(i) = (ic(i+1) - ic(i)) / freq;
        end

        % 9) FC -> IC siguiente (tiempo de vuelo)
        if i < length(fc)
            if fc(i) < ic(i+1)
                t_vuelo(i) = (ic(i+1) - fc(i)) / freq;
            else
                t_vuelo(i) = NaN; % paso inválido si FC ocurre después del siguiente IC
            end
        end

        % 10) % vuelo frente a contacto (en cada ciclo)
        if i <= length(t_vuelo) && i <= length(t_fs_to)
            if ~isnan(t_vuelo(i)) && ~isnan(t_fs_to(i))
                pct_vuelo(i) = (t_vuelo(i) / (t_vuelo(i) + t_fs_to(i))) * 100;
            end
        end
    end

    % Guardar resultados
    resultados.tiempos.fs_to      = t_fs_to;
    resultados.tiempos.maxs_fs    = t_maxs_fs;
    resultados.tiempos.fs_mvp     = t_fs_mvp;
    resultados.tiempos.mvp_mp     = t_mvp_mp;
    resultados.tiempos.mp_to      = t_mp_to;
    resultados.tiempos.to_mins    = t_to_mins;
    resultados.tiempos.maxs_mins  = t_maxs_mins;
    resultados.tiempos.ic_ic      = t_ic_ic;
    resultados.tiempos.vuelo      = t_vuelo;
    resultados.tiempos.pct_vuelo  = pct_vuelo;

    % Medias
    resultados.medias.fs_to      = mean(t_fs_to, 'omitnan');
    resultados.medias.maxs_fs    = mean(t_maxs_fs, 'omitnan');
    resultados.medias.fs_mvp     = mean(t_fs_mvp, 'omitnan');
    resultados.medias.mvp_mp     = mean(t_mvp_mp, 'omitnan');
    resultados.medias.mp_to      = mean(t_mp_to, 'omitnan');
    resultados.medias.to_mins    = mean(t_to_mins, 'omitnan');
    resultados.medias.maxs_mins  = mean(t_maxs_mins, 'omitnan');
    resultados.medias.ic_ic      = mean(t_ic_ic, 'omitnan');
    resultados.medias.vuelo      = mean(t_vuelo, 'omitnan');
    resultados.medias.pct_vuelo  = mean(pct_vuelo, 'omitnan');

end

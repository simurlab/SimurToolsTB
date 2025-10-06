function resultados = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq)
%TIEMPOS_EVENTOS_CARRERA Calcula intervalos temporales entre eventos de carrera.
%
%   resultados = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq)
%
%   INPUT:
%       ic      : índices de contacto inicial (IC / Foot-strike).
%       fc      : índices de contacto final (FC / Toe-off).
%       max_s   : índices de máximo swing.
%       min_s   : índices de mínimo swing.
%       mvp     : índices de máxima velocidad de pronación.
%       mp      : índices de máxima pronación.
%       freq    : frecuencia de muestreo (Hz).
%
%   OUTPUT:
%       resultados : estructura con:
%           .tiempos -> vectores de intervalos por ciclo (s).
%           .medias  -> promedios de cada intervalo (s).
%
%   EVENTOS CONSIDERADOS:
%       1) IC → FC
%       2) MaxSwing → IC
%       3) IC → MVP
%       4) MVP → MP
%       5) MP → FC
%       6) FC → MinSwing
%       7) MaxSwing → MinSwing
%
%   EXAMPLE:
%       fs = 100;  % Hz
%       ic  = [10 110 210];
%       fc  = [60 160 260];
%       max_s = [5 105 205];
%       min_s = [80 180 280];
%       mvp = [30 130 230];
%       mp  = [40 140 240];
%       resultados = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, fs);
%
%
%   History:
%       - 02/10/2025: Versión inicial adaptada a convención snake_case.
%

    n = length(ic);

    % Prealocación con NaN por si faltan eventos
    t_fs_to      = NaN(1,n);
    t_maxs_fs    = NaN(1,n);
    t_fs_mvp     = NaN(1,n);
    t_mvp_mp     = NaN(1,n);
    t_mp_to      = NaN(1,n);
    t_to_mins    = NaN(1,n);
    t_maxs_mins  = NaN(1,n);

    for i = 1:n
        % 1) IC -> FC
        if i <= length(fc)
            t_fs_to(i) = (fc(i) - ic(i)) / freq;
        end

        % 2) MaxSwing -> IC
        if i <= length(max_s) && ~isnan(max_s(i))
            t_maxs_fs(i) = (ic(i) - max_s(i)) / freq;
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
            t_maxs_mins(i) = (min_s(i) - max_s(i)) / freq;
        end
    end

    % Guardar resultados en estructura
    resultados.tiempos.fs_to      = t_fs_to;
    resultados.tiempos.maxs_fs    = t_maxs_fs;
    resultados.tiempos.fs_mvp     = t_fs_mvp;
    resultados.tiempos.mvp_mp     = t_mvp_mp;
    resultados.tiempos.mp_to      = t_mp_to;
    resultados.tiempos.to_mins    = t_to_mins;
    resultados.tiempos.maxs_mins  = t_maxs_mins;

    % Medias ignorando NaN
    resultados.medias.fs_to      = mean(t_fs_to, 'omitnan');
    resultados.medias.maxs_fs    = mean(t_maxs_fs, 'omitnan');
    resultados.medias.fs_mvp     = mean(t_fs_mvp, 'omitnan');
    resultados.medias.mvp_mp     = mean(t_mvp_mp, 'omitnan');
    resultados.medias.mp_to      = mean(t_mp_to, 'omitnan');
    resultados.medias.to_mins    = mean(t_to_mins, 'omitnan');
    resultados.medias.maxs_mins  = mean(t_maxs_mins, 'omitnan');

end

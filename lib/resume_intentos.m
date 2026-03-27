function resume_intentos(inicio_paso, fin_paso, path_dir)
%% ------------------------------------------------------------------------
% RESUME_INTENTOS  Procesa archivos de intentos (e.g. e0101.mat)
%                  calculando eventos, tiempos, amplitudes, RMS,
%                  cadencia y tiempo de vuelo (%).
%
%   resume_intentos(inicio_paso, fin_paso, path_dir)
%
% INPUT:
%   inicio_paso - Paso inicial a considerar (si <=0 → se usa 1)
%   fin_paso    - Paso final a considerar (si <=0 o > nº pasos → último)
%   path_dir    (opcional) - Carpeta donde buscar archivos .mat
%                            (por defecto = pwd)
%
% Requiere:
%   - eventos_pie_carrera.m
%   - tiempos_eventos_carrera.m
%   - amplitud_frenado_carrera.m
%   - amplitud_impacto_carrera.m
%   - aceleracion_vert_frenado_carrera.m
%   - aceleracion_vert_impacto_carrera.m
%   - cadencia.m
%
% Versión: 08/10/2025 - SiMuR Toolbox v1.8.0
% -------------------------------------------------------------------------

    if nargin < 3 || isempty(path_dir)
        path_dir = pwd;  % Carpeta actual por defecto
    end

    if ~isfolder(path_dir)
        error('❌ La carpeta especificada no existe: %s', path_dir);
    end

    fprintf('📂 Procesando archivos en: %s\n', path_dir);

    % --- Configuración inicial ---
    freq = 120;         % Frecuencia de muestreo [Hz]
    th   = 150;         % Umbral para detección de eventos

    % --- Buscar archivos de intentos ---
    archivos = dir(fullfile(path_dir, '*.mat'));
    archivos = archivos(~cellfun(@isempty, regexp({archivos.name}, '^[a-zA-Z]\d{4}\.mat$', 'once')));

    resultados = {};

    if isempty(archivos)
        warning('⚠️ No se encontraron archivos de intentos en: %s', path_dir);
        return;
    end

    for k = 1:numel(archivos)
        nombre = archivos(k).name;
        fullpath = fullfile(path_dir, nombre);
        datos = load(fullpath);

        pies = {'FL_1','FR_1'};
        for p = 1:length(pies)
            pie = pies{p};

            % ---- Buscar tabla del pie ----
            posiblesCampos = fieldnames(datos);
            campoPie = posiblesCampos(startsWith(posiblesCampos, pie));
            if isempty(campoPie)
                continue;
            end
            campoPie = campoPie{1};
            tabla = datos.(campoPie);

            % ---- Señales necesarias ----
            if istable(tabla)
                gyr_ml   = tabla.Gyr_Y;
                gyr_pron = tabla.Gyr_Z;
                acc_ap   = tabla.Acc_Y;
                acc_v    = tabla.Acc_Z;
            elseif isstruct(tabla)
                gyr_ml   = tabla.Gyr_Y;
                gyr_pron = tabla.Gyr_Z;
                acc_ap   = tabla.Acc_Y;
                acc_v    = tabla.Acc_Z;
            else
                warning('⚠️ %s no tiene estructura válida.', campoPie);
                continue;
            end

            % ---- Detección de eventos (con pronación) ----
            [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr_ml, th, freq, gyr_pron);

            if isempty(ic) || isempty(fc)
                warning('⚠️ No se detectaron pasos en %s (%s).', nombre, pie);
                continue;
            end

            % --- Validar y ajustar rango de pasos ---
            n_pasos = numel(ic);
            ini = inicio_paso;
            fin = fin_paso;

            if ini <= 0 || ini > n_pasos
                ini = 1;
            end
            if fin <= 0 || fin > n_pasos
                fin = n_pasos;
            end
            if ini > fin
                warning('⚠️ inicio_paso (%d) > fin_paso (%d). Se ajusta automáticamente.', ini, fin);
                ini = 1;
                fin = n_pasos;
            end

            % ---- Calcular cadencia ----
            try
                cad = cadencia(ic, freq, 'global'); % [pasos/min]
            catch
                cad = NaN;
            end

            % ---- Calcular tiempos de eventos ----
            tiempos = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq);

            % ---- Seleccionar pasos definidos (ini:fin) ----
            campos = fieldnames(tiempos.tiempos);
            medias_intervalo = struct();
            for c = 1:length(campos)
                campo = campos{c};
                v = tiempos.tiempos.(campo);

                if isempty(v)
                    medias_intervalo.(campo) = NaN;
                    continue;
                end

                % Ajustar rango dentro del tamaño del vector
                ini_valid = max(1, min(ini, numel(v)));
                fin_valid = max(ini_valid, min(fin, numel(v)));
                v_sel = v(ini_valid:fin_valid);

                medias_intervalo.(campo) = round(mean(v_sel, 'omitnan') * 1000, 1); % [ms]
            end

            % ---- Calcular amplitudes y RMS ----
            try
                [~, braking_moda] = amplitud_frenado_carrera({ic}, acc_ap, false);
            catch
                braking_moda = NaN;
            end

            try
                [~, impact_moda] = amplitud_impacto_carrera({ic}, acc_v);
            catch
                impact_moda = NaN;
            end

            try
                [~, rms_frenado_moda] = aceleracion_vert_frenado_carrera(ic, fc, acc_ap, gyr_ml);
            catch
                rms_frenado_moda = NaN;
            end

            try
                [~, rms_impacto_moda] = aceleracion_vert_impacto_carrera(ic, fc, acc_v, gyr_ml);
            catch
                rms_impacto_moda = NaN;
            end

            % ---- Extraer datos medios de vuelo ----
            vuelo_ms_mean    = round(tiempos.medias.vuelo * 1000, 1);
            contacto_ms_mean = round(tiempos.medias.fs_to * 1000, 1);
            vuelo_pct_mean   = round(tiempos.medias.pct_vuelo, 2);
            ic_ic_ms_mean    = round(tiempos.medias.ic_ic * 1000, 1);

            % ---- Guardar resultados ----
            resultados(end+1, :) = {nombre, pie, ...
                medias_intervalo.fs_to, medias_intervalo.fs_mvp, medias_intervalo.mvp_mp, ...
                medias_intervalo.mp_to, medias_intervalo.to_mins, medias_intervalo.maxs_mins, ...
                medias_intervalo.maxs_fs, ...
                cad, vuelo_ms_mean, vuelo_pct_mean, ic_ic_ms_mean, ...
                braking_moda, impact_moda, ...
                rms_frenado_moda, rms_impacto_moda};
        end
    end

    % ---- Crear tabla final ----
    if ~isempty(resultados)
        T = cell2table(resultados, ...
            'VariableNames', {'Archivo','Pie', ...
            'FS_TO [ms]','FS_MVP [ms]','MVP_MP [ms]','MP_TO [ms]', ...
            'TO_MinS [ms]','MinS_MaxS [ms]','MaxS_FS [ms]', ...
            'Cadencia [pasos/min]','Vuelo [ms]','Vuelo [%]','Ciclo [ms]', ...
            'Frenado [Gs]','Impacto [Gs]','RMS_Frenado [Gs]','RMS_Impacto [Gs]'});
        
        fprintf('===== 🧩 Tabla resumen de tiempos (pasos %d–%d), amplitudes, RMS, cadencia y vuelo =====\n', ...
            inicio_paso, fin_paso);
        disp(T);
    else
        disp('⚠️ No se pudo generar ninguna fila válida (revisa estructura de los .mat).');
    end
end

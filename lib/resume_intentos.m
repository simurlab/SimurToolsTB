%% ------------------------------------------------------------------------
% PROCESAR_INTENTOS  Procesa archivos de intentos (e.g. e0101.mat)
%                    calculando eventos, tiempos, cadencia y amplitudes.
%
% Requiere:
%   - eventos_pie_carrera.m
%   - tiempos_eventos_carrera.m
%   - amplitud_frenado_carrera.m
%   - amplitud_impacto_carrera.m
%   - rms_aceleracion_frenado_carrera.m
%   - rms_aceleracion_impacto_carrera.m
%
% Versión: 06/10/2025 - SiMuR Toolbox v1.5.0
% -------------------------------------------------------------------------

clear; clc; close all;

freq = 120;         % Frecuencia de muestreo [Hz]
th   = 150;         % Umbral para detección de eventos
inicio_paso = 5;    % Paso inicial a considerar para el promedio
fin_paso    = 30;   % Paso final a considerar para el promedio

% --- Buscar archivos de intentos tipo e0101, f0102, etc. ---
archivos = dir('*.mat');
archivos = archivos(~cellfun(@isempty, regexp({archivos.name}, '^[a-zA-Z]\d{4}\.mat$', 'once')));

resultados = {};

if isempty(archivos)
    error('❌ No se encontraron archivos de intentos en la carpeta actual.');
end

for k = 1:numel(archivos)
    nombre = archivos(k).name;
    datos = load(nombre);

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
            gyr_ml = tabla.Gyr_Y;
            acc_ap = tabla.Acc_Y;
            acc_v  = tabla.Acc_Z;
        elseif isstruct(tabla)
            gyr_ml = tabla.Gyr_Y;
            acc_ap = tabla.Acc_Y;
            acc_v  = tabla.Acc_Z;
        else
            warning('⚠️ %s no tiene estructura válida.', campoPie);
            continue;
        end

        % ---- Detección de eventos ----
        [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr_ml, th, freq);

        if isempty(ic) || isempty(fc)
            warning('⚠️ No se detectaron pasos en %s (%s).', nombre, pie);
            continue;
        end

        % ---- Calcular tiempos ----
        tiempos = tiempos_eventos_carrera(ic, fc, max_s, min_s, mvp, mp, freq);

        % ---- Seleccionar pasos definidos (inicio_paso:fin_paso) ----
        campos = fieldnames(tiempos.tiempos);
        medias_intervalo = struct();
        for c = 1:length(campos)
            campo = campos{c};
            v = tiempos.tiempos.(campo);

            if numel(v) >= fin_paso
                v_sel = v(inicio_paso:fin_paso);
            elseif numel(v) > inicio_paso
                v_sel = v(inicio_paso:end);
            else
                v_sel = [];
            end

            % Convertir a milisegundos y redondear
            medias_intervalo.(campo) = round(mean(v_sel, 'omitnan') * 1000, 1); % [ms]
        end

        % ---- Calcular amplitud de frenado ----
        try
            [~, braking_moda] = amplitud_frenado_carrera({ic}, acc_ap, false);
        catch
            braking_moda = NaN;
        end

        % ---- Calcular amplitud de impacto ----
        try
            [~, impact_moda] = amplitud_impacto_carrera({ic}, acc_v);
        catch
            impact_moda = NaN;
        end

        % ---- Calcular RMS de frenado ----
        try
            [~, rms_frenado_moda] = rms_aceleracion_frenado_carrera(ic, fc, acc_ap, gyr_ml);
        catch
            rms_frenado_moda = NaN;
        end

        % ---- Calcular RMS de impacto ----
        try
            [~, rms_impacto_moda] = rms_aceleracion_impacto_carrera(ic, fc, acc_v, gyr_ml);
        catch
            rms_impacto_moda = NaN;
        end

        % ---- Guardar resultados ----
        resultados(end+1, :) = {nombre, pie, ...
            medias_intervalo.fs_to, medias_intervalo.maxs_fs, medias_intervalo.fs_mvp, ...
            medias_intervalo.mvp_mp, medias_intervalo.mp_to, medias_intervalo.to_mins, ...
            medias_intervalo.maxs_mins, ...
            braking_moda, impact_moda, ...
            rms_frenado_moda, rms_impacto_moda};
    end
end

% ---- Crear tabla final ----
if ~isempty(resultados)
    T = cell2table(resultados, ...
        'VariableNames', {'Archivo','Pie', ...
        'IC_FC [ms]','MaxS_IC [ms]','IC_MVP [ms]','MVP_MP [ms]','MP_FC [ms]', ...
        'FC_MinS [ms]','MaxS_MinS [ms]', ...
        'Braking [Gs]','Impact [Gs]','RMS_Frenado [Gs]','RMS_Impacto [Gs]'});

    fprintf('===== 🧩 Tabla resumen de tiempos (pasos %d–%d) y amplitudes de impacto/frenado =====\n', ...
        inicio_paso, fin_paso);
    disp(T);
else
    disp('⚠️ No se pudo generar ninguna fila válida (revisa estructura de los .mat).');
end

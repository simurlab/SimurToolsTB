function [tabla, info_segmentos] = f_carga_DOT(varargin)
% f_carga_DOT  Carga y procesa datos desde uno o varios archivos .csv de un sensor Xsens Dot.
%
% [tabla, info_segmentos] = f_carga_DOT('Name', Value, ...)
%
% Parámetros nombre-valor (opcionales):
%   'folder_path' - Ruta a la carpeta con archivos .csv. Por defecto: carpeta actual.
%   'save'        - 'y' para guardar la tabla como dot_YYMMDD.mat. Por defecto: 'n'.
%
% Salidas:
%   tabla           - Tabla combinada de todos los datos procesados.
%   info_segmentos  - Estructura con campos: nombre_dot, segmento, orientacion.

    % -------------------- Valores por defecto --------------------
    ruta_carpeta = pwd;
    guardar = 'n';

    % -------------------- Procesar argumentos nombre-valor --------------------
    for i = 1:2:length(varargin)
        nombre = lower(varargin{i});
        valor = varargin{i+1};
        switch nombre
            case 'ruta_carpeta'
                ruta_carpeta = valor;
            case 'save'
                guardar = valor;
            otherwise
                error('Parámetro desconocido: %s', nombre);
        end
    end

    % -------------------- Buscar archivos .csv --------------------
    archivos = dir(fullfile(ruta_carpeta, '*.csv'));
    if isempty(archivos)
        error('No se encontraron archivos .csv en la ruta: %s', ruta_carpeta);
    end

    % Ordenar por fecha y hora del nombre
    nombres = {archivos.name};
    fechas_str = erase(extractAfter(extractAfter(nombres, '_'), '_'), '.csv');
    fechas = datetime(fechas_str, 'InputFormat', 'yyyyMMdd_HHmmss');
    [~, idx_orden] = sort(fechas);
    archivos = archivos(idx_orden);

    % -------------------- Cargar todos los archivos y concatenar --------------------
    tabla_total = table();
    desfase_tiempo = 0;
    desfase_muestra = 0;
    info_segmentos = struct('IMU', {}, 'ubicacion', {}, 'modelo', {}, ...
                        'frecuencia', {}, 'segmento', {}, 'orientacion', {});

    % -------------------- Preguntar por orientación --------------------
    orientaciones = {};
    if numel(archivos) == 1
        vector_orientacion = input('Introduce orientación del sensor [1 2 3]: ');
        orientaciones{1} = vector_orientacion;
    else
        orientacion_comun = input('Todos los archivos tienen misma orientación? (s/n): ', 's');
        if strcmpi(orientacion_comun, 's')
            vector_orientacion = input('Introduce orientación común [1 2 3]: ');
            for i = 1:numel(archivos)
                orientaciones{i} = vector_orientacion;
            end
        else
            for i = 1:numel(archivos)
                fprintf('Archivo %s\n', archivos(i).name);
                vector_orientacion = input('Introduce orientación para este segmento [1 2 3]: ');
                orientaciones{i} = vector_orientacion;
            end
        end
    end

    for k = 1:numel(archivos)
        archivo_csv = fullfile(ruta_carpeta, archivos(k).name);
        t = readtable(archivo_csv);

        if any(strcmp(t.Properties.VariableNames, 'SampleTimeFine'))
            t.Properties.VariableNames{'SampleTimeFine'} = 'Time';
        else
            error('No se encontró la columna SampleTimeFine en el archivo CSV: %s', archivos(k).name);
        end

        % Ajuste de tiempo y muestras
        t.Time = t.Time - t.Time(1);
        t.Time = t.Time / 1000 + desfase_tiempo;
        t.Index = (1:height(t))' + desfase_muestra;

        desfase_tiempo = t.Time(end) + 0.008;
        desfase_muestra = t.Index(end);

        % Extraer nombre DOT
        [~, nombre_base, ~] = fileparts(archivos(k).name);
        dot_match = regexp(nombre_base, '^(DOT\d+)', 'tokens', 'once');
        if isempty(dot_match)
            nombre_dot = 'DOT';
        else
            nombre_dot = dot_match{1};
        end
        [~, nombre_carpeta] = fileparts(ruta_carpeta);
        carpeta_tipo = regexp(nombre_carpeta, '^(FR|FL|COG)', 'match', 'once');

        % Guardar segmento
        info_segmentos(end+1) = struct( ...
            'IMU', nombre_dot, ...
            'ubicacion', carpeta_tipo, ...
            'modelo', 'DOT', ...
            'frecuencia', 120, ...
            'segmento', [t.Index(1), t.Index(end)], ...
            'orientacion', orientaciones{k} ...
        );

        tabla_total = [tabla_total; t];
    end

    tabla = tabla_total;

    % -------------------- Guardar archivo si se solicita --------------------
    if strcmpi(guardar, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(ruta_carpeta, ['dot_' fecha '.mat']);
        save(nombre_archivo, 'tabla', 'info_segmentos');
    end
end

function [tabla, info_sensor] = f_carga_DOT(varargin)
% f_carga_DOT  Carga datos desde un único archivo .csv de un sensor Xsens DOT.
%
% [tabla, info_sensor] = f_carga_DOT('folder_path', RUTA, 'save', 'y')
%
% Parámetros:
%   'folder_path' - Ruta a la carpeta con archivo .csv. Por defecto: carpeta actual.
%   'save'        - 'y' para guardar la tabla como dot_YYMMDD.mat. Por defecto: 'n'.
%
% Salidas:
%   tabla        - Tabla con los datos del sensor.
%   info_sensor  - Struct con info: IMU, ubicacion, modelo, frecuencia, orientacion.

    % -------------------- Parámetros por defecto --------------------
    ruta_carpeta = pwd;
    guardar = 'n';

    % -------------------- Leer argumentos --------------------
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

    % -------------------- Buscar archivo .csv --------------------
    archivos = dir(fullfile(ruta_carpeta, '*.csv'));
    if isempty(archivos)
        error('❌ No se encontró ningún archivo .csv en la ruta: %s', ruta_carpeta);
    elseif numel(archivos) > 1
        error('❌ Solo se permite un archivo .csv. Se encontraron %d archivos.', numel(archivos));
    end

    archivo_csv = fullfile(ruta_carpeta, archivos(1).name);
    t = readtable(archivo_csv);

    % -------------------- Validar columnas --------------------
    if any(strcmp(t.Properties.VariableNames, 'SampleTimeFine'))
        t.Properties.VariableNames{'SampleTimeFine'} = 'Time';
    else
        error('❌ No se encontró la columna "SampleTimeFine" en el archivo.');
    end

    % -------------------- Ajustar tiempo y muestras --------------------
    t.Time = t.Time - t.Time(1);      % Ajuste relativo
    t.Time = t.Time / 1000;           % Pasar a segundos
    t.Index = (1:height(t))';         % Índice de muestra

    % -------------------- Extraer info del nombre y carpeta --------------------
    [~, nombre_base, ~] = fileparts(archivos(1).name);
    dot_match = regexp(nombre_base, '^(DOT\d+)', 'tokens', 'once');
    if isempty(dot_match)
        nombre_dot = 'DOT';
    else
        nombre_dot = dot_match{1};
    end

    [~, nombre_carpeta] = fileparts(ruta_carpeta);
    carpeta_tipo = regexp(nombre_carpeta, '^(FR|FL|COG)', 'match', 'once');

    % -------------------- Solicitar orientación --------------------
    fprintf('Sensor %s (%s)\n', carpeta_tipo, archivo_csv);
    orientacion = input('👉 Introduce orientación del sensor [1 2 3]: ');

    if ~isnumeric(orientacion) || numel(orientacion) ~= 3
        error('❌ Orientación inválida. Debe ser un vector [1 2 3].');
    end

    % -------------------- Preparar info_sensor --------------------
    info_sensor = struct( ...
        'IMU', nombre_dot, ...
        'ubicacion', carpeta_tipo, ...
        'modelo', 'DOT', ...
        'frecuencia', 120, ...
        'orientacion', orientacion ...
    );

    tabla = t;

    % -------------------- Guardar si se solicita --------------------
    if strcmpi(guardar, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(ruta_carpeta, ['dot_' fecha '.mat']);
        save(nombre_archivo, 'tabla', 'info_sensor');
        fprintf('💾 Archivo guardado: %s\n', nombre_archivo);
    end
end

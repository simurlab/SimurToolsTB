function [tabla, info_sensor] = carga_dot(varargin)
% CARGA_DOT Carga datos desde un archivo .csv de un sensor Xsens DOT.
%
%   [tabla, info_sensor] = carga_dot('ruta_carpeta', RUTA, 'save', 'y', ...
%                                    'orientacion', [1 2 3])
%
% Esta función lee un archivo .csv generado por un sensor Xsens DOT,
% ajusta el tiempo de muestreo y devuelve una tabla con los datos junto
% con información básica del sensor.
%
% INPUT (pares 'clave', valor):
%   'ruta_carpeta' - Ruta a la carpeta con archivo .csv 
%                    (por defecto: carpeta actual).
%   'save'         - 'y' para guardar como dot_YYMMDD.mat (por defecto: 'n').
%   'orientacion'  - Vector [1 2 3] indicando la orientación del sensor.
%
% OUTPUT:
%   tabla        - Tabla con los datos del sensor (tiempo, índices, medidas).
%   info_sensor  - Estructura con información del sensor:
%                  (IMU, ubicación, modelo, frecuencia, orientación).
%
% EXAMPLE:
%   [datos, info] = carga_dot('ruta_carpeta', 'C:\datos\FR', ...
%                             'save', 'y', 'orientacion', [1 2 3]);
%
% Author:   Diego
% History:  24.01.2007   versión inicial
%           18.12.2007   adaptación a toolbox
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Parámetros por defecto --------------------
    ruta_carpeta = pwd;
    guardar = 'n';
    orientacion = [];

    % -------------------- Leer argumentos --------------------
    for i = 1:2:length(varargin)
        nombre = lower(varargin{i});
        valor = varargin{i+1};
        switch nombre
            case 'ruta_carpeta'
                ruta_carpeta = valor;
            case 'save'
                guardar = valor;
            case 'orientacion'
                orientacion = valor;
            otherwise
                error('❌ Parámetro desconocido: %s', nombre);
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

    % -------------------- Ajustar tiempo e índices --------------------
    t.Time = (t.Time - t.Time(1)) / 1000;  % ms → s, relativo al inicio
    t.Index = (1:height(t))';              % índice de muestra

    % -------------------- Extraer info de nombre y carpeta --------------------
    [~, nombre_base, ~] = fileparts(archivos(1).name);
    dot_match = regexp(nombre_base, '^(DOT\d+)', 'tokens', 'once');
    if isempty(dot_match)
        nombre_dot = 'DOT';
    else
        nombre_dot = dot_match{1};
    end

    [~, nombre_carpeta] = fileparts(ruta_carpeta);
    ubicacion = regexp(nombre_carpeta, '^(FR|FL|COG)', 'match', 'once');

    % -------------------- Validar orientación --------------------
    if isempty(orientacion)
        warning('⚠️ No se especificó orientación. Se establece en [1 2 3].');
        orientacion = [1 2 3];
    elseif ~isnumeric(orientacion) || numel(orientacion) ~= 3
        error('❌ Orientación inválida. Debe ser un vector [1 2 3].');
    end

    % -------------------- info_sensor --------------------
    info_sensor = struct( ...
        'IMU', nombre_dot, ...
        'ubicacion', ubicacion, ...
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

function [tabla, info_sensor] = carga_dynathlon(varargin)
%CARGA_DYNATHLON Carga datos desde un archivo .csv generado por la app Dynathlon.
%
%   [tabla, info_sensor] = carga_dynathlon('archivo', RUTA, 'save', 'y', ...
%                                          'orientacion', [1 2 3])
%
%   Lee un archivo .csv de un sensor Dynathlon, normaliza el tiempo y
%   devuelve una tabla con los datos junto con información del sensor.
%
%   Formato de archivo esperado:
%     Nombre:   XX_YYYYMMDD_HHMMSS.csv  (p.ej. PD_20260416_113857.csv)
%     Prefijos: MD = Muslo Derecho, PD = Pie Derecho, PI = Pie Izquierdo
%     Columnas: packetCounter, SampleTimeFine [µs], eulerX/Y/Z [°],
%               accX/Y/Z [m/s²], gyrX/Y/Z [°/s]
%     Frecuencia de muestreo: 120 Hz
%
% INPUT (pares 'clave', valor):
%   'archivo'    - Ruta completa al archivo .csv (obligatorio).
%   'save'       - 'y' para guardar como dynathlon_YYMMDD.mat (por defecto: 'n').
%   'orientacion'- Vector [1 2 3] indicando la orientación del sensor
%                  respecto al sistema anatómico {V, ML, AP}.
%
% OUTPUT:
%   tabla       - Tabla con los datos del sensor. Columnas:
%                   Time [s], packetCounter, eulerX/Y/Z [°],
%                   accX/Y/Z [m/s²], gyrX/Y/Z [°/s], Index.
%   info_sensor - Estructura con metadatos del sensor:
%                   IMU, ubicacion, modelo, frecuencia, orientacion.
%
% EJEMPLO:
%   [datos, info] = carga_dynathlon('archivo', 'PD_20260416_113857.csv', ...
%                                   'save', 'y', 'orientacion', [3 -1 2]);
%
% See also: carga_dot, carga_shimmer, carga_bimu, carga_IMUstd
%
% Author:   SiMuR Lab
% History:  23.04.2026   versión inicial

    % -------------------- Parámetros por defecto --------------------
    archivo     = '';
    guardar     = 'n';
    orientacion = [];

    % -------------------- Leer argumentos --------------------
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'archivo'
                archivo = varargin{i+1};
            case 'save'
                guardar = varargin{i+1};
            case 'orientacion'
                orientacion = varargin{i+1};
            otherwise
                error('Parámetro desconocido: %s', varargin{i});
        end
    end

    if isempty(archivo)
        error('Debes especificar la ruta al archivo con el parámetro ''archivo''.');
    end
    if ~isfile(archivo)
        error('Archivo no encontrado:\n  %s', archivo);
    end

    % -------------------- Leer CSV --------------------
    t = readtable(archivo, 'VariableNamingRule', 'preserve');

    if ~ismember('SampleTimeFine', t.Properties.VariableNames)
        error('El archivo no contiene la columna "SampleTimeFine". ¿Es un archivo Dynathlon?');
    end

    % -------------------- Normalizar tiempo --------------------
    t.Time  = (t.SampleTimeFine - t.SampleTimeFine(1)) / 1e6;  % µs → s
    t.Index = (1:height(t))';
    t.SampleTimeFine = [];   % eliminar columna original de timestamp

    % Reordenar: Time e Index al principio
    cols = t.Properties.VariableNames;
    t = t(:, ['Time', 'Index', cols(~ismember(cols, {'Time','Index','SampleTimeFine'}))]);

    % -------------------- Extraer metadatos del nombre de archivo --------------------
    [carpeta, nombre_base, ~] = fileparts(archivo);

    prefijo_match = regexp(nombre_base, '^([A-Z]+)_', 'tokens', 'once');
    if isempty(prefijo_match)
        prefijo = 'XX';
    else
        prefijo = prefijo_match{1};
    end

    ubicacion_map = struct('MD', 'Muslo Derecho', 'PD', 'Pie Derecho', 'PI', 'Pie Izquierdo');
    if isfield(ubicacion_map, prefijo)
        ubicacion = ubicacion_map.(prefijo);
    else
        ubicacion = prefijo;
    end

    % -------------------- Orientación --------------------
    if isempty(orientacion)
        warning('No se especificó orientación del sensor.');
        orientacion = input('Introduce orientación del sensor [ej: 1 2 3]: ');
    elseif ~isnumeric(orientacion) || numel(orientacion) ~= 3
        error('Orientación inválida. Debe ser un vector de 3 elementos.');
    end

    % -------------------- Construir info_sensor --------------------
    info_sensor = struct( ...
        'IMU',        prefijo, ...
        'ubicacion',  ubicacion, ...
        'modelo',     'Dynathlon', ...
        'frecuencia', 120, ...
        'orientacion', orientacion ...
    );

    tabla = t;

    % -------------------- Guardar si se solicita --------------------
    if strcmpi(guardar, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_mat = fullfile(carpeta, ['dynathlon_' fecha '.mat']);
        save(nombre_mat, 'tabla', 'info_sensor');
        fprintf('Archivo guardado: %s\n', nombre_mat);
    end
end

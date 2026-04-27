function [tabla, info_sensor] = carga_dynathlon(archivo, varargin)
%CARGA_DYNATHLON Carga datos desde un archivo .csv generado por la app Dynathlon.
%
%   [tabla, info_sensor] = carga_dynathlon(archivo)
%   [tabla, info_sensor] = carga_dynathlon(archivo, orientacion)
%   [tabla, info_sensor] = carga_dynathlon(archivo, orientacion, 'save')
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
% INPUT:
%   archivo     - Ruta completa al archivo .csv (obligatorio).
%   orientacion - (opcional) Vector de 3 elementos indicando la orientación
%                 del sensor respecto al sistema anatómico {V, ML, AP}.
%                 Si se omite, se solicitará de forma interactiva.
%   'save'      - (opcional) Pasar la cadena 'save' para guardar el resultado
%                 como dynathlon_YYMMDD.mat en la misma carpeta del archivo.
%
% OUTPUT:
%   tabla       - Tabla con los datos del sensor. Columnas:
%                   Time [s], packetCounter, eulerX/Y/Z [°],
%                   accX/Y/Z [m/s²], gyrX/Y/Z [°/s], Index.
%   info_sensor - Estructura con metadatos del sensor:
%                   IMU, ubicacion, modelo, frecuencia, orientacion.
%
% EJEMPLOS:
%   [datos, info] = carga_dynathlon('PD_20260416_113857.csv');
%   [datos, info] = carga_dynathlon('PD_20260416_113857.csv', [3 -1 2]);
%   [datos, info] = carga_dynathlon('PD_20260416_113857.csv', [3 -1 2], 'save');
%
% See also: carga_dot, carga_shimmer, carga_bimu, carga_IMUstd
%
% Author:   SiMuR Lab
% History:  23.04.2026   versión inicial
%           24.04.2026   simplificada interfaz; corregida extracción de prefijo

    % -------------------- Validar archivo --------------------
    if nargin < 1 || isempty(archivo)
        error('Debes especificar la ruta al archivo .csv.');
    end
    if ~isfile(archivo)
        error('Archivo no encontrado:\n  %s', archivo);
    end

    % -------------------- Leer argumentos opcionales --------------------
    orientacion = [];
    guardar     = false;

    for i = 1:numel(varargin)
        v = varargin{i};
        if isnumeric(v) && numel(v) == 3
            orientacion = v;
        elseif ischar(v) && strcmpi(v, 'save')
            guardar = true;
        else
            error('Argumento no reconocido. Uso: carga_dynathlon(archivo, [orientacion], ''save'')');
        end
    end

    % -------------------- Leer CSV --------------------
    t = readtable(archivo, 'VariableNamingRule', 'preserve');

    if ~ismember('SampleTimeFine', t.Properties.VariableNames)
        error('El archivo no contiene la columna "SampleTimeFine". ¿Es un archivo Dynathlon?');
    end

    % -------------------- Normalizar tiempo --------------------
    t.Time  = (t.SampleTimeFine - t.SampleTimeFine(1)) / 1e6;  % µs → s
    t.Index = (1:height(t))';
    t.SampleTimeFine = [];

    cols = t.Properties.VariableNames;
    t = t(:, ['Time', 'Index', cols(~ismember(cols, {'Time', 'Index', 'SampleTimeFine'}))]);

    % -------------------- Extraer prefijo del nombre de archivo --------------------
    [carpeta, nombre_base, ~] = fileparts(archivo);

    % El prefijo es todo lo que va antes del primer '_' (ej: 'PD', 'MD', 'PI')
    partes  = strsplit(nombre_base, '_');
    prefijo = upper(partes{1});

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
    end

    % -------------------- Construir info_sensor --------------------
    info_sensor = struct( ...
        'IMU',         prefijo, ...
        'ubicacion',   ubicacion, ...
        'modelo',      'Dynathlon', ...
        'frecuencia',  120, ...
        'orientacion', orientacion ...
    );

    tabla = t;

    % -------------------- Guardar si se solicita --------------------
    if guardar
        fecha      = datestr(now, 'yymmdd');
        nombre_mat = fullfile(carpeta, ['dynathlon_' fecha '.mat']);
        save(nombre_mat, 'tabla', 'info_sensor');
        fprintf('Archivo guardado: %s\n', nombre_mat);
    end
end

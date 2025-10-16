function [tabla, info_sensor] = carga_shimmer(varargin)
% CARGA_SHIMMER Carga datos desde un archivo .csv de un sensor Shimmer.
%
%   [tabla, info_sensor] = carga_shimmer('ruta_carpeta', RUTA, 'save', 'y', ...
%                                        'orientacion', [1 2 3])
%
%   Esta función lee un archivo .csv generado por un sensor Shimmer,
%   corrige muestreos irregulares mediante interpolación y devuelve una
%   tabla estandarizada junto con información del sensor.
%
% INPUT (pares 'clave', valor):
%   'ruta_carpeta' : ruta a la carpeta con archivo .csv
%                    (por defecto: carpeta actual).
%   'save'         : 'y' para guardar como shimmer_YYMMDD.mat (por defecto: 'n').
%   'orientacion'  : vector [1 2 3] con la orientación del sensor.
%
% OUTPUT:
%   tabla       : tabla estandarizada con acelerómetro, giroscopio,
%                 magnetómetro, timestamp y contador de paquetes.
%   info_sensor : estructura con información del sensor:
%                 IMU, ubicación, modelo, frecuencia, orientación.
%
% EXAMPLE:
%   [datos, info] = carga_shimmer('ruta_carpeta','C:\datos\FR', ...
%                                 'save','y','orientacion',[1 2 3]);
%
% See also: readtable, rellenar_huecos_interpolacion
%
% Author:   JC
% History:  xx.yy.zz    versión inicial
%           29.09.2025  normalizada y modernizada
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

    % -------------------- Configurar opciones de importación --------------------
    data_lines = [4, Inf];
    opts = delimitedTextImportOptions("NumVariables", 12);
    opts.DataLines = data_lines;
    opts.Delimiter = "\t";
    opts.VariableNames = ["Time", "Acc_X", "Acc_Y", "Acc_Z", ...
                          "Gyr_X", "Gyr_Y", "Gyr_Z", "Battery", ...
                          "Mag_X", "Mag_Y", "Mag_Z", "Extra"];
    opts.VariableTypes = ["double","double","double","double", ...
                          "double","double","double","double", ...
                          "double","double","double","string"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    t = readtable(archivo_csv, opts);

    % -------------------- Ajustar tiempo e índice --------------------
    t.Time = (t.Time - t.Time(1)) / 1000;  % ms → s, relativo
    t.Index = (1:height(t))';

    % -------------------- Corrección de muestreo irregular --------------------
    ts = t.Time;
    [ts_ext, IMU.Acc_X] = rellenar_huecos_interpolacion(ts, t.Acc_X, 1.6);
    [~, IMU.Acc_Y]      = rellenar_huecos_interpolacion(ts, t.Acc_Y, 1.6);
    [~, IMU.Acc_Z]      = rellenar_huecos_interpolacion(ts, t.Acc_Z, 1.6);
    [~, IMU.Gyr_X]      = rellenar_huecos_interpolacion(ts, t.Gyr_X, 1.6);
    [~, IMU.Gyr_Y]      = rellenar_huecos_interpolacion(ts, t.Gyr_Y, 1.6);
    [~, IMU.Gyr_Z]      = rellenar_huecos_interpolacion(ts, t.Gyr_Z, 1.6);
    [~, IMU.Mag_X]      = rellenar_huecos_interpolacion(ts, t.Mag_X, 1.6);
    [~, IMU.Mag_Y]      = rellenar_huecos_interpolacion(ts, t.Mag_Y, 1.6);
    [~, IMU.Mag_Z]      = rellenar_huecos_interpolacion(ts, t.Mag_Z, 1.6);

    % Campos estándar de IMU
    IMU.Timestamp = ts_ext;
    IMU.PacketCounter = (1:numel(ts_ext))';

    % Tabla final
    tabla = struct2table(IMU);

    % -------------------- Frecuencia real de muestreo --------------------
    frq_ms = median(diff(ts_ext));
    freq = 1000 / frq_ms;
    fprintf('📡 Frecuencia estimada: %.2f Hz\n', freq);

    % -------------------- Extraer info de carpeta --------------------
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
        'IMU', 'Shimmer', ...
        'ubicacion', ubicacion, ...
        'modelo', 'Shimmer', ...
        'frecuencia', freq, ...
        'orientacion', orientacion ...
    );

    % -------------------- Guardar si se solicita --------------------
    if strcmpi(guardar, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(ruta_carpeta, ['shimmer_' fecha '.mat']);
        save(nombre_archivo, 'tabla', 'info_sensor');
        fprintf('💾 Archivo guardado: %s\n', nombre_archivo);
    end
end

function [tabla, info_sensor] = f_carga_Shimmer(varargin)
% f_carga_Shimmer  Carga datos desde un único archivo .csv de un sensor Shimmer.
%
% [tabla, info_sensor] = f_carga_Shimmer('folder_path', RUTA, 'save', 'y')
%
% Parámetros:
%   'folder_path' - Ruta a la carpeta con archivo .csv. Por defecto: carpeta actual.
%   'save'        - 'y' para guardar la tabla como shimmer_YYMMDD.mat. Por defecto: 'n'.
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

    %% Set up the Import Options and import the data
    
    % If dataLines is not specified, define defaults
%if nargin < 3
    dataLines = [4, Inf];
%end

    opts = delimitedTextImportOptions("NumVariables", 12);

    % Specify range and delimiter
    opts.DataLines = dataLines;
    opts.Delimiter = "\t";

    % Specify column names and types
    opts.VariableNames = ["Time", "Acc_X", "Acc_Y", "Acc_Z", "Gyr_X", "Gyr_Y", "Gyr_Z", " Battery", "Mag_X", "Mag_Y", "Mag_Z", "VarName12"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];

    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % Specify variable properties
    opts = setvaropts(opts, "VarName12", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, "VarName12", "EmptyFieldRule", "auto");



    t = readtable(archivo_csv,opts);

    % -------------------- Validar columnas --------------------
    % if any(strcmp(t.Properties.VariableNames, 'SampleTimeFine'))
    %     t.Properties.VariableNames{'SampleTimeFine'} = 'Time';
    % else
    %     error('❌ No se encontró la columna "SampleTimeFine" en el archivo.');
    % end

    % -------------------- Ajustar tiempo y muestras --------------------
    t.Time = t.Time - t.Time(1);      % Ajuste relativo
    t.Time = t.Time / 1000;           % Pasar a segundos
    t.Index = (1:height(t))';         % Índice de muestra


    %% Corrección de muestreos irregulares:
    %
    medicion=t;
    % tiempos en ms:
    ts=(medicion.Time-medicion.Time(1));

    [ts_ext, IMU.Acc_X, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Acc_X, 1.6);
    [ts_ext, IMU.Acc_Y, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Acc_Y, 1.6);
    [ts_ext, IMU.Acc_Z, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Acc_Z, 1.6);
    [ts_ext, IMU.Gyr_X, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Gyr_X, 1.6);
    [ts_ext, IMU.Gyr_Y, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Gyr_Y, 1.6);
    [ts_ext, IMU.Gyr_Z, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Gyr_Z, 1.6);
    [ts_ext, IMU.Mag_X, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Mag_X, 1.6);
    [ts_ext, IMU.Mag_Y, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Mag_Y, 1.6);
    [ts_ext, IMU.Mag_Z, idx_interp, huecos] = rellenarHuecosInterpolacion(ts, medicion.Mag_Z, 1.6);

%% testigo del numero de muestras interpoladas:
%
signal=medicion.Mag_Z;
sig_ext=IMU.Mag_Z;
Calidad=100*(1-(-size(signal)+size(sig_ext))/size(signal));
disp('Calidad (% de señal no interpolada):');
disp(Calidad)

%% completar los campus del IMU std que no tiene el shimmer:
%
% Timestamp en ms:
IMU.Timestamp=ts_ext;

% Conteo de paquetes
IMU.PacketCounter=(1:height(IMU.Timestamp))';

% Tabla std IMU
IMUout=struct2table(IMU);
 
%% Frecuencia de muestreo real.
%
frq_ms=median(diff(ts_ext));
freq=1000/frq_ms;
disp('Muestreo (Hz): ');
disp(freq)
 

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
        'modelo', 'Shimmer', ...
        'frecuencia', freq, ...
        'orientacion', orientacion ...
    );

    %tabla = t;
    tabla=IMUout;

    % -------------------- Guardar si se solicita --------------------
    if strcmpi(guardar, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(ruta_carpeta, ['shimmer_' fecha '.mat']);
        save(nombre_archivo, 'tabla', 'info_sensor');
        fprintf('💾 Archivo guardado: %s\n', nombre_archivo);
    end
end

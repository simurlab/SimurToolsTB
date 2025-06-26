function [tabla, info_sensor] = f_carga_BIMU(varargin)
% f_carga_BIMU  Carga y procesa archivos .bin de una IMU personalizada (BIMU).
%
% [tabla, info_sensor] = f_carga_BIMU('ruta_carpeta', RUTA, 'save', 'y')
%
% Parámetros:
%   'ruta_carpeta' - Ruta a la carpeta con archivos .bin. Por defecto: carpeta actual.
%   'acc_scale'    - Escala para el acelerómetro. Por defecto: 0.000488.
%   'gyr_scale'    - Escala para el giroscopio. Por defecto: 0.070.
%   'save'         - 'y' para guardar tabla como bimu_YYMMDD.mat. Por defecto: 'n'.
%
% Salidas:
%   tabla        - Tabla unificada con datos de todos los bin.
%   info_sensor  - Estructura con info: IMU, ubicación, modelo, frecuencia, orientación.

    % -------------------- Parámetros por defecto --------------------
    acc_scale = 0.000488;
    gyr_scale = 0.070;
    save_flag = 'n';
    ruta_carpeta = pwd;

    % -------------------- Argumentos --------------------
    for i = 1:2:length(varargin)
        name = lower(varargin{i});
        value = varargin{i+1};
        switch name
            case 'acc_scale'
                acc_scale = value;
            case 'gyr_scale'
                gyr_scale = value;
            case 'save'
                save_flag = value;
            case 'ruta_carpeta'
                ruta_carpeta = value;
            otherwise
                error('❌ Parámetro desconocido: %s', name);
        end
    end

    % -------------------- Constantes --------------------
    MAX_TIMESTAMP = 2^24;
    SAMPLE_PERIOD = 1 / 3332;  % frecuencia de 3332 Hz

    % -------------------- Archivos .bin --------------------
    files = dir(fullfile(ruta_carpeta, '*.bin'));
    if isempty(files)
        error('❌ No se encontraron archivos .bin en %s', ruta_carpeta);
    end

    % Ordenar numéricamente
    nums = NaN(numel(files),1);
    for k = 1:numel(files)
        [~, name] = fileparts(files(k).name);
        nums(k) = str2double(name);
    end
    [~, order] = sort(nums);
    files = files(order);

    % -------------------- Inicialización --------------------
    acc_x = []; acc_y = []; acc_z = [];
    gyr_x = []; gyr_y = []; gyr_z = [];
    ts    = [];

    % -------------------- Leer archivos --------------------
    for k = 1:numel(files)
        fname = fullfile(ruta_carpeta, files(k).name);
        fid = fopen(fname, 'rb');
        if fid == -1, error('No se pudo abrir: %s', fname); end
        raw = fread(fid, Inf, 'uint8=>uint8'); fclose(fid);

        N = floor(numel(raw) / 16);
        if N == 0, continue; end

        gx = zeros(N,1,'int16'); gy = gx; gz = gx;
        ax = gx; ay = gx; az = gx;
        t  = zeros(N,1,'uint32');

        for i = 1:N
            off = (i-1) * 16;
            gx(i) = typecast(raw(off + (1:2)), 'int16');
            gy(i) = typecast(raw(off + (3:4)), 'int16');
            gz(i) = typecast(raw(off + (5:6)), 'int16');
            ax(i) = typecast(raw(off + (7:8)), 'int16');
            ay(i) = typecast(raw(off + (9:10)), 'int16');
            az(i) = typecast(raw(off + (11:12)), 'int16');
            b0 = raw(off+13); b1 = raw(off+14); b2 = raw(off+15);
            t(i) = uint32(b0) + bitshift(uint32(b1),8) + bitshift(uint32(b2),16);
        end

        gyr_x = [gyr_x; double(gx) * gyr_scale];
        gyr_y = [gyr_y; double(gy) * gyr_scale];
        gyr_z = [gyr_z; double(gz) * gyr_scale];
        acc_x = [acc_x; double(ax) * acc_scale];
        acc_y = [acc_y; double(ay) * acc_scale];
        acc_z = [acc_z; double(az) * acc_scale];
        ts    = [ts;    double(t)];
    end

    % -------------------- Corregir reinicios de timestamp --------------------
    dts = diff(ts);
    rollover_idx = find(dts < 0);
    offset = zeros(size(ts));
    for r = rollover_idx'
        offset(r+1:end) = offset(r+1:end) + 1;
    end
    ts_corrected = ts + offset * MAX_TIMESTAMP;

    % -------------------- Crear tabla --------------------
    Time = (ts_corrected - ts_corrected(1)) * SAMPLE_PERIOD;
    PacketCounter = (1:numel(ts_corrected))';

    tabla = table(PacketCounter, Time, ...
                  acc_x, acc_y, acc_z, ...
                  gyr_x, gyr_y, gyr_z, ...
                  'VariableNames', {'PacketCounter','Time', ...
                                    'Acc_X','Acc_Y','Acc_Z', ...
                                    'Gyr_X','Gyr_Y','Gyr_Z'});

    % -------------------- Guardar si se solicita --------------------
    if strcmpi(save_flag, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(ruta_carpeta, ['bimu_' fecha '.mat']);
        save(nombre_archivo, 'tabla');
        fprintf('💾 Archivo guardado: %s\n', nombre_archivo);
    end

    % -------------------- info_sensor --------------------
    [~, nombre_carpeta] = fileparts(ruta_carpeta);
    carpeta_tipo = regexp(nombre_carpeta, '^(FR|FL|COG)', 'match', 'once');

    fprintf('Sensor %s: BIMU\n', carpeta_tipo);
    orientacion = input('👉 Introduce orientación del sensor [1 2 3]: ');

    if ~isnumeric(orientacion) || numel(orientacion) ~= 3
        error('❌ Orientación inválida. Debe ser un vector [1 2 3].');
    end

    info_sensor = struct( ...
        'IMU', 'B1', ...
        'ubicacion', carpeta_tipo, ...
        'modelo', 'BIMU', ...
        'frecuencia', 3332, ...
        'orientacion', orientacion ...
    );
end

function medicion = carga_silop(filename)
% CARGA_DATOS_SILOP Lee un archivo de datos en formato SILOP (.sl).
%
%   medicion = carga_datos_silop(filename)
%
% Esta función descomprime un archivo en formato SILOP (`.sl`), extrae las 
% señales de los sensores configurados y devuelve los datos en una celda 
% donde cada elemento corresponde a un sensor.
%
% INPUT:
%   filename : nombre del archivo `.sl` a cargar.
%
% OUTPUT:
%   medicion : cell array, cada elemento es un struct con:
%                - nombre  : nombre del sensor
%                - tiempo  : vector de tiempo en segundos
%                - Accel   : aceleraciones [X Y Z]
%                - Gyro    : giroscopios [X Y Z]
%                - Mag     : magnetómetros [X Y Z]
%
% EXAMPLE:
%   medicion = carga_datos_silop('fede.sl');
%
% See also: carga_datos_xsens, carga_datos_shimmer, cargar_datos_camara
%
% Author:   Diego
% History:  12.11.2019   creación del archivo
%           30.09.2025   normalizada y documentada
%

    % -------------------- Comprobaciones --------------------
    if nargin < 1
        error('Se debe incluir el nombre del fichero como parámetro');
    end
    existe = dir(filename);
    if isempty(existe)
        error('No se encuentra el fichero especificado');
    end

    % -------------------- Descomprimir y cargar --------------------
    unzip(filename);
    warning off
    tmp = load('config.mat');
    warning on
    delete('config.mat');

    load('datos.log'); %#ok<LOAD>
    delete('datos.log');

    existe = dir('datos_alg.log');
    datos_alg = [];
    if ~isempty(existe)
        load('datos_alg.log'); %#ok<LOAD>
        delete('datos_alg.log');
    end

    captura = [datos, datos_alg];
    [~, tam] = size(datos);   % número de columnas de datos de sensores
    freq = tmp.SILOP_CONFIG.BUS.Xbus.freq;
    tmp = tmp.SILOP_CONFIG.SENHALES;

    % -------------------- Procesar sensores --------------------
    sensores = fieldnames(tmp);
    for k = 2:numel(sensores)
        medicion{k-1} = struct();  %#ok<AGROW>
        sensor = tmp.(sensores{k});
        names = fieldnames(sensor);

        medicion{k-1}.nombre = sensores{k};
        medicion{k-1}.tiempo = captura(:,1)/freq;

        for kk = 3:numel(names)
            if sensor.(names{kk}) <= tam
                % Se descartan datos de algoritmos
                switch names{kk}
                    case 'Acc_X'
                        medicion{k-1}.Accel(:,1) = captura(:,sensor.(names{kk}));
                    case 'Acc_Y'
                        medicion{k-1}.Accel(:,2) = captura(:,sensor.(names{kk}));
                    case 'Acc_Z'
                        medicion{k-1}.Accel(:,3) = captura(:,sensor.(names{kk}));
                    case 'G_X'
                        medicion{k-1}.Gyro(:,1) = captura(:,sensor.(names{kk}));
                    case 'G_Y'
                        medicion{k-1}.Gyro(:,2) = captura(:,sensor.(names{kk}));
                    case 'G_Z'
                        medicion{k-1}.Gyro(:,3) = captura(:,sensor.(names{kk}));
                    case 'MG_X'
                        medicion{k-1}.Mag(:,1) = captura(:,sensor.(names{kk}));
                    case 'MG_Y'
                        medicion{k-1}.Mag(:,2) = captura(:,sensor.(names{kk}));
                    case 'MG_Z'
                        medicion{k-1}.Mag(:,3) = captura(:,sensor.(names{kk}));
                    otherwise
                        warning('⚠️ Señal "%s" no detectada correctamente', names{kk});
                end
            end
        end
    end

    % -------------------- Limpiar elementos vacíos --------------------
    for k = length(medicion):-1:1
        if length(fieldnames(medicion{k})) == 2 % Solo tiempo y nombre
            medicion(k) = [];
        end
    end
end

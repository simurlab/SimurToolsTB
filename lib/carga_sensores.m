function carga_sensores(varargin)
% CREA_ INTENTOS Carga, procesa y guarda datos de múltiples sensores IMU.
%
%   crea_intentos()
%       Busca carpetas con prefijos FR*, FL*, COG*, carga los sensores y
%       guarda un archivo .mat unificado sin información de actividad.
%
%   crea_intentos('Actividad')
%       Igual que lo anterior, pero añade la actividad especificada en el
%       metadato de cada sensor (por ejemplo, 'Vallas', 'Carrera').
%
% INPUT:
%   actividad (opcional) - texto con el nombre de la actividad.
%
% OUTPUT:
%   Se guarda un archivo .mat en la carpeta actual que contiene:
%       - Tablas con datos de cada sensor
%       - Metadatos asociados (modelo, frecuencia, ubicación, actividad)
%   El archivo sigue la convención: <letra><num>.mat
%
% EXAMPLE:
%   % Ejecutar dentro de la carpeta del sujeto/session:
%   crea_intentos('Carrera');
%
% See also: carga_dot, carga_bimu, carga_shimmer
%
% Author:   Gonzalo
% History:  01.07.2025  creación inicial
%           29.09.2025  documentación normalizada y modernizada
%

    % -------------------- Validación de argumentos --------------------
    if nargin > 1
        error('❌ Solo se admite un argumento opcional para la actividad.');
    end

    incluir_actividad = false;
    if nargin == 1
        actividad = varargin{1};
        if ~ischar(actividad) && ~isstring(actividad)
            error('❌ El argumento de actividad debe ser texto.');
        end
        incluir_actividad = true;
    end

    % -------------------- Detectar carpetas de sensores --------------------
    carpeta_base = pwd;
    subdirs = dir(carpeta_base);
    subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name},{'.','..'}));

    n_sensores = 0;
    modelos = {};
    frecuencias = [];
    ubicaciones = {};
    rutas = {};

    patrones = {'FR','FL','COG'}; % prefijos válidos

    for i = 1:length(subdirs)
        nombre = subdirs(i).name;
        for p = 1:numel(patrones)
            patron = patrones{p};
            if startsWith(nombre, patron)
                ruta = fullfile(carpeta_base, nombre);
                archivos_csv = dir(fullfile(ruta, '*.csv'));
                archivos_bin = dir(fullfile(ruta, '*.bin'));

                if ~isempty(archivos_csv)
                    if numel(archivos_csv) > 1
                        error('❌ Solo se permite un único archivo .csv en: %s', nombre);
                    end
                    if contains(archivos_csv.name, "himmer")
                        modelo = 'Shimmer';
                        frecuencia = 1020; % Hz real del Shimmer
                    else
                        modelo = 'DOT';
                        frecuencia = 120;
                    end
                elseif ~isempty(archivos_bin)
                    modelo = 'Bimu';
                    frecuencia = 3332;
                else
                    warning('⚠️ Carpeta %s sin archivos .csv ni .bin, se omite.', nombre);
                    continue;
                end

                n_sensores = n_sensores + 1;
                modelos{n_sensores,1} = modelo;
                frecuencias(n_sensores,1) = frecuencia;
                ubicaciones{n_sensores,1} = patron;
                rutas{n_sensores,1} = ruta;
            end
        end
    end

    if n_sensores == 0
        error('❌ No se detectaron sensores válidos en las carpetas actuales.');
    end

    % -------------------- Procesamiento --------------------
    datos_guardados = struct();
    contadores = struct('FR',0,'FL',0,'COG',0);

    for i = 1:n_sensores
        modelo = modelos{i};
        frecuencia = frecuencias(i);
        ubicacion = ubicaciones{i};
        ruta = rutas{i};

        try
            switch modelo
                case 'DOT'
                    [tabla, info_sensor] = carga_dot('ruta_carpeta', ruta);
                case 'Bimu'
                    [tabla, info_sensor] = carga_bimu('ruta_carpeta', ruta);
                case 'Shimmer'
                    [tabla, info_sensor] = carga_shimmer('ruta_carpeta', ruta);
                otherwise
                    error('Tipo de sensor desconocido: %s', modelo);
            end

            % Añadir campos comunes
            info_sensor.modelo = modelo;
            info_sensor.frecuencia = frecuencia;
            if incluir_actividad
                info_sensor.actividad = actividad;
            end

            % Guardar con nombre único por ubicación
            contadores.(ubicacion) = contadores.(ubicacion) + 1;
            nombre_base = sprintf('%s_%d', ubicacion, contadores.(ubicacion));
            datos_guardados.(nombre_base) = tabla;
            datos_guardados.([nombre_base '_metadata']) = info_sensor;

        catch e
            error('❌ Error al procesar sensor %d (%s):\n%s', i, ubicacion, e.message);
        end
    end

    % -------------------- Nombre archivo salida --------------------
    ruta_actual = pwd;
    partes_ruta = strsplit(ruta_actual, filesep);

    if numel(partes_ruta) < 3
        error('Ruta demasiado corta para determinar nombre de archivo.');
    end

    letra_match = regexp(partes_ruta{end-2}, '^[a-zA-Z]', 'match');
    num_match = regexp(partes_ruta{end}, '^\d{2}', 'match');

    if isempty(letra_match) || isempty(num_match)
        error('❌ Formato de carpeta no válido para generar nombre de archivo.');
    end

    nombre_archivo = [lower(letra_match{1}) num_match{1} '.mat'];

    % -------------------- Guardar archivo final --------------------
    save(fullfile(ruta_actual, nombre_archivo), '-struct', 'datos_guardados','-v7.3');
    fprintf('✅ Archivo guardado como: %s\n', nombre_archivo);
end

function f_carga(varargin)
% F_CARGA Carga, procesa y guarda datos de sensores desde carpetas estructuradas.
%
% USO:
%   f_carga()              -> guarda los datos sin información de actividad.
%   f_carga('Vallas')      -> guarda los datos con actividad especificada en metadata.
%
% DESCRIPCIÓN:
% - Busca carpetas en el directorio actual que comiencen con 'FR', 'FL' o 'COG'.
% - Detecta si son sensores Xsens (.csv) o Bimu (.bin).
% - Carga los datos y los guarda como archivo .mat con nombre generado a partir
%   de las carpetas contenedoras (ej: h01.mat si está en ...\h Carpeta\01 Prueba).
% - Incluye metadata con modelo, frecuencia, ubicación y ruta. Actividad solo si se especifica.

% -------------------- Validación de argumentos --------------------
if nargin > 1
    error('Solo se admite un argumento opcional para la actividad.');
end

incluirActividad = false;
if nargin == 1
    actividad = varargin{1};
    if ~ischar(actividad) && ~isstring(actividad)
        error('El argumento de actividad debe ser texto.');
    end
    incluirActividad = true;
end

% -------------------- Detección de carpetas de sensores --------------------
carpetaBase = pwd;
subdirs = dir(carpetaBase);
subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.','..'}));

nSensores = 0;
Modelos = {};
Frecuencias = [];
Ubicaciones = {};
Rutas = {};

% Prefijos válidos de carpetas de sensores
patrones = {'FR', 'FL', 'COG'};

for i = 1:length(subdirs)
    nombre = subdirs(i).name;
    for p = 1:numel(patrones)
        patron = patrones{p};
        if startsWith(nombre, patron)
            ruta = fullfile(carpetaBase, nombre);
            archivos_csv = dir(fullfile(ruta, '*.csv'));
            archivos_bin = dir(fullfile(ruta, '*.bin'));

            % Determinar tipo de sensor
            if ~isempty(archivos_csv)
                modelo = 'Xsens Dot';
                frecuencia = 120;
            elseif ~isempty(archivos_bin)
                modelo = 'Bimu';
                frecuencia = 3332;
            else
                warning('⚠️ Carpeta %s no contiene archivos .csv ni .bin, se omite.', nombre);
                continue;
            end

            % Guardar información del sensor
            nSensores = nSensores + 1;
            Modelos{nSensores,1} = modelo;
            Frecuencias(nSensores,1) = frecuencia;
            Ubicaciones{nSensores,1} = patron;
            Rutas{nSensores,1} = ruta;   % <- ESTA LÍNEA ES LA QUE FALTABA

        end
    end
end

if nSensores == 0
    error('❌ No se detectaron sensores válidos en las carpetas actuales.');
end

% -------------------- Inicialización de estructuras de salida --------------------
tablasGuardadas = struct();
ubicacionContadores = struct('FR', 0, 'FL', 0, 'COG', 0);

% -------------------- Procesamiento de cada sensor --------------------
for i = 1:nSensores
    modelo = Modelos{i};
    ubicacion = Ubicaciones{i};
    ruta = Rutas{i};

    try
        % Procesar según tipo de sensor
        if strcmp(modelo, 'Xsens Dot')
            tabla = f_carga_DOT('folder_path', ruta);
        elseif strcmp(modelo, 'Bimu')
            tabla = f_carga_BIMU('folder_path', ruta);
        else
            error('Tipo de sensor desconocido: %s', modelo);
        end
    catch e
        error('Error al procesar sensor %d (%s):\n%s', i, ubicacion, e.message);
    end

    % Asignar nombre único por ubicación
    ubicacionContadores.(ubicacion) = ubicacionContadores.(ubicacion) + 1;
    nombreBase = sprintf('%s_%d', ubicacion, ubicacionContadores.(ubicacion));
    tablasGuardadas.(nombreBase) = tabla;
end

% -------------------- Crear metadata --------------------
metadata = struct([]);
for i = 1:nSensores
    metadata(i).Modelo     = Modelos{i};
    metadata(i).Frecuencia = Frecuencias(i);
    metadata(i).Ubicacion  = Ubicaciones{i};
    if incluirActividad
        metadata(i).Actividad = actividad;
    end
end
tablasGuardadas.metadata = metadata;

% -------------------- Construir nombre de archivo de salida --------------------
rutaActual = pwd;
rutasPartes = strsplit(rutaActual, filesep);

if numel(rutasPartes) < 3
    error('Ruta demasiado corta para determinar nombre de archivo.');
end

nombreCarpetaLetra = rutasPartes{end-1};
nombreCarpetaNum   = rutasPartes{end};

% Extraer letra y dos dígitos del nombre de las carpetas
letraMatch = regexp(nombreCarpetaLetra, '^[a-zA-Z]', 'match');
numMatch   = regexp(nombreCarpetaNum, '^\d{2}', 'match');

if isempty(letraMatch)
    error('No se encontró letra al principio en la carpeta superior: "%s"', nombreCarpetaLetra);
end
if isempty(numMatch)
    error('No se encontraron 2 dígitos al principio en la carpeta actual: "%s"', nombreCarpetaNum);
end

letra = lower(letraMatch{1});
numStr = numMatch{1};

nombreArchivo = [letra numStr '.mat'];

% -------------------- Guardar archivo final --------------------
save(fullfile(rutaActual, nombreArchivo), '-struct', 'tablasGuardadas', '-v7.3');
fprintf('✅ Archivo guardado como: %s\n', nombreArchivo);
end

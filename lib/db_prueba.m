function f_carga(varargin)
% F_CARGA Carga, procesa y guarda datos de sensores desde carpetas estructuradas.
%
% USO:
%   f_carga()              -> guarda los datos sin información de actividad.
%   f_carga('Vallas')      -> guarda los datos con actividad especificada.

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

% Prefijos válidos
patrones = {'FR', 'FL', 'COG'};

for i = 1:length(subdirs)
    nombre = subdirs(i).name;
    for p = 1:numel(patrones)
        patron = patrones{p};
        if startsWith(nombre, patron)
            ruta = fullfile(carpetaBase, nombre);
            archivos_csv = dir(fullfile(ruta, '*.csv'));
            archivos_bin = dir(fullfile(ruta, '*.bin'));

            if ~isempty(archivos_csv)
                if numel(archivos_csv) > 1
                    error('❌ Solo se permite un único archivo .csv en la carpeta: %s', nombre);
                end
                modelo = 'Xsens Dot';
                frecuencia = 120;
            elseif ~isempty(archivos_bin)
                modelo = 'Bimu';
                frecuencia = 3332;
            else
                warning('⚠️ Carpeta %s no contiene archivos .csv ni .bin, se omite.', nombre);
                continue;
            end

            nSensores = nSensores + 1;
            Modelos{nSensores,1} = modelo;
            Frecuencias(nSensores,1) = frecuencia;
            Ubicaciones{nSensores,1} = patron;
            Rutas{nSensores,1} = ruta;
        end
    end
end

if nSensores == 0
    error('❌ No se detectaron sensores válidos en las carpetas actuales.');
end

% -------------------- Procesamiento --------------------
tablasGuardadas = struct();
ubicacionContadores = struct('FR', 0, 'FL', 0, 'COG', 0);

for i = 1:nSensores
    modelo = Modelos{i};
    frecuencia = Frecuencias(i);
    ubicacion = Ubicaciones{i};
    ruta = Rutas{i};

    try
        if strcmp(modelo, 'Xsens Dot')
            [tabla, info_sensor] = f_carga_DOT('ruta_carpeta', ruta);
        elseif strcmp(modelo, 'Bimu')
            [tabla, info_sensor] = f_carga_BIMU('ruta_carpeta', ruta);
        else
            error('Tipo de sensor desconocido: %s', modelo);
        end

        % Añadir campos comunes
        for j = 1:numel(info_sensor)
            info_sensor(j).modelo = modelo;
            info_sensor(j).frecuencia = frecuencia;
            if incluirActividad
                info_sensor(j).actividad = actividad;
            end
        end

        % Asignar nombre y guardar
        ubicacionContadores.(ubicacion) = ubicacionContadores.(ubicacion) + 1;
        nombreBase = sprintf('%s_%d', ubicacion, ubicacionContadores.(ubicacion));
        tablasGuardadas.(nombreBase) = tabla;
        tablasGuardadas.([nombreBase '_metadata']) = info_sensor;

    catch e
        error('❌ Error al procesar sensor %d (%s):\n%s', i, ubicacion, e.message);
    end
end

% -------------------- Construir nombre archivo salida --------------------
rutaActual = pwd;
rutasPartes = strsplit(rutaActual, filesep);

if numel(rutasPartes) < 3
    error('Ruta demasiado corta para determinar nombre de archivo.');
end

letraMatch = regexp(rutasPartes{end-1}, '^[a-zA-Z]', 'match');
numMatch = regexp(rutasPartes{end}, '^\d{2}', 'match');

if isempty(letraMatch) || isempty(numMatch)
    error('❌ Formato de carpeta no válido para generar nombre de archivo.');
end

nombreArchivo = [lower(letraMatch{1}) numMatch{1} '.mat'];

% -------------------- Guardar archivo final --------------------
save(fullfile(rutaActual, nombreArchivo), '-struct', 'tablasGuardadas', '-v7.3');
fprintf('✅ Archivo guardado como: %s\n', nombreArchivo);
end

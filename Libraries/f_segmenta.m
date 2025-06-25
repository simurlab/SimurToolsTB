function f_segmenta(varargin)
% FSEGMENTA Segmenta señales de sensores a partir de archivo tipo letraNN.mat.
%
% - Busca archivo con formato [letra][NN].mat (ej. h01.mat)
% - Para cada sensor (FR_X, FL_X, COG_X) permite segmentar Acc_Y interactivamente
%   o con archivo externo de intervalos ('intentosPath')
% - Crea archivos [letraNNXX].mat con señales y metadatos filtrados (si corresponde)
% - La metadata se filtra por coincidencia exacta entre el intervalo y el campo segmento
% - Se añade campo 'intervaloIntento' en los metadatos si hay una única coincidencia

    % -------------------- Argumentos --------------------
    parser = inputParser;
    addParameter(parser, 'intentosPath', '', @(x) ischar(x) || isstring(x));
    parse(parser, varargin{:});
    rutaIntentos = parser.Results.intentosPath;

    usarIntentosExternos = ~isempty(rutaIntentos);
    listaIntentos = struct('sensor', {}, 'intento', {}, 'inicio', {}, 'fin', {});

    % -------------------- Archivo base --------------------
    archivos = dir('*.mat');
    coincidencias = regexp({archivos.name}, '^[a-zA-Z]\d{2}\.mat$', 'match', 'once');
    archivoBase = archivos(~cellfun('isempty', coincidencias));

    if isempty(archivoBase)
        error('❌ No se encontró archivo con formato letraNN (ej: h01.mat)');
    end

    archivoBase = archivoBase(1).name;
    nombreBase = archivoBase(1:end-4);
    fprintf('📂 Cargando archivo base: %s\n', archivoBase);

    datos = load(archivoBase);
    nombresCampos = fieldnames(datos);
    sensores = nombresCampos(contains(nombresCampos, {'FR_', 'FL_', 'COG_'}) & ~endsWith(nombresCampos, '_metadata'));

    if isempty(sensores)
        error('❌ No se encontraron sensores esperados en el archivo.');
    end

    segmentos = struct();

    % -------------------- Intentos externos --------------------
    if usarIntentosExternos
        datosExternos = load(rutaIntentos);
        if ~isfield(datosExternos, 'intentos')
            error('❌ El archivo %s no contiene variable "intentos".', rutaIntentos);
        end
        listaIntentos = datosExternos.intentos;
        fprintf('📄 Usando intervalos desde: %s\n', rutaIntentos);
    end

    % -------------------- Procesar sensores --------------------
    for s = 1:numel(sensores)
        sensor = sensores{s};
        tabla = datos.(sensor);

        if ~istable(tabla) || ~ismember('Acc_Y', tabla.Properties.VariableNames)
            warning('⚠️ Sensor %s no tiene Acc_Y o no es tabla. Se omite.', sensor);
            continue;
        end

        segmentos.(sensor) = {};
        fprintf('\n=== Segmentación de %s ===\n', sensor);

        if usarIntentosExternos
            intentosSensor = listaIntentos(strcmp({listaIntentos.sensor}, sensor));
            for i = 1:numel(intentosSensor)
                i1 = intentosSensor(i).inicio;
                i2 = intentosSensor(i).fin;
                segmentos.(sensor){end+1} = tabla(i1:i2, :);
                fprintf('%s: [%d %d], intento %d\n', sensor, i1, i2, intentosSensor(i).intento);
            end
        else
            figure('Name', sensor); clf;
            plot(tabla.Acc_Y); grid on;
            xlabel('Muestra'); ylabel('Acc_Y');

            numeroIntento = 1;
            while true
                prompt = sprintf('Intervalo [%d %d] para intento %02d o "q": ', ...
                    1, height(tabla), numeroIntento);
                entrada = input(prompt, 's');

                if isempty(entrada)
                    fprintf('%s: intento vacío, se omite.\n', sensor);
                    numeroIntento = numeroIntento + 1;
                    continue;
                end
                if strcmpi(entrada, 'q')
                    break;
                end

                try
                    entrada = regexprep(entrada, '[\[\],]', ' ');
                    partes = str2double(strsplit(strtrim(entrada)));
                    if numel(partes) == 2 && all(~isnan(partes)) && partes(1) < partes(2)
                        i1 = max(1, floor(partes(1)));
                        i2 = min(height(tabla), floor(partes(2)));
                        segmentos.(sensor){end+1} = tabla(i1:i2, :);

                        fprintf('%s: [%d %d], intento %d\n', sensor, i1, i2, numeroIntento);
                        listaIntentos(end+1) = struct( ...
                            'sensor', sensor, ...
                            'intento', numeroIntento, ...
                            'inicio', i1, ...
                            'fin', i2);
                    else
                        warning('❌ Intervalo inválido.');
                    end
                catch
                    warning('❌ Entrada no válida.');
                end
                numeroIntento = numeroIntento + 1;
            end
        end
    end

    % -------------------- Guardar fragmentos --------------------
    if isempty(listaIntentos)
        fprintf('🛑 No hay intentos definidos.\n');
        return;
    end

    intentosUnicos = unique([listaIntentos.intento]);

    for i = 1:numel(intentosUnicos)
        idIntento = intentosUnicos(i);
        fragmento = struct();

        for s = 1:numel(sensores)
            sensor = sensores{s};
            listaSegmentos = segmentos.(sensor);

            indices = find(strcmp({listaIntentos.sensor}, sensor) & [listaIntentos.intento] == idIntento);
            if numel(indices) == 1
                fragmento.(sensor) = listaSegmentos{end};
                intervalo = [listaIntentos(indices).inicio, listaIntentos(indices).fin];
            elseif isempty(indices)
                continue;
            else
                error('❌ Múltiples entradas para intento %d del sensor %s.', idIntento, sensor);
            end

            campoMeta = [sensor '_metadata'];
            if isfield(datos, campoMeta) && isfield(fragmento, sensor)
                metadataTotal = datos.(campoMeta);

                coincidencias = [];
                for m = 1:numel(metadataTotal)
                    seg = metadataTotal(m).segmento;
                    if intervalo(1) >= seg(1) && intervalo(2) <= seg(2)
                        coincidencias(end+1) = m;
                    end
                end

                if numel(coincidencias) == 1
                    metaFiltrada = metadataTotal(coincidencias);
                    if isfield(metaFiltrada, 'carpeta')
                        metaFiltrada = rmfield(metaFiltrada, 'carpeta');
                    end
                    metaFiltrada.intervaloIntento = intervalo;
                    fragmento.(campoMeta) = metaFiltrada;
                elseif isempty(coincidencias)
                    warning('⚠️ Sin coincidencia en metadata para %s [%d %d].', sensor, intervalo);
                else
                    error('❌ Intervalo [%d %d] en %s coincide con múltiples segmentos.', intervalo, sensor);
                end
            end
        end

        if isempty(fieldnames(fragmento))
            continue;
        end

        if isfield(datos, 'metadata')
            fragmento.metadata = datos.metadata;
        end

        nombreArchivo = sprintf('%s%02d.mat', nombreBase, idIntento);
        save(nombreArchivo, '-struct', 'fragmento');
        fprintf('📅 Guardado: %s\n', nombreArchivo);
    end

    % -------------------- Guardar archivo de intentos --------------------
    if ~usarIntentosExternos
        save('intentos.mat', 'listaIntentos');
        fprintf('📍 Guardado intentos.mat\n');
    end
end

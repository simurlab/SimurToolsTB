function f_segmenta(varargin)
% F_SEGMENTA Segmenta señales de sensores a partir de archivo tipo letraNN.mat.
%
% - Busca archivo con formato [letra][NN].mat (ej. h01.mat)
% - Para cada sensor (FR_X, FL_X, COG_X) permite segmentar interactivamente Acc_Y,
%   o bien utiliza un archivo .mat con intervalos predefinidos (via 'intentos_path')
% - Crea archivos [letraNNXX].mat donde XX es el número de segmento sincronizado entre sensores
% - Incluye metadata original en cada archivo

    % -------------------- Procesar argumentos --------------------
    p = inputParser;
    addParameter(p, 'intentos_path', '', @(x) ischar(x) || isstring(x));
    parse(p, varargin{:});
    intentosPath = p.Results.intentos_path;

    usarIntentosExternos = ~isempty(intentosPath);
    intentos = struct('sensor', {}, 'segmento', {}, 'inicio', {}, 'fin', {}, 'archivoDestino', {});

    % -------------------- Buscar archivo base --------------------
    archivos = dir('*.mat');
    baseMatch = regexp({archivos.name}, '^[a-zA-Z]\d{2}\.mat$', 'match', 'once');
    baseFile = archivos(~cellfun('isempty', baseMatch));

    if isempty(baseFile)
        error('❌ No se encontró un archivo .mat con formato letraNN (ej: h01.mat)');
    end

    baseFile = baseFile(1).name;
    baseName = baseFile(1:end-4);
    fprintf('📂 Cargando archivo base: %s\n', baseFile);

    datos = load(baseFile);
    campos = fieldnames(datos);
    sensores = campos(contains(campos, {'FR_', 'FL_', 'COG_'}));

    if isempty(sensores)
        error('❌ No se encontraron sensores FR_, FL_ o COG_ en el archivo.');
    end

    segmentos = struct();  % estructura con campos por sensor
    maxSegmentos = 0;

    % -------------------- Cargar intentos externos si se usa --------------------
    if usarIntentosExternos
        datosIntentos = load(intentosPath);
        if ~isfield(datosIntentos, 'intentos')
            error('❌ El archivo %s no contiene una variable llamada intentos.', intentosPath);
        end
        intentos = datosIntentos.intentos;
        fprintf('📄 Usando intervalos predefinidos desde: %s\n', intentosPath);
    end

    % -------------------- Procesar cada sensor --------------------
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
            % -------------------- Usar intervalos de archivo --------------------
            intentosSensor = intentos(strcmp({intentos.sensor}, sensor));
            for i = 1:numel(intentosSensor)
                i1 = intentosSensor(i).inicio;
                i2 = intentosSensor(i).fin;
                segmentos.(sensor){end+1} = tabla(i1:i2, :);
                fprintf('%s: [%d %d], segmento %d\n', sensor, i1, i2, intentosSensor(i).segmento);
            end
        else
            % -------------------- Segmentación interactiva --------------------
            figure('Name', sensor); clf;
            plot(tabla.Acc_Y); grid on;
            xlabel('Muestra'); ylabel('Acc_Y');

            segNum = 1;
            while true
                prompt = sprintf('Intervalo [%d %d] para segmento %02d o "q" para siguiente sensor: ', ...
                    1, height(tabla), segNum);
                entrada = input(prompt, 's');

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

                        fprintf('%s: [%d %d], segmento %d\n', sensor, i1, i2, segNum);
                        intentos(end+1) = struct( ...
                            'sensor', sensor, ...
                            'segmento', segNum, ...
                            'inicio', i1, ...
                            'fin', i2, ...
                            'archivoDestino', '' ...
                        );
                        segNum = segNum + 1;
                    else
                        warning('❌ Intervalo inválido.');
                    end
                catch
                    warning('❌ Entrada no válida.');
                end
            end
        end

        maxSegmentos = max(maxSegmentos, numel(segmentos.(sensor)));
    end

    % -------------------- Guardar archivos por segmento --------------------
    if maxSegmentos == 0
        fprintf('🛑 No se definieron segmentos. Nada que guardar.\n');
        return;
    end

    for k = 1:maxSegmentos
        frag = struct();
        for s = 1:numel(sensores)
            sensor = sensores{s};
            lista = segmentos.(sensor);
            if k <= numel(lista)
                frag.(sensor) = lista{k};
            end
        end

        if isempty(fieldnames(frag))
            continue;
        end

        if isfield(datos, 'metadata')
            frag.metadata = datos.metadata;
        end

        nombre = sprintf('%s%02d.mat', baseName, k);
        save(nombre, '-struct', 'frag');
        fprintf('💾 Guardado fragmento: %s\n', nombre);

        % Actualizar campo archivoDestino si es segmentación manual
        if ~usarIntentosExternos
            for j = 1:numel(intentos)
                if intentos(j).segmento == k
                    intentos(j).archivoDestino = nombre;
                end
            end
        end
    end

    % -------------------- Guardar intentos si fueron creados manualmente --------------------
    if ~usarIntentosExternos
        save('intentos.mat', 'intentos');
        fprintf('📝 Guardado log de intervalos en intentos.mat\n');
    end
end

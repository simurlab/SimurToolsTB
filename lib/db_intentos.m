function db_intentos(varargin)
%DB_INTENTOS Segmenta zonas estáticas e intentos a partir de datos IMU.
%
%   db_intentos()
%       Modo interactivo: el usuario selecciona intervalos estáticos e
%       intentos mediante gráficas e inputs. Guarda fragmentos por intento
%       y un archivo resumen con todos los intervalos.
%
%   db_intentos('resumen','intentos_h01.mat')
%       Modo automático: utiliza un archivo de resumenTabla previamente
%       generado para segmentar automáticamente sin interacción.
%
%   SALIDAS:
%       - Archivos .mat con los intentos: <letra><num><id>.mat
%       - Archivo resumen: intentos<letra><num>.mat con la tabla
%         resumenTabla (contiene estáticos e intentos).
%
%   EJEMPLOS:
%       % En carpeta de sujeto/session con h01.mat
%       db_intentos();
%
%       % Reutilizando un resumen previo
%       db_intentos('resumen','intentos_h01.mat');
%
%   See also: carga_sensores


    % -------------------- Parseo de argumentos --------------------
    resumenFile = '';
    for i = 1:2:length(varargin)
        nombre = lower(varargin{i});
        valor = varargin{i+1};
        switch nombre
            case 'resumen'
                resumenFile = valor;
            otherwise
                error('❌ Parámetro desconocido: %s', nombre);
        end
    end
    usarResumen = ~isempty(resumenFile);

    % -------------------- Nombre del archivo base --------------------
    rutaActual = pwd;
    partesRuta = strsplit(rutaActual, filesep);

    if numel(partesRuta) < 3
        error('Ruta demasiado corta para determinar nombre de archivo.');
    end

    letraMatch = regexp(partesRuta{end-1}, '^[a-zA-Z]', 'match');
    numMatch = regexp(partesRuta{end}, '^\d{2}', 'match');
    if isempty(letraMatch) || isempty(numMatch)
        error('❌ Formato de carpeta no válido.');
    end
    letra = lower(letraMatch{1});
    numero = numMatch{1};
    nombreArchivo = sprintf('%s%s.mat', letra, numero);

    if ~isfile(nombreArchivo)
        error('❌ No se encontró el archivo base: %s', nombreArchivo);
    end

    datos = load(nombreArchivo);
    campos = fieldnames(datos);

    % Campos de datos (sin sufijo _metadata)
    camposDatos = campos(cellfun(@(c) isempty(regexp(c, '_metadata$', 'once')), campos));
    % Ubicaciones base: 'COG' agrupa 'COG_1' y 'COG_2'
    baseLocations = unique(regexprep(camposDatos, '_\d+$', ''));

    % -------------------- Resumen preexistente --------------------
    if usarResumen
        s = load(resumenFile);
        if ~isfield(s,'resumenTabla')
            error('❌ El archivo de resumen no contiene "resumenTabla".');
        end
        resumenTabla = s.resumenTabla;
    end

    zonasEstaticas = struct();
    segmentosPorIdentificador = struct();
    intentosGlobales = [];

    % -------------------- Procesar por ubicación base --------------------
    for i = 1:numel(baseLocations)
        base = baseLocations{i};

        % Todos los sensores de esta ubicación (p.ej. COG_1, COG_2)
        variantes = camposDatos(cellfun(@(c) ...
            ~isempty(regexp(c, ['^' base '_\d+$'], 'once')), camposDatos));
        if isempty(variantes)
            continue;
        end

        % Primer sensor: sirve de referencia para gráficas e intervalos
        primerIdent = variantes{1};
        if ~isfield(datos, primerIdent) || ~isfield(datos, [primerIdent '_metadata'])
            warning('⚠️ Falta tabla o metadata para %s. Se omite.', primerIdent);
            continue;
        end
        tablaPrimera = datos.(primerIdent);

        % --- Zona estática (se selecciona una vez, se aplica a todas las variantes) ---
        if usarResumen
            filaEst = resumenTabla(strcmp(resumenTabla.Tipo,'estatico') & ...
                                   strcmp(resumenTabla.Ubicacion, primerIdent), :);
            if isempty(filaEst)
                warning('⚠️ No se encontró intervalo estático para %s.', primerIdent);
                continue;
            end
            i1e = filaEst.Intervalo(1);
        else
            figure('Name',[base ' - Zona Estática']); clf;
            plot(tablaPrimera.Acc_X); hold on;
            plot(tablaPrimera.Acc_Y); plot(tablaPrimera.Acc_Z);
            legend({'Acc_X','Acc_Y','Acc_Z'}); grid on;
            title(['Selecciona zona estática para ' base ...
                   sprintf(' (%d sensor/es)', numel(variantes))]);

            while true
                entrada = input('Intervalo estático [i1 i2]: ','s');
                partes = sscanf(entrada,'%f');
                if numel(partes)==2 && partes(1)<partes(2)
                    i1e = max(1,floor(partes(1)));
                    if (partes(2)-i1e+1) < 50
                        warning('❌ Mínimo 50 muestras requeridas.');
                        continue;
                    end
                    break;
                else
                    warning('❌ Entrada inválida. Intenta de nuevo.');
                end
            end
        end

        % Extraer zona estática de cada variante con el mismo intervalo
        for k = 1:numel(variantes)
            ident = variantes{k};
            zonasEstaticas.(ident) = datos.(ident)(i1e:i1e+49,:);
        end

        % --- Intentos (se seleccionan una vez, se aplican a todas las variantes) ---
        if usarResumen
            filasIntentos = resumenTabla(strcmp(resumenTabla.Tipo,'intervalo') & ...
                                         strcmp(resumenTabla.Ubicacion, primerIdent), :);
            for j = 1:height(filasIntentos)
                intento = filasIntentos.Numero(j);
                i1 = filasIntentos.Intervalo(j,1);
                i2 = filasIntentos.Intervalo(j,2);
                for k = 1:numel(variantes)
                    ident = variantes{k};
                    if ~isfield(segmentosPorIdentificador, ident)
                        segmentosPorIdentificador.(ident) = {};
                    end
                    segmentosPorIdentificador.(ident){intento} = ...
                        [zonasEstaticas.(ident); datos.(ident)(i1:i2,:)];
                end
                intentosGlobales = [intentosGlobales; struct( ...
                    'intento', intento, 'base', base, ...
                    'inicio', i1, 'fin', i2, ...
                    'inicio_estatico', i1e, 'fin_estatico', i1e+49)];
            end
        else
            intento = 1;
            while true
                entrada = input(sprintf('Intento %02d [i1 i2] (Enter=salta, q=salir): ', intento),'s');
                if strcmpi(entrada,'q'), break; end
                if isempty(entrada), intento=intento+1; continue; end
                partes = sscanf(entrada,'%f');
                if numel(partes)==2 && partes(1)<partes(2)
                    i1 = max(1,floor(partes(1)));
                    i2 = min(height(tablaPrimera),floor(partes(2)));
                    for k = 1:numel(variantes)
                        ident = variantes{k};
                        if ~isfield(segmentosPorIdentificador, ident)
                            segmentosPorIdentificador.(ident) = {};
                        end
                        segmentosPorIdentificador.(ident){intento} = ...
                            [zonasEstaticas.(ident); datos.(ident)(i1:i2,:)];
                    end
                    intentosGlobales = [intentosGlobales; struct( ...
                        'intento', intento, 'base', base, ...
                        'inicio', i1, 'fin', i2, ...
                        'inicio_estatico', i1e, 'fin_estatico', i1e+49)];
                    intento = intento+1;
                else
                    warning('❌ Intervalo inválido.');
                end
            end
        end
    end

    % -------------------- Guardar fragmentos --------------------
    intentosUnicos = unique([intentosGlobales.intento]);
    nombreBase = sprintf('%s%s', letra, numero);

    for i = 1:numel(intentosUnicos)
        idIntento = intentosUnicos(i);
        fragmento = struct();
        for j = 1:numel(camposDatos)
            ident = camposDatos{j};
            if ~isfield(segmentosPorIdentificador, ident)
                continue;
            end
            segs = segmentosPorIdentificador.(ident);
            if idIntento > numel(segs) || isempty(segs{idIntento})
                continue;
            end
            fragmento.(ident) = segs{idIntento};
            meta = datos.([ident '_metadata']);
            base = regexprep(ident, '_\d+$', '');
            intentosFiltrados = intentosGlobales([intentosGlobales.intento]==idIntento & ...
                                                 strcmp({intentosGlobales.base}, base));
            if ~isempty(intentosFiltrados)
                meta.intervaloIntento  = [intentosFiltrados(1).inicio, intentosFiltrados(1).fin];
                meta.intervaloEstatico = [intentosFiltrados(1).inicio_estatico, intentosFiltrados(1).fin_estatico];
            end
            fragmento.([ident '_metadata']) = meta;
        end
        nombreIntento = sprintf('%s%02d.mat', nombreBase, idIntento);
        save(nombreIntento,'-struct','fragmento');
        fprintf('📁 Guardado: %s\n', nombreIntento);
    end

    % -------------------- Guardar resumen si interactivo --------------------
    if ~usarResumen
        Tipo = {}; Numero = []; Ubicacion = {}; Intervalo = [];
        basesUnicas = unique({intentosGlobales.base});
        for i = 1:numel(basesUnicas)
            base = basesUnicas{i};
            intentosBase = intentosGlobales(strcmp({intentosGlobales.base}, base));
            % Identificador del primer sensor de esta base para el resumen
            variantes = camposDatos(cellfun(@(c) ...
                ~isempty(regexp(c, ['^' base '_\d+$'], 'once')), camposDatos));
            primerIdent = variantes{1};
            if ~isempty(intentosBase)
                Tipo{end+1,1} = 'estatico';
                Numero(end+1,1) = 0;
                Ubicacion{end+1,1} = primerIdent;
                Intervalo(end+1,:) = [intentosBase(1).inicio_estatico, intentosBase(1).fin_estatico];
            end
            for j = 1:numel(intentosBase)
                Tipo{end+1,1} = 'intervalo';
                Numero(end+1,1) = intentosBase(j).intento;
                Ubicacion{end+1,1} = primerIdent;
                Intervalo(end+1,:) = [intentosBase(j).inicio, intentosBase(j).fin];
            end
        end
        resumenTabla = table(Tipo,Numero,Ubicacion,Intervalo);
        nombreResumen = sprintf('intentos%s%s.mat', letra, numero);
        save(nombreResumen,'resumenTabla');
        fprintf('📄 Resumen guardado como %s\n', nombreResumen);
    end
end

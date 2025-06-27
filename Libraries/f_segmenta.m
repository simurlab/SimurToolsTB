function f_segmenta(nombreResumen)
% F_SEGMENTA Interactivamente (o automáticamente) segmenta zonas estáticas e intentos por ubicación.
% Si se proporciona un archivo .mat con la tabla 'resumenTabla', se usa como entrada automática.

<<<<<<< HEAD
    % Obtener carpeta actual y su nombre
    carpetaActual = pwd;
    [carpetaPadre, nombreActual] = fileparts(carpetaActual);
    [~, nombrePadre] = fileparts(carpetaPadre);

    % Extraer letra y número para construir nombre base
    letra = regexp(nombrePadre, '[a-zA-Z]', 'match', 'once');
    if isempty(letra)
        error('❌ No se encontró una letra en el nombre de la carpeta padre.');
    end
    numero = regexp(nombreActual, '\d+', 'match', 'once');
    if isempty(numero)
        error('❌ No se encontró número en el nombre de la carpeta actual.');
    end
    numero = sprintf('%02d', str2double(numero));
    nombreArchivo = sprintf('%s%s.mat', letra, numero);
    fprintf('📂 Cargando archivo: %s\n', nombreArchivo);

    if ~isfile(nombreArchivo)
        error('❌ No se encontró el archivo "%s".', nombreArchivo);
    end

    datos = load(nombreArchivo);
=======
% -------------------- Construir nombre archivo salida --------------------
rutaActual = pwd;
rutasPartes = strsplit(rutaActual, filesep);

if numel(rutasPartes) < 3
    error('Ruta demasiado corta para determinar nombre de archivo.');
end

letraMatch = regexp(rutasPartes{end-2}, '^[a-zA-Z]', 'match');
numMatch = regexp(rutasPartes{end}, '^\d{2}', 'match');

if isempty(letraMatch) || isempty(numMatch)
    error('❌ Algo salió mal en la carga del archivo...');
end

nombreArchivo = [lower(letraMatch{1}) numMatch{1} '.mat'];

%datos = load('h01.mat');
datos = load(nombreArchivo);

>>>>>>> 3a414cd8eaf1cbbbef88fddd757dd679a031a1c5
    campos = fieldnames(datos);
    ubicaciones = unique(regexprep(campos, '_\d+(_metadata)?$', ''));

    % Cargar resumenTabla si se pasa como argumento
    usarResumen = nargin > 0 && isfile(nombreResumen);
    if usarResumen
        s = load(nombreResumen);
        if ~isfield(s, "resumenTabla")
            error('❌ El archivo no contiene la variable "resumenTabla".');
        end
        resumenTabla = s.resumenTabla;
    end

    zonasEstaticas = struct();
    segmentosPorUbicacion = struct();
    intentosGlobales = [];

    for i = 1:numel(ubicaciones)
        ubic = ubicaciones{i};
        nombreTabla = sprintf('%s_1', ubic);
        nombreMeta = sprintf('%s_1_metadata', ubic);

        if ~isfield(datos, nombreTabla) || ~isfield(datos, nombreMeta)
            warning('⚠️ Falta tabla o metadata para %s. Se omite.', ubic);
            continue;
        end

        tabla = datos.(nombreTabla);

        % ---------- Zona Estática ----------
        if usarResumen
            filaEst = resumenTabla(strcmp(resumenTabla.Tipo, 'estatico') & strcmp(resumenTabla.Ubicacion, [ubic '_1']), :);
            if isempty(filaEst)
                warning('⚠️ No se encontró intervalo estático para %s en resumen. Se omite.', ubic);
                continue;
            end
            i1 = filaEst.Intervalo(1);
            zonasEstaticas.(ubic) = tabla(i1:i1+49, :);
        else
            figure('Name', [ubic ' - Zona Estática']); clf;
            plot(tabla.Acc_X); hold on;
            plot(tabla.Acc_Y); plot(tabla.Acc_Z);
            legend({'Acc_X', 'Acc_Y', 'Acc_Z'}); grid on;
            title(['Selecciona zona estática para ' ubic]);

            while true
                entrada = input('Intervalo estático [i1 i2]: ', 's');
                partes = sscanf(entrada, '%f');
                if numel(partes) == 2 && partes(1) < partes(2)
                    i1 = max(1, floor(partes(1)));
                    if (partes(2) - i1 + 1) < 50
                        warning('❌ Mínimo 50 muestras requeridas.');
                        continue;
                    end
                    zonasEstaticas.(ubic) = tabla(i1:i1+49, :);
                    break;
                else
                    warning('❌ Entrada inválida. Intenta de nuevo.');
                end
            end
        end

        % ---------- Intentos ----------
        segmentos = {};
        if usarResumen
            filasIntentos = resumenTabla(strcmp(resumenTabla.Tipo, 'intervalo') & strcmp(resumenTabla.Ubicacion, [ubic '_1']), :);
            for j = 1:height(filasIntentos)
                intento = filasIntentos.Numero(j);
                i1 = filasIntentos.Intervalo(j,1);
                i2 = filasIntentos.Intervalo(j,2);
                segmento = [zonasEstaticas.(ubic); tabla(i1:i2, :)];
                segmentos{intento} = segmento;

                intentosGlobales = [intentosGlobales; struct( ...
                    'intento', intento, ...
                    'ubicacion', ubic, ...
                    'inicio', i1, ...
                    'fin', i2, ...
                    'inicio_estatico', i1, ...
                    'fin_estatico', i1 + 49 ...
                )];
            end
        else
            intento = 1;
            while true
                prompt = sprintf('Intento %02d [%d-%d] (Enter=salta, q=salir): ', intento, 1, height(tabla));
                entrada = input(prompt, 's');
                if strcmpi(entrada, 'q')
                    break;
                elseif isempty(entrada)
                    intento = intento + 1;
                    continue;
                end

                partes = sscanf(entrada, '%f');
                if numel(partes) == 2 && partes(1) < partes(2)
                    i1 = max(1, floor(partes(1)));
                    i2 = min(height(tabla), floor(partes(2)));
                    segmento = [zonasEstaticas.(ubic); tabla(i1:i2, :)];
                    segmentos{intento} = segmento;

                    intentosGlobales = [intentosGlobales; struct( ...
                        'intento', intento, ...
                        'ubicacion', ubic, ...
                        'inicio', i1, ...
                        'fin', i2, ...
                        'inicio_estatico', i1, ...
                        'fin_estatico', i1 + 49 ...
                    )];
                    intento = intento + 1;
                else
                    warning('❌ Intervalo inválido. Intenta de nuevo.');
                end
            end
        end

        segmentosPorUbicacion.(ubic) = segmentos;
    end

    % ---------- Guardado por intento ----------
    intentosUnicos = unique([intentosGlobales.intento]);
<<<<<<< HEAD
    nombreBase = sprintf('%s%s', letra, numero);

=======
    %nombreBase = 'h01';
    nombreArchivo2 = [lower(letraMatch{1}) numMatch{1}];
    nombreBase=nombreArchivo2;
    
>>>>>>> 3a414cd8eaf1cbbbef88fddd757dd679a031a1c5
    for i = 1:numel(intentosUnicos)
        idIntento = intentosUnicos(i);
        fragmento = struct();

        for j = 1:numel(ubicaciones)
            ubic = ubicaciones{j};
            segmentos = segmentosPorUbicacion.(ubic);
            if idIntento > numel(segmentos) || isempty(segmentos{idIntento})
                continue;
            end
            fragmento.(sprintf('%s_1', ubic)) = segmentos{idIntento};

            meta = datos.(sprintf('%s_1_metadata', ubic));
            intentosFiltrados = intentosGlobales([intentosGlobales.intento] == idIntento & strcmp({intentosGlobales.ubicacion}, ubic));
            if ~isempty(intentosFiltrados)
                meta.intervaloIntento = [intentosFiltrados.inicio, intentosFiltrados.fin];
            end
            fragmento.(sprintf('%s_1_metadata', ubic)) = meta;
        end

        nombreIntento = sprintf('%s%02d.mat', nombreBase, idIntento);
        save(nombreIntento, '-struct', 'fragmento');
        fprintf('📁 Guardado: %s\n', nombreIntento);
    end

    % ---------- Guardado de resumen si fue interactivo ----------
    if ~usarResumen
        Tipo = {};
        Numero = [];
        Ubicacion = {};
        Intervalo = [];

        ubicacionesUnicas = unique({intentosGlobales.ubicacion});
        for i = 1:numel(ubicacionesUnicas)
            ubic = ubicacionesUnicas{i};
            intentosUbic = intentosGlobales(strcmp({intentosGlobales.ubicacion}, ubic));

            % Estático
            if ~isempty(intentosUbic)
                Tipo{end+1,1} = 'estatico';
                Numero(end+1,1) = 0;
                Ubicacion{end+1,1} = [ubic '_1'];
                Intervalo(end+1,:) = [intentosUbic(1).inicio_estatico, intentosUbic(1).fin_estatico];
            end

            % Intentos
            for j = 1:numel(intentosUbic)
                Tipo{end+1,1} = 'intervalo';
                Numero(end+1,1) = intentosUbic(j).intento;
                Ubicacion{end+1,1} = [ubic '_1'];
                Intervalo(end+1,:) = [intentosUbic(j).inicio, intentosUbic(j).fin];
            end
        end

        resumenTabla = table(Tipo, Numero, Ubicacion, Intervalo);
        save('intentos.mat', 'resumenTabla');
        fprintf('📄 Resumen tipo tabla guardado como "intentos.mat"\n');
    end
end

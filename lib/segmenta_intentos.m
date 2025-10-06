function segmenta_intentos(varargin)
%SEGMENTAR_INTENTOS Segmenta zonas estáticas e intentos a partir de datos IMU.
%
%   segmentar_intentos()
%       Modo interactivo: el usuario selecciona intervalos estáticos e
%       intentos mediante gráficas e inputs. Guarda fragmentos por intento
%       y un archivo resumen con todos los intervalos.
%
%   segmentar_intentos('resumen','intentos_h01.mat')
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
%       segmentar_intentos();
%
%       % Reutilizando un resumen previo
%       segmentar_intentos('resumen','intentos_h01.mat');
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

    letraMatch = regexp(partesRuta{end-2}, '^[a-zA-Z]', 'match');
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
    ubicaciones = unique(regexprep(campos, '_\d+(_metadata)?$', ''));

    % -------------------- Resumen preexistente --------------------
    if usarResumen
        s = load(resumenFile);
        if ~isfield(s,'resumenTabla')
            error('❌ El archivo de resumen no contiene "resumenTabla".');
        end
        resumenTabla = s.resumenTabla;
    end

    zonasEstaticas = struct();
    segmentosPorUbicacion = struct();
    intentosGlobales = [];

    % -------------------- Procesar por ubicación --------------------
    for i = 1:numel(ubicaciones)
        ubic = ubicaciones{i};
        nombreTabla = sprintf('%s_1', ubic);
        nombreMeta  = sprintf('%s_1_metadata', ubic);

        if ~isfield(datos, nombreTabla) || ~isfield(datos, nombreMeta)
            warning('⚠️ Falta tabla o metadata para %s. Se omite.', ubic);
            continue;
        end
        tabla = datos.(nombreTabla);

        % --- Zona estática ---
        if usarResumen
            filaEst = resumenTabla(strcmp(resumenTabla.Tipo,'estatico') & ...
                                   strcmp(resumenTabla.Ubicacion,[ubic '_1']), :);
            if isempty(filaEst)
                warning('⚠️ No se encontró intervalo estático para %s.', ubic);
                continue;
            end
            i1e = filaEst.Intervalo(1);
            zonasEstaticas.(ubic) = tabla(i1e:i1e+49,:);
        else
            figure('Name',[ubic ' - Zona Estática']); clf;
            plot(tabla.Acc_X); hold on;
            plot(tabla.Acc_Y); plot(tabla.Acc_Z);
            legend({'Acc_X','Acc_Y','Acc_Z'}); grid on;
            title(['Selecciona zona estática para ' ubic]);

            while true
                entrada = input('Intervalo estático [i1 i2]: ','s');
                partes = sscanf(entrada,'%f');
                if numel(partes)==2 && partes(1)<partes(2)
                    i1e = max(1,floor(partes(1)));
                    if (partes(2)-i1e+1) < 50
                        warning('❌ Mínimo 50 muestras requeridas.');
                        continue;
                    end
                    zonasEstaticas.(ubic) = tabla(i1e:i1e+49,:);
                    break;
                else
                    warning('❌ Entrada inválida. Intenta de nuevo.');
                end
            end
        end

        % --- Intentos ---
        segmentos = {};
        if usarResumen
            filasIntentos = resumenTabla(strcmp(resumenTabla.Tipo,'intervalo') & ...
                                         strcmp(resumenTabla.Ubicacion,[ubic '_1']), :);
            for j = 1:height(filasIntentos)
                intento = filasIntentos.Numero(j);
                i1 = filasIntentos.Intervalo(j,1);
                i2 = filasIntentos.Intervalo(j,2);
                segmentos{intento} = [zonasEstaticas.(ubic); tabla(i1:i2,:)];
                intentosGlobales = [intentosGlobales; struct( ...
                    'intento', intento, 'ubicacion', ubic, ...
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
                    i2 = min(height(tabla),floor(partes(2)));
                    segmentos{intento} = [zonasEstaticas.(ubic); tabla(i1:i2,:)];
                    intentosGlobales = [intentosGlobales; struct( ...
                        'intento', intento, 'ubicacion', ubic, ...
                        'inicio', i1, 'fin', i2, ...
                        'inicio_estatico', i1e, 'fin_estatico', i1e+49)];
                    intento = intento+1;
                else
                    warning('❌ Intervalo inválido.');
                end
            end
        end
        segmentosPorUbicacion.(ubic) = segmentos;
    end

    % -------------------- Guardar fragmentos --------------------
    intentosUnicos = unique([intentosGlobales.intento]);
    nombreBase = sprintf('%s%s', letra, numero);

    for i = 1:numel(intentosUnicos)
        idIntento = intentosUnicos(i);
        fragmento = struct();
        for j = 1:numel(ubicaciones)
            ubic = ubicaciones{j};
            segmentos = segmentosPorUbicacion.(ubic);
            if idIntento > numel(segmentos) || isempty(segmentos{idIntento})
                continue;
            end
            fragmento.(sprintf('%s_1',ubic)) = segmentos{idIntento};
            meta = datos.(sprintf('%s_1_metadata',ubic));
            intentosFiltrados = intentosGlobales([intentosGlobales.intento]==idIntento & ...
                                                 strcmp({intentosGlobales.ubicacion},ubic));
            if ~isempty(intentosFiltrados)
                meta.intervaloIntento = [intentosFiltrados.inicio, intentosFiltrados.fin];
            end
            fragmento.(sprintf('%s_1_metadata',ubic)) = meta;
        end
        nombreIntento = sprintf('%s%02d.mat', nombreBase, idIntento);
        save(nombreIntento,'-struct','fragmento');
        fprintf('📁 Guardado: %s\n', nombreIntento);
    end

    % -------------------- Guardar resumen si interactivo --------------------
    if ~usarResumen
        Tipo = {}; Numero = []; Ubicacion = {}; Intervalo = [];
        ubicacionesUnicas = unique({intentosGlobales.ubicacion});
        for i = 1:numel(ubicacionesUnicas)
            ubic = ubicacionesUnicas{i};
            intentosUbic = intentosGlobales(strcmp({intentosGlobales.ubicacion},ubic));
            if ~isempty(intentosUbic)
                Tipo{end+1,1} = 'estatico';
                Numero(end+1,1) = 0;
                Ubicacion{end+1,1} = [ubic '_1'];
                Intervalo(end+1,:) = [intentosUbic(1).inicio_estatico, intentosUbic(1).fin_estatico];
            end
            for j = 1:numel(intentosUbic)
                Tipo{end+1,1} = 'intervalo';
                Numero(end+1,1) = intentosUbic(j).intento;
                Ubicacion{end+1,1} = [ubic '_1'];
                Intervalo(end+1,:) = [intentosUbic(j).inicio, intentosUbic(j).fin];
            end
        end
        resumenTabla = table(Tipo,Numero,Ubicacion,Intervalo);
        nombreResumen = sprintf('intentos%s%s.mat', letra, numero);
        save(nombreResumen,'resumenTabla');
        fprintf('📄 Resumen guardado como %s\n', nombreResumen);
    end
end

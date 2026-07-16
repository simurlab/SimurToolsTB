classdef Dynathlon
    % Carga los datos de los sensores de Dynathlon y permite guardarlos en
    % un .mat 
    % Uso:
    %   d = Dynathlon('ruta_carpeta', '.\data\l_01 20260702 - Las Mestas Vallas\experiment_20260702_113328', 'save', 'y', 'orientacion', [1 2 3], 'actividad', 'Vallas', 'freq', 120);    
    %   plot(d.DatosSensores.MD.Time, d.DatosSensores.MD.Acc_X)
    %      o
    %   d.plotData();

    properties
        Atleta = "";
        Actividad = "";
        NSensores = 0;
        IDSensores = string([]);
        Orientacion = [];
        %FechaActividad = "";
        Ruta_carpeta = "";
        Freq = 120;         % **** Revisar si calcularlo en base a TimeStampsFine
        DatosSensores

    end

    methods
        %% Constructor
        function obj = Dynathlon(varargin)
            % Valores por defecto
            obj.Ruta_carpeta = pwd;
            guardar = 'n';

            % -------------------- Leer argumentos de entrada --------------------
            for i = 1:2:length(varargin)
                nombre = lower(varargin{i});
                valor = varargin{i+1};
                switch nombre
                    case 'ruta_carpeta'
                        obj.Ruta_carpeta = valor;
                    case 'save'
                        guardar = valor;
                    case 'orientacion'
                        obj.Orientacion = valor;
                    case 'actividad'
                        obj.Actividad = valor;
                    case 'freq'
                        obj.Freq = valor;
                    otherwise
                        error('❌ Parámetro desconocido: %s', nombre);
                end
            end
            
            % ----- Cargar datos de los IMUs -----
            obj = obj.carga_IMUsDynathlon();

            % ----- Guardar en .mat cada IMU si se solicita -----
            if strcmpi(guardar, 'y') || strcmpi(guardar, 'Y')
                obj.guarda_IMUsDynathlon();
            end

            % ----- Mostrar info tiempos -----
                fileMP4 = dir(fullfile(obj.Ruta_carpeta, '*.mp4'));
                if ~isempty(fileMP4)
                    pathMP4 = fullfile(fileMP4.folder, fileMP4.name);
                    v = VideoReader(pathMP4);
                else
                    error('❌ No se encontró ningún archivo .mp4 en la ruta: %s', obj.Ruta_carpeta)
                end

            tt = [v.NumFrames;v.Duration;v.FrameRate];
            ttname = ["Video"];
            for k = 1:obj.NSensores
                nombreIMU = obj.IDSensores(k);
                tt = [tt [length(obj.DatosSensores.(nombreIMU).Time); obj.DatosSensores.(nombreIMU).Time(end)/1000;obj.DatosSensores.(strcat(nombreIMU,"_metadata")).frecuencia]];
                ttname = [ttname nombreIMU];
            end
            Tt = array2table(tt,'VariableNames',cellstr(ttname), 'RowNames', {'Samples','Duration [s]','Freq'});
            disp(Tt)

        end
        
        %% Para visualizar datos inerciales de todos los sensores por columnas
        function HFig = plot_data(obj,Seniales2plot)
            % Input por defecto:
            arguments
                obj 
                Seniales2plot string = ["Acc_X","Acc_Y","Acc_Z","Gyr_X","Gyr_Y","Gyr_Z"];
            end
            
            % Crear figura
            SenialesName = Seniales2plot;
            HFig = figure;
            for i = 1:numel(SenialesName)
                senial = SenialesName(i);
                for j = 1:obj.NSensores
                    subplot(numel(SenialesName),obj.NSensores,(i-1)*obj.NSensores+j)
                    hold on;

                    nombreIMU = obj.IDSensores(j);
                    plot(obj.DatosSensores.(nombreIMU).Time/1000, obj.DatosSensores.(nombreIMU).(senial));
                    %plot(obj.DatosSensores.(nombreIMU).Time/1000, obj.DatosSensores.(nombreIMU).(senial), '.');
                    if i == 1
                        title(obj.IDSensores(j), 'Interpreter', 'none');
                    end
                    if j == 1
                        ylabel(strrep(senial, '_', ' '));
                    end
                    if i == numel(SenialesName)
                        xlabel('Tiempo [s]');
                    end
                end 
            end
        end
    end

    methods (Access = private)
        function obj = carga_IMUsDynathlon(obj)
            % -------------------- Buscar archivos .csv --------------------
            archivos = dir(fullfile(obj.Ruta_carpeta, '*.csv'));
            if isempty(archivos)
                error('❌ No se encontró ningún archivo .csv en la ruta: %s', obj.Ruta_carpeta);
            end
        
            if numel(archivos) > 3
                error('❌ Hay más de 3 archivos .csv en la ruta: %s', obj.Ruta_carpeta);
            end

            for k = 1:numel(archivos)
                archivo_csv = fullfile(obj.Ruta_carpeta, archivos(k).name);
                sprintf('Archivo: %s', archivo_csv);
                t = readtable(archivo_csv);
                % -------------------- Validar columnas --------------------
                if any(strcmp(t.Properties.VariableNames, 'SampleTimeFine'))
                    t.Properties.VariableNames{'SampleTimeFine'} = 'Time';
                else
                    error('❌ No se encontró la columna "SampleTimeFine" en el archivo: %s', archivo_csv);
                end
                % ----- Actualizar número de sensores ------
                obj.NSensores = obj.NSensores+1;

                % -------------------- Ajustar tiempo e índices --------------------
                t.Time = (t.Time - t.Time(1)) / 1000;  % us → ms, relativo al inicio
                t.Index = (1:height(t))';              % índice de muestra
                % -------------------- Extraer info de nombre y carpeta --------------------
                [~, nombre_base, ~] = fileparts(archivos(k).name);
                [nombre_dot, ~] = strtok(nombre_base, '_');
                nombre_dot = string(nombre_dot);

                nombre_dot = strrep(nombre_dot," ","_"); % Arregla espacios " " -> "_" para nombre variable valido

                %[~, nombre_carpeta] = fileparts(Ruta_carpeta);
                ubicacion = nombre_dot;

                % ----- Añadir nombre del Sensor a la lista -----
                obj.IDSensores = [obj.IDSensores nombre_dot];
                
                % ----- Comprobar que no haya nombres repetidos -----
                if obj.NSensores > numel(unique(obj.IDSensores))
                    error('❌ Nombre de sensores repetidos. XX debe ser único en cada archivo XX_xxxx.csv, ');
                end

                % -------------------- Validar orientación --------------------
                if k > size(obj.Orientacion,1)                                        % ************REV
                    warning('⚠️ No se especificó orientación.');
                    tx = sprintf('👉 Introduce orientación del sensor %s, [1 2 3]: ',nombre_dot);
                    obj.Orientacion(k,:) = input(tx);
                end
                if ~isnumeric(obj.Orientacion(k,:)) || numel(obj.Orientacion(k,:)) ~= 3
                    error('❌ Orientación inválida. Debe ser un vector [1 2 3].');
                end
                % -------------------- info_sensor --------------------
                info_sensor = struct( ...
                    'IMU', nombre_dot, ...
                    'ubicacion', ubicacion, ...
                    'modelo', 'DOT', ...
                    'frecuencia', mean(1000./(diff(t.Time))), ...           %***REV
                    'orientacion', obj.Orientacion(k,:), ...
                    'actividad', obj.Actividad ...
                );
                % ----- Guardar los datos en array de datos de sensores -----
                if ~ismember('PacketCounter', t.Properties.VariableNames) % Compatibilidad con DOT y Dynathlon
                    obj.DatosSensores.(nombre_dot) = renamevars(t, {'packetCounter','accX','accY','accZ','gyrX','gyrY','gyrZ'}, {'PacketCounter','Acc_X','Acc_Y','Acc_Z','Gyr_X','Gyr_Y','Gyr_Z'});
                else
                    obj.DatosSensores.(nombre_dot) = t;
                end

                obj.DatosSensores.(strcat(nombre_dot,"_metadata")) = info_sensor;
            end

        end
        function guarda_IMUsDynathlon(obj)
            % ----- Para cada sensor guardar datos en formato compatible
            % con Simur TB -----
            % Crear struct temporal con variables a guardar en formato
            % leible por carga_IMUstd
            datos_a_guardar = struct();
            for k = 1:length(obj.IDSensores)
                nameSens = obj.IDSensores(k);
                datos_a_guardar.(nameSens) = obj.DatosSensores.(nameSens);
                datos_a_guardar.(strcat(nameSens,"_metadata")) = obj.DatosSensores.(strcat(nameSens,"_metadata"));
            end

            % Nombre del archivo .mat
            fecha = datestr(now, 'yymmdd');
            nombre_archivo = fullfile(obj.Ruta_carpeta, sprintf('DynathlonIMUs_%s.mat', fecha));
            % Guardar campos del struct temporal
            save(nombre_archivo, '-struct', 'datos_a_guardar');
            fprintf('💾 Archivo guardado: %s\n', nombre_archivo);
        end
    end
end
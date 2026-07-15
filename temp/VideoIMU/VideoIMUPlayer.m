classdef VideoIMUPlayer < handle
    % DYNATHLONPLAYER  Visualizador de vídeo + señales IMU
    % 
    % Uso:
    %   d = Dynathlon('ruta_carpeta', '.\datos\experiment_20260416_113857');
    %   p = DynathlonPlayer(d);
    %   p.setEditMode(true);   % flechas izq/dcha para ajustar offset
    %
    % Requiere carpeta "frames_{video_name}" con imagenes de cada frame.
    %   crear_FramesFolder('.\datos\experiment_20260416_113857\video_20260702_120246.mp4');
    % 

    properties (SetAccess = private)
        myIMU
        idIMU

        FramesFolder = {}
        FrameFiles = {}
        VidName = {}
        VideoObj
        Fig
        AxVideo
        AxIMU
        SignalNames     % Señales a plotear ej: ["Acc_X","Acc_Y","Acc_Z","Gyr_X","Gyr_Y","Gyr_Z"];

        hImg
        CurrentTime = 0
        Offset = {}

        t_video = {} % Cell con Arrays con los tiempos asociados a cada frame del video.

        % Throttling fuera del buffer
        LIMIT02 = false          % evitar releer el mismo frame
        
        LastFrameIdx = []
        DisplayScale = 1      % reducción del frame al cachear (0.5 = mitad de resolución)
    
    end

    methods
        %% Constructor
        function obj = VideoIMUPlayer(ruta_video,db_file, sensor_id, seniales2plot, IMU_sync_sample, Frame_sync_sample)
        % INPUT:
        %   rutas_videos - (String) Ruta de video/s. Array de string si hay
        %                  mas de un video.
        %   db_file      - Ruta al archivo .mat en formato IMUstd. Debe contener al
        %                  menos un campo cuyo nombre empiece por sensor_id (p.ej.
        %                  'MD') con columnas Acc_X, Acc_Y, Acc_Z, Gyr_X, Gyr_Y,
        %                  Gyr_Z.
        %   sensor_id    - Prefijo del campo del sensor dentro del archivo, p.ej.
        %                  'COG', 'PD', 'MD'. Si hay varios campos con ese prefijo
        %                  (COG_1, COG_2, ...) se usa el primero encontrado.
        %   seniales2plot- Señales a mostrar junto al video: ["Acc_X","Acc_Y","Acc_Z","Gyr_X","Gyr_Y","Gyr_Z", "Acc_Mod", etc]
        %                  Implementar más señales aquí si se quiere aumentar opciones                   
        %    
        %   IMU_sync_sample   - indice de muestra del IMU en el que el IMU se
        %                       sincroniza con el video.
        %   Frame_sync_sample - frame del video en el que el se sincroniza
        %                       con el IMU.
        %       Ejemplo: Si se sincroniza video-IMU de forma manual. Y se
        %       tiene que en la muestra n-esima de IMU se corresponde al
        %       frame k-esimo del video. Entonces: 
        %                   IMU_sync_sample = n;
        %                   Frame_sync_sample = k;
        %       Si se tienen varios videos, Frame_sync_sample será un
        %       array con los frames que sincronizan.
        %
        % EJEMPLO:
        %   p = VideoIMUPlayer("./vid2.mp4", "./Data.mat", "MD")
        %     o
        %   p = VideoIMUPlayer(["./vid1.mp4" "./vid2.mp4"], "./Data.mat", "MD", ["Acc_X","Acc_Y","Acc_Z"], 10, [10 231])

            arguments
                ruta_video
                db_file
                sensor_id
                seniales2plot string = ["Acc_X","Acc_Y","Acc_Z","Gyr_X","Gyr_Y","Gyr_Z"];
                IMU_sync_sample = 1;    % Por defecto de considera IMU y video inician en el mismo instante
                Frame_sync_sample = 1;  % Por defecto de considera IMU y video inician en el mismo instante
            end
            
            % Comprobación input size
            n_videos = length(ruta_video);  % Numero de videos
            n_imus = length(sensor_id);     % Numero de imus
            if (Frame_sync_sample == 1) && (length(Frame_sync_sample) ~= n_videos)
                Frame_sync_sample = ones(1,n_videos);   % Valor por defecto si hay varios videos y no se especifica sync
            end

            % Cargar datos de sensor/es: sensor_id
            datos = load(db_file);
        
            posiblesCampos = fieldnames(datos);
            esSensor = startsWith(posiblesCampos, sensor_id);
        
            if ~any(esSensor)
                error('carga_IMUstd:SensorNoDisponible', ...
                      'Sensor "%s" no disponible en el archivo %s.', ...
                      sensor_id, db_file);
            end
        
            obj.idIMU = sensor_id;
            obj.SignalNames = seniales2plot;
    
            % Para cada IMU
            for i = 1:n_imus
                % Extraer datos de IMU:
                obj.myIMU.(sensor_id(i)) = datos.(sensor_id(i));

                %% ----- Opciones para plotear (Ampliable) -----
                if any(contains(seniales2plot,"Acc_Mod"))   % Modulo de la aceleración
                    obj.myIMU.(sensor_id(i)).Acc_Mod = sqrt(sum([obj.myIMU.(sensor_id(i)).Acc_X obj.myIMU.(sensor_id(i)).Acc_Y obj.myIMU.(sensor_id(i)).Acc_Z].^2,2));
                end
                if any(contains(seniales2plot,"ZeroCrossGyr_Y"))   % Cruce por 0 del Gyr_Y
                    obj.myIMU.(sensor_id(i)).Acc_Mod.ZeroCrossGyr_Y = [diff(sign(obj.myIMU.(sensor_id(i)).Gyr_Y)) ; 0];
                end
                %% ---------------------------------

            end

            % Localizar video y carpeta con sus frames
            for i = 1:n_videos
                [ruta_carpeta, nombre_video, ~] = fileparts(ruta_video(i));
                obj.FramesFolder{i} = fullfile(ruta_carpeta, sprintf('frames_%s', nombre_video));
                if isempty(obj.FramesFolder{i})
                    error('❌ No se encontró carpeta con los frames de %s. Ejecuta crear_FramesFolder primero.', nombre_video);
                end
                obj.FrameFiles{i} = dir(fullfile(obj.FramesFolder{i}, 'frame_*.jpg'));
                if isempty(obj.FrameFiles{i})
                    error('❌ No se encontraron frames de %s. Ejecuta crear_FramesFolder primero.', nombre_video);
                end
                obj.VidName{i} = nombre_video;

                % Extraer tiempos de cada frame
                obj.t_video{i} = extraer_tiempos_frames(ruta_video(i), true);

                % Info aux de video
                obj.VideoObj{i} = VideoReader(ruta_video(i));

                % Offset segun sync dada por IMU_sync_sample y Frame_sync_sample
                obj.Offset{i} = obj.myIMU.(sensor_id(1)).Time(IMU_sync_sample)/1000 - obj.t_video{i}(Frame_sync_sample(i));  % Si hay varios IMUs se da por hecho que estan sincronizados entre si
            end

            % Inicializar param auxiliare
            obj.LastFrameIdx = -ones(n_videos,1);

            % Iniciar gráfica
            obj.build();
        end

        %% Interfaz gráfica
        function build(obj)
            NSensores = length(obj.idIMU);  % Número de sensores
            NVid = length(obj.VidName);  % Número de videos

            % Crear Figura
            obj.Fig = figure('Name','Video-IMU Player');
            nSeniales = numel(obj.SignalNames);
            t = tiledlayout(obj.Fig, nSeniales, NSensores+NVid, ...
                'TileSpacing','compact', 'Padding','compact');

            % Video
            for i = 1:NVid
                obj.AxVideo{i} = nexttile(t, i, [nSeniales 1]);
                frame = imread(fullfile(obj.FramesFolder{i}, obj.FrameFiles{i}(1).name));
                obj.hImg{i} = imshow(frame, 'Parent', obj.AxVideo{i});
                title(obj.AxVideo{i}, sprintf('Video: %s', obj.VidName{i}),"Interpreter","none");
                set(obj.AxVideo{i}, 'Tag', sprintf('Vid_%d', i));       % para ignorar axes de video
            end
 
            % IMUs
            obj.AxIMU = gobjects(nSeniales, NSensores);
            for r = 1:nSeniales
                senial = obj.SignalNames(r);
                for k = 1:NSensores
                    ax = nexttile(t);
                    obj.AxIMU(r,k) = ax;
                    nameSens = obj.idIMU(k);
                    plot(ax, obj.myIMU.(nameSens).Time/1000, obj.myIMU.(nameSens).(senial));

                        %ylim([min(tabla.(senial)) max(tabla.(senial))]);
                    
                    if r == 1,        title(ax, nameSens, 'Interpreter','none'); end
                    if k == 1,        ylabel(ax, strrep(senial,'_',' ')); end
                    if r == nSeniales, xlabel(ax, 'Tiempo [s]'); end
                end
            end

            % Cursor temporal arrastrable
            draggableCursorV4(obj.Fig, @(tCursor) obj.onCursorMove(tCursor));
        end

        function diff_array_ms = plotSyncError(obj)         %% REVISAR
            % Calcular error de sincronización segun tiempo IMU y tiempo de
            % frame del video
            nameSens = obj.idIMU(1);    % Se asume IMUs sincronzados entre si
            t_imu = obj.myIMU.(nameSens).Time/1000; 
            NVid = length(obj.VidName);
            diff_array_ms = {};

            for i = 1:NVid
                t_target = t_imu - obj.Offset{i};
                t_target = max(0, min(obj.VideoObj{i}.Duration, t_target));
                
                % 'nearest' para buscar el t_video más cercano para TODOS los t_target al mismo tiempo
                t_video_elegido = interp1(obj.t_video{i}, obj.t_video{i}, t_target, 'nearest');
                
                % Calcular diferencia en milisegundos Video-IMU
                diff_array_ms{i} = round((t_video_elegido - t_target) * 1000,0);
                
                % Gráfica
                figure('Name', 'Err sincronización (IMU vs Video)');
                hold on;
                plot(t_imu, diff_array_ms{i}, 'b-', 'LineWidth', 1.2);
                
                xlabel('Tiempo IMU [s]'); ylabel('Diferencia (Vídeo - IMU) [ms]');
                title(sprintf('Video: %s', obj.VidName{i}), 'Interpreter','none');
                grid minor; box on;
                yline(0, 'r--', 'Sync Perfecta', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'center');
                hold off;
            end
        end
    end  

    methods (Access = private)
        function onCursorMove(obj, tCursor)
            obj.refreshFrame(tCursor);
        end

        %% Refresco del frame de vídeo mediante lectura de jpg en carpeta "frames_{videoname}"
        function refreshFrame(obj, t)
            obj.CurrentTime = t;
            
            % Para cada Video:
            for i = 1:length(obj.VidName)
                tVideo = t - obj.Offset{i};
                tVideo = max(0, min(obj.VideoObj{i}.Duration, tVideo));    % Clamp a limites del tiempo video
    
                [~, frameIdx] = min(abs(obj.t_video{i} - tVideo));    % Coger el frame con tiempo más cercano
    
                diff_tiempo = (obj.t_video{i}(frameIdx) - tVideo)*1000;   % Diferencia entre frames video-imu [ms]
    
                % Evitar leer mismo frame
                if (obj.LIMIT02 && frameIdx == obj.LastFrameIdx(i)), return; end
                obj.LastFrameIdx(i) = frameIdx;
    
                % Leer la imagen del frame
                ruta_img = fullfile(obj.FramesFolder{i}, obj.FrameFiles{i}(frameIdx).name);
                frame = imread(ruta_img);
                set(obj.hImg{i}, 'CData', frame);
    
                xlabel(obj.AxVideo{i}, sprintf('t_{IMU}=%.3f s | t_{vid}=%.3f s | off=%.3f s | dif=%+.0f ms | Video Frame:%d', t, obj.t_video{i}(frameIdx), obj.Offset{i}, diff_tiempo, frameIdx));
                drawnow limitrate;
            end
        end
    end
end


%% Funciones auxiliares para cursor arrastrable 
% (Modificado a partir de código autogenerado por Gemini)
function draggableCursorV4(fig, updateFcn)
    if nargin < 2, updateFcn = []; end
    if ~ishandle(fig) || ~strcmp(get(fig,'Type'),'figure')
        error('Debe proporcionar un handle de figura válido.');
    end
    
    ax = findall(fig, 'Type','axes');
    ax = flipud(ax);
    ax = ax(~contains({ax.Tag}, "Vid_"));   % excluir axes cuyo Tag contiene 'Vid_'
    linkaxes(ax, 'x');
    
    curves = cell(numel(ax),1);
    for i = 1:numel(ax)
        curves{i} = findall(ax(i), 'Type','line');
    end
    
    % Se asume que la primera gráfica tiene la base de tiempo general
    lineas_visibles = curves{1}(strcmp(get(curves{1},'Visible'),'on'));
    x_ref = get(lineas_visibles(1), 'XData'); 
    
    xMin = min(x_ref);
    xMax = max(x_ref);
    
    % Posición inicial al centro, pero anclada a un valor real
    x0_raw = (xMin + xMax) / 2;
    [~, idx0] = min(abs(x_ref - x0_raw));
    x0 = x_ref(idx0);
    
    vlines = gobjects(numel(ax),1);
    txt    = gobjects(numel(ax),1);
    for i = 1:numel(ax)
        axes(ax(i)); %#ok<LAXES>
        vlines(i) = xline(ax(i), x0, 'k', 'LineWidth',1.5, 'HandleVisibility','off');
        y0 = getExactY(curves{i}, x0);
        txt(i) = text(ax(i), x0, y0, sprintf('t=%.3f, y=%.3f', x0, y0), ...
            'Color','k', 'FontSize',9, 'VerticalAlignment','bottom', ...
            'BackgroundColor',[1 1 1 .5]);
    end
    
    set(fig, 'WindowButtonDownFcn', @startDrag);
    set(fig, 'WindowButtonUpFcn',   @stopDrag);
    dragging = false;
    
    function startDrag(~,~)
        dragging = true;
        set(fig, 'WindowButtonMotionFcn', @draggingCallback);
    end
    function stopDrag(~,~)
        dragging = false;
        set(fig, 'WindowButtonMotionFcn', '');
    end
    
    function draggingCallback(~,~)
        if ~dragging, return; end
        cp = get(ax(1), 'CurrentPoint');
        xv_raw = cp(1,1);
        
        % 1. Efecto Imán: Buscar el valor X real más cercano al ratón
        [~, idx_near] = min(abs(x_ref - xv_raw));
        xv_snapped = x_ref(idx_near);
        
        % 2. Actualizar las líneas y textos usando los valores estrictos
        for k = 1:numel(ax)
            vlines(k).Value = xv_snapped; 
            yv = getExactY(curves{k}, xv_snapped); 
            
            txt(k).Position = [xv_snapped yv];
            txt(k).String   = sprintf('t=%.3f, y=%.3f', xv_snapped, yv);
        end
        
        if ~isempty(updateFcn), updateFcn(xv_snapped); end
    end
end

% Función auxiliar
function y = getExactY(curves, xv_snapped)
    if isempty(curves), y = NaN; return; end
    curves = curves(strcmp(get(curves,'Visible'),'on'));
    if isempty(curves), y = NaN; return; end
    
    x = get(curves(1), 'XData');
    ydata = get(curves(1), 'YData');
    
    % Buscar el índice exacto en esta curva particular
    [~, idx] = min(abs(x - xv_snapped));
    y = ydata(idx);
end
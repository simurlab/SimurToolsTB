function t_video = extraer_tiempos_frames(ruta_video, usar_ffprobe)
% EXTRAER_TIEMPOS_FRAMES obtiene los tiempos de cada frame de un archivo de video
%
% INPUT:
%   ruta_video   - (String/Char) Ruta completa o relativa al archivo de video.
%   usar_ffprobe - (bool) Flag para seleccionar el método de extracción:
%                      * true: Usa la herramienta externa FFprobe.
%                      * false: Usa la clase nativa VideoReader de MATLAB y lee 
%                        el video secuencialmente (más lento).
%
% OUTPUT:
%  t_video       - (Nx1) tiempo en segundos asociado a cada frame
%
% EJEMPLO:
%   t_video = tiempos_frames(./data/experiment_20260416_113857/video_20260416_113857.mp4, true);
%   t_video(125) ; % Tiempo asociado al frame 125
%
% DEPENDENCIAS:
%       Si 'usar_ffprobe' es true, se requiere tener instalado FFMPEG en el
%       sistema y que la ruta al ejecutable 'ffprobe.exe' coincida con la 
%       variable 'ruta_ffprobe' definida dentro del código (por defecto: 
%       'C:\ffmpeg\bin\ffprobe.exe').
    
    % Ruta por defecto de los ejecutables de FFMPEG
    ruta_ffmpeg = 'C:\ffmpeg\bin';    % Requiere descargar FFMPEG ('https://www.gyan.dev/ffmpeg/builds/')
    
    ruta_ffprobe = strcat(ruta_ffmpeg, '\ffprobe.exe');

    %% Lectura tiempos de video por cada frame
    [~,nombre,~]=fileparts(ruta_video);
    
    % Mediante ffprobe (más rápido)
    if usar_ffprobe
        % String para comando por Matlab
        cmd = sprintf('"%s" -v error -select_streams v:0 -show_entries packet=pts_time -of csv=p=0 "%s"', ruta_ffprobe, ruta_video);
        
        fprintf("Ejecutando FFprobe en segundo plano para video:\n\t%s \n...\n", nombre);
        
        tic;
    
        % Ejecutar comando en la terminal invisible de Windows
        [estado, salida_texto] = system(cmd);   % 'estado' (0 si no fallo), 'salida_texto' tiene la respuesta cruda
        
        % Si ffprobe correcto
        if estado == 0
            % Pasar linea de texto a vector
            t_video = sscanf(salida_texto, '%f');
    
            toc_t = toc;    % tiempo que se tarda en extraer array de tiempos por frame
            % Ordenar (orden de decodificación (DTS) crudo -> orden cronológico visual correcto (PTS))
            t_video = sort(t_video);
            
            fprintf('Frames totales: %d\nTiempo extraccion: %.3f s\n', length(t_video), toc_t);
        else
            error('FFprobe.exe falló: %s', salida_texto);
        end
    else
        % Mediante Matlab (más lento que ffprobe.exe)
        v = VideoReader(ruta_video);
        t_video = nan(v.NumFrames,1); % Vector para almacenar los tiempos de cada frame
        
        t_video(1,1) = v.CurrentTime; % Guardar el tiempo del 1er frame
        % Leer frame a frame para recoger metadatos del frame
        i = 1; % inicializacion del contador de frames
        tic;
        while hasFrame(v)
            readFrame(v); % Avanzar frame
            i = i+1;
            if i<=v.NumFrames                  % Evitar coger el tiempo de v.Duration
                t_video(i, 1) = v.CurrentTime; % Guardar el tiempo del frame
            end
        end
        toc_t = toc;
        fprintf('Frames totales: %d\nTiempo extraccion: %.3f s\n', length(t_video), toc_t);
    end
end
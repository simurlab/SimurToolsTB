function ruta_frames_folder = crear_FramesFolder(ruta_video)
% CREAR_FRAMESFOLDER crea una subcarpeta, en la misma carpeta donde esta el video,con todos los frames en forma de imagenes .jpg. 
%       Facilita la visualizacion con player_video_sensor.
%       Las imagenes se nombran como frame_xxxxx.jpg, donde xxxxx: es el
%       número/posición de frame del video
%
% INPUT:
%   ruta_video   - (String/Char) Ruta completa o relativa al archivo de video.
%
% OUTPUT:
%   ruta_frames_folder - Ruta de la carpeta donde se guardaron los frames
%   en forma de .jpg.
%
% EJEMPLO:
%   frames_folder = crear_FramesFolder('.\data\l_03 20260702 - Las Mestas Vallas\video_20260702_120246.mp4');
%   imshow(strcat(frames_folder,'\frame_00001.jpg'))    % Mostrar el primer frame
%
% DEPENDENCIAS:
%       Se requiere tener instalado FFMPEG en el sistema y que la ruta al ejecutable 
%       'ffmpeg.exe' coincida con la variable 'ruta_ffprobe' definida dentro del código. 
%       Por defecto: 'C:\ffmpeg\bin'.


    [ruta_ffmpeg, ~] = get_ffmpeg_path();

    [ruta_carpeta, nombre_video, ~] = fileparts(ruta_video);
    ruta_frames = fullfile(ruta_carpeta, sprintf('frames_%s', nombre_video));
    
    % Crear carpeta para frames si no existe
    if ~exist(ruta_frames, 'dir')
        mkdir(ruta_frames);
        fprintf('📁 Carpeta creada: %s\n', ruta_frames);
    else
        % Comprobar si ya hay imagenes en la carpeta de frames
        imagenes_existentes = dir(fullfile(ruta_frames, 'frame_*.jpg'));
        if ~isempty(imagenes_existentes)
            error('⚠️ La carpeta ya existe y contiene %d imágenes.\n', length(imagenes_existentes));
        end
    end

    % String para comando por Matlab
    cmd = sprintf('"%s" -i "%s" -fps_mode passthrough -q:v 2 "%s\\frame_%%05d.jpg"', ruta_ffmpeg, ruta_video, ruta_frames);
    
    fprintf("Ejecutando FFMPEG para extraccion de frames del video:\n\t%s \n...\n",nombre_video);
    
    tic;

    % Ejecutar comando en la terminal invisible de Windows
    [estado, salida_texto] = system(cmd);   % 'estado' (0 si no fallo), 'salida_texto' tiene la respuesta cruda
    
    % Si FFMPEG correcto
    if estado == 0
            toc_t = toc;    % tiempo que se tarda en extraer array de tiempos por frame      
            fprintf('\nFinalizado en: %.3f s\n', toc_t);        
    else
        error('❌ FFMPEG falló al extraer los frames:\n%s', salida_texto);
    end

end
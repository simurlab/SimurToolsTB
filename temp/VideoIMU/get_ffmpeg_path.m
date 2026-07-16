function [ffmpeg_path, ffprobe_path] = get_ffmpeg_path()
% GET_FFMPEG_PATH busca los ejecutables de FFMPEG en el sistema de forma multiplataforma
%
% OUTPUT:
%   ffmpeg_path  - Ruta completa al ejecutable ffmpeg
%   ffprobe_path - Ruta completa al ejecutable ffprobe
%
% Busca en rutas típicas según el sistema operativo:
%   Windows: C:\ffmpeg\bin, Program Files, PATH
%   macOS:   /usr/local/bin, /opt/homebrew/bin
%   Linux:   /usr/bin, /usr/local/bin

    ffmpeg_path = '';
    ffprobe_path = '';

    % Detectar sistema operativo
    if ispc
        ext = '.exe';
        paths_to_check = {
            'C:\ffmpeg\bin', ...
            'C:\Program Files\ffmpeg\bin', ...
            'C:\Program Files (x86)\ffmpeg\bin'
        };
    elseif ismac
        ext = '';
        paths_to_check = {
            '/usr/local/bin', ...
            '/opt/homebrew/bin'
        };
    else % Linux
        ext = '';
        paths_to_check = {
            '/usr/bin', ...
            '/usr/local/bin'
        };
    end

    % Intentar encontrar ffmpeg en rutas conocidas
    for i = 1:length(paths_to_check)
        ffmpeg_candidate = fullfile(paths_to_check{i}, ['ffmpeg' ext]);
        ffprobe_candidate = fullfile(paths_to_check{i}, ['ffprobe' ext]);

        if isfile(ffmpeg_candidate)
            ffmpeg_path = ffmpeg_candidate;
            ffprobe_path = ffprobe_candidate;
            return;
        end
    end

    % Si no se encontró, intentar usar 'which' (en sistemas Unix-like)
    if ~ispc
        [status, result] = system('which ffmpeg');
        if status == 0
            ffmpeg_path = strtrim(result);
            [status, result] = system('which ffprobe');
            if status == 0
                ffprobe_path = strtrim(result);
            end
            return;
        end
    end

    % Si aún no se encontró, lanzar error
    if isempty(ffmpeg_path)
        error(['❌ No se encontró FFMPEG instalado en el sistema.\n' ...
               'Por favor, instale FFMPEG:\n' ...
               '   Windows: https://www.gyan.dev/ffmpeg/builds/\n' ...
               '   macOS: brew install ffmpeg\n' ...
               '   Linux: sudo apt-get install ffmpeg']);
    end
end

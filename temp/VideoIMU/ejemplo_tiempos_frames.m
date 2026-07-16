%% Ejemplo de comprobación de tiempos de cada frame de un video Dynathlon
%clear; close; clc
% Carpeta donde esta el video y el .csv del IMU (Carpeta extraida del .dth de Dynathlon App )
FOLDER_PATH = "C:\Users\sayet\Desktop\SaltoVallas_Test\data\l_03 20260702 - Las Mestas Vallas\";


nvidfile = 1; % Si hay mas de un .mp4, coger el n-esimo encontrado

% Opcional (uso de ffprobe por comando)
FFPROBE = true;         % Usar ffprobe.exe

N_DECIMALES = 3;    % Redondear a unidades de ms

% Lectura tiempos de video por cada frame
fileMP4 = dir(fullfile(FOLDER_PATH, '*.mp4'));
ruta_video   = fullfile(fileMP4(nvidfile).folder, fileMP4(nvidfile).name);  % Si hay más de un video en la carpeta, se toma el n-esimo

t_video = extraer_tiempos_frames(ruta_video,FFPROBE);

% Redondear tiempos de frames de video al las unidades de ms
%t_video = round(t_video,6);     % Redondeo a us

dt = round(diff(t_video),N_DECIMALES); % Redondeo a unidades de ms
u_val = unique(dt); % valores unicos
n_uval=groupcounts(dt); % repeticion de valores unicos

dt_medio = mean(dt);

% Mostrar diff valores
fprintf('\nTiempo medio entre frames: %f ms\n',dt_medio*1000);

Tt = array2table([u_val n_uval],'VariableNames',{'Valores unicos de diff','Repeticiones'});
disp(Tt)


figure('Name', 'Revisión tiempos en video');
sgtitle(sprintf(" Video: %s", fileMP4(nvidfile).name), 'Interpreter', 'none')
ax1 = subplot(3,1,1); hold on;
plot(t_video, '.'); plot(t_video);
xlabel("Frame"); ylabel("T_frame [s]",'Interpreter','none');

ax2 = subplot(3,1,2)
plot(dt)
xlabel("Frame"); ylabel("diff(T_frame) [s]",'Interpreter','none')

ax3 = subplot(3,1,3)
plot(1./(dt))
xlabel("Frame"); ylabel("1/diff(T_frame) [Hz]",'Interpreter','none')

linkaxes([ax1 ax2 ax3],'x')

% Conteo de saltos de tiempo y frequencia con la que se producen
figure('Name', 'Saltos de Tiempo en video');
s = swarmchart(ones(size(dt)), dt, 15, 'filled','MarkerEdgeColor','k');
xticks([]); box off; 

ylabel('\Delta t entre frames [ms]');
title('Ocurrencia de saltos de tiempo');



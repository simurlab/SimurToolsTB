%% Ejemplo de VideoIMUPlayer con 1 video y 1 IMU

% NOTA: Se necesita haber creado una subcarpeta en la ubicacion del Video con los
% frames en forma de .jpg: 
    % crear_FramesFolder(ruta_video);

% Se necesita el .mat en formato IMUstd con los datos de los sensor/es
% Si se tiene datos de Dynathlon, guardar datos imu con:
    % ruta_carpeta_dynathlon = "./data/experiment_001";
    % d = Dynathlon('ruta_carpeta', ruta_carpeta_dynathlon, 'save', 'y');


ruta_video = ".\data\k_experiment_02/video_20260702_120246.mp4";
db_file = ".\data\experiment_20260416_113857\DynathlonIMUs_260714.mat"; %.mat con datos IMU
id_sensor = "MD"; % Nombre del sensor
seniales2plot = ["Gyr_X","Gyr_Y","Gyr_Z","Acc_Mod"];

p = VideoIMUPlayer(ruta_video, db_file, id_sensor, seniales2plot);
    % Para desplazarse por IMU/Video, activar cualquier gráfica marcando la
    % lupa o el simbolo desplazamiento.

%p.plotSyncError();


%% Ejemplo con directos de Dynathlon
% ruta_DynathlonData = "C:\Users\sayet\Downloads\Telegram Desktop\experiment_20260416_113857";
% 
% % Localizar video
% fileMP4 = dir(fullfile(ruta_DynathlonData, '*.mp4'));
% if numel(fileMP4) > 1, error("Debe haber un único video en: \n\t %s",ruta_DynathlonData); end
% if numel(fileMP4) < 1, error("Video no encontrado en: \n\t %s",ruta_DynathlonData); end
% 
% rutaCompletaMP4 = string(fullfile(fileMP4.folder, fileMP4.name));   % *** input con ruta para VideoIMUPlayer debe ser STRING 
% 
% %crear_FramesFolder(rutaCompletaMP4);
% 
% % Localizar .mat
% fileMAT = dir(fullfile(ruta_DynathlonData, '*.mat'));
% if numel(fileMAT) > 1, error("Debe haber un único .mat en: \n\t %s",ruta_DynathlonData); end
% if numel(fileMAT) < 1
%     disp('.mat no encontrado, creando ...')
%     d = Dynathlon('ruta_carpeta', ruta_DynathlonData, 'save', 'y', 'actividad', 'Vallas', 'freq', 120);
%     fileMAT = dir(fullfile(ruta_DynathlonData, '*.mat'));
% end
% 
% db_file = fullfile(fileMAT.folder, fileMAT.name);
% 
% % Nombre del sensor
% id_sensor = "MD";                                                   % *** Debe ser STRING
% 
% % Señales a mostrar:
% %seniales2plot = ["Gyr_X","Gyr_Y","Gyr_Z","Acc_Mod"];
% %p = VideoIMUPlayer(rutaCompletaMP4, db_file, id_sensor, seniales2plot);
% p = VideoIMUPlayer(rutaCompletaMP4, db_file, id_sensor);
% 
% p.plotSyncError();
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

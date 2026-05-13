%% Cargamos los datos en el formato IMU std.
% VALLAS LAS MESTAS. g01.mat.
path_dataset = './g01.mat';
segment_body = 'COG';
[dataset_vallas_las_mestas_cog_acc, dataset_vallas_las_mestas_cog_gyro] = carga_IMUstd(path_dataset, segment_body);

%% Una primera visualización de los datos
figure,

subplot(211),
plot(dataset_vallas_las_mestas_cog_acc), 
xlabel('Muestra [-]'),
ylabel('Acc [m/s^2]'), 
title('Acelerómetro'), 

subplot(212),
plot(dataset_vallas_las_mestas_cog_gyro), 
xlabel('Muestra [-]'), 
ylabel('Gyro [º/s]'), 
title('Giroscopio')

%% Planteamos autoencoder + KNN en cuello de botella para el descubrimiento de patrones de actividad

fs = 120;
winSec = 10;
k = 4;

[idx_kmeans, labelsTS, features, autoenc] = ...
    autoencoderClusteringPipeline( ...
        dataset_vallas_las_mestas_cog_acc, ...
        dataset_vallas_las_mestas_cog_gyro, ...
        fs, winSec, k);


% %% Matrix Profile (MP)
% X = [dataset_vallas_las_mestas_cog_acc, dataset_vallas_las_mestas_cog_gyro];
% fs = 120;
% m = fs * 10; % ventana de 10 s
% [MP, MPI] = matrixProfile(X(:,1), m);  % usar Ax por ejemplo
% 
% plot(MP);
% title("Matrix Profile");


%% Feature extraction + clustering clásico
fs = 120;
winSec = 10;
k = 4;

[idx, labelsTS, F] = extractFeaturesAndCluster( ...
    dataset_vallas_las_mestas_cog_acc, ...
    dataset_vallas_las_mestas_cog_gyro, ...
    fs, winSec, k);

X = [dataset_vallas_las_mestas_cog_acc, dataset_vallas_las_mestas_cog_gyro];
plotSignalsWithColorBands(X, labelsTS, fs);

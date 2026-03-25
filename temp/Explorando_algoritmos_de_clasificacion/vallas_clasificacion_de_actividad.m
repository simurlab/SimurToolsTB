%% Cargamos los datos en el formato IMU std.
path_dataset = '/Users/alejandro/git/simurlab/SimurToolsTB/datos/g01.mat';
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
%% ================================
% PARAMETROS DEL PROCESAMIENTO
% ================================
fs = 120;              % Frecuencia de muestreo (Hz)
win = fs * 10;         % Ventana de 10 segundos = 1200 muestras
hop = win / 2;         % Solapamiento

%% ================================
% 1. CARGA Y CONCATENACIÓN DE SEÑALES
% ================================
% Suponemos:
% Acc = [Ax Ay Az]  (Nx3)
% Gyr = [Gx Gy Gz]  (Nx3)

X = [dataset_vallas_las_mestas_cog_acc dataset_vallas_las_mestas_cog_gyro];   % Nx6


%% ================================
% 2. SEGMENTACIÓN EN VENTANAS
% ================================
N = size(X,1);
windows = {};

i = 1;
while i + win - 1 <= N
    segment = X(i : i+win-1, :);   % (win x 6)
    windows{end+1} = segment;
    i = i + hop;
end

numWindows = numel(windows);
fprintf("Ventanas generadas: %d\n", numWindows);


%% ================================
% 3. APLANAR CADA VENTANA EN UN VECTOR
% ================================
Xwin = zeros(numWindows, win*6);

for k = 1:numWindows
    w = windows{k};        % (win x 6)
    Xwin(k,:) = w(:)';     % 1 x (win*6)
end


%% ================================
% 4. NORMALIZACIÓN
% ================================
[Xnorm, ps] = mapminmax(Xwin', 0, 1);
Xnorm = Xnorm';    % vuelve a (numWindows x features)


%% ================================
% 5. AUTOENCODER NO SUPERVISADO
% ================================
hiddenSize = 20;

autoenc = trainAutoencoder( Xnorm', hiddenSize, ...
    'MaxEpochs', 100, ...
    'L2WeightRegularization', 0.0005, ...
    'SparsityRegularization', 3, ...
    'SparsityProportion', 0.1, ...
    'ShowProgressWindow', false);

fprintf("Autoencoder entrenado.\n");


%% ================================
% 6. EXTRAER EMBEDDINGS (CUELLO DE BOTELLA)
% ================================
features = encode(autoenc, Xnorm');
features = features';   % (numWindows x hiddenSize)


%% ================================
% 7. CLUSTERING NO SUPERVISADO
% ================================
% OPCIÓN A: K-means
k = 4;   % número de actividades latentes
[idx_kmeans, C] = kmeans(features, k, 'Replicates', 10);

fprintf("Clustering completado.\n");


%% ================================
% 8. VISUALIZACIÓN 2D (TSNE)
% ================================
Y2 = tsne(features);   % proyección 2D

figure;
gscatter(Y2(:,1), Y2(:,2), idx_kmeans);
title("Clusters detectados (K-means)");
xlabel("Dim 1"); ylabel("Dim 2");


%% ================================
% 9. ASIGNAR CLÚSTERES A LA SERIE TEMPORAL ORIGINAL
% ================================
labelsTS = zeros(N,1);

i = 1;
for k = 1:numWindows
    labelsTS(i : i+win-1) = idx_kmeans(k);  % o idx_db(k)
    i = i + hop;
end

fprintf("Etiquetas temporales reconstruidas.\n");


%%
plotSignalsWithColorBands(X, labelsTS, fs);
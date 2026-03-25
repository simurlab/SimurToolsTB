function [idx_kmeans, labelsTS, features, autoenc] = ...
    autoencoderClusteringPipeline(Acc, Gyr, fs, winSec, k)
% ================================================================
% AUTOENCODER + K-MEANS PIPELINE PARA 'DESCUBRIR' DE ACTIVIDADES
% ================================================================
% Acc  : matriz Nx3 (Acelerómetro)
% Gyr  : matriz Nx3 (Giroscopio)
% fs   : frecuencia de muestreo (Hz)
% winSec : duración de ventana (segundos)
% k    : nº de clusters para K-means
%
% Salidas:
%  - idx_kmeans : etiquetas de clusters por ventana
%  - labelsTS   : etiquetas reconstruidas por muestra
%  - features   : embeddings del cuello de botella
%  - autoenc    : autoencoder entrenado
%
% ================================================================

%% -------------------------------
% 1. Concatenación
% -------------------------------
X = [Acc, Gyr];
N = size(X,1);

%% -------------------------------
% 2. Ventanas
% -------------------------------
win = fs * winSec;
hop = floor(win / 2);

windows = {};
i = 1;
while i + win - 1 <= N
    windows{end+1} = X(i:i+win-1, :);
    i = i + hop;
end
numWindows = numel(windows);
fprintf("Ventanas generadas: %d\n", numWindows);

%% -------------------------------
% 3. Flatten de ventanas
% -------------------------------
Xwin = zeros(numWindows, win*6);
for k2 = 1:numWindows
    Xwin(k2,:) = windows{k2}(:)';
end

%% -------------------------------
% 4. Normalización
% -------------------------------
[Xnorm, ps] = mapminmax(Xwin', 0, 1);
Xnorm = Xnorm';

%% -------------------------------
% 5. Autoencoder
% -------------------------------
hiddenSize = 20;

autoenc = trainAutoencoder(Xnorm', hiddenSize, ...
    'MaxEpochs', 100, ...
    'L2WeightRegularization', 0.0005, ...
    'SparsityRegularization', 3, ...
    'SparsityProportion', 0.1, ...
    'ShowProgressWindow', false);

fprintf("Autoencoder entrenado.\n");

%% -------------------------------
% 6. Features del bottleneck
% -------------------------------
features = encode(autoenc, Xnorm');
features = features';

%% -------------------------------
% 7. Clustering
% -------------------------------
[idx_kmeans, C] = kmeans(features, k, 'Replicates', 10);
fprintf("Clustering completado.\n");

%% -------------------------------
% 8. Reconstruir etiquetas temporales
% -------------------------------
labelsTS = zeros(N,1);
i = 1;
for k2 = 1:numWindows
    labelsTS(i:i+win-1) = idx_kmeans(k2);
    i = i + hop;
end
fprintf("Etiquetas temporales reconstruidas.\n");

%% -------------------------------
% 9. Visualización opcional
% -------------------------------
plotSignalsWithColorBandsAndFeatures(X, labelsTS, fs, features);

end
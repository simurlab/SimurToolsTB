function [idx, labelsTS, F] = extractFeaturesAndCluster(Acc, Gyr, fs, winSec, k)
% ================================================================
% Aprendizaje NO supervisado mediante:
%   - Ventaneo
%   - Extracción de features estadísticas simples
%   - Clustering vía K-means
%
% Entradas:
%   Acc: Nx3
%   Gyr: Nx3
%   fs: frecuencia de muestreo
%   winSec: tamaño ventana en segundos
%   k: nº de clusters
%
% Salidas:
%   idx: etiquetas por ventana
%   labelsTS: etiquetas por muestra (reproyectadas)
%   F: matriz de features (numWindows x numFeatures)
% ================================================================

%% -------------------------------------
% 1. Concatenar señales IMU
%% -------------------------------------
X = [Acc Gyr];
N = size(X,1);

%% -------------------------------------
% 2. Ventaneo
%% -------------------------------------
win = fs * winSec;
hop = win / 2;

windows = {};
i = 1;
while i + win - 1 <= N
    windows{end+1} = X(i:i+win-1,:);
    i = i + hop;
end

numWindows = numel(windows);
fprintf("Ventanas: %d\n", numWindows);

%% -------------------------------------
% 3. Extracción de features
%% -------------------------------------
F = [];
for w = 1:numWindows
    seg = windows{w};
    
    % Separar sensores
    Acc_w = seg(:,1:3);
    Gyr_w = seg(:,4:6);
    
    % Magnitud
    magAcc = sqrt(sum(Acc_w.^2,2));
    magGyr = sqrt(sum(Gyr_w.^2,2));

    % Features temporales
    feat_rms   = rms(seg);         % 1x6
    feat_var   = var(seg);         % 1x6
    feat_mean  = mean(seg);        % 1x6
    feat_max   = max(seg);         % 1x6
    feat_min   = min(seg);         % 1x6
    feat_range = feat_max - feat_min;

    % Magnitud
    feat_mag = [rms(magAcc) var(magAcc) rms(magGyr) var(magGyr)];

    % Entropía magnitud
    p = histcounts(magAcc, 30, 'Normalization','probability');
    p(p==0)=[]; 
    ent_mag = -sum(p.*log2(p));

    % FFT barata
    Y = abs(fft(seg));
    energyFFT = sum(Y(2:10,:));    % primera banda (muy barata)
    
    % Unir todas
    f = [feat_rms, feat_var, feat_mean, feat_range, feat_mag, ent_mag, energyFFT];
    F = [F; f];
end

fprintf("Features extraídas: %d por ventana\n", size(F,2));

%% -------------------------------------
% 4. Normalización (opcional)
%% -------------------------------------
F = normalize(F);

%% -------------------------------------
% 5. Clustering K-means
%% -------------------------------------
idx = kmeans(F, k, 'Replicates',10);

%% -------------------------------------
% 6. Reconstrucción temporal de etiquetas
%% -------------------------------------
labelsTS = zeros(N,1);
i = 1;
for w = 1:numWindows
    labelsTS(i:i+win-1) = idx(w);
    i = i + hop;
end

end
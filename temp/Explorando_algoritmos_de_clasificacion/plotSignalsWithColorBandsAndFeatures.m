function plotSignalsWithColorBandsAndFeatures(X, labelsTS, fs, features)
% ============================================================
% Visualiza:
%   1) Señales crudas con bandas de cluster
%   2) Features del cuello de botella del autoencoder
% ============================================================

[N, numSignals] = size(X);
t = (0:N-1) / fs;

uniqueClusters = unique(labelsTS);
uniqueClusters(uniqueClusters < 0) = [];   % evita ruido de DBSCAN
K = numel(uniqueClusters);
colors = lines(K);

signalNames = {'Ax','Ay','Az','Gx','Gy','Gz'};

%% ============================================================
% 1) PLOTEO DE SEÑALES + BANDAS
% ============================================================
figure('Name','Señales crudas con bandas de actividad');

clusterBounds = cell(K,1);
for c = 1:K
    lbl = uniqueClusters(c);
    mask = (labelsTS == lbl);
    d = diff([false; mask; false]);
    startIdx = find(d==1);
    endIdx   = find(d==-1) - 1;
    clusterBounds{c} = [startIdx, endIdx];
end

for s = 1:numSignals
    subplot(numSignals,1,s); hold on;
    yl = [min(X(:,s)) max(X(:,s))];

    for c = 1:K
        bounds = clusterBounds{c};
        col = colors(c,:);
        for b = 1:size(bounds,1)
            xi = t(bounds(b,1));
            xf = t(bounds(b,2));
            patch([xi xf xf xi], [yl(1) yl(1) yl(2) yl(2)], col, ...
                  'FaceAlpha', 0.15, 'EdgeColor', 'none');
        end
    end

    plot(t, X(:,s), 'k', 'LineWidth', 1);
    ylabel(signalNames{s});
    if s == 1
        title('Acelerómetro + Giroscopio con bandas por clúster');
    end
end
xlabel('Tiempo (s)');


%% AÑADIR LEYENDA
hold on;
legendHandles = zeros(K,1);
for c = 1:K
    legendHandles(c) = plot(nan, nan, 's', ...
        'MarkerFaceColor', colors(c,:), ...
        'MarkerEdgeColor', colors(c,:), ...
        'MarkerSize', 8);
end
legend(legendHandles, ...
    arrayfun(@(x) sprintf('Cluster %d', x), uniqueClusters, 'UniformOutput', false));


%% ============================================================
% 2) PLOTEO DE FEATURES LATENTES DEL AUTOENCODER
% ============================================================
[numWindows, hiddenSize] = size(features);
fwindows = 1:numWindows;   % eje de ventanas

figure('Name','Features latentes del cuello de botella');
for f = 1:hiddenSize
    subplot(hiddenSize, 1, f); hold on;
    plot(fwindows, features(:,f), 'k', 'LineWidth', 1);
    ylabel(sprintf('F%d', f));

    % Añadir bandas de color por cluster (a nivel de ventana)
    for c = 1:K
        mask = (labelsTS == uniqueClusters(c));

        % Convertimos labelsTS a etiquetas por ventana
        % Para ello hacemos voting cada win/2 posiciones:
        windowLabels = zeros(numWindows,1);
        win = floor(N / numWindows);
        for w = 1:numWindows
            startIdx = (w-1)*win + 1;
            endIdx   = w*win;
            windowLabels(w) = mode(labelsTS(startIdx:endIdx));
        end

        idx = (windowLabels == uniqueClusters(c));
        d = diff([false; idx; false]);
        startW = find(d==1);
        endW   = find(d==-1) - 1;

        col = colors(c,:);
        yl = ylim;
        for b = 1:length(startW)
            xi = startW(b);
            xf = endW(b);
            patch([xi xf xf xi], [yl(1) yl(1) yl(2) yl(2)], col, ...
                'FaceAlpha', 0.15, 'EdgeColor','none');
        end
    end

    if f == 1
        title('Características latentes del autoencoder');
    end
    if f == hiddenSize
        xlabel('Ventana');
    end
end

end
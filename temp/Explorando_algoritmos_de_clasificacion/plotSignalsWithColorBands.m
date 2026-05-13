function plotSignalsWithColorBands(X, labelsTS, fs, features)
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

end
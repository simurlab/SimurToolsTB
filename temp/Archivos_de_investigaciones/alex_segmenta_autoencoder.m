%% 0. Semilla fija para reproducibilidad
rng(42);
 
% %% 1. Generar la señal escalonada
% t = 0:0.1:40; % Tiempo
% signal = zeros(size(t));
% 
% step_times = [0, 12, 22, 31];
% step_values = [82, 80, 77, 75];
% 
% for i = 1:length(step_times)
%     signal(t >= step_times(i)) = step_values(i);
% end
% 
% %% 2. Añadir ruido moderado
% mu = 0; 
% sigma = 1; % Ruido moderado
% random_number = normrnd(mu, sigma, 1, length(signal));
% random_integer = round(random_number);
% signal_noisy = signal + random_integer;



lostcs=cellfun(@length, cachoOrigen);

signal_noisy= lostcs;

t=1:length(lostcs);

%% 3. Suavizar la señal para reducir ruido pero mantener transiciones
window_smooth = 5;
signal_smooth = movmean(signal_noisy, window_smooth);

%% 4. Dividir la señal suavizada en ventanas sin solapamiento
window_size = 20; % 2 segundos
num_windows = floor(length(signal_smooth)/window_size);

data = zeros(window_size, num_windows);
time_windows = zeros(window_size, num_windows);

for i = 1:num_windows
    idx_start = (i-1)*window_size + 1;
    idx_end = i*window_size;
    data(:, i) = signal_smooth(idx_start : idx_end);
    time_windows(:, i) = t(idx_start : idx_end);
end

%% 5. Entrenar el autoencoder con más dimensiones latentes
hiddenSize = 5;

autoenc = trainAutoencoder(data, hiddenSize, ...
    'MaxEpochs', 300, ...
    'L2WeightRegularization', 0.0005, ...
    'SparsityRegularization', 2, ...
    'SparsityProportion', 0.05, ...
    'ScaleData', true);

%% 6. Obtener características latentes
features = encode(autoenc, data);

%% 7. Calcular índice de silueta para diferentes k y elegir k óptimo
max_k = 5;
silh_avg = zeros(max_k,1);

for k = 2:max_k
    idx_k = kmeans(features', k, 'Replicates', 20);
    silh_vals = silhouette(features', idx_k);
    silh_avg(k) = mean(silh_vals);
end

% figure;
% plot(2:max_k, silh_avg(2:end), '-o');
% xlabel('Número de clusters (k)');
% ylabel('Silhouette promedio');
% title('Selección automática de k con índice de silueta');
% grid on;

% Elegir el k que maximiza el índice de silueta
[~, k_opt] = max(silh_avg);
fprintf('Número óptimo de clusters detectado: %d\n', k_opt);

%% 8. Clustering final con k_opt
[idx, ~] = kmeans(features', k_opt, 'Replicates', 20);

%% 9. Visualizar segmentación (sobre señal original) con etiquetas de cluster y líneas de separación
colors = lines(k_opt);
figure; hold on; grid on

for i = 1:num_windows
    % Índices del tiempo original para la ventana actual
    idx_start = (i-1)*window_size + 1;
    idx_end = i*window_size;
    
    % Señal original segmentada (sin suavizar)
    segment_signal = signal_noisy(idx_start:idx_end);
    segment_time = t(idx_start:idx_end);
    
    % Graficar el segmento con color según su cluster
    plot(segment_time, segment_signal, 'Color', colors(idx(i), :), 'LineWidth', 2);
    
    % Etiqueta del cluster en el centro del segmento
    x_text = mean(segment_time);
    y_text = mean(segment_signal);
    text(x_text, y_text, sprintf('C%d', idx(i)), ...
         'Color', colors(idx(i), :), 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% Líneas de separación entre clusters diferentes
for i = 1:num_windows-1
    if idx(i) ~= idx(i+1)
        x_sep = t(i * window_size); % Tiempo donde termina una ventana y empieza otra
        yl = ylim;
        plot([x_sep x_sep], yl, 'k--', 'LineWidth', 1.5);
    end
end

xlabel('Tiempo (s)');
ylabel('Amplitud');
title(sprintf('Segmentación por clusters (k = %d) sobre señal original', k_opt));
hold off;


% %% 10. Visualizar datos en espacio latente con clusters
% dims = size(features, 1);
% 
% figure; hold on; grid on;
% colors = lines(k_opt);
% 
% if dims >= 3
%     % 3D plot con primeras 3 dimensiones latentes
%     for c = 1:k_opt
%         scatter3(features(1, idx == c), features(2, idx == c), features(3, idx == c), ...
%             50, colors(c,:), 'filled');
%     end
%     xlabel('Latente 1');
%     ylabel('Latente 2');
%     zlabel('Latente 3');
%     title('Datos en espacio latente (3D) con clusters');
% else
%     % 2D plot
%     for c = 1:k_opt
%         scatter(features(1, idx == c), features(2, idx == c), ...
%             50, colors(c,:), 'filled');
%     end
%     xlabel('Latente 1');
%     ylabel('Latente 2');
%     title('Datos en espacio latente (2D) con clusters');
% end
% 
% legend(arrayfun(@(x) sprintf('Cluster %d', x), 1:k_opt, 'UniformOutput', false));
% hold off;

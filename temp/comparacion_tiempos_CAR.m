%% Tiempos Paula Blanquer
t1_teorico_Paula= [ 1.125, 1.123, 1.114, 1.116, 1.118];

t2_teorico_Paula=[1.161, 1.108, 1.091, 1.103, 1.111];

t3_teorico_Paula=[1.149, 1.104, 1.097, 1.096, 1.118];

%--
t1_IMU_COG_Paula=[1.1000, 1.1167, 1.1000, 1.1083, 1.1083];

t2_IMU_COG_Paula=[1.1083, 1.0833, 1.1083, 1.1083, 1.0917];

t3_IMU_COG_Paula=[1.0917, 1.1167, 1.1167, 1.1083, 1.1417];

t4_IMU_COG_Paula=[1.1000, 1.0917, 1.1083, 1.0833, 1.1000];


%% Tiempos Daniel Cisneros
t1_teorico_DanielC= [1.117, 1.078, 1.084, 1.121, 1.128];

t2_teorico_DanielC= [1.101, 1.116, 1.120, 1.105, 1.113];

t3_teorico_DanielC= [1.092, 1.083, 1.079, 1.091, 1.097];

%--
t1_IMU_COG_DanielC=[1.1083, 1.0917, 1.0750, 1.1250, 1.1000];

t2_IMU_COG_DanielC=[1.1000, 1.1167, 1.1000, 1.1083, 1.1083];


%% estadísticos
datos_tiempos=[t1_teorico_Paula; t2_teorico_Paula; t3_teorico_Paula;
    t1_IMU_COG_Paula; t2_IMU_COG_Paula; t3_IMU_COG_Paula; t4_IMU_COG_Paula;
    t1_teorico_DanielC; t2_teorico_DanielC; t3_teorico_DanielC; t1_IMU_COG_DanielC;
    t2_IMU_COG_DanielC];

% R_pearson = corrcoef(datos_tiempos)  % Para vectores fila
% R_spearman = corr(datos_tiempos, 'Type', 'Spearman')
% 
% 
% % Transponer para que cada vector sea una columna
% R = corrcoef(datos_tiempos');     % salida: matriz de correlación n x n
% 
% % Visualizar
% heatmap(R, 'ColorLimits', [-1 1], 'Colormap', parula);
% title('Correlación de Pearson');


% Calcular matriz de correlación de Spearman
R_spearman = corr(datos_tiempos', 'Type', 'Spearman');

% Definir etiquetas personalizadas
labels = [
    "t1 teorico Paula";
    "t2 teorico Paula";
    "t3 teorico Paula";
    "t1 IMU COG Paula";
    "t2 IMU COG Paula";
    "t3 IMU COG Paula";
    "t4 IMU COG Paula";
    "t1 teorico DanielC";
    "t2 teorico DanielC";
    "t3 teorico DanielC";
    "t1 IMU COG DanielC";
    "t2 IMU COG DanielC"
];

% Visualizar como heatmap
clf; hold off;
heatmap(labels, labels, R_spearman, ...
    'ColorLimits', [-1 1], ...
    'Colormap', parula);
title('Correlación de Spearman (Tendencia)');


% El numero de intervalos a estudiar:
num_intervalos=size(Intervalos,1);
freq=120;
tabla_total = table();  % Tabla vacía inicial
for i=1:num_intervalos
    % Convertir los límites de los intervalos a enteros
    inicio=int32(Intervalos(i,1)); % Las muestras de intervalos ya están expresadas en miles, IMPORTANTE!!!
    final=int32(Intervalos(i,2));  % Las muestras de intervalos ya están expresadas en miles, IMPORTANTE!!!
    
    % Selección del signo del gyro medio_lateral, anteroposterior y vertical:
    gyroml=-g_cal(inicio:final,3);  % en el talon, D (-), SIGN!!!
    gyroant=g_cal(inicio:final,1);
    gyrvert=g_cal(inicio:final,2);
    
    % Selección del signo del acelerómetro medio_lateral, anteroposterior y vertical:
    accml=-a_cal(inicio:final,3);
    accant=a_cal(inicio:final,1);
    accvert=a_cal(inicio:final,2);
    
    % ***********************************************************************
    % ********** DETECCIÓN Y ELIMINACIÓN DE VALORES NAN DE gyroml ***********
    % En el vector informacion_NaN almacenamos:
    % - El número de valores NaN detectados en el giroscopio
    % mediolateral (variable cantidad_NaN_gyroml).
    % - Los índices asociados a cada valor NaN
    % (variable indices_NaN_gyroml).
    indices_NaN_gyroml = find(isnan(gyroml));                                 % Encontrar índices de NaN en gyroml
    cantidad_NaN_gyroml = length(indices_NaN_gyroml);                         % Contar NaN
    informacion_NaN_gyroml = [cantidad_NaN_gyroml, indices_NaN_gyroml];       % Almacenar información
    gyroml = gyroml(~isnan(gyroml));                                          % Eliminación de todos los valores NaN
    
    % ***********************************************************************
    % ********** DETECCIÓN Y ELIMINACIÓN DE VALORES NAN DE gyroant ***********
    % En el vector informacion_NaN almacenamos:
    % - El número de valores NaN detectados en el giroscopio
    % anteroposterior (variable cantidad_NaN_gyroant).
    % - Los índices asociados a cada valor NaN
    % (variable indices_NaN_gyroant).
    indices_NaN_gyroant = find(isnan(gyroant));                               % Encontrar índices de NaN en gyroant
    cantidad_NaN_gyroant = length(indices_NaN_gyroant);                       % Contar NaN
    informacion_NaN_gyroant = [cantidad_NaN_gyroant, indices_NaN_gyroant];    % Almacenar información
    gyroant = gyroant(~isnan(gyroant));                                       % Eliminación de todos los valores NaN
    
    % ***********************************************************************
    % Filtrar el giroscopio anteroposterior
    orden=5;                                                                  % Orden del filtro
    corte=5/freq;                                                             % Frecuencia de corte
    gyroant_fil=filtro0(gyroant,orden,corte);                                 % Aplicar filtro
    
    % Filtro y detección (requiere la TB de SP de Matlab):
    th=150;                                                                   % Umbral para detección de eventos
    [IC, FC, MaxS, MinS, MVP, MP]=eventospie_carrera(gyroml,th,freq,gyroant); % Detectar eventos
    [z1,z2,z3,vz1, vz2, vz3, eventos]=test(gyroml, Intervalos(i,:), i,gyroant);       % Realizar pruebas y obtener eventos
    tabla_total = [tabla_total; eventos];                                     % Acumulación de eventos en la tabla total
    zonas(i,1)=z1;                                                            % Almacenar resultados en zonas
    zonas(i,2)=z2;
    zonas(i,3)=z3;
    zonas(i,4)=mean(vz3);                                                     % Calcular media
    zonas(i,5)=std(vz3);                                                      % Calcular desviación estándar
    % sum(zonas(:,3))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
% Mostrar tabla en ventana emergente
f = figure('Name', sprintf('Experimento  %s', identificador), ...
           'NumberTitle', 'off', ...
           'Position', [100 100 600 300]);
uitable(f, 'Data', table2cell(tabla_total), ...
           'ColumnName', tabla_total.Properties.VariableNames, ...
           'Units', 'Normalized', ...
           'Position', [0 0 1 1]);

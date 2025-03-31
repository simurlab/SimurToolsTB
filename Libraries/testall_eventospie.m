%% testall_eventospie
%
% Utilidad para testear la función de detección de eventos en el pie
% en un experimento previamente cargado con carga_calibra
%
% Supone que en la memoria principal está:
% - IMU : los originales datos del IMU
% - gyrML : los datos del giro calibrados
% - acc2 :  los datos de los accs calibrados
% - Intervalos: la selección de muestras que interesa analizar
% - txt0: ID del expe.
% - txt1: localización del IMU (D/I/S)
% - txt2: colocación del IMU( E/L/T)
%

%function testall_eventospie(Intervalos,ID)

%function testall_eventospie(ID)

% global gyrML;
% global num_intervalos;
% global Intervalos;
% global freq;


% if (nargin==0)
%     prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
%     txt_visualiza = input(prompt,"s");
%     if isempty(txt_visualiza)
%         txt_visualiza = 'N';
%     end
% else
%     txt_visualiza=ID;
% end

prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
    txt_visualiza = input(prompt,"s");
    if isempty(txt_visualiza)
        txt_visualiza = 'N';
    end



for i=1:num_intervalos,

    inicio=int32(1000*Intervalos(i,1));
    final=int32(1000*Intervalos(i,2));
    
    % Selección del signo del gyro medio_lateral:
    gyroml=-gyrML(inicio:final,3);  % en el talon, D (-)

    % ***********************************************************************
    % ********** DETECCIÓN Y ELIMINACIÓN DE VALORES NAN DE gyroml ***********
    % En el vector informacion_NaN almacenamos:
    % - El número de valores NaN detectados en el giroscopio
    % mediolateral (variable cantidad_NaN_gyroml).
    % - Los índices asociados a cada valor NaN
    % (variable indices_NaN_gyroml).
    indices_NaN_gyroml = find(isnan(gyroml));
    cantidad_NaN_gyroml = length(indices_NaN_gyroml);
    informacion_NaN = [cantidad_NaN_gyroml, indices_NaN_gyroml];
    gyroml = gyroml(~isnan(gyroml)); % Eliminación de todos los valores NaN
    % ***********************************************************************


    % filtro y deteccion (requiere la TB de SP de Matlab):
    th=150;
    [IC,FC]=eventospie_carrera(gyroml,th,freq);

    % TC en ms:
    TC=1000*(FC-IC)/freq;

    % Definir los valores de separación en ms:
    a = round(1+(1000/freq)); % una muestra o coincidentes, en ms
    b = 80;  % menos de esos ms, caso dudoso

    % Contar los elementos en cada zona
    zona1 = sum(TC < a);        % Menores que a
    zona2 = sum(TC >= a & TC <= b);  % Entre a y b (inclusive)
    zona3 = sum(TC > b);        % Mayores que b

    vz1 = TC((TC < a));        % Menores que a
    vz2 = TC((TC >= a & TC <= b));  % Entre a y b (inclusive)
    vz3 = TC((TC > b));        % Mayores que b


    % resultados de la detección:
    zonas(i,1)=zona1; % fallos
    zonas(i,2)=zona2; % dudosas
    zonas(i,3)=zona3; % correctos
    zonas(i,4)=mean(vz3);
    zonas(i,5)=std(vz3);


    %----- FIGURAS OPCIONALES PARA DEBUGEAR---- ----------------

    if txt_visualiza == 'S'

        orden=5;
        corte=6/freq;
        gyr2fil=filtro0(gyroml,orden,corte);
        % Detecciones:

        figure
        plot(gyroml, 'LineWidth',4)
        grid
        hold on
        plot(gyr2fil, 'LineWidth',4)
        plot(IC, gyr2fil(IC), 'v', 'MarkerSize', 25, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
        plot(FC, gyr2fil(FC), '^', 'MarkerSize', 25, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
        decora4K(freq);

        annotation('textbox', [0.15, 0.8, 0.1, 0.1], ... % [x y width height]
            'String', sprintf('Ini: %.0f   Fin: %.0f', inicio, final), ...
            'FitBoxToText', 'on', ...
            'BackgroundColor', 'yellow', ...
            'FontSize', 18, 'FontWeight', 'bold', ...
            'EdgeColor', 'black');

        annotation('textbox', [0.55, 0.8, 0.1, 0.1], ... % [x y width height]
            'String', sprintf('Resultado: %d %d %d', zona1, zona2, zona3), ...
            'FitBoxToText', 'on', ...
            'BackgroundColor', 'green', ...
            'FontSize', 18, 'FontWeight', 'bold', ...
            'EdgeColor', 'black');


    end
end

% Volcado de resultados para cortar y pegar en una hoja de cálculo:
%
fprintf('%.0f \t %.0f \t %.0f \t %.1f \t %.1f \n ', zonas');
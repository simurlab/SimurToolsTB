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

prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
txt_visualiza = input(prompt,"s");
if isempty(txt_visualiza)
    txt_visualiza = 'N';
end

% Selección del signo del gyro medio_lateral en función del experimento:
%
if txt2 == 'L'   % En el lateral, para datos B1 a B6
    if txt1 == 'D'
        % JC1:(-)  JC2:(-)  B3: (+)  JC4: (-)
        sign_gyr=gyrML;
    else
        % JC1:(+)  JC2:(-)  JC3: (+) JC4: (-)
        sign_gyr=-gyrML;
    end
else
    if txt2 == 'E'
        sign_gyr=gyrML;  % En el empeine, para exps. A1-A6 (+)
    else
        sign_gyr=-gyrML;  % en el talon, D (-)
    end
end



for i=1:size(Intervalos,1)

    inicio=1000*Intervalos(i,1);
    final=1000*Intervalos(i,2);
    gyroml=sign_gyr(inicio:final,2);  % en el talon, D (-)

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


    %[z1,z2,z3,vz1, vz2, vz3]=ftest_ep(gyroml, Intervalos(i,:), freq);

    inicio=1000*Intervalos(i,1);
    final=1000*Intervalos(i,2);

    % -1 3
    gyroant=gyrML(inicio:final,1);


    % filtro y deteccion (requiere la TB de SP de Matlab):
    th=150;
    %[IC,FC]=eventospie_carrera(gyroml,th,freq);
    [IC,FC, MaxS,MinS,MVP,MP]=eventospie_carrera(gyroml,th,freq,gyroant);
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

    mat_eventos=[IC; MVP; MP; FC; MinS; MaxS];

    % resultados de la detección:
    zonas(i,1)=zona1; % fallos
    zonas(i,2)=zona2; % dudosas
    zonas(i,3)=zona3; % correctos
    zonas(i,4)=mean(vz3);
    zonas(i,5)=std(vz3);

    fase1{i}=(mat_eventos(2,:)-mat_eventos(1,:))*(1000/freq);
    fase2{i}=(mat_eventos(3,:)-mat_eventos(2,:))*(1000/freq);
    fase3{i}=(mat_eventos(4,:)-mat_eventos(3,:))*(1000/freq);
    fase4{i}=(mat_eventos(5,:)-mat_eventos(4,:))*(1000/freq);
    fase5{i}=(mat_eventos(6,:)-mat_eventos(5,:))*(1000/freq);
    fase6{i}=(mat_eventos(6,:)-mat_eventos(5,:))*(1000/freq);
    fase_support{i}=(mat_eventos(4,:)-mat_eventos(1,:))*(1000/freq);
    fase_recover{i}=(mat_eventos(6,:)-mat_eventos(4,:))*(1000/freq);




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

        figure
        subplot(141)
        plot([fase1{i}(:)]); grid; title('FS a MPV', 'FontSize', 12, 'FontWeight', 'bold');
        subplot(142)
        plot([fase2{i}(:)]);grid; title('MPV a MP', 'FontSize', 12, 'FontWeight', 'bold');
        subplot(143)
        plot([fase3{i}(:)]); grid; title('MP a TO', 'FontSize', 12, 'FontWeight', 'bold');
        subplot(144)
        plot([fase_support{i}(:)]); grid; title('Tiempo Contacto', 'FontSize', 12, 'FontWeight', 'bold');
        sgtitle('Tiempos entre eventos', 'FontSize', 16, 'FontWeight', 'bold');

        % figure
        % subplot(141)
        % plot([fase5{1}(:); fase5{2}(:); fase5{3}(:); fase5{4}(:)]); grid;
        % subplot(142)
        % plot([fase6{1}(:); fase6{2}(:); fase6{3}(:); fase6{4}(:)]);grid;
        % subplot(143)
        % plot([fase_support{1}(:); fase_support{2}(:); fase_support{3}(:); fase_support{4}(:)]); grid;
        % subplot(144)
        % plot([fase_recover{1}(:); fase_recover{2}(:); fase_recover{3}(:); fase_recover{4}(:)]); grid;
        % 
        % 
        % figure
        % subplot(121)
        % bar([fase1{1}(20:160)' fase3{1}(20:160)'],'stacked')
        % subplot(122)
        % bar([ fase_support{1}(20:160)'],'stacked')
    end
end

% Volcado de resultados para cortar y pegar en una hoja de cálculo:
%
fprintf('%.0f \t %.0f \t %.0f \t %.1f \t %.1f \n ', zonas'); 


% if txt_visualiza == 'S'
% 
%         figure
%         subplot(141)
%         plot([fase1{1}(:); fase1{2}(:); fase1{3}(:); fase1{4}(:)]); grid; title('FS a MPV', 'FontSize', 12, 'FontWeight', 'bold');
%         subplot(142)
%         plot([fase2{1}(:); fase2{2}(:); fase2{3}(:); fase2{4}(:)]);grid; title('MPV a MP', 'FontSize', 12, 'FontWeight', 'bold');
%         subplot(143)
%         plot([fase3{1}(:); fase3{2}(:); fase3{3}(:); fase3{4}(:)]); grid; title('MP a TO', 'FontSize', 12, 'FontWeight', 'bold');
%         subplot(144)
%         plot([fase4{1}(:); fase4{2}(:); fase4{3}(:); fase4{4}(:)]); grid; title('TO a MinS', 'FontSize', 12, 'FontWeight', 'bold');
%         sgtitle('Tiempos entre eventos', 'FontSize', 16, 'FontWeight', 'bold');
% 
%         figure
%         subplot(141)
%         plot([fase5{1}(:); fase5{2}(:); fase5{3}(:); fase5{4}(:)]); grid;
%         subplot(142)
%         plot([fase6{1}(:); fase6{2}(:); fase6{3}(:); fase6{4}(:)]);grid;
%         subplot(143)
%         plot([fase_support{1}(:); fase_support{2}(:); fase_support{3}(:); fase_support{4}(:)]); grid;
%         subplot(144)
%         plot([fase_recover{1}(:); fase_recover{2}(:); fase_recover{3}(:); fase_recover{4}(:)]); grid;
% 
% 
%         figure
%         subplot(121)
%         bar([fase1{1}(20:160)' fase3{1}(20:160)'],'stacked')
%         subplot(122)
%         bar([ fase_support{1}(20:160)'],'stacked')
%     end
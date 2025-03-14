%% Revisa varios intervalos

clear zonas
clear Intervalos

% --------------------------------------------------------------------------------
% Exp. 1 JC
% Intervalos=[1 36; 40 55; 55 90; 95 110; 115 140; 145 160; 165 195; 200 215; 220 255; 260 275; 280 310; 320 335; 340 365; 375 390; 395 430; 440 465];
 
% Exp. 2 JC
% Intervalos=[1 30; 34 37; 37 40; 40 44; 44 47; 47 51; 51 54; 54 57; 57 62; 62 66; 66 74; 74 76; 76 79; 79 83; 83 86; 86 90; 90 96; 96 100; 100 104; 104 106; 106 114; 114 116; 116 121; 121 125;125 133; 133 135; 135 141; 141 144; 144 147; 147 149; 149 157];

% Exp. 3 JC
% Intervalos=[1 20; 20 60; 60 72; 72 84; 84 89; 89 102; 102 108; 108 120; 120 126; 126 141; 141 147; 147 168];

% Exp. 4 JC
% Intervalos=[40 45; 45 54; 55 60; 66 67;  67 71; 71 75; 75 79; 79 89; 89 93; 93 104; 104 116; 116 132; 132 146; 146 161; 161 175; 175 190; 190 205; 205 220];
% Cachos de acel-decel:
% Intervalos=[103.5 116.5; 131.5 146.5; 160 175 ];

% Exp. 5 JC
% Intervalos=[40 45; 45 54; 55 60; 66 67;  67 71; 71 75; 75 79; 79 89; 89 93; 93 104; 104 116; 116 132; 132 146; 146 161; 161 175; 175 190; 190 205; 205 220];
% Cachos de acel-decel:
Intervalos=[28 48; 64 78; 110 125];
% el primero son de 15'' hasta 18km/h; el segundo fueron 15+15+10+... hasta
% 20km/h, y la bajada como se pudo; el tercero más standar
% --------------------------------------------------------------------------------


% --------------------------------------------------------------------------------
% Prueba para NaN, Exp.1 2022
% Intervalos = [1, 41.6]; % Obtenemos 1 NaN en la muestra 24563
% --------------------------------------------------------------------------------

% --------------------------------------------------------------------------------
% Exp. 1 2022, modificamos la variable Intervalos
% Intervalos=[5 20;       % Calentamiento, 2 [min]
%             20 27.2;    % Vel. Mín., 1 [min]
%             27.2 34.4;  % Vel. Intermedia, 1 [min]
%             34.4 41.6]; % Vel. Máx., 1 [min]

% Exp. 2 2022
% Intervalos=[1.8 3.2;    % Calentamiento, 2 [min]
%             3.2 3.9;    % Vel. Mín., 1 [min]
%             3.9 4.6;    % Vel. Intermedia, 1 [min]
%             4.6 5.3     % Vel. Máx., 1 [min]
%             ]*10;       % Número de muestras

% Exp. 3 2022
% Intervalos=[0.7 2.1;     % Calentamiento, 2 [min]
%             2.1 2.8;     % Vel. Mín., 1 [min]
%             2.8 3.5;     % Vel. Intermedia, 1 [min]
%             3.5 4.2;     % Vel. Máx., 1 [min]
%             ]*10;        % Número de muestras

% Exp. 4 2022
% Intervalos=[0.6 2.0;     % Calentamiento, 2 [min]
%             2.0 2.7;     % Vel. Mín., 1 [min]
%             2.7 3.4;     % Vel. Intermedia, 1 [min]
%             3.4 4.1;     % Vel. Máx., 1 [min]
%             ]*10;        % Número de muestras

% Exp. 5 2022
% Intervalos=[0.48 1.88;     % Calentamiento, 2 [min]
%             1.88 2.58;     % Vel. Mín., 1 [min]
%             2.58 3.28;     % Vel. Intermedia, 1 [min]
%             3.28 3.98;     % Vel. Máx., 1 [min]
%             ]*10;          % Número de muestras

% Exp. 6 2022
% Intervalos=[7 10; 10 22.2; 22.2 34.4; 34.4 46.6];
% Intervalos=[11.3 46; 50.5 61];
% --------------------------------------------------------------------------------

%inicio=1000*inifin(1);
%final=1000*inifin(2);



for i=1:size(Intervalos,1)

    inicio=1000*Intervalos(i,1);
    final=1000*Intervalos(i,2);
    
    if txt2 == 'L'   % En el lateral, para datos JC2025 
      if txt1 == 'D'
            gyroml=-gyrML(inicio:final,2);
        else 
            gyroml=-gyrML(inicio:final,2);
        end
    else   % En el empeine, para deportista 2022
        gyroml=-gyrML(inicio:final,2);
    end

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


    [z1,z2,z3,vz1, vz2, vz3]=ftest_ep(gyroml, Intervalos(i,:), freq);
    
    zonas(i,1)=z1;
    zonas(i,2)=z2;    
    zonas(i,3)=z3;
    zonas(i,4)=mean(vz3);
    zonas(i,5)=std(vz3);
end

sum(zonas(:,3))

figure
bar(zonas(:,4))

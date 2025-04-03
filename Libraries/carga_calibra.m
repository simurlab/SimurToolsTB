%% carga_calibra
%
% Utilidad para cargar y calibrar los datos de una prueba, a partir de su ID
%

function [a_cal, g_cal, Intervalos, quat_cal]=carga_calibra(IDexp,Visualiza)

% Suponemos que hay un archivo con datos matlab.mat accesible:
load;
freq=120; % por ahora...

global num_intervalos;
num_intervalos=0;

% limpiamos variables intermedias para evitar problemas:
clear zonas
clear Intervalos

 % Cuenta el número de argumentos
 numArgs = nargin;

 switch numArgs
     case 0
         prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
         txt_visualiza = input(prompt,"s");
         if isempty(txt_visualiza)
             txt_visualiza = 'N';
         end
         % Carga de los datos experimentales que se van a analizar: experimento y sensor:
         % La variable global txt0 será la ID del expe.
         %

         prompt = "Introduzca el ID del experimento correspondiente al matlab.mat (A/B + 1/2/3/4/5/6) [A1]: ";
         txt0 = input(prompt,"s");
         if isempty(txt0)
             txt0 = 'A1';
         end
     case 1
        txt0 = IDexp;
        txt_visualiza = 'N';
     case 2
          txt0 = IDexp;
          txt_visualiza = Visualiza; 
     otherwise
 end

%% PARTE DE CARGA DE DATOS, EN FUNCION DEL ID
%
%
% prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
% txt_visualiza = input(prompt,"s");
% if isempty(txt_visualiza)
%     txt_visualiza = 'N';
% end
% 
% 
% % Carga de los datos experimentales que se van a analizar: experimento y sensor:
% % La variable global txt0 será la ID del expe.
% %
% if nargin==0
%     prompt = "Introduzca el ID del experimento correspondiente al matlab.mat (A/B + 1/2/3/4/5/6) [A1]: ";
%     txt0 = input(prompt,"s");
%     if isempty(txt0)
%         txt0 = 'A1';
%     end
% else
%     txt0=IDexp;
% end


% Según su ID, cargamos variables propias de cada experimento:
% - Intervalos: muestras de estudio (en miles)
% - IntervaloEstatico: intervalo de muestras en reposo para reorientacion
% - IMU: uno de los varios IMUs utilizados en el experimento
% - Rcalib: describe la posicion inicial del sensor en coordenadas anatomicas
% - txt1: localización del IMU (Derecha/Izda/Sacro)
% - txt2: colocación del IMU(Empeine/Lateral/Talon)
% -
switch txt0
    case 'A1'
        txt1 = 'D';
        txt2 = 'E';
        IMU=datos_totales_A(1).IMU1;
        %IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[8.2 20;       % Calentamiento, 2 [min]
            20.7 27.2;    % Vel. Mín., 1 [min]
            27.9 34.4;  % Vel. Intermedia, 1 [min]
            34.4 40.5   % Vel. Máx., 1 [min]
            ];
    case 'A2'
        txt1 = 'D';
        txt2 = 'E';
        IMU=datos_totales_A(2).IMU1; %IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[20 32;    % Calentamiento, 2 [min]
            32 39;    % Vel. Mín., 1 [min]
            40 46;    % Vel. Intermedia, 1 [min]
            46.1 53     % Vel. Máx., 1 [min]
            ];
    case 'A3'
        txt1 = 'D';
        txt2 = 'E';
      IMU=datos_totales_A(3).IMU1; %IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[220 250];
        Intervalos=[12 21;     % Calentamiento, 2 [min]
            21 28;     % Vel. Mín., 1 [min]
            29 35;     % Vel. Intermedia, 1 [min]
            35.1 42;     % Vel. Máx., 1 [min]
            ];
    case 'A4'
        txt1 = 'D';
        txt2 = 'E';
      IMU=datos_totales_A(4).IMU1; %IMU=IMU1;
      Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[7 20;     % Calentamiento, 2 [min]
            20 27;     % Vel. Mín., 1 [min]
            27.2 34;     % Vel. Intermedia, 1 [min]
            34.3 41;     % Vel. Máx., 1 [min]
            ];
    case 'A5'
        txt1 = 'D';
        txt2 = 'E';
        IMU=datos_totales_A(5).IMU1; 
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[7.2 18.8;     % Calentamiento, 2 [min]
            19.1 25.8;     % Vel. Mín., 1 [min]
            25.8 32.8;     % Vel. Intermedia, 1 [min]
            33 39.8;     % Vel. Máx., 1 [min]
            ];
    case 'A6'
        txt1 = 'D';
        txt2 = 'E';
        IMU=datos_totales_A(6).IMU1; %IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[9.4 10;  % Calentamiento, 2 [min]
            10.9 22.2;       % Vel. Mín., 1 [min]
            22.3 34.4;     % Vel. Intermedia, 1 [min]
            34.4 46.5];    % Vel. Máx., 1 [min]
    case 'B1'
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'L';
        if txt1 == 'D'
            IMU=datos_totales_B(1).IMU1; %IMU=IMU1;
            %IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[10 25];
        else
            IMU=datos_totales_B(1).IMU2; %IMU=IMU1;
            %IMU=IMU2;
            Rcalib=[ -2 , -3, 1];
            IntervalEstatico=[70 90];
        end
        Intervalos=[1 36; 40 55; 55 90; 95 110; 115 140; 145 160; 165 195;
            200 215; 220 255; 260 275; 280 310; 320 335; 340 365; 375 390; 395 430; 440 465];
    case 'B2'
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'L';
        if txt1 == 'D'
                  IMU=datos_totales_B(2).IMU1; %IMU=IMU1;
            %IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[60 80];
        else
                  IMU=datos_totales_B(2).IMU2; %IMU=IMU1;
            %IMU=IMU2;
            Rcalib=[ -2 , -3, 1];
            IntervalEstatico=[10 30];
        end
        Intervalos=[1 30; 34 37; 37 40; 40 44; 44 47; 47 51; 51 54; 54 57; 57 62;
            62 66; 66 74; 74 76; 76 79; 79 83; 83 86; 86 90; 90 96; 96 100; 100 104;
            104 106; 106 114; 114 116; 116 121; 121 125;125 133; 133 135; 135 141; 141 144; 144 147; 147 149; 149 157];
    case 'B3'
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'L';

        if txt1 == 'D'
            IMU=datos_totales_B(3).IMU1; %IMU=IMU1;
            %IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[10 40];
        else
            IMU=datos_totales_B(3).IMU2; %IMU=IMU1;
            %IMU=IMU2;
            Rcalib=[ -2 , -3, 1];
            IntervalEstatico=[70 100];
        end
        Intervalos=[1 20; 20 60; 60 72; 72 84; 84 89; 89 102; 102 108; 108 120; 120 126; 126 141; 141 147; 147 168];
        %Intervalos=[60 72; 72 84];
    case 'B4'       
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'L';
        if txt1 == 'D'
            IMU=datos_totales_B(4).IMU1; %IMU=IMU1;
            %IMU=IMU1;
            Rcalib=[ -2, -3, 1];
        else
            IMU=datos_totales_B(4).IMU2; %IMU=IMU1; 
            %IMU=IMU2;
            Rcalib=[ 2 , 3, 1];
        end
        IntervalEstatico=[50 90];
        Intervalos=[40 45; 45 54; 55 60; 66 67;  67 71; 71 75; 75 79; 79 89;
            89 93; 93 104; 104 116; 116 132; 132 146; 146 161; 161 175; 175 190; 190 205; 205 220];
        % Las series correspondientes a acel-decel:
        % Intervalos=[103.5 116.5; 131.5 146.5; 160 175 ];
    case 'B5'
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'T';
        if txt1 == 'D'
            IMU=datos_totales_B(5).IMU1; %IMU=IMU1;
            %IMU=IMU1;
        else
            IMU=datos_totales_B(5).IMU2; %IMU=IMU1;
            %IMU=IMU2;
        end
        Rcalib=[ 1 , -2, -3];
        IntervalEstatico=[50 90];
        Intervalos=[1 28; 28 48;48 64; 64 78;78 110; 110 125; 125 140];
        % el primero intervalo son escalones de 15'' de 8km/h a 18km/h;
        % el segundo fueron 15+15+10+... hasta 20km/h, bajada rápida; el tercero de 10''
    case 'B6'  % cross en el talón; el IMU1 se desconectó a media prueba.
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'T';
        if txt1 == 'D'
                       IMU=datos_totales_B(6).IMU1; %IMU=IMU1;
            %IMU=IMU1;
        else
                       IMU=datos_totales_B(6).IMU2; %IMU=IMU1;
            %IMU=IMU2;
        end
        Rcalib=[ 1 , -2, -3];
        IntervalEstatico=[50 90];
        Intervalos=[5 75; 75.5 83; 84 87; 87 134];
    case 'B7'  % empeine alto
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'E';
        if txt1 == 'D'
            IMU=IMU1;
        else
            IMU=IMU2;
        end
        Rcalib=[ 1 , -2, -3];
        IntervalEstatico=[50 90];
        Intervalos=[3 104; 104 120];

    case 'B8'  % empeine bajo
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'E';
        if txt1 == 'D'
            IMU=IMU1;
        else
            IMU=IMU2;
        end
        Rcalib=[ 1 , -2, -3];
        IntervalEstatico=[50 90];
        Intervalos=[3 17; 17 30; 30 46; 46 59.7; 59.7 77; 77 96; 96 111];
end

% El numero de intervalos a estudiar:
num_intervalos=size(Intervalos,1);


%% PARTE DE CALIBRACION
%
% Una vez definido el IMU, se cargan los datos:
accx=IMU.Acc_X;
accy=IMU.Acc_Y;
accz=IMU.Acc_Z;
gyrx=IMU.Gyr_X;
gyry=IMU.Gyr_Y;
gyrz=IMU.Gyr_Z;

quat_w = IMU.Quat_W;
quat_x = IMU.Quat_X;
quat_y = IMU.Quat_Y;
quat_z = IMU.Quat_Z;

acc=[accx accy accz];
gyr=[gyrx gyry gyrz];
quat = [quat_w quat_x quat_y quat_z];
M_orientacion=quat2rotm(quat);

% Calibracion en coordenadas anatómicas:
%
ini=IntervalEstatico(1,1);
fin=IntervalEstatico(1,2);

% Matriz de re-orientación vertical, en coordenadas anatómicas:
Mrot=calibra_anatomical(acc(ini:fin,:), Rcalib);

% Acss y gyros re-orientados en coor.anatómicas:
acc_cal=acc*Mrot'; 
gyr_cal=gyr*Mrot';
M_orientacion_cal = pagemtimes(M_orientacion, Mrot);
quat_cal=rotm2quat(M_orientacion_cal);

% En coordenadas ISB
a_cal=Anatomical2ISB(acc_cal);
g_cal=Anatomical2ISB(gyr_cal);



%% PARTE DE VISUALIZACION:
%
%
if txt_visualiza == 'S'

    %% Figura larga para visualizar todo el experimento;
    fig_new=figure;
    plot(accx);
    hAx = gca; % Handle to current axes
    % Adjust font sizes
    hAx.FontSize = 28;
    grid
    posi = [21        1717        3791        410];
    fig_new.OuterPosition=posi;


    %% Calibracion anatómica
    % Figura larga para ayudar a identificar una zona de reposo
    fig_new=figure;
    plot(accx(1:400));
    hAx = gca; % Handle to current axes
    % Adjust font sizes
    hAx.FontSize = 28;
    grid
    posi = [21        1717        3791        410];
    fig_new.OuterPosition=posi;

    % figura para chequear que la re-orientación fue correcta:
    figure;
    subplot(211); plot(acc(ini:fin,:), 'LineWidth', 3); grid; title('Accs originales', 'FontSize', 12, 'FontWeight', 'bold');
    subplot(212); plot(a_cal(ini:fin,:), 'LineWidth', 3); grid; title('Accs calibradas', 'FontSize', 12, 'FontWeight', 'bold');
    sgtitle('Chequeo del resultado de la calibracion', 'FontSize', 16, 'FontWeight', 'bold');

end

end
%-------------------------- Fin de carga_calibra --------------

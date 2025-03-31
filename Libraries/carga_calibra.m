%% carga_calibra
%
% Utilidad para cargar y calibrar los datos de una prueba, a partir de su ID
%

% Suponemos que hay un archivo con datos matlab.mat accesible:
load;
freq=120; % por ahora...

global num_intervalos;
num_intervalos=0;

% limpiamos variables intermedias para evitar problemas:
clear zonas
clear Intervalos


%% PARTE DE CARGA DE DATOS, EN FUNCION DEL ID
%
%
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
        IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[5 20;       % Calentamiento, 2 [min]
            20 27.2;    % Vel. Mín., 1 [min]
            27.2 34.4;  % Vel. Intermedia, 1 [min]
            34.4 41.6]; % Vel. Máx., 1 [min]
    case 'A2'
        txt1 = 'D';
        txt2 = 'E';
        IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[1.8 3.2;    % Calentamiento, 2 [min]
            3.2 3.9;    % Vel. Mín., 1 [min]
            3.9 4.6;    % Vel. Intermedia, 1 [min]
            4.6 5.3     % Vel. Máx., 1 [min]
            ]*10;
    case 'A3'
        txt1 = 'D';
        txt2 = 'E';
        IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[220 250];
        Intervalos=[0.7 2.1;     % Calentamiento, 2 [min]
            2.1 2.8;     % Vel. Mín., 1 [min]
            2.8 3.5;     % Vel. Intermedia, 1 [min]
            3.5 4.2;     % Vel. Máx., 1 [min]
            ]*10;
    case 'A4'
        txt1 = 'D';
        txt2 = 'E';
        IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[0.6 2.0;     % Calentamiento, 2 [min]
            2.0 2.7;     % Vel. Mín., 1 [min]
            2.7 3.4;     % Vel. Intermedia, 1 [min]
            3.4 4.1;     % Vel. Máx., 1 [min]
            ]*10;
    case 'A5'
        txt1 = 'D';
        txt2 = 'E';IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[0.48 1.88;     % Calentamiento, 2 [min]
            1.88 2.58;     % Vel. Mín., 1 [min]
            2.58 3.28;     % Vel. Intermedia, 1 [min]
            3.28 3.98;     % Vel. Máx., 1 [min]
            ]*10;
    case 'A6'
        txt1 = 'D';
        txt2 = 'E';
        IMU=IMU1;
        Rcalib=[ 3 , -2, 1];
        IntervalEstatico=[50 90];
        Intervalos=[7 10;  % Calentamiento, 2 [min]
            10 22.2;       % Vel. Mín., 1 [min]
            22.2 34.4;     % Vel. Intermedia, 1 [min]
            34.4 46.6];    % Vel. Máx., 1 [min]
    case 'B1'
        prompt = "pie Dcho o pie Izdo? D/I [D]: ";
        txt1 = input(prompt,"s");
        if isempty(txt1)
            txt1 = 'D';
        end
        txt2 = 'L';
        if txt1 == 'D'
            IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[10 25];
        else
            IMU=IMU2;
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
            IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[60 80];
        else
            IMU=IMU2;
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
            IMU=IMU1;
            Rcalib=[ 2 , 3, 1];
            IntervalEstatico=[10 40];
        else
            IMU=IMU2;
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
            IMU=IMU1;
            Rcalib=[ -2, -3, 1];
        else
            IMU=IMU2;
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
            IMU=IMU1;
        else
            IMU=IMU2;
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
            IMU=IMU1;
        else
            IMU=IMU2;
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
acc=[accx accy accz];
gyr=[gyrx gyry gyrz];

% Calibracion en coordenadas anatómicas:
%
ini=IntervalEstatico(1,1);
fin=IntervalEstatico(1,2);

% Matriz de re-orientación vertical, en coordenadas anatómicas:
Mrot=calibra_anatomical(acc(ini:fin,:), Rcalib);

% Acss y gyros re-orientados en coor.anatómicas:
acc_cal=acc*Mrot'; 
gyr_cal=gyr*Mrot';

% En coordenadas ISB
acc2=Anatomical2ISB(acc_cal);
gyrML=Anatomical2ISB(gyr_cal);



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
    subplot(212); plot(acc2(ini:fin,:), 'LineWidth', 3); grid; title('Accs calibradas', 'FontSize', 12, 'FontWeight', 'bold');
    sgtitle('Chequeo del resultado de la calibracion', 'FontSize', 16, 'FontWeight', 'bold');

end

%-------------------------- Fin de carga_calibra --------------

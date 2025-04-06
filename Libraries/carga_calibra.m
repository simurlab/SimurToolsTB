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
% Según su ID (txt0), cargamos variables propias de cada experimento:
% - Intervalos: muestras de estudio (en miles)
% - IntervaloEstatico: intervalo de muestras en reposo para reorientacion
% - IMU: uno de los varios IMUs utilizados en el experimento
% - Rcalib: describe la posicion inicial del sensor en coordenadas anatomicas
% - txt1: localización del IMU (Derecha/Izda/Sacro)
% - txt2: colocación del IMU(Empeine/Lateral/Talon)
% -
switch txt0
    case 'A1'
        eval(datos_totales_A{1,2});
    case 'A2'
        eval(datos_totales_A{2,2});
    case 'A3'
        eval(datos_totales_A{3,2});
    case 'A4'
        eval(datos_totales_A{4,2});
    case 'A5'
        eval(datos_totales_A{5,2});
    case 'A6'
        eval(datos_totales_A{6,2});
    case 'B1'
        eval(datos_totales_B{1,2});
    case 'B2'
        eval(datos_totales_B{2,2});
    case 'B3'
        eval(datos_totales_B{3,2});
    case 'B4'
        eval(datos_totales_B{4,2});
    case 'B5'
        eval(datos_totales_B{5,2});
    case 'B6'  
        eval(datos_totales_B{6,2});
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

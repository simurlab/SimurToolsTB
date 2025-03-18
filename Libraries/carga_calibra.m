%% carga_calibra
%
% cargar y visualizar los datos.
% suponemos que hay un archivo con datos matlab.mat accesible:
load;
freq=120;


% Recabar información de cómo estaba el sensor concreto:

prompt = "pie Dcho, pie Izdo o Sacro? D/I/S [D]: ";
txt1 = input(prompt,"s");
if isempty(txt1)
    txt1 = 'D';
end

prompt = "colocado en Empeine, en Talón o en Lateral? E/T/L [L]: ";
txt2 = input(prompt,"s");
if isempty(txt2)
    txt2 = 'L';
end

% Para el IMU seleccionado, el vector R necesario para luego reorientar 
% la posición inicial del sensor a un estandar:
switch txt2
    case 'L'
        if txt1 == 'D'
        IMU=IMU2;
        R=[ 2 , 3, 1]; 
        else 
        IMU=IMU1;
        R=[ -2 , -3, 1]; 
        end
    case 'T'
        IMU=IMU1;
        R=[ 3 , 2, 1];
    case 'E'
        if txt1 == 'D'
        IMU=IMU2;
        R=[ 1 , -2, -3]; 
        else 
        IMU=IMU1;
        R=[ 1 , -2, -3]; 
        end
end

accx=IMU.Acc_X;
accy=IMU.Acc_Y;
accz=IMU.Acc_Z;
gyrx=IMU.Gyr_X;
gyry=IMU.Gyr_Y;
gyrz=IMU.Gyr_Z;
acc=[accx accy accz];
gyr=[gyrx gyry gyrz];


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


ini=input("Muestra inicio de calibración:");
fin=input("Muestra fin de calibración:");

% Matriz de orientación:
Mrot=calibra_anatomical(acc(ini:fin,:), R);
acc2=acc*Mrot';


% figura para chequear que la re-orientación fue correcta:
figure; 
subplot(211); plot(acc(ini:fin,:)); grid;
subplot(212); plot(acc2(ini:fin,:)); grid;

% gyro ML con el que se harán detecciones de eventos:
gyrML=gyr*Mrot';







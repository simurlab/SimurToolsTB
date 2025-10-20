% CARGA_CALIBRA Funcion para cargar y calibrar los datos de una prueba,
% a partir de su ID (apoyado en calibra_anatomical). Supone que hay un
% archivo con datos tipo BD-InnovaIM accesible localmente.
%
% CARGA_CALIBRA Tomando como base las velocidad angular en el eje mediolateral realiza un proceso de
% filtrado (apoyado en filtro0). Se identifican los eventos de contacto inicial y final del pie en el que
% esta el sensor.
%
% Sintax: [a_cal, g_cal, Intervalos, quat_cal]=carga_calibra(IDexp, numSensor, Visualiza)
%
% Parametros de entrada:
%    IDexp              - Código de identificación del sensor (letra+numero)
%    numSensor          - Entero que identifica el sensor Sensor (1,2,3) == pie derecho, izdo o COG respect.
%    Visualiza          - Opción de gráficas aux. para debugging ('S', 'N')
%
% Parametros de salida:
%    a_cal              - Acelerómetros calibrados formato ISB
%    g_cal              - Giroscopios calibrados formato ISB
%    Intervalos         - Zonas de estudios, con muestra de inicio y final.
%    quat_cal           - quaterniones dados por el sensor

function [a_cal, g_cal, quat_cal]=calibra1(IMU,Rcal,freq)

%freq=120; % por ahora...

% Cuenta el número de argumentos
numArgs = nargin;




%% PARTE DE CALIBRACION Y PASO A ISB
%

%Rcal=[-3 2 1];

% Una vez definido el IMU, se cargan los datos:
accx=IMU.Acc_X;
accy=IMU.Acc_Y;
accz=IMU.Acc_Z;
acc=[accx accy accz];

gyrx=IMU.Gyr_X;
gyry=IMU.Gyr_Y;
gyrz=IMU.Gyr_Z;
gyr=[gyrx gyry gyrz];

if ismember('Quat_W', IMU.Properties.VariableNames)
    quat_w = IMU.Quat_W;
end
if ismember('Quat_X', IMU.Properties.VariableNames)
    quat_x = IMU.Quat_X;
end
if ismember('Quat_Y', IMU.Properties.VariableNames)
    quat_y = IMU.Quat_Y;
end
if ismember('Quat_Z', IMU.Properties.VariableNames)
    quat_z = IMU.Quat_Z;
    quat = [quat_w quat_x quat_y quat_z];
end

if ismember('Euler_X', IMU.Properties.VariableNames)
    euler_x = IMU.Euler_X;
end
if ismember('Euler_Y', IMU.Properties.VariableNames)
    euler_y = IMU.Euler_Y;
end
if ismember('Euler_Z', IMU.Properties.VariableNames)
    euler_z = IMU.Euler_Z;
    euler = [euler_x euler_y euler_z];
end



% Calibracion en coordenadas anatómicas:
% Zona de reposo para calibrar:
ini=74*freq;
fin=75*freq;

% Matriz de re-orientación vertical, en coordenadas anatómicas:
Mrot=calibra_anatomical(acc(ini:fin,:), Rcal);

%  Re-orientados en coor.anatómicas:
acc_cal=acc*Mrot';
gyr_cal=gyr*Mrot';

% Paso a coordenadas ISB:
a_cal=Anatomical2ISB(acc_cal);
g_cal=Anatomical2ISB(gyr_cal);


% % Intento de reorientar los cuaterniones con la calibracion.
% Ahora sirve solo para los DOTS:
if ismember('Quat_Z', IMU.Properties.VariableNames)
    M_orientacion=quat2rotm(quat);
    M_orientacion_cal = pagemtimes(M_orientacion, Mrot);
    quat_cal=rotm2quat(M_orientacion_cal);
end







%% PARTE OPCIONAL, FIGURA PARA INSPECCIONAR QUE LA CARGA Y CALIBRACION ESTAN OK
%
%
% if Visualiza == 'S'
% 
%     % figura para chequear que la re-orientación es la correcta:
%     figure;
%     subplot(211); plot(acc(ini:fin,:), 'LineWidth', 3); grid; title('Accs originales', 'FontSize', 12, 'FontWeight', 'bold');
%     subplot(212); plot(a_cal(ini:fin,:), 'LineWidth', 3); grid; title('Accs calibradas', 'FontSize', 12, 'FontWeight', 'bold');
%     sgtitle('Chequeo del resultado de la calibracion', 'FontSize', 16, 'FontWeight', 'bold');
% 
% end

end
%-------------------------- Fin de carga_calibra --------------

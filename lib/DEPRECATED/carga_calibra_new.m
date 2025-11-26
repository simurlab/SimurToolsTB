% CARGA_CALIBRA Funcion para cargar y orientar en formato ISB los datos 
% de una prueba. Supone que hay un archivo con datos tipo BD-InnovaIM 
% accesible, dado por su ID.
% Utiliza la funcion calibra_anatomical. 
%
% Sintax: [a_cal, g_cal, Intervalos]=carga_calibra(IDexp, numSensor, Visualiza)
%
% Parametros de entrada:
%    IDexp              - Código de identificación de la prueba (letra+numero)
%    numSensor          - Entero que identifica el sensor (1,2,3) == pie derecho, izdo o COG respect.
%    Visualiza          - Opción de gráficas aux. para debugging ('S', 'N')
%
% Parametros de salida:
%    a_cal              - Acelerómetros calibrados formato ISB
%    g_cal              - Giroscopios calibrados formato ISB
%    Intervalos         - Zonas de estudios, con muestra de inicio y final.
%    quat_cal           - quaterniones dados por el sensor

function [a_cal, g_cal]=carga_calibra(IDexp,queSensor,Visualiza)


%Cuenta el número de argumentos
%numArgs = nargin;


%queSensor='FR_1';
%IDexp='b0101.mat';


%% PARTE de carga del .mat con los datos del experimento
%
% Puede ser un grupo de experimentos o uno en particular.

IDexpfile=IDexp;
[~, ~, ext] = fileparts(IDexp);
if isempty(ext)
    IDexpfile = [IDexp, '.mat'];
end



% Ahora ya debe estar disponible el archivo, salvo error, y lo cargamos:
%
if isfile(IDexpfile)
    load(IDexpfile);
    fprintf('Archivo %s cargado correctamente. \n', IDexpfile);
else
    error('El archivo no existe: %s', IDexpfile);
end




% Acceder a un campo de la estructura cargada con load(IDexpfile)
% Acceder a los datos del sensor específico
sensorData = eval(queSensor);

% construye una cadena que una queSensor con '_metadata'
metadataField = strcat(queSensor, '_metadata');

% evalua esa cadena
Rcal = eval(metadataField).orientacion; % Acceder a los cuaterniones del metadata





% Una vez definido el IMU, se cargan los datos:
accx=sensorData.Acc_X;
accy=sensorData.Acc_Y;
accz=sensorData.Acc_Z;
acc=[accx accy accz];

gyrx=sensorData.Gyr_X;
gyry=sensorData.Gyr_Y;
gyrz=sensorData.Gyr_Z;
gyr=[gyrx gyry gyrz];

% Acceder a un campo de la estructura 

% Calibracion en coordenadas anatómicas:
% Zona de reposo para calibrar:
%ini=IntervalEstatico(queSensor,1);
%fin=IntervalEstatico(queSensor,2);
ini=1;
fin=50;
% Matriz de re-orientación vertical, en coordenadas anatómicas:
Mrot=calibra_anatomical(acc(ini:fin,:), Rcal);

%  Re-orientados en coor.anatómicas:
a_cal=acc*Mrot';
g_cal=gyr*Mrot';

% Paso a coordenadas ISB:
%a_cal=Anatomical2ISB(acc_cal);
%g_cal=Anatomical2ISB(gyr_cal);


% % % Intento de reorientar los cuaterniones con la calibracion.
% % Ahora sirve solo para los DOTS:
% if ismember('Quat_Z', IMU.Properties.VariableNames)
%     M_orientacion=quat2rotm(quat);
%     M_orientacion_cal = pagemtimes(M_orientacion, Mrot);
%     quat_cal=rotm2quat(M_orientacion_cal);
% end







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

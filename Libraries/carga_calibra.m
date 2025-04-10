%% carga_calibra
%
% Funcion para cargar y calibrar los datos de una prueba, a partir de su ID
%

function [a_cal, g_cal, Intervalos, quat_cal]=carga_calibra(IDexp,queSensor,Visualiza)

% Suponemos que hay un archivo con datos matlab.mat con la estructura 
% BD-InnovaIM accesible localmente:

 % Cuenta el número de argumentos
 numArgs = nargin;

% if  numArgs==0
%          prompt = "Introduzca el ID del experimento [a1]: ";
%          txt0 = input(prompt,"s");
%          IDexp=txt0;
%          if isempty(txt0)
%              IDexp = 'a1';
%          end     
% 
%          prompt = "Introduzca el Sensor de interés (1/2/3) [1]: ";
%          queSensor = input(prompt);
%          if isempty(queSensor)
%              queSensor = 1;
%          end 
% 
%          prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
%          Visualiza = input(prompt,"s");
%          if isempty(Visualiza)
%              Visualiza = 'N';
%          end
% end




%load;
freq=120; % por ahora...


% global num_intervalos;
% num_intervalos=0;
% 
% % limpiamos variables intermedias para evitar problemas:
% clear zonas
% clear Intervalos



 switch numArgs
     case 0
         prompt = "Introduzca el ID del experimento [a1]: ";
         txt0 = input(prompt,"s");
         IDexp=txt0;
         if isempty(txt0)
             IDexp = 'a1';
         end     
         
         prompt = "Introduzca el Sensor de interés (1/2/3) [1]: ";
         queSensor = input(prompt);
         if isempty(queSensor)
             queSensor = 1;
         end 
         
         prompt = "¿Quiere Visualizar los pasos intermedios? (S/N) [N]: ";
         Visualiza = input(prompt,"s");
         if isempty(Visualiza)
             Visualiza = 'N';
         end
     case 1
        txt0 = IDexp;
        queSensor=1;
        txt_visualiza = 'N';
     case 2
        txt0 = IDexp;
        txt_visualiza = Visualiza; 
     otherwise
 end


 %% Carga del .mat
 % cuando son individuales:

     IDexpfile=IDexp;
     [~, ~, ext] = fileparts(IDexp);
     if isempty(ext)
         IDexpfile = [IDexp, '.mat'];
     end
  
     % Verificar si el archivo existe
     if ~isfile(IDexpfile)
         separarCeldaPorFila('ax.mat','datos_totales');
     end


     % Verificar si el archivo existe
     if isfile(IDexpfile)    
         load(IDexpfile);
         disp('Archivo cargado correctamente.');
     else
         error('El archivo no existe: %s', IDexpfile);
     end
   
     %separarCeldaPorFila('ax.mat','datos_totales');
      %   error('El archivo no existe: %s', IDexpfile);
     
     % cuando son de una grupo de experimentos _x.mat
 %     if ~contains(IDexp, 'x')
 %  else
 %     disp('La letra "x" SÍ está en la cadena.');
 % end


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
eval(datos_totales{1,2});

% switch IDexp
%     case 'a1'
%         eval(datos_totales{1,2});
%     case 'a2'
%         eval(datos_totales{2,2});
%     case 'a3'
%         eval(datos_totales{3,2});
%     case 'a4'
%         eval(datos_totales{4,2});
%     case 'a5'
%         eval(datos_totales{5,2});
%     case 'a6'
%         eval(datos_totales{6,2});
%     case 'b1'
%         eval(datos_totales{1,2});
%     case 'b2'
%         eval(datos_totales{2,2});
%     case 'b3'
%         eval(datos_totales{3,2});
%     case 'b4'
%         eval(datos_totales{4,2});
%     case 'b5'
%         eval(datos_totales{5,2});
%     case 'b6'  
%         eval(datos_totales{6,2});
% end


% El numero de intervalos a estudiar:
num_intervalos=size(Intervalos,1);

 
switch queSensor
    case 1
        IMU=datos_totales{1}.IMU1; 
    case 2
        IMU=datos_totales{1}.IMU2;
    case 3
        IMU=datos_totales{1}.IMU3;
end
Rcal=Rcalib(queSensor,:);




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
Mrot=calibra_anatomical(acc(ini:fin,:), Rcal);

% Acss y gyros re-orientados en coor.anatómicas:
acc_cal=acc*Mrot'; 
gyr_cal=gyr*Mrot';
M_orientacion_cal = pagemtimes(M_orientacion, Mrot);
quat_cal=rotm2quat(M_orientacion_cal);

% En coordenadas ISB
a_cal=Anatomical2ISB(acc_cal);
g_cal=Anatomical2ISB(gyr_cal);



%% FIGURAS PARA INSPECCIONAR QUE LA CARGA Y CALIBRACION ESTAN OK
%
%
if Visualiza == 'S'

    % figura para chequear que la re-orientación es la correcta:
    figure;
    subplot(211); plot(acc(ini:fin,:), 'LineWidth', 3); grid; title('Accs originales', 'FontSize', 12, 'FontWeight', 'bold');
    subplot(212); plot(a_cal(ini:fin,:), 'LineWidth', 3); grid; title('Accs calibradas', 'FontSize', 12, 'FontWeight', 'bold');
    sgtitle('Chequeo del resultado de la calibracion', 'FontSize', 16, 'FontWeight', 'bold');

end

end
%-------------------------- Fin de carga_calibra --------------

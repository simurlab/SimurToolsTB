% EVENTOSPIE_CARRERA Detecta los eventos IC y FC a partir de la velocidad angular en el eje mediolateral
% durante la carrera
%
% EVENTOSPIE_CARRERA Tomando como base las velocidad angular en el eje mediolateral realiza un proceso de
% filtrado (apoyado en filtro0). Se identifican los eventos de contacto inicial y final del pie en el que 
% esta el sensor.
%
% Sintax: [IC,FC]=eventospie_carrera(gyr,th,freq)
%
% Parametros de entrada:
%    gyr           - vector con la velocidad de giro en el eje mediolateral
%    th            - velocidad mínima a alcanzar para detectar eventos. Aconsejado 150
%    frecuencia    - frecuencia de muestreo.
%
% Parametros de salida:
%    IC : muestras en las que se ha detectado el contacto con el suelo
%    FC.  muestras en las que se ha detectado el final del contacto con el suelo

function [IC,FC]=eventospie(gyr,th,freq)
 
    % filtrado
    orden=5;
    corte=6/freq;
   
    gyr=filtro0(gyr,orden,corte);
    

    tam=size(gyr);% tamaño de la señal de aceleración de entrada
    tam=tam(1);

    % Obtencion de la señal rectangular:
    Datos2=gyr(2:tam)-gyr(1:tam-1);
    Datos2=Datos2>=0;

    % Obtencion de las señal de pulsos:
    Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);
    maximos=find(Datos2==1)+1;
    minimos=find(Datos2==-1)+1;
    minimos=minimos(gyr(minimos)<0);

    % min_local=minimos(1);
    max_paso=maximos(1);
    mins_paso=[];

    IC=[];
    FC=[];

for i=2:length(maximos)
 
   if gyr(maximos(i))>=th
             
       mins_paso=minimos(minimos>max_paso(end) & minimos<maximos(i));
   
       if length(mins_paso)>=2
           max_paso=[max_paso, maximos(i)];
           [fc,ifc]=min(gyr(mins_paso(2:end)));%el primero es el ic, no vale como fc.
           FC=[FC mins_paso(ifc+1)];
           IC=[IC mins_paso(1)];
           
       end
   end
    
end

end




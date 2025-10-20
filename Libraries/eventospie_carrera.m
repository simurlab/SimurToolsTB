% EVENTOSPIE_CARRERA Detecta los eventos IC y FC a partir de la velocidad angular en el eje mediolateral
% durante la carrera
%
% EVENTOSPIE_CARRERA Tomando como base las velocidad angular en el eje mediolateral realiza un proceso de
% filtrado (apoyado en filtro0). Se identifican los eventos de contacto inicial y final del pie en el que 
% esta el sensor.
%
% Sintax: [IC,FC,MaxS,MinS,MVP,MP]=eventospie_carrera(gyr,th,freq,gyrpron)
%
% Parametros de entrada:
%    gyr           - vector con la velocidad de giro en el eje mediolateral
%    th            - velocidad mínima a alcanzar para detectar eventos. Aconsejado 150
%    frecuencia    - frecuencia de muestreo.
%    gyrpron       - vector con la velocidad de giro en el eje frontal(opcional. 
%                    Sin este parámetro MVP Y MP devolveran un array vacio
%
% Parametros de salida:
%    IC  :  muestras en las que se ha detectado el contacto con el suelo
%    FC  :  muestras en las que se ha detectado el final del contacto con el suelo
%    MaxS:  muestras en las que se ha detectado el maximo swing(hacia delante)(NaN=no detectado)
%    MinS:  muestras en las que se ha detectado el minimo swing(hacia atras)  (NaN=no detectado)
%    MVP :  muestras en las que se detecta la máxima velocidad de pronación (NaN=no detectado)
function [IC,FC,MaxS,MinS,MVP,MP]=eventospie_carrera(gyr,th,freq,gyrpron)
 
    % filtrado
    orden = 8+floor(freq / 100); % orden mínimo 3. A más fm más potente debe ser el filtro
    corte=6/freq;
   
    gyr=filtro0(gyr,orden,corte);
    gyrpron=filtro0(gyrpron,orden,corte);

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
    max_paso=maximos(1);
    
    IC=[];
    FC=[];
    MaxS=[];
    MinS=[];

    pasos_cero_maxs=find(diff(gyr>0)==-1);
    pasos_cero_mins=find(diff(gyr>0)==+1);

    if nargin==4
        %maximos de la pronacion
    	% Obtencion de la señal rectangular:
    	Datos2=gyrpron(2:tam)-gyrpron(1:tam-1);
    	Datos2=Datos2>=0;
    	% Obtencion de las señal de pulsos de pronacion:
    	Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);
    	maximospron=find(Datos2==1)+1;
    	
        %Pasos por cero de positivo a negativo
        % Obtencion de la señal rectangular:
    	Datos3=gyrpron<0;
        Datos3=diff(Datos3);
        %El 1 ha quedado en la última muestra positiva
        pasosceropron=find(Datos3==1);
        %Lo cambio por el siguiente si el siguiente está más próximo al 0
        for i=1:length(pasosceropron)
            if abs(gyrpron(pasosceropron(i)))>abs(gyrpron(pasosceropron(i)+1))
                pasosceropron(i)=pasosceropron(i)+1;
            end
        end
    end
    MVP=[];
    MP=[];

    for i=2:length(maximos)
        if gyr(maximos(i))>=th
            mins_paso=minimos(minimos>max_paso(end) & minimos<maximos(i));
   
            if length(mins_paso)>=2
                max_paso=[max_paso, maximos(i)]; %#ok<*AGROW>
                [fc,ifc]=min(gyr(mins_paso(2:end))); %#ok<ASGLU> 
                %el primero es el ic, no vale como fc.
                FC=[FC mins_paso(ifc+1)];
                IC=[IC mins_paso(1)];

                %maxs es el último evento. se tiene que buscar antes del IC
                %del siguiente paso. pero aún no tenemos el ic del
                %siguiente paso
                %maxs=pasos_cero_maxs(pasos_cero_maxs>max_paso(end-1)& pasos_cero_maxs<IC(end));
                maxs=pasos_cero_maxs(pasos_cero_maxs>max_paso(end));
                if ~isempty(maxs)
                    MaxS=[MaxS, maxs(1)];
                else
                    MaxS=[MaxS, NaN];
                end

                mins=pasos_cero_mins(pasos_cero_mins>FC(end) & pasos_cero_mins<max_paso(end));
                if ~isempty(mins)
                    MinS=[MinS, mins(end)];
                else
                    MinS=[MinS, NaN];
                end

                if nargin==4
                    mvp=maximospron(maximospron>IC(end)& maximospron<FC(end));
                    if ~isempty(mvp)
                        MVP=[MVP, mvp(1)];
                        % CÁLCULO DE EVENTO MP solo si hay MVP
                        mp=pasosceropron(pasosceropron>MVP(end)& pasosceropron<FC(end));
                        if ~isempty(mp)
                            MP=[MP, mp(1)];
                        else
                            MP=[MP, NaN];
                        end
                    else
                        MVP=[MVP, NaN];
                        MP=[MP, NaN];
                    end
                end
            end
        end
    end
    


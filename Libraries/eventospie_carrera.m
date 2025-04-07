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
    max_paso=maximos(1);
    
    IC=[];
    FC=[];
    MaxS=[];
    MinS=[];

    pasos_cero_maxs=find(diff(gyr>0)==-1);
    pasos_cero_mins=find(diff(gyr>0)==+1);

    if nargin==4
        orden=5;
        corte=5/freq;
    	%maximos y minimos de la pronacion
    	gyrpron_fil=filtro0(gyrpron,orden,corte);
    	% Obtencion de la señal rectangular:
    	Datos2=gyrpron(2:tam)-gyrpron(1:tam-1);
    	Datos2=Datos2>=0;
    	% Obtencion de las señal de pulsos de pronacion:
    	Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);
    	maximospron=find(Datos2==1)+1;
    	minimospron=find(Datos2==-1)+1;
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
                    else
                        MVP=[MVP, NaN];
                    end
                    % -----------------------
                    % CÁLCULO DE EVENTO MP
                    % -----------------------
                    % Opción 1: Versión inicial de Diego
                    % mp=minimospron(minimospron>IC(end)& minimospron<FC(end));
                    % if ~isempty(mp)
                    %     MP=[MP, mp(1)];
                    % else
                    %     MP=[MP, NaN];
                    % end

                    % *************************************************************
                    % Opción 2: Definir ventana deslizante de n muestras y 
                    % calcular std en cada ventana. El evento MP se detecta
                    % cuando la std sea menor que un umbral.
                    % Calcular std en componente antero-posterior del giroscopio
                    % Tamaño de la ventana deslizante
                    % windowSize = 4; % [muestras]
                    % Calcular la desviación estándar en la ventana deslizante
                    % std_gyroant = movstd(gyrpron_fil, windowSize);
                    % umbral = 20;                           % THRESHOLD expresado en [°/s]
                    % MP = find(std_gyroant < umbral);       % Tendremos un evento MP cuando la std de gyroant sea menor que un umbral
                    % MP_segmentados = cell(length(IC), 1);  % Inicialización de array de celdas para almacenar los eventos MP.
                    % for i = 1:length(IC)
                    %     aux = MP(MP>=IC(i) & MP<=FC(i));   % Máximos locales comprendidos entre IC y FC.
                    %     if ~any(isempty(aux))              % Si no hay ningún valor NaN:
                    %         MP_segmentados{i} = aux(1);    % Escogemos la muestra de la primera std
                    %     else                              
                    %         MP_segmentados{i} = NaN;
                    %     end
                    %     %MP_segmentados{i} = aux(1);        % Escogemos la primera muestra en la que la std de gyroant es menor que un umbral
                    % end
                    % MP_segmentados=cell2mat(MP_segmentados);
                    % MP=MP_segmentados';
                    % ***************************************************************

                    % ***************************************************************
                    % Opción 3: Calcular el coeficiente de variación a lo
                    % largo de la señal gyrpron
                    windowSize = 4;                                                         % Tamaño de la ventana deslizante
                    cvValues = movstd(gyrpron, windowSize) ./ movmean(gyrpron, windowSize); % Calcular el coeficiente de variación en ventanas móviles
                    cvThreshold = 0.1;                                                      % Umbral para CV
                    constantCV = cvValues < cvThreshold;                                    % Detectar zonas con CV bajo
                    aux=find(constantCV);                                                   % Identificamos índices en los que el vector lógico es 1
                    min_after_MVP = [];                                                     % Inicializa un vector para guardar los mínimos posteriores
                    for i = 1:length(MVP)                                                   % Para cada evento MVP --> HACER:
                        mins_after = aux(aux> MVP(i));                                      % Busca los mínimos que ocurren después del evento actual   
                        if ~isempty(mins_after)                                             % Si hay alguno, toma el primero (el más cercano después del evento)
                            min_after_MVP(end+1) = mins_after(1);                           % Escogemos la primera a estado alto después del evento MP
                        end                                                                 % Fin de sentencia if
                    end                                                                     % Fin de bucle for
                    MP=min_after_MVP;                                                       % Guardamos el evento MP detectado
                    % Visualización
                    % figure;
                    % %subplot(2,1,1);
                    % plot(gyrpron, 'b');
                    % title('Señal Original');
                    % xlabel('Tiempo');
                    % ylabel('Valor');
                    % hold on
                    % plot(1000*constantCV, 'r', 'LineWidth', 2);
                    % plot(MVP, gyrpron(MVP), '^')
                    % grid
                    % ***************************************************************
                end
            end
        end
    end
    


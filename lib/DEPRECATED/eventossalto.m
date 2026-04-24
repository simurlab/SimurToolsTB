% EVENTOSSALTO Detecta 4 eventos a partir de las acelerariones verticales
% del COG durante el salto
%
% EVENTOSSALTO Tomando como base las aceleraciones verticales del COG realiza un proceso de
% filtrado que le permite diferenciar cada salto. Una vez detectado un salto, realiza un proceso de detecci�n de
% minimos y maximos que permite identificar los eventos
% Inicio,Preparacion,PreContacto, y Fin
%
% Sintax: tiempos=eventossalto(AccVert,frecuencia)
%
% Parametros de entrada:
%    AccVert       - vector con la aceleracion vertical. Puede ser de un
%                    salto o de varios. No puede tener medios saltos. Puede
%                    contener instantes de tiempo en los que se está
%                    estático, pero no los correspondientes a movimientos
%                    distintos del salto.
%    frecuencia    - entero indicando la frecuencia de muestreo. Por
%                    defecto vale 100Hz.
%
% Parametros de salida:
%    tiempos: vector del mismo tamanyo que los datos, con unos en las posiciones 
%             de los eventos y ceros el resto:
%             tiempos(:,1)=AccVert;
%             tiempos(:,2)=deteccion de inicio de salto
%             tiempos(:,3)=deteccion de contacto inicial (paso por g)
%             tiempos(:,4)=deteccion de fin de salto (apoyo intenso) (máximo)
%             tiempos(:,5)=deteccion de preparacion para el contacto (mínimo)
%
% Examples:
%
% See also:
%


% Historial de Modificaciones: 
%  Desarrollado por Alberto Castanon.
%  Modificado por: Diego, 24-ene-07 -> adaptacion del codigo a siloptoolbox
%  Modificad por : Diego, 18-dic-07 -> adaptacion a v0.3 

function tiempos=eventossalto(AccVert,frecuencia)

if (nargin<2)
    frecuencia=100;
end


% En primer lugar se busca el numero de minimos que se producen durante 
% las  mediciones y que sean inferiores a -3
minimos=buscamaximosth(-AccVert,1.5);
ind_min=find(minimos==1);
num=length(ind_min);

% Se queda con un minimos por salto, eliminando aquellos otros que pudiera
% haber en un periodo de 1 seg ( util sobretodo para las aceleraciones
% medidas en el pie, donde hay mas minimos inferiores a -3)
% Nos quedamos con el primer punto que cumpla la condición
inicio=ind_min(1);
for i= 2:num
        if ind_min(i)- inicio <= frecuencia
               minimos(ind_min(i))= 0; %Se descarta el punto
        else
            inicio=ind_min(i); %Se acepta el punto y se comprueba el resto
        end
end

% Obtiene el numero definitivo de saltos y su posición
ind_min=find(minimos==1);
num_saltos=length(ind_min);


% A continuacion se hallara el maximo (mayor de 20) que hay a continuación
% del minimo en cada salto para obtener (a partir de él) 
% el punto más cercano al paso por 9.81.
maximos= buscamaximosth(AccVert,20);
ind_max=find(maximos);
num=length(ind_max); 


% De todos los maximos superiores a 20 se cogeran solo aquellos que estan
% justo a continuación del minimo hallado anteriormente
j=1;
if (num_saltos>=1)
    for i=1:num
        if ind_max(i)> ind_min(j)    
            ind_max2(j)=ind_max(i); %#ok<AGROW>
            j=j+1;
        end
        if j>num_saltos  %Ya se asigno un máximo a cada mínimo
            break;       %y terminamos
        end
    end
end
ind_max=ind_max2; 

% Ahora he de obtener el mínimo que está justo antes del máximo
% anteriormente hallado y cuyo valor sea inferior a 9.81, para ello cojo el
% trozo de señal entre el mínimo absoluto y el máximo absoluto ya sabidos.
for i=1:num_saltos
     datos_tramo=-AccVert(ind_min(i)+1:ind_max(i)+1); %No es ind_max(i)-1??
     min=buscamaximosth(datos_tramo,-9.81);
     indice=find(min==1);   %Localización del minimo en el tramo
     ind_min_cerc(i)=indice(end)+ind_min(i); %#ok<AGROW> %Paso a las coordenadas globales 
end

% Una vez obtenido ese minimo obtengo el paso por 9.81 de la señal de
% aceleración mirando cual es el maximo de -|señal-9.81|
for i=1:num_saltos
    datos_tramo=-abs(AccVert(ind_min_cerc(i)+1:ind_max(i)+1)-9.81); %No es ind_max(i)-1??
    paso_g=buscamaximos(datos_tramo);
    ind_g=find(paso_g==1);
    ind_paso_g(i)=ind_g(1)+ind_min_cerc(i); %#ok<AGROW>
end



% Ahora creo una matriz de eventos colocando las aceleraciones en la primera columna,
% los minimos hallados al principio en una columna, los pasos por g en otra,
% los maximos finales en la cuarta y los minimos cercanos a ellos en la quinta.
tiempos(:,1)=AccVert;
tiempos(:,2)=0*AccVert;
tiempos(:,3)=0*AccVert;
tiempos(:,4)=0*AccVert;
tiempos(:,5)=0*AccVert;
for n=ind_min
	tiempos(n,2)=1;
end
for n=ind_paso_g
	tiempos(n,3)=1;
end
for n=ind_max
	tiempos(n,4)=1;
end
for n=ind_min_cerc
	tiempos(n,5)=1;
end

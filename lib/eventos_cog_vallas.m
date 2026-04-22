function [MaxAcc,saltos,caidas,IC,FC]=eventos_cog_vallas(acc_vert_raw,acc_tot_raw)
    orden=5;
    corte=30/120;
    acc_vert=filtro_paso_bajo_f0(acc_vert_raw,orden,corte);
    acc_tot=filtro_paso_bajo_f0(acc_tot_raw,orden,corte);
    tam=length(acc_vert);
    % Obtencion del signo de la derivada
    Datos=acc_vert(2:tam)-acc_vert(1:tam-1);
    Datos=Datos>=0;
    % Obtencion de las señal de pulsos:
    Datos=Datos(1:tam-2)-Datos(2:tam-1);
    maximos=find(Datos==1)+1;
    %limitamos a los pulsos que pasan de 15m/s2
    altos=acc_vert(maximos)>15;
    indices_altos=altos;
    eventos=maximos(indices_altos);
    eventos=eventos';
    %Eliminamos eventos demasiado próximos
    eventos_f=[eventos(1)];
    for k=eventos(2:end)
        if k>eventos_f(end)+15 %15/120 segundos 1/6 de segundo
            eventos_f=[eventos_f,k]; %#ok<AGROW>
        end
    end
    MaxAcc=eventos_f;

    %análisis del tramo
    %amplitude en torno al primer paso del tramo
    paso1=max(acc_vert_raw(MaxAcc(1)-1:MaxAcc(1)+1));
    %1º paso en el que la amplitud es un 50% superior
    %se va a corresponder al salto
    for k=1:length(MaxAcc)
        if max(acc_vert_raw(MaxAcc(k)-1:MaxAcc(k)+1))>1.5*paso1
            salto1=k;
            break
        end
    end
    %Idenfifiacmos la primera caida. Siguiente Máximo lo bastante separado
    if MaxAcc(salto1+1)<MaxAcc(salto1)+40 %es un pico falso
        caida1=salto1+2;
    else
        caida1=salto1+1;
    end
    %Registramos el primer paso de valla
    saltos=salto1;
    caidas=caida1;
    last=caida1;

    %identificamos el resto de pasos
    while last<=length(MaxAcc)-5 %Queda una secuencia
        saltos=[saltos,last+3]; %#ok<AGROW>
        if MaxAcc(last+4)<MaxAcc(last+3)+40 %es un pico falso
            caidas=[caidas, last+5]; %#ok<AGROW>
        else
            caidas=[caidas, last+4]; %#ok<AGROW>
        end
        last=caidas(end);
    end
    %Si se quiere cambiar los indices para estar en la señal global
    %Por ahora se deja sin cambiar. Asi están todos los pasos, y estos 
    %indices indican cual es el salto y la caida
    %saltos=MaxAcc(saltos);
    %caidas=MaxAcc(caidas);

    %Buscamos el mínimo situado en las 10 muestras anteriores al evento
    for k = 1:length(MaxAcc)
        if MaxAcc(k) > 10 % Ensure we have enough samples to look back
            [~,minimo] = min(acc_tot(MaxAcc(k)-10:MaxAcc(k)-1));
            minimos(k) = minimo; %#ok<AGROW>
        else
            minimos(k) = 10; %#ok<AGROW>
        end
    end
    %y desplazamos los eventos esa cantidad
    IC = MaxAcc - 10 + minimos -1; % Adjust the event based on the minimum value

    %FC tiempo desde el 1º valor que baje de 20m/s2
    for k =1:length(MaxAcc)
        if MaxAcc(k)+30<length(acc_tot_raw)
            indice = find(acc_tot(MaxAcc(k)+5:MaxAcc(k)+30)<20,1);
            FC(k) = MaxAcc(k)+5+indice-1; %#ok<AGROW>
        else
            FC (k) =length(acc_tot); %#ok<AGROW>
        end
    end
end

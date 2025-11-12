function eventos=prov_evento_IC_COG_carrera(acc_vert_raw)
    orden=5;
    corte=30/120;
    acc_vert=filtro_paso_bajo_f0(acc_vert_raw,orden,corte);
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
    eventos=eventos_f;
end

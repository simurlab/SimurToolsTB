function [pasos,saltos,caidas]=prov_secuencia_110_vallas(acc_vert_raw,eventos,inicio,secuencia)
    pasos=eventos(eventos>inicio & eventos<inicio+1300);
    %análisis del tramo
    %amplitude en torno al primer paso del tramo
    paso1=max(acc_vert_raw(pasos(1)-1:pasos(1)+1));
    %1º paso en el que la amplitud es un 50% superior
    %se va a corresponder al salto
    for k=1:length(pasos)
        if max(acc_vert_raw(pasos(k)-1:pasos(k)+1))>1.5*paso1
            t1s1=k;
            break
        end
    end
    t1sec=t1s1+cumsum(secuencia);
    saltos=t1sec(1:2:end);
    caidas=t1sec(2:2:end);
end

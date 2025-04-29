function [IC,FC]=eventosespalda_carrera1(acc)

%opcion1: minimos y maximos de la acc resultante
acc_r=sqrt(sum(acc.^2,2));

%filtrado de media movil
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
acc_r = filtfilt(b,a,acc_r-acc_r(1))+acc_r(1);

d_acc=acc_r;
tam=size(d_acc);% tamaño de la señal de aceleración de entrada
tam=tam(1);

% Obtencion de la señal rectangular:
Datos2=d_acc(2:tam)-d_acc(1:tam-1);
Datos2=Datos2>=0;

% Obtencion de las señal de pulsos:
Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);

ultimos_IC=[];
ultimos_FC=[];

IC_aux=[];
FC_aux=[];

for i=51:(tam-2)
    th=(max(acc_r(i-50:i))+min(acc_r(i-50:i)))/2;
    IC_aux(i)=0; %#ok<*AGROW>
    FC_aux(i)=0;
    if (Datos2(i)<0) % se detecta un IC
         ultimos_IC= [ultimos_IC i];
    end
    if (Datos2(i)>0) % se detecta un FC
        ultimos_FC= [ultimos_FC i];
    end
    if(Datos2(i)>0 && acc_r(i)>th)% maximo del ciclo        
        if ~isempty(ultimos_IC)
            IC_aux(ultimos_IC(end))=1;
            ultimos_IC=[];
        end
        if ~isempty(ultimos_FC)
            FC_aux(ultimos_FC(end))=1;
            ultimos_FC=[];
        end
    end
end
IC=find(IC_aux==1)+1;
FC=find(FC_aux==1)+1;
end




function [IC,FC]=eventosespalda_carrera4(acc)

%opcion1: minimos y maximos de la acc resultante
acc_r_nof=sqrt(sum(acc.^2,2));

%filtrado de media movil
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
acc_r = filtfilt(b,a,acc_r_nof-acc_r_nof(1))+acc_r_nof(1);

d_acc=acc_r;
tam=size(d_acc);% tamaño de la señal de aceleración de entrada
tam=tam(1);

% Obtencion de la señal rectangular:
Datos2=d_acc(2:tam)-d_acc(1:tam-1);
Datos2=Datos2>=0;

% Obtencion de las señal de pulsos:
Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);

ultimos_MINC=[];
ultimos_MAXC=[];

MINC_aux=[];
MAXC_aux=[];

for i=51:(tam-2)
    th=(max(acc_r(i-50:i))+min(acc_r(i-50:i)))/2;
    MINC_aux(i)=0; %#ok<*AGROW>
    MAXC_aux(i)=0;
    if (Datos2(i)<0) % se detecta un IC
         ultimos_MINC= [ultimos_MINC i];
    end
    if (Datos2(i)>0) % se detecta un FC
        ultimos_MAXC= [ultimos_MAXC i];
    end
    if(Datos2(i)>0 && acc_r(i)>th)% maximo del ciclo        
        if ~isempty(ultimos_MINC)
            MINC_aux(ultimos_MINC(end))=1;
            ultimos_MINC=[];
        end
        if ~isempty(ultimos_MAXC)
            MAXC_aux(ultimos_MAXC(end))=1;
            ultimos_MAXC=[];
        end
    end
end
MINC=find(MINC_aux==1)+1;
MAXC=find(MAXC_aux==1)+1;

%Me aseguro de que es una secuencia lógica de IC-FC-IC-FC...
%con el mismo tamaño y ordenados
[MINC,MAXC]=eliminarduplicados(MINC,MAXC);

IC=[];
FC=[];
for i=1:length(MINC)
     [~,IC_temp]=min(acc_r_nof(MINC(i):MAXC(i)));
    IC_temp=IC_temp+MINC(i)-1;
    IC=[IC, IC_temp ];
    if i<length(MINC) 
        [~,FC_temp]=min(acc_r_nof(MAXC(i):MINC(i+1)));
    else
        [~,FC_temp]=min(acc_r_nof(MAXC(i):end));
    end
    FC_temp=FC_temp+MAXC(i)-1;
    FC=[FC, FC_temp ];
end

end




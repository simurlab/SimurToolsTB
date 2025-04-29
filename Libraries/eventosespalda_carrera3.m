

function [IC,FC]=eventosespalda3(acc,th)

%opcion3: IC-> minimo acc vertical; 
%         FC-> minimo derivada acc resultante (punto inflexion)

%IC-> minimo acc vertical -------------------------------------------------
%filtrado de media movil
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
acc = filtfilt(b,a,acc-acc(1))+acc(1);

v_acc=acc(:,2);
tam=size(v_acc);% tamaño de la señal de aceleración de entrada
tam=tam(1);

% Obtencion de la señal rectangular:
Datos1=v_acc(2:tam)-v_acc(1:tam-1);
Datos1=Datos1>=0;

% Obtencion de las señal de pulsos:
Datos1=Datos1(1:tam-2)-Datos1(2:tam-1);

%FC -> minimo deribada acc resultante (punto inflexion) -------------------
acc_r=sqrt(sum(acc.^2,2));
d_acc=diff(acc_r(:,1));
tam=size(d_acc);% tamaño de la señal de aceleración de entrada
tam=tam(1);

% Obtencion de la señal rectangular:
Datos2=d_acc(2:tam)-d_acc(1:tam-1);
Datos2=Datos2>=0;

% Obtencion de las señal de pulsos:
Datos2=Datos2(1:tam-2)-Datos2(2:tam-1);


% cambio de pie-> maximo acc resultante -----------------------------------
acc_r=sqrt(sum(acc.^2,2));
tam=size(acc_r);% tamaño de la señal de aceleración de entrada
tam=tam(1);

% Obtencion de la señal rectangular:
Datos3=acc_r(2:tam)-acc_r(1:tam-1);
Datos3=Datos3>=0;

% Obtencion de las señal de pulsos:
Datos3=Datos3(1:tam-2)-Datos3(2:tam-1);


ultimos_IC=[];
ultimos_FC=[];

IC_aux=[];
FC_aux=[];

for i=51:(tam-3)
    th=(max(acc_r(i-50:i))+min(acc_r(i-50:i)))/2;
    IC_aux(i)=0;
    FC_aux(i)=0;
   
     if (Datos1(i)<0) % se detecta un IC
         ultimos_IC= [ultimos_IC i];
    end
    if (Datos2(i)<0) % se detecta un FC
        ultimos_FC= [ultimos_FC i];
    end

    if(Datos3(i)>0 && acc_r(i)>th)% maximo del ciclo
        
        if ~isempty(ultimos_IC) && ~isempty(ultimos_FC)
            IC_aux(ultimos_IC(end))=1;
            ultimos_IC=[];
            FC_aux(ultimos_FC(1))=1;
            ultimos_FC=[];
        end
            
    end
   
end

IC=find(IC_aux==1)+1;
FC=find(FC_aux==1)+1;



end




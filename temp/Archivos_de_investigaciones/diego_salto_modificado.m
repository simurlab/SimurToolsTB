clc, clear all, close all

% Cargamos y calibramos datos
[a_cal, g_cal]=carga_calibra('f1',3,'N');

%% Experimento
% load salto.mat

% load f4.mat

% g_vert_raw=DOT3(:,1);

g_vert_raw=a_cal(:,2);
plot(g_vert_raw), hold on;

orden=5;
corte=30/120;
   
g_vert=filtro0(g_vert_raw,orden,corte);

tam=length(g_vert);

% Obtencion de la señal rectangular:
Datos=g_vert(2:tam)-g_vert(1:tam-1);
Datos=Datos>=0;

% Obtencion de la señal de pulsos:
Datos=Datos(1:tam-2)-Datos(2:tam-1);
maximos=find(Datos==1)+1;

altos=g_vert(maximos)>15;
indices_altos=find(altos);
eventos=maximos(indices_altos);
eventos=eventos';

eventos_f=[eventos(1)];
%Eliminamos eventos demasiado próximos
for k=eventos(2:end)
    if k>eventos_f(end)+15 %15/120 segundos 1/6 de segundo
        eventos_f=[eventos_f,k]; %#ok<AGROW>
    end
end
eventos=eventos_f;

%figure(1)
plot(g_vert)

% inicio=12200; % <-- PARÁMETRO A MODIFICAR
% inicio=56574;
% inicio=133849;
% inicio=201515;
inicio=273773;
trial0=eventos(eventos>inicio & eventos<inicio+1400);
plot(trial0, g_vert(trial0),'*g', 'MarkerSize',15);

% **** SEGUNDA CARRERA ****
inicio=137680; % <-- PARÁMETRO A MODIFICAR
trial1=eventos(eventos>inicio & eventos<inicio+1200); % <-- PARÁMETRO A MODIFICAR, el 1200
plot(trial1, g_vert(trial1),'*g', 'MarkerSize',15);
%análisis del tramo
paso1=max(g_vert_raw(trial1(1)-1:trial1(1)+1)); 
for k=1:length(trial1)
    if max(g_vert_raw(trial1(k)-1:trial1(k)+1))>1.5*paso1
        t1s1=k;
        break
    end
end
t1sec=k+cumsum([0,2,3,2,3,2,3,2,3,2,3,2]);
plot(trial1(t1sec),g_vert_raw(trial1(t1sec)),'r*');
pasos_valla=[inicio,0,0,0,0,0,0];
for valla=1:6
    pasos_valla(valla+1)=(trial1(t1sec(2*valla))+trial1(t1sec(2*valla-1)))/2;
end
tiempos_tramo1=diff(pasos_valla)/120


% **** TERCERA CARRERA ****
inicio=133718;
trial2=eventos(eventos>inicio & eventos<inicio+1700);
plot(trial2, g_vert(trial2),'*g');

%análisis del tramo
paso1=max(g_vert_raw(trial2(1)-1:trial2(1)+1)); 
for k=1:length(trial2)
    if max(g_vert_raw(trial2(k)-1:trial2(k)+1))>1.5*paso1
        t2s1=k;
        break
    end
end
t2sec=k+cumsum([0,2,3,2,3,2,3,2,3,2,3,2]);
plot(trial2(t2sec),g_vert_raw(trial2(t2sec)),'r*');

pasos_valla=[inicio,0,0,0,0,0,0];
for valla=1:6
    pasos_valla(valla+1)=(trial2(t2sec(2*valla))+trial2(t2sec(2*valla-1)))/2;
end
tiempos_tramo2=diff(pasos_valla)/120





inicio=201350; % PARÁMETRO A MODIFICAR: Indicar muestra asociada al comienzo de la carrera
trial3=eventos(eventos>inicio & eventos<inicio+1300);
plot(trial3, g_vert(trial3),'*g');


%análisis del tramo
paso1=max(g_vert_raw(trial3(1)-1:trial3(1)+1)); 
for k=1:length(trial3)
    if max(g_vert_raw(trial3(k)-1:trial3(k)+1))>1.5*paso1
        t3s1=k;
        break
    end
end
t3sec=k+cumsum([0,2,3,2,3,2,3,2,3,2,3,2]);
plot(trial3(t3sec),g_vert_raw(trial3(t3sec)),'r*');
pasos_valla=[inicio,0,0,0,0,0,0];
for valla=1:6
    pasos_valla(valla+1)=(trial3(t3sec(2*valla))+trial3(t3sec(2*valla-1)))/2;
end
tiempos_tramo3=diff(pasos_valla)/120




inicio=273610;
trial4=eventos(eventos>inicio & eventos<inicio+1300);
plot(trial4, g_vert(trial4),'*g');

%análisis del tramo
paso1=max(g_vert_raw(trial4(1)-1:trial4(1)+1)); 
for k=1:length(trial4)
    if max(g_vert_raw(trial4(k)-1:trial4(k)+1))>1.5*paso1
        t4s1=k;
        break
    end
end
t4sec=k+cumsum([0,2,3,2,3,2,3,2,3,2,3,2]);
plot(trial4(t4sec),g_vert_raw(trial4(t4sec)),'r*');
pasos_valla=[inicio,0,0,0,0,0,0];
for valla=1:6
    pasos_valla(valla+1)=(trial4(t4sec(2*valla))+trial4(t4sec(2*valla-1)))/2;
end
tiempos_tramo4=diff(pasos_valla)/120


% %Tiempos. 
% %Obtenidos a mano, de la gráfica. 
% t1s=12128;
% t1j=[12394,12527,12661,12796];
% t1a=[12452,12585,12717,12852];
% t1m=(t1j+t1a)/2;
% t1diff=diff([t1s,t1m])/120
% 
% t2s=56560;
% t2j=[56825,56957,57091,57223,57356,57489];
% t2a=[56882,57018,57148,57277,57411,57544];
% t2m=(t2j+t2a)/2;
% t2diff=diff([t2s,t2m])/120
% 
% t3s=133718;
% t3j=[133981,134113,134244,134377,134510,134641];
% t3a=[134037,134168,134301,134431,134564,134697];
% t3m=(t3j+t3a)/2;
% t3diff=diff([t3s,t3m])/120
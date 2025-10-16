% CALIBRA_EJEZ Calibracion estatica con accs y mags, metodo TRIAD.
%
% CALIBRA_EJEZ El procedimiento se explica con más detalle en el doc. 
% Se coloca el sensor en (6) posiciones static, se selecciona una ventana 
% en la que la signal no varie, y se trabaja con los valores medios.
% Devuelve una matriz de rotacion o de calibracion.
%
% Example:
%   Mrot=calibra_ejez(AccXsens, MagXsens, num_posiciones, t_movimiento, vCALIBRA, k_inicial, f_s, t_espera_calibra);
%   accs_cal=(Mrot*AccXsens(1:end,:)')';
%
%    See also CALIBRA_EJEX.

% Historial de Modificaciones: 
%  Desarrollado por JC.
%  Modificado por: Diego, 24-ene-07 -> adaptacion del codigo a siloptoolbox
%  Modificad por : JC, 12-nov-19 -> adaptacion a v0.3 


function [fROT] = calibra_ejez(AccXsens, MagXsens, num_posiciones, t_movimiento, vCALIBRA, k_inicial, f_s, t_espera_calibra)

% Inicializando variables:

% Poner a 1 para debugear:
pintamonos=1;

zona_util=30/100;   % fraccion del intervalo que NO se utilizara
k_espera_calibra=floor(f_s*t_espera_calibra); % lo mismo, pero en muestras
k_movimiento=floor(f_s*t_movimiento); % lo mismo, pero en muestras
rot_accs=AccXsens;
% Definici?n de la zona util para calibrar, en muestras:
frac_bloque=floor((zona_util)*k_espera_calibra);
% Por si quisieramos cambiar los ejes de la posici?nm inicial del sensor:
vINIPOS(1,:)=[ 1  0  0   0  1  0   0  0  1];
M0=vec2mat(vINIPOS(1,:),3);

ww=[650	730
920	1000
1150	1230
1370	1450
1590	1670
1850	1930];

%Separar muestras en posiciones estaticas del experimento
for cpos = 1:1:size(ww)
   win_ini = ww(cpos,1);
   win_fin = ww(cpos,2);
   qqi = ((cpos-1)*80)+1;
   qqf = qqi + 80;
  
  %Calculo de acceleraciones
  AccXS_Static(qqi:qqf,:) = AccXsens(win_ini:win_fin,1:3);
  
  
    %Calculo de Magneticos
  MagXS_Static(qqi:qqf,:) = MagXsens(win_ini:win_fin,1:3);
 
 
  % valores medios de accs y mags:
  acc_pos=mean(AccXsens(win_ini:win_fin,:));
  mag_pos=mean(MagXsens(win_ini:win_fin,:));
   
  % vectores unitarios de accs y mags:
  vacc(cpos,:)=acc_pos/norm(acc_pos);
  vmag(cpos,:)=mag_pos/norm(mag_pos);
    
  % METODO TRIAD:    
    zlocal=vacc(cpos,:);
    ylocal=cross(vacc(cpos,:),vmag(cpos,:));
    xlocal=cross(ylocal,zlocal);
    % guardamos la matriz completa en forma de vector:
    vROTA(cpos,:)=[xlocal ylocal zlocal];
    % y en forma de matriz:
    mROTMini=[xlocal' ylocal' zlocal'];
    % mROTMini=vec2mat(vROTA(cpos,:),3)';
    mROTM=mROTMini*vec2mat(vCALIBRA(cpos,:),3)'*M0;
    ROTACOMPLETA(cpos,:)=reshape(mROTM',[],9);
    
    % dibujo de las accs originales vs las calibradas:
    rot_accs(win_ini:win_fin,:)=(mROTM'*AccXsens(win_ini:win_fin,:)')';
    % Para debugear se pintan las senyales y las ventanas utilies:
    if (pintamonos==1),
        figure(cpos); subplot(311);
        plot(AccXsens); axis([win_ini win_fin -10 10]); grid; 
        line([win_ini win_ini],[-10 10]);
        line([win_fin win_fin],[-10 10]);
        subplot(312);
        plot(MagXsens); axis([win_ini win_fin -10 10]); grid;  
        line([win_ini win_ini],[-10 10]);
        line([win_fin win_fin],[-10 10]);
        subplot(313);
        plot(rot_accs); axis([win_ini win_fin -10 10]); grid;  
        input('PAUSA... dale al RETURN para seguir...');
    end
    %ini_cpos(cpos+1)=ini_cpos(cpos)+(k_bloque(cpos));
    
 end


end


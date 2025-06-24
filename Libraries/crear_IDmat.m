function crea_IDmat (prueba_name)  
%% Generamos un unico ID.mat con los datos y las condiciones de cada experimento.
%  Debería ejecutarse una sola vez para crear la BD.
%

%clear, clc

%Prueba='a1';
Prueba=prueba_name;
myfilen= string(string('Prueba_') + Prueba)
load(myfilen);
condiciones;
I1=IMU1; I2=IMU2; I3=IMU3;

for numimus=1:NumSensores,

IM1total=[];
IM2total=[];
IM3total=[];
for ii=1:length(Intervalos(:,1)),
    IM1=I1(Intervalos(ii,1):Intervalos(ii,2),:);
    IM2=I2(Intervalos(ii,1):Intervalos(ii,2),:);
    IM3=I3(Intervalos(ii,1):Intervalos(ii,2),:);

    IM1total=[IM1total ; IM1];
    IM2total=[IM2total ; IM2];
    IM3total=[IM3total ; IM3];

   myfilen= string(Prueba +  string('0') + string(ii))
   
    %datos_totales = {load(IM1), fileread(fullfile('condiciones.m')) };
    datos_totales = {IM1, IM2, IM3, fileread(fullfile('condiciones.m')) };
    save(myfilen, 'datos_totales')

end

myfilen= string(Prueba + string('xx'))
   
    %datos_totales = {load(IM1), fileread(fullfile('condiciones.m')) };
    datos_totales = {IM1total, IM2total, IM3total, fileread(fullfile('condiciones.m')) };
    save(myfilen, 'datos_totales')


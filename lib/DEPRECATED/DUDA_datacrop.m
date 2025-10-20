% DATACROP Elimina manualmente un rango de datos de un archivo de xsens.
%
% DATACROP Elimina manualmente un rango de datos de un archivo de xsens. 
% Primero pregunta por el nombre del archivo de datos. Luego los
% dibuja para ayudar a definir las muestras inicial y final de
% datos a eliminar. Luego los elimina, los dibuja de nuevo, y 
% guarda los resultados en nombrearchivo.log.clean
% 
% Syntax: 
%   datacrop
% 
% Examples: 
%   datacrop
%
% See also: load, limpia_estatico

% Author:   Juan C. Alvarez
% History:  18.05.2006 creado
%           01.12.2006 formateado para la silopTB
%

%% Seleccion del archivo a limpiar
clear data_file;
data_file=input('Nombre del archivo de datos a limpiar: ','s');
jc=load(data_file);
display('Archivo le�do OK, numero total de muestras:' );tam=size(jc);
p1=1;   % muestra inicial de estudio
p2=tam(1,1); % Muestra final de estudio, normalmente todo
figure, subplot(211), plot(jc), grid, xlabel('Datos iniciales');

display('Seleccione el intervalo de muestras a eliminar.');
el1=input('Muestra inicial: ');
el2=input('Muestra final: ');
jc=[jc(p1:el1,:);  jc(el2:p2,:)];
subplot(212),plot(jc),grid, xlabel('Datos limpiados');

s=[data_file, '.clean'];
save(s,'jc','-ASCII');

% Fin del script
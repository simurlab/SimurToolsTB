% CALIBRA_ANATOMICAL Reorient the obtained data so that they coincide approximately with 
%   the anatomical axes.
%
% CALIBRA_ANATOMICAL Taking as a base a signal, in which the initial instants the only acceleration 
%    is that of gravity, it calculates the rotation matrix that realigns the reference axes so that 
%    the accelerations correspond to the antero-posterior, mid-lateral and vertical axes.
%
% Sintax: Mrot=calibra_anatomical(acc_static,R_approx)
%
% Input parameters:
%
%   acc_static: matrix with the accelerations in static position used for calibration.
%
%   R_approx: Parameter indicating the approximate orientation that is initially estimated. 
%           It can be given in three ways:
%           1) if the parameter is not included it is assumed to be in the standard position:
%                 column 1=vertical axis
%                 column 2=lateral mid-axis change of sign
%                 column 3= anteroposterior axis
%           2) a vector can be given with three numbers indicating in which column are the 
%              antero-posterior, mid lateral and vertical accelerations respectively. 
%              If any axis is inverted, it is put with a negative sign.  
%              The default orientation described in case 1) corresponds to [ 3 , -2 , 1 ]
%           3) an initial rotation matrix can be given to align the axes to leave them in 
%              the antero-posterior, mid lateral and vertical order.
%
% Output parameters:
%
%   Mrot - Rotation matrix that transforms the initial data to the anatomical axes. 
%          If original data are columns of a matrix (nx3) the way to obtain the data referred 
%          to the anatomical axes will be to make the multiplication:
%               dat_anat=(data_sensor*Mrot')
%          or 
%               dat_anat=(Mrot*sensor_data')'
%
% Examples:
%

% Author:   Rafael C. 
% History:  12.11.2000  file created
%                       full description at the top
%           19.11.2000  suggestions for in-code comments added
% Author:   JC.
%           12.12.2007  Adaptada correctamente a la toolbox.
%           03.12.2019  Modified for SiMurTools
%           26.03.2025  Opcion para devolver ejes en el convenio ISB 

function RR=calibra_anatomical(datos,v_orden)

if (nargin==1)
  v_orden=[3,-2,1]; %Orden estandar "anatomico" en el proyecto silop
end

[tam1,tam2]=size(v_orden);
if (tam1*tam2==3)
    orden=v_orden;
    R=zeros(3,3);
    for k=1:3
        R(k,abs(orden(k)))=sign(orden(k));
    end
else
    error('Matriz R de formato incorrecto');
end

% Ordenar los ejes de los datos
datos=datos*R';

% Calculamos la direccion de la gravedad como la suma vectorial del valor 
% medio de las aceleraciones dividido por el modulo
ug=mean(datos,1)/norm(mean(datos,1));

% Hacemos una rotacion en torno al eje Z (direccion vertical) para que en
% el nuevo sistema de coordenadas las aceleracion de la gravedad quede
% comprendida en el plano sagital (X,Z)

proy_ug=[ug(1) ug(2)]; % Proyeccion de la gravedad sobre el plano XY
proy_ug=proy_ug/norm(proy_ug); % Vector unitario en la direccion de la proyeccion
c1=proy_ug(1);
c2=proy_ug(2);

% Se gira para anular la componente mas cercana a cero
if (abs(c1)>abs(c2))
  % Se gira para hacer la componente Y=0;
  if (c1>0)
    Rz=[c1 c2 0;-(c2) c1 0;0 0 1];
  else
    Rz=[-c1 -(c2) 0;  c2 -c1 0; 0 0 1];
  end
  datos=datos*Rz';
    
  % Hacer una rotacion respecto del eje mediolateral (Y) para anular la
  % componente anteroposterior de la gravedad
  ug=mean(datos,1)/norm(mean(datos,1));
  
  % Tomar la proyeccion de ug sobre el plano sagital
  c1=ug(1);
  c3=ug(3);
  Ry=[c3 0 -(c1); 0 1 0; c1 0 c3];
  
  RR=Ry*Rz*R;
else
  % Se gira para hacer la componente Y=0;
  if (c2>0)
    Rz=[c2 -(c1) 0;  c1 c2 0; 0 0 1];
  else
    Rz=[-c2 c1 0; -(c1) -c2 0; 0 0 1];
  end
  datos=datos*Rz';
    
  % Hacer una rotacion respecto del eje mediolateral (Y) para anular la
  % componente anteroposterior de la gravedad
  ug=mean(datos,1)/norm(mean(datos,1));
  
  % Tomar la proyeccion de ug sobre el plano sagital
  c2=ug(2);
  c3=ug(3);
  Rx=[1 0 0; 0  c3 -(c2);0  c2 c3];

  RR=Rx*Rz*R;


end

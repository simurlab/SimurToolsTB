% FILTRO0 Filtro paso bajo de fase cero
%
% FILTRO0 Implementa un filtro FIR paso bajo de fase 0. 
% 
% Syntax: Y=filtro0(datos,orden,corte)
% 
% Input parameters:
%   datos-> señal a filtrar
%   orden -> orden del filtro FIR a usar
%   corte-> frecuencia de corte normalizada. La frecuencia de corte debe estar entre 0 y 1, con 1
% 		correspondiendo a la mitad de la frecuencia de muestreo
%
% Output parameters:
%  Y -> señal filtrada
%
% Examples:
% %filtramos a 2.5Hz una señal muestreada a 100Hz. fcorte=0.05*100/2
% filtrado=filtro0(datos,60,0.05); 
%


function Y=filtro0(datos,orden,corte)

b=fir1(orden,corte,'low'); % diseño de filtro FIR paso bajo

% Realiza un filtrado digital de fase cero procesando los datos de entrada,
% datos, tanto en dirección directa como inversa.
warning off
Y=filtfilt(b,1,datos);
warning on
end

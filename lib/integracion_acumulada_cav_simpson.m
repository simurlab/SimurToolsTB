function p = integracion_acumulada_cav_simpson(v)
% CUM_CAM_SIMP Integral numérica acumulada mediante la regla de Cavalieri-Simpson.
%
%   p = integracion_acumulada_cav_simpson(v)
%
%   Esta función extiende la idea de cumsum y cumtrapz para realizar la 
%   integral acumulada de una señal usando la aproximación de 
%   Cavalieri-Simpson:
%
%       y(t) = y(t-1) + (1/6) * (x(t-1) + 4*x(t) + x(t+1))
%
% INPUT:
%   v : vector columna o fila con la señal a integrar.
%
% OUTPUT:
%   p : señal integrada acumulada.
%
% EXAMPLE:
%   x = 0:0.1:10;
%   v = sin(x);             % señal a integrar
%   p = integracion_acumulada_cav_simpson(v);    % integral aproximada
%   plot(x, v, 'b', x, p(1:end-1), 'r')
%   legend('Señal original','Integral aproximada')
%

%
% Author:   Diego
% History:  xx.yy.zz    creación del archivo
%           29.09.2025  normalizada y modernizada
%

    % Extender señal con ceros para bordes
    v = [0;0;v;0;0];

    % Inicializar salida
    p = zeros(length(v)-1,1);

    % Integral acumulada por Cavalieri-Simpson
    for k = 2:(length(v)-1)
        p(k) = p(k-1) + (1/6) * (v(k-1) + 4*v(k) + v(k+1));
    end
end

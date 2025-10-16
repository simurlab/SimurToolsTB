function pos = doble_integracion_msi(aceleracion, freq)
% DOBLE_INTEGRACION_MSI Doble integración de la aceleración con método MSI.
%
%   pos = doble_integ_msi(aceleracion, freq)
%
%   Esta función estima la posición a partir de la aceleración aplicando
%   el método MSI (Mean Subtraction Integration). El método supone:
%       1) La aceleración tiene media cero.
%       2) En consecuencia, la velocidad final es igual a la velocidad inicial.
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo en Hz.
%
% OUTPUT:
%   pos : vector con la señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:1;                          % tiempo en segundos
%   a = [ones(1,50) -ones(1,50)];          % aceleración con media cero
%   p = doble_integ_msi(a, 100);
%   plot(t, p), xlabel('Tiempo [s]'), ylabel('Posición [u]')
%
% 
% Author:   Diego
% History:  30.11.2019   renombrada (JC)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Filtrado por media cero --------------------
    acc_filt = aceleracion - mean(aceleracion);

    % -------------------- Primera integración → velocidad --------------------
    vel = cumsum(acc_filt / freq);

    % -------------------- Segunda integración → posición --------------------
    pos = cumsum(vel / freq);
end

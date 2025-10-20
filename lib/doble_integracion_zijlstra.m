function pos = doble_integracion_zijlstra(aceleracion, freq)
% DOBLE_INTEGRACION_ZIJLSTRA Doble integración con el método de Zijlstra/Kose.
%
%   pos = doble_integracion_zijlstra(aceleracion, freq)
%
%   Esta función estima la posición a partir de una señal de aceleración
%   aplicando el método de Zijlstra (también atribuido a Kose). El método:
%       1) Supone aceleración de media cero.
%       2) Supone aceleración inicial y final ≈ 0 (evita distorsión en
%          los bordes de la señal).
%       3) Supone velocidad de media cero (posición inicial ≈ final).
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo (Hz).
%
% OUTPUT:
%   pos : señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:2;
%   a = [zeros(1,20) 2*ones(1,100) zeros(1,80)];
%   p = doble_integ_zijlstra(a, 100);
%   plot(t, p), xlabel('Tiempo [s]'), ylabel('Posición [u]')
%
% See also: doble_integracion, doble_integ_msi, doble_integ_lri, doble_integ_ddi, doble_integ_ofi
%
% Author:   Diego
% History:  (sin fecha en original)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Filtro pasa-bajo --------------------
    [b, a] = butter(2, 20/(freq/2));
    acc_filt = filtfilt(b, a, aceleracion);

    % -------------------- Doble integración --------------------
    vel = cumsum(acc_filt / freq);
    pos = cumsum(vel / freq);

    % -------------------- Filtro pasa-alto para eliminar drift --------------------
    [b, a] = butter(2, 0.1/(freq/2), 'high');
    pos = filtfilt(b, a, pos);
end

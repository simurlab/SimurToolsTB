function pos = doble_integracion_ofi(aceleracion, freq)
% DOBLE_INTEGRACION_OFI Doble integración de la aceleración con método OFI.
%
%   pos = doble_integracion_ofi(aceleracion, freq)
%
%   Esta función estima la posición a partir de la aceleración aplicando
%   el método OFI (Optimal Frequency Integration). El método:
%       1) Supone aceleración de media cero (velocidad inicial ≈ final).
%       2) Supone aceleración inicial y final ≈ 0 (para evitar distorsión
%          por el filtro paso alto).
%       3) Busca la frecuencia de corte óptima que minimiza el error de
%          posición final tras doble integración.
%       4) Combina integración directa e inversa mediante una función de
%          peso suavizada.
%
% INPUT:
%   aceleracion : vector con la señal de aceleración.
%   freq        : frecuencia de muestreo en Hz.
%
% OUTPUT:
%   pos : vector con la señal de posición estimada.
%
% EXAMPLE:
%   t = 0:0.01:5;
%   a = [zeros(1,100) 2*ones(1,200) zeros(1,200)];
%   p = doble_integ_ofi(a, 100);
%   plot(t, p), xlabel('Tiempo [s]'), ylabel('Posición [u]')
%
%
% Author:   Diego
% History:  30.11.2019   renombrada (JC)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Rango de frecuencias candidato --------------------
    rango = 0.01:0.01:0.15;
    error_min = Inf;

    % -------------------- Búsqueda de frecuencia óptima --------------------
    for f = rango
        [b,a] = butter(2, f/(freq/2), 'high');
        acc_filt = filter(b, a, aceleracion);

        vel_filt = cumcamsimp(acc_filt / freq); % integración personalizada

        % Condición: velocidad final pequeña
        if abs(vel_filt(end)) < 0.1
            pos_filt = cumcamsimp(vel_filt / freq);
            error_actual = abs(pos_filt(end));

            if error_actual < error_min
                error_min = error_actual;
                f_opt = f;
                vel_ok = vel_filt; %#ok<NASGU>
                pos_ok = pos_filt; %#ok<NASGU>
            end
        end
    end

    % -------------------- Filtro óptimo --------------------
    [b,a] = butter(2, f_opt/(freq/2), 'high');
    acc_filt = filter(b, a, aceleracion);

    % -------------------- Velocidad directa --------------------
    vel_directa = cumcamsimp(acc_filt / freq);

    % -------------------- Velocidad inversa --------------------
    vel_inversa = zeros(size(vel_directa));
    vel_inversa(end:-1:1) = cumcamsimp(-acc_filt(end:-1:1) / freq);

    % -------------------- Función de peso suavizada --------------------
    n = length(vel_inversa);
    tiempo = (1:n)';
    beta = 0.1;
    s = atan((2*tiempo - n) / (2*n*beta));
    w = (s - s(1)) / (s(end) - s(1));

    % -------------------- Combinación de velocidades --------------------
    vel_combinada = vel_inversa .* w + vel_directa .* (1 - w);

    % -------------------- Integración final → posición --------------------
    pos = cumcamsimp(vel_combinada / freq);
end

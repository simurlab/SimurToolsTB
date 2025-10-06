function datos = mostrar_orientacion_solido_rigido(matriz, paso, total, pos1, marcadores, mostrar_marcadores)
%MOSTRAR_ORIENTACION_SOLIDO_RIGIDO Representa la orientación de un sólido rígido.
%
%   datos = mostrar_orientacion_solido_rigido(matriz, paso, total, pos1, marcadores, mostrar_marcadores)
%
%   Esta función calcula y representa la orientación de un sólido rígido
%   definido por un conjunto de marcadores, a partir de sus cuaterniones
%   y posiciones obtenidas desde un archivo MOCAP.
%
% INPUT:
%   matriz            : matriz leída desde un archivo CSV con los datos.
%   paso              : salto de frames para representar la orientación
%                       (para ahorrar tiempo en animaciones).
%   total             : booleano (true/false). 
%                       - true  → se representa toda la secuencia.
%                       - false → se representa solo una parte.
%   pos1              : columna de la matriz correspondiente al primer
%                       componente del cuaternión.
%   marcadores        : vector con los índices de los marcadores que
%                       definen el sólido rígido.
%   mostrar_marcadores: booleano (true/false). 
%                       - true  → se representan sólido y marcadores.
%                       - false → solo el sólido rígido.
%
% OUTPUT:
%   datos : trayectoria del centro del sólido rígido.
%
% EJEMPLO:
%   datos = mostrar_orientacion_solido_rigido(M, 25, true, 19, [26 29 32], true);
%
%   % Donde M es la matriz cargada desde el CSV del sistema MOCAP.
%
% See also: mostrar_marcadores_solido_rigido, trayectoria_marcador, quat2tform
%
% Author:   (original) Diego
% History:  ??.??.20??   creado
%           30.09.2025   normalizada y modernizada

    % --- Extraer cuaterniones ---
    a = matriz(:, pos1);
    b = matriz(:, pos1+1);
    c = matriz(:, pos1+2);
    d = matriz(:, pos1+3);
    quat = [d, a, b, c];
    quat_norm = normalize(quat); % normalización

    % --- Trayectoria del sólido rígido ---
    solidorig = trayectoria_marcador(matriz, pos1+4);

    % --- Representación inicial ---
    hold off
    mostrar_marcadores_solido_rigido(matriz, marcadores, mostrar_marcadores);
    hold on

    % --- Rango de representación ---
    if total
        max_iter = length(solidorig);
        i = 1;
    else
        max_iter = 2000;
        i = 1300;
    end

    % --- Representar frames del sólido ---
    T0 = eye(4);
    while i < max_iter
        T1 = trvec2tform(solidorig(i,:)) * quat2tform(quat_norm(i,:)) * T0;
        pframe(T1, 'green', 50); % representación del frame en verde
        title('MOVIMIENTO RIGID BODY');
        legend('Representación');
        grid on;
        hold on;
        i = i + paso;
    end

    % --- Salida ---
    datos = solidorig;
end

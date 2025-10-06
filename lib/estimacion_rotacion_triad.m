function R = estimacion_rotacion_triad(acc, mg, acc0, mg0)
%ESTIMACION_ROTACIÓN_TRIAD Algoritmo TRIAD para la estimación de la rotación.
%
%   R = triad_estatico(acc, mg, acc0, mg0)
%
%   Este algoritmo implementa el método TRIAD para estimar la matriz de
%   rotación a partir de medidas de aceleración y campo magnético en una
%   posición estática. Devuelve la rotación que transforma de los ejes
%   actuales a los ejes de referencia iniciales.
%
%   INPUT:
%       acc  : vector [1x3] con los valores de aceleración actual 
%              [acc_x, acc_y, acc_z].
%       mg   : vector [1x3] con los valores del campo magnético actual 
%              [mg_x, mg_y, mg_z].
%       acc0 : vector [1x3] con los valores de aceleración en rotación 0.
%       mg0  : vector [1x3] con los valores del campo magnético en rotación 0.
%
%   OUTPUT:
%       R : matriz de rotación (3x3) que convierte del sistema actual al
%           sistema inicial.
%
%   EXAMPLE:
%       acc  = [0.1, 0.0, 9.7];
%       mg   = [0.3, 0.1, -0.5];
%       acc0 = [0.0, 0.0, 9.81];
%       mg0  = [0.2, 0.0, -0.6];
%       R = estimacion_rotacion_triad(acc, mg, acc0, mg0);
%
%
%   History:
%       - 29/07/2019: Versión inicial por Diego.
%       - 02/10/2025: Adaptación a convención snake_case y documentación.
%

    % --- Base actual ---
    V1 = acc / norm(acc);           % Primer vector normalizado
    tmp = mg / norm(mg);
    V2 = cross(V1, tmp);            % Perpendicular entre acc y mag
    V2 = V2 / norm(V2);
    V3 = cross(V1, V2);             % Tercer vector ortogonal
    V = [V1', V2', V3'];

    % --- Base de referencia (rotación 0) ---
    v1 = acc0 / norm(acc0);
    tmp = mg0 / norm(mg0);
    v2 = cross(v1, tmp);
    v2 = v2 / norm(v2);
    v3 = cross(v1, v2);
    v = [v1', v2', v3'];

    % --- Matriz de rotación ---
    R = v * inv(V);

end

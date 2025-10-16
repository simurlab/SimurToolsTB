function [angulo, fiable] = orientacion_compas(campo_x, campo_y, campo_z, angulo0)
%ORIENTACION_COMPAS Calcula la orientación a partir de un compás magnético.
%
%   [angulo, fiable] = orientacion_compas(campo_x, campo_y, campo_z, angulo0)
%
%   Esta función estima la orientación en el plano horizontal a partir de
%   los datos de un compás magnético situado en el COG (centro de gravedad).
%   Además, evalúa la fiabilidad de la lectura según la componente vertical
%   del campo magnético.
%
% INPUT:
%   campo_x : componente X (anteroposterior) del vector magnético.
%   campo_y : componente Y (mediolateral) del vector magnético.
%   campo_z : componente Z (vertical) del vector magnético.
%   angulo0 : (opcional) ángulo de referencia a restar. Por defecto = 0.
%             Se conserva entre llamadas mediante una variable persistente.
%
% OUTPUT:
%   angulo : vector con el ángulo de orientación en radianes (desenvuelto).
%   fiable : vector lógico (1 = fiable, 0 = no fiable) en cada instante.
%
% EJEMPLO:
%   cx = cos(linspace(0,2*pi,100));
%   cy = sin(linspace(0,2*pi,100));
%   cz = zeros(size(cx));
%   [ang, ok] = orientacion_compas(cx, cy, cz);
%   plot(rad2deg(ang)), title('Orientación compás [°]')
%
% See also: orientacion_giroscopo, orientacion_kalman
%
% Author:   Diego Álvarez
% History:  ??.??.200?   creado
%           13.12.2007   adaptado para uso online y documentado
%           30.09.2025   normalizada y modernizada

    % --- Variable persistente para referencia angular ---
    persistent ref
    if isempty(ref)
        ref = 0;
    end

    % Actualizar referencia si se pasa angulo0
    if nargin > 3
        ref = angulo0;
    end

    % --- Cálculo del ángulo en el plano horizontal ---
    angulo = unwrap(atan2(campo_y, campo_x)) - ref;

    % --- Fiabilidad: el campo no debe apuntar fuera del plano horizontal ---
    fiable = (campo_z < 1 & campo_z > -1);
end

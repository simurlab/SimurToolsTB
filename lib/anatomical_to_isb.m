function [data_out, R] = anatomical_to_isb(data_in)
% ANATOMICAL_TO_ISB Convierte coordenadas del sistema anatómico al sistema ISB.
%
%   [data_out, R] = anatomical_to_isb(data_in)
%
% INPUT:
%   data_in  - Matriz Nx3 con las coordenadas en el sistema anatómico.
%
% OUTPUT:
%   data_out - Matriz Nx3 con las coordenadas transformadas al sistema ISB.
%   R        - Matriz de transformación 3x3 usada en la conversión.
%
% EXAMPLE:
%   % Transformar un vector en sistema anatómico a ISB:
%   coords_anat = [1 2 3];
%   [coords_isb, R] = anatomical_to_isb(coords_anat);
%
% Author:   JC
% History:  xx.yy.zz    Diego  creación del archivo
%           29.09.25    normalizada y modernizada
%

    orden = [1 3 -2];
    R = zeros(3,3);
    for k = 1:3
        R(k, abs(orden(k))) = sign(orden(k));
    end

    data_out = data_in * R';
end

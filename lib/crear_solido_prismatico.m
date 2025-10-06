function P = crear_solido_prismatico()
%CREAR_SOLIDO_PRISMATICO Genera un sólido rígido prismático definido por 8 vértices.
%
%   P = crear_solido_prismatico()
%
%   Esta función devuelve la matriz de coordenadas de un sólido rígido
%   prismático (tipo cuña) definido por 8 vértices. El sólido se representa
%   en forma de matriz de 3x16, de forma que cada columna corresponde a un
%   vértice en coordenadas cartesianas (X, Y, Z), listo para ser usado en
%   representaciones con plot3.
%
%   La cuña se define mediante un parámetro de "puntiagudez" (def), que
%   controla la simetría del sólido entre los valores 0 y 0.5.
%
%   OUTPUT:
%       P : matriz 3x16 con las coordenadas cartesianas de los vértices.
%
%   EJEMPLO:
%       P = crear_solido_prismatico();
%       plot3(P(1,:), P(2,:), P(3,:), 'o-'); grid on; axis equal;
%
% Author:  
% History:  xx.yy.zz   versión inicial
%           29.09.2025 normalizada y modernizada

    % Factor de puntiagudez de la cuña (0–0.5)
    def = 0.45;

    % Definición de vértices
    A = [0    0    0];
    B = [1    0    0];
    C = [def  1.5  0];
    D = [0    0    0.5];
    E = [def  1.5  0.5];
    F = [1    0    0.5];
    G = [1-def 1.5 0];
    H = [1-def 1.5 0.5];

    % Matriz de salida (3x16)
    P = [A; B; F; H; G; C; A; D; E; H; F; D; E; C; G; B]';
end

function dibujar_voxel(start, size_voxel, color_voxel, alpha)
%DIBUJAR_VOXEL Dibuja un voxel 3D en un gráfico tridimensional.
%
%   dibujar_voxel(start)
%   dibujar_voxel(start, size_voxel)
%   dibujar_voxel(start, size_voxel, color_voxel, alpha)
%
%   INPUT:
%       start       : vector [1x3] con la posición inicial del voxel 
%                     en coordenadas [x, y, z].
%       size_voxel  : vector [1x3] con el tamaño del voxel [dx, dy, dz].
%                     Por defecto [1,1,1].
%       color_voxel : color del voxel (string o caracter, ej. 'r', 'b', 'g').
%                     Por defecto 'b' (azul).
%       alpha       : nivel de transparencia (1 = opaco, 0 = transparente).
%                     Por defecto 1.
%
%   OUTPUT:
%       Ninguno. La función dibuja directamente el voxel en la figura activa.
%
%   EXAMPLE:
%       dibujar_voxel([2 3 4],[1 2 3],'r',0.7);
%       axis([0 10 0 10 0 10]);
%       view(60,-30);
%
%   See also: pframe, psolido, plot3
%
%   History:
%       - 15/04/2003: Versión inicial por Suresh Joel (SiMuR Lab).
%       - 02/10/2025: Adaptación a convención snake_case, comentarios en español.
%

    % --- Manejo de argumentos ---
    switch nargin
        case 1
            size_voxel = [1 1 1];
            color_voxel = 'b';
            alpha = 1;
        case 2
            color_voxel = 'b';
            alpha = 1;
        case 3
            alpha = 1;
        case 4
            % todo definido
        otherwise
            error('Número incorrecto de argumentos para voxel_draw');
    end

    % --- Definición de los 8 vértices ---
    x = [start(1) + [0 0 0 0 size_voxel(1) size_voxel(1) size_voxel(1) size_voxel(1)]; ...
         start(2) + [0 0 size_voxel(2) size_voxel(2) 0 0 size_voxel(2) size_voxel(2)]; ...
         start(3) + [0 size_voxel(3) 0 size_voxel(3) 0 size_voxel(3) 0 size_voxel(3)]]';

    % --- Dibujo de las caras ---
    for n = 1:3
        if n == 3
            x = sortrows(x, [n,1]);
        else
            x = sortrows(x, [n n+1]);
        end

        % Cara 1
        temp = x(3,:);
        x(3,:) = x(4,:);
        x(4,:) = temp;
        h = patch(x(1:4,1), x(1:4,2), x(1:4,3), color_voxel, ...
                  'LineStyle', ':', 'LineWidth', 0.1);
        set(h, 'FaceAlpha', alpha);

        % Cara 2
        temp = x(7,:);
        x(7,:) = x(8,:);
        x(8,:) = temp;
        h = patch(x(5:8,1), x(5:8,2), x(5:8,3), color_voxel, ...
                  'LineStyle', ':', 'LineWidth', 0.5);
        set(h, 'FaceAlpha', alpha);
    end

end

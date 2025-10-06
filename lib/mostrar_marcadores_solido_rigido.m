function datos = mostrar_marcadores_solido_rigido(matriz, marcadores, representar)
%MOSTRAR_MARCADORES_SOLIDO_RIGIDO Grafica los marcadores que definen un sólido rígido.
%
%   datos = mostrar_marcadores_solido_rigido(matriz, marcadores, representar)
%
%   Esta función extrae y visualiza los marcadores que forman un sólido rígido
%   a partir de una matriz de puntos. Además de la representación gráfica,
%   devuelve las trayectorias del sólido rígido y muestra métricas de
%   eficiencia en consola.
%
% INPUT:
%   matriz      : matriz con los datos de los marcadores.
%   marcadores  : vector con los índices de los marcadores que forman
%                 el sólido rígido.
%   representar : booleano (true/false). Si es true, se grafica el sólido.
%
% OUTPUT:
%   datos : matriz con las posiciones del sólido rígido detectado
%           en cada frame válido.
%
% EJEMPLO:
%   datos = mostrar_marcadores_solido_rigido(M, [26 29 32], true);
%
%   % Donde M es la matriz de puntos cargada desde MOCAP.
%
%
% Author:   (original) Diego
% History:  ??.??.20??   creado
%           30.09.2025   normalizada y modernizada

    num_marc = length(marcadores);
    trayectoria = [];
    trayectoria2 = [];

    % Construir trayectoria concatenando cada marcador
    for i = 1:num_marc
        trayectoria = [trayectoria, trayectoria_marcador(matriz, marcadores(i))]; %#ok<AGROW>
    end

    long = num_marc * 3;
    max_len = size(trayectoria, 1);

    for i = 1:max_len
        t = trayectoria(i, :);
        s = matriz(i, 1:6);

        if norm(t) ~= 0
            trayectoria2 = [trayectoria2; s t]; %#ok<AGROW>

            % Extraer coordenadas de cada marcador
            x1 = [];
            y1 = [];
            z1 = [];
            for j = 1:3:long
                x1 = [x1 t(j)]; %#ok<AGROW>
                y1 = [y1 t(j+1)]; %#ok<AGROW>
                z1 = [z1 t(j+2)]; %#ok<AGROW>
            end

            % Cerrar el polígono
            x1 = [x1 t(1)];
            y1 = [y1 t(2)];
            z1 = [z1 t(3)];

            % Plot 3D
            if representar
                plot3(x1, y1, z1)
                hold on
            else
                hold off
            end
        end
    end

    % Salida
    datos = trayectoria2;

    % Eficiencia
    eficiencia = (size(trayectoria2, 1) / size(trayectoria, 1)) * 100;
    fprintf("Se tienen %i posiciones de sólido rígido de %i frames\n", size(trayectoria2,1), size(trayectoria,1));
    fprintf("Eficiencia de %2.3f %%\n", eficiencia);
    fprintf("------------------------------------------------------------\n");
end

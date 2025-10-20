function marcador = trayectoria_marcador(matriz, idx)
%TRAYECTORIA_MARCADOR Obtiene y representa la trayectoria 3D de un marcador.
%
%   marcador = trayectoria_marcador(matriz, idx)
%
%   INPUT:
%       matriz : matriz con todas las coordenadas de los marcadores.
%                Cada marcador ocupa 3 columnas consecutivas (X, Y, Z).
%       idx    : índice de la primera columna del marcador (X).
%
%   OUTPUT:
%       marcador : matriz (N x 3) con la trayectoria del marcador en las
%                  coordenadas X, Y, Z.
%
%   EXAMPLE:
%       % Supongamos que matriz contiene 30 columnas (10 marcadores)
%       % y queremos extraer el 3º marcador, que empieza en la columna 7:
%       marcador = trayectoria_marcador(matriz, 7);
%
%   See also: scatter3, plot3
%
%   History:
%       - 02/10/2025: Versión inicial adaptada a convención snake_case.
%

    % Extraer coordenadas
    x = matriz(:, idx);
    y = matriz(:, idx+1);
    z = matriz(:, idx+2);

    % Guardar trayectoria
    marcador = [x, y, z];

    % Representación gráfica
    scatter3(x, y, z, 'filled')
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    title('Trayectoria del marcador')
    grid on
    axis equal

end

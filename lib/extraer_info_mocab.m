function datos = extraer_info_mocab(path)
%EXTRAER_INFO_MOCAB Extrae información de un archivo MOCAB con cabezal.
%
%   datos = extraer_info_mocab(path)
%
%   Esta función procesa un archivo CSV exportado de un sistema MOCAB con
%   cabezal, identificando sólidos rígidos, marcadores asociados y
%   marcadores libres. Además, muestra por consola un resumen con:
%       - Número de sólidos rígidos y sus posiciones.
%       - Número de marcadores de sólidos rígidos y sus posiciones.
%       - Número de marcadores sin sólido rígido y sus posiciones.
%
% INPUT:
%   path : ruta del archivo CSV a procesar.
%
% OUTPUT:
%   datos : matriz con los datos numéricos del archivo CSV.
%
% EJEMPLO:
%   datos = extraer_info_mocab('prueba_movimiento_cabezal.csv');
%
% Author:   (original) Desconocido
% History:  ??.??.20??   versión inicial
%           30.09.2025   normalizada y modernizada

    % --- Lectura del archivo ---
    cell_data = readcell(path);
    marcador_rigido = {'W'};
    marcador_libre  = {'Marker'};
    idx_rigidos = [];
    idx_libres = [];
    cont_rigidos = 0;
    cont_libres = 0;
    nombres_rigidos = {};

    % --- Buscar encabezados ---
    for fila = 1:14
        fila_data = cell_data(fila,:);
        for col = 1:length(fila_data)
            if isequal(fila_data(col), marcador_rigido)
                cont_rigidos = cont_rigidos + 1;
                idx_rigidos = [idx_rigidos col]; %#ok<AGROW>
                nombres_rigidos{cont_rigidos} = cell_data{fila-4,col}; %#ok<AGROW>
            end
            if isequal(fila_data(col), marcador_libre)
                cont_libres = cont_libres + 1;
                idx_libres = [idx_libres col]; %#ok<AGROW>
            end
        end
    end

    % --- Construir etiquetas de marcadores rígidos ---
    etiquetas_rigidos = strings(1, cont_rigidos);
    for k = 1:cont_rigidos
        etiquetas_rigidos(k) = strcat(string(nombres_rigidos{k}), " Marker");
    end

    % --- Identificar posiciones ---
    fila_titulos = cell_data(fila-4,:);
    idx_marcadores_rigidos = [];
    for k = 1:length(etiquetas_rigidos)
        for c = 1:length(fila_titulos)
            if isequal(etiquetas_rigidos(k), fila_titulos(c))
                idx_marcadores_rigidos = [idx_marcadores_rigidos c]; %#ok<AGROW>
            end
        end
    end

    % --- Lectura de datos numéricos ---
    fila_inicio = fila + 1;
    datos = csvread(path, fila_inicio, 0);

    % --- Postprocesamiento ---
    r11 = min(idx_libres):3:max(idx_libres);
    num_marcadores_libres = cont_libres / 3;

    % Selección de coordenadas X de marcadores rígidos
    t1 = [];
    i = 1;
    while i < length(idx_marcadores_rigidos)
        t1 = [t1 idx_marcadores_rigidos(i)]; %#ok<AGROW>
        if idx_marcadores_rigidos(i) == (max(idx_marcadores_rigidos)-2)
            i = i + 342432; % salida abrupta
        end
        i = i + 3;
    end

    % --- Mensajes en consola ---
    fprintf('Número de sólidos rígidos: %i\n', cont_rigidos);
    fprintf('Número de marcadores con sólido: %i\n', length(t1));
    fprintf('Número de marcadores sin sólido: %i\n', num_marcadores_libres);

    if cont_rigidos > 0
        fprintf('Posiciones de la coordenada X de los sólidos rígidos:\n');
        disp(idx_rigidos - 3);
        fprintf('Formato: Cuaternión (X,Y,Z,W) seguido de posición (X,Y,Z)\n');
        fprintf('----------------------------------------------------------\n');
    end

    if ~isempty(t1)
        fprintf('Posiciones iniciales de cada marcador de sólido rígido:\n');
        disp(t1);
        fprintf('Cada índice corresponde a la coordenada X (X,Y,Z)\n');
        fprintf('----------------------------------------------------------\n');
    end

    if cont_libres > 0
        fprintf('Posiciones iniciales de cada marcador sin sólido rígido:\n');
        disp(r11);
        fprintf('Cada índice corresponde a la coordenada X (X,Y,Z)\n');
    end

    fprintf('La salida de la función es la matriz de datos leída del CSV.\n');
end

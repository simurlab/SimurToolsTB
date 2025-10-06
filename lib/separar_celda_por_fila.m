function separar_celda_filas(nombre_archivo, nombre_variable)
%SEPARAR_CELDA_FILAS Separa las filas de una celda y guarda cada una en un archivo .mat independiente.
%
%   separar_celda_filas(nombre_archivo, nombre_variable)
%
%   INPUT:
%       nombre_archivo  : string con el nombre del archivo .mat a cargar.
%       nombre_variable : string con el nombre de la variable (celda) dentro del archivo.
%
%   OUTPUT:
%       Archivos .mat individuales con cada fila de la celda.
%       El nombre se genera automáticamente como <letra><i>.mat,
%       usando la primera letra del archivo original y el índice de fila.
%
%   EXAMPLE:
%       separar_celda_filas('datos_prueba.mat','mi_celda');
%
%   See also: load, save, iscell
%
% Author:   [Tu nombre / iniciales]
% History:  xx.yy.zzzz  creación del archivo
%           02.10.2025  normalizado a snake_case, documentado y corregida generación de nombres
%

    % -------------------- Cargar archivo --------------------
    datos = load(nombre_archivo);

    % -------------------- Extraer variable --------------------
    if isfield(datos, nombre_variable)
        celda = datos.(nombre_variable);
    else
        error('La variable "%s" no se encuentra en el archivo.', nombre_variable);
    end

    % -------------------- Verificar tipo --------------------
    if ~iscell(celda)
        error('La variable especificada no es una celda.');
    end

    % -------------------- Guardar cada fila --------------------
    for i = 1:size(celda, 1)
        datos_totales = celda(i, :);  
        nombre_fila = sprintf('%s%d.mat', nombre_archivo(1), i);
        save(nombre_fila, 'datos_totales');
        fprintf('✅ Guardada fila %d en %s\n', i, nombre_fila);
    end
end

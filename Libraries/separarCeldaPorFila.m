function separarCeldaPorFila(nombreArchivo, nombreVariable)
    % Carga el archivo .mat
    datos = load(nombreArchivo);

    % Extrae la celda desde el archivo cargado
    if isfield(datos, nombreVariable)
        celda = datos.(nombreVariable);
    else
        error('La variable "%s" no se encuentra en el archivo.', nombreVariable);
    end

    % Verifica que sea una celda
    if ~iscell(celda)
        error('La variable especificada no es una celda.');
    end

    % Recorre las filas y guarda cada una en un archivo separado
    for i = 1:size(celda, 1)
        datos_totales = celda(i, :);  % toma la fila i
        nombreFila = sprintf([nombreArchivo(1), int2str(i), '.mat'], i);
        save(nombreFila, 'datos_totales');
        fprintf('Guardada fila %d en %s\n', i, nombreFila);
    end
end
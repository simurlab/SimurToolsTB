function tabla = f_carga_DOT(varargin)
% f_carga_DOT  Carga y procesa datos desde un archivo .csv de un sensor Xsens Dot.
%
% tabla = f_carga_DOT('Name', Value, ...)
%
% Parámetros nombre-valor (opcionales):
%   'folder_path' - Ruta a la carpeta con archivos .csv. Por defecto: carpeta actual.
%   'save'        - 'y' para guardar la tabla como dot_YYMMDD.mat. Por defecto: 'n'.
%
% Salida:
%   tabla         - Tabla con los datos procesados (incluye columna 'Time' en segundos).

    % -------------------- Valores por defecto --------------------
    folder_path = pwd;
    save_flag = 'n';

    % -------------------- Procesar argumentos nombre-valor --------------------
    for i = 1:2:length(varargin)
        name = lower(varargin{i});
        value = varargin{i+1};
        switch name
            case 'folder_path'
                folder_path = value;
            case 'save'
                save_flag = value;
            otherwise
                error('Parámetro desconocido: %s', name);
        end
    end

    % -------------------- Buscar archivo .csv --------------------
    archivos = dir(fullfile(folder_path, '*.csv'));
    if isempty(archivos)
        error('No se encontraron archivos .csv en la ruta: %s', folder_path);
    end

    % -------------------- Leer archivo y renombrar columna --------------------
    archivoCSV = fullfile(folder_path, archivos(1).name);
    tabla = readtable(archivoCSV);

    if any(strcmp(tabla.Properties.VariableNames, 'SampleTimeFine'))
        tabla.Properties.VariableNames{'SampleTimeFine'} = 'Time';
    else
        error('No se encontró la columna SampleTimeFine en el archivo CSV.');
    end

    % -------------------- Normalizar el tiempo --------------------
    tabla.Time = tabla.Time - tabla.Time(1);  % inicio en 0
    tabla.Time = tabla.Time / 1000;           % convertir a segundos

    % -------------------- Guardar archivo si se solicita --------------------
    if strcmpi(save_flag, 'y')
        fecha = datestr(now, 'yymmdd');
        nombre_archivo = fullfile(folder_path, ['dot_' fecha '.mat']);
        save(nombre_archivo, 'tabla');
    end
end

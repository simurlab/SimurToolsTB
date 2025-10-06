function datos = lectura_archivo_csv(path)
%LECTURA_ARCHIVO_CSV Lee un archivo CSV sin cabecera y devuelve los datos en una matriz.
%
%   datos = lectura_archivo_csv(path)
%
%   Esta función carga un archivo CSV que no contiene cabeceras ni
%   información adicional, devolviendo únicamente los datos numéricos en
%   una matriz de MATLAB.
%
% INPUT:
%   path : ruta del archivo CSV a leer.
%
% OUTPUT:
%   datos : matriz con los valores contenidos en el archivo.
%
% EJEMPLO:
%   datos = lectura_archivo_csv('mediciones.csv');
%
% Author:   (original) Desconocido
% History:  ??.??.20??   versión inicial
%           30.09.2025   normalizada y modernizada

    datos = csvread(path);
end

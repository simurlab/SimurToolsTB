function [acc_cal, gyr_cal] = carga_IMUstd(db_file, sensor_id)
%CARGA_IMUSTD Lee un sensor IMU de un archivo IMUstd y devuelve sus senales
%   reorientadas al sistema anatomico {V, ML, AP}.
%
%   [acc_cal, gyr_cal] = carga_IMUstd(db_file, sensor_id)
%
%   Lee el archivo db_file (formato IMUstd), localiza el sensor indicado
%   por sensor_id, y aplica calibra_anatomical sobre la zona estatica
%   inicial (primeras 50 muestras) para alinear los ejes del sensor con
%   el sistema de referencia anatomico. Las 50 muestras de reposo se
%   descartan de la salida.
%
% INPUT:
%   db_file    - Ruta al archivo .mat en formato IMUstd. Debe contener al
%                menos un campo cuyo nombre empiece por sensor_id (p.ej.
%                'COG_1') con columnas Acc_X, Acc_Y, Acc_Z, Gyr_X, Gyr_Y,
%                Gyr_Z, y un campo '<sensor_id>_metadata' con el campo
%                'orientacion' (vector [1x3] o matriz [3x3]).
%   sensor_id  - Prefijo del campo del sensor dentro del archivo, p.ej.
%                'COG', 'PD', 'MD'. Si hay varios campos con ese prefijo
%                (COG_1, COG_2, ...) se usa el primero encontrado.
%
% OUTPUT:
%   acc_cal    - Aceleraciones reorientadas a ejes anatomicos [N x 3],
%                columnas: [V, ML, AP] en m/s^2 (o g, segun el sensor).
%                Las primeras 50 muestras de reposo han sido descartadas.
%   gyr_cal    - Velocidades angulares reorientadas [N x 3], columnas:
%                [V, ML, AP] en deg/s. Misma longitud que acc_cal.
%
% EJEMPLO:
%   [acc, gyr] = carga_IMUstd('h0101.mat', 'COG');
%   [acc, gyr] = carga_IMUstd('h0101.mat', 'PD');
%
% See also: calibra_anatomical, db_intentos, carga_dot, carga_shimmer
%
% Author:   SiMuR Lab

    %----------------------------------------------------------------------
    % 1) Cargar archivo y localizar el campo del sensor
    %----------------------------------------------------------------------
    datos = load(db_file);

    posiblesCampos = fieldnames(datos);
    esSensor = startsWith(posiblesCampos, sensor_id);

    if ~any(esSensor)
        error('carga_IMUstd:SensorNoDisponible', ...
              'Sensor "%s" no disponible en el archivo %s.', ...
              sensor_id, db_file);
    end

    % En caso de varios matches, nos quedamos con el primero
    campoSensor = posiblesCampos{find(esSensor, 1, 'first')};
    tabla = datos.(campoSensor);

    %----------------------------------------------------------------------
    % 2) Extraer aceleraciones y giros
    %----------------------------------------------------------------------
    acc = [tabla.Acc_X, tabla.Acc_Y, tabla.Acc_Z];
    gyr = [tabla.Gyr_X, tabla.Gyr_Y, tabla.Gyr_Z];

    %----------------------------------------------------------------------
    % 3) Obtener orientacion del sensor (metadata)
    %----------------------------------------------------------------------
    metadataField = [campoSensor, '_metadata'];

    if ~isfield(datos, metadataField)
        error('carga_IMUstd:SinMetadata', ...
              'No se ha encontrado el campo de metadata "%s".', metadataField);
    end

    Rcal = datos.(metadataField).orientacion;

    %----------------------------------------------------------------------
    % 4) Calibracion / reorientacion a coordenadas anatomicas
    %    Usamos las primeras 50 muestras (reposo) para calibrar
    %----------------------------------------------------------------------
    iniReposo = 1;
    finReposo = 50;

    Mrot = calibra_anatomical(acc(iniReposo:finReposo, :), Rcal);

    % Re-orientar toda la senal a coordenadas anatomicas
    a_cal = acc * Mrot.';
    g_cal = gyr * Mrot.';

    %----------------------------------------------------------------------
    % 5) Omitir las primeras 50 muestras (reposo) en la salida
    %----------------------------------------------------------------------
    inicio = 50;
    acc_cal = a_cal(inicio:end, :);
    gyr_cal = g_cal(inicio:end, :);

end

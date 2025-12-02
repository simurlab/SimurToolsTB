%% Función para leer datos de un sensor y devolver accs y giros calibrados
function [acc_cal, gyr_cal] = carga_IMUstd(db_file, sensor_id)
% CARGA_IMUSTD  Lee datos de un sensor IMU y devuelve aceleraciones y giros
% calibrados y reorientados a coordenadas anatómicas.
%
%   [acc_cal, gyr_cal] = carga_IMUstd(db_file, sensor_id)
%
%   ENTRADAS:
%       db_file   : nombre del archivo .mat con los datos
%       sensor_id : prefijo del nombre del campo del sensor (string/char)
%
%   SALIDAS:
%       acc_cal : aceleraciones calibradas (ya recortadas), [N x 3]
%       gyr_cal : giros calibrados (ya recortados), [N x 3]
%
%   NOTAS:
%       - Se asume que en 'datos' hay un campo cuyo nombre empieza por
%         sensor_id, con subcampos Acc_X, Acc_Y, Acc_Z, Gyr_X, Gyr_Y, Gyr_Z.
%       - Se asume también un campo 'xxx_metadata' con el mismo prefijo
%         que contiene la orientación en datos.(xxx_metadata).orientacion.
%       - Las primeras 50 muestras se usan para calibrar (reposo) y se
%         eliminan del resultado final.

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
    % 3) Obtener orientación del sensor (metadata)
    %----------------------------------------------------------------------
    metadataField = [campoSensor, '_metadata'];

    if ~isfield(datos, metadataField)
        error('carga_IMUstd:SinMetadata', ...
              'No se ha encontrado el campo de metadata "%s".', metadataField);
    end

    Rcal = datos.(metadataField).orientacion;

    %----------------------------------------------------------------------
    % 4) Calibración / reorientación a coordenadas anatómicas
    %    Usamos las primeras 50 muestras (reposo) para calibrar
    %----------------------------------------------------------------------
    iniReposo = 1;
    finReposo = 50;

    Mrot = calibra_anatomical(acc(iniReposo:finReposo, :), Rcal);

    % Re-orientar toda la señal a coordenadas anatómicas
    a_cal = acc * Mrot.';
    g_cal = gyr * Mrot.';

    %----------------------------------------------------------------------
    % 5) Omitir las primeras 50 muestras (reposo) en la salida
    %----------------------------------------------------------------------
    inicio = 50;                  % mismas 50 que usaste para reposo
    acc_cal = a_cal(inicio:end, :);
    gyr_cal = g_cal(inicio:end, :);

end
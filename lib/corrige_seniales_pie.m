function [gyro_ml, gyro_ap, calidad_seniales] = corrige_seniales_pie(gyro_ml, gyro_ap)
% CORRIGE_SENIALES_PIE Corrige valores NaN en las señales de giroscopio.
%
%   [gyro_ml, gyro_ap, calidad_seniales] = corrige_seniales_pie(gyro_ml, gyro_ap)
%
%   Esta función detecta y corrige valores perdidos (NaN) en las señales de
%   giroscopio mediolateral (gyro_ml) y anteroposterior (gyro_ap). Los NaN se
%   sustituyen por interpolación lineal entre los valores adyacentes. Si el
%   primer o el último valor de la señal es NaN, se reemplaza por 0.
%
% INPUT:
%   gyro_ml : vector con la señal de giroscopio mediolateral (puede contener NaN).
%   gyro_ap : vector con la señal de giroscopio anteroposterior (puede contener NaN).
%
% OUTPUT:
%   gyro_ml          : señal mediolateral corregida (sin NaNs).
%   gyro_ap          : señal anteroposterior corregida (sin NaNs).
%   calidad_seniales : vector [n_nan_ml, n_nan_ap] con el número de NaNs
%                      corregidos en cada señal.
%
% EXAMPLE:
%   ml = [0.1 0.2 NaN 0.4 0.5];
%   ap = [0.0 NaN NaN 0.3 0.4];
%   [ml_corr, ap_corr, calidad] = corrige_seniales_pie(ml, ap);
%
% Author:   Diego
% History:  xx.yy.zz    creación del archivo
%           21.01.2008  documentada
%           30.09.2019  adaptada a la nueva documentación
%           29.09.2025  normalizada y modernizada
%

    %% Corrección de gyro_ml
    indices_nan_ml = find(isnan(gyro_ml));
    n_nan_ml = numel(indices_nan_ml);

    % Reemplazar primer/último NaN por 0
    if ~isempty(indices_nan_ml)
        if isnan(gyro_ml(1))
            gyro_ml(1) = 0;
            indices_nan_ml = indices_nan_ml(2:end);
        end
        if ~isempty(indices_nan_ml) && isnan(gyro_ml(end))
            gyro_ml(end) = 0;
            indices_nan_ml = indices_nan_ml(1:end-1);
        end
    end

    % Interpolación en cada NaN
    for idx = indices_nan_ml
        desplazamiento = 1;
        while isnan(gyro_ml(idx + desplazamiento))
            desplazamiento = desplazamiento + 1;
        end
        salto = gyro_ml(idx + desplazamiento) - gyro_ml(idx - 1);
        paso = salto / (desplazamiento + 1);
        gyro_ml(idx) = gyro_ml(idx - 1) + paso;
    end

    %% Corrección de gyro_ap
    indices_nan_ap = find(isnan(gyro_ap));
    n_nan_ap = numel(indices_nan_ap);

    % Reemplazar primer/último NaN por 0
    if ~isempty(indices_nan_ap)
        if isnan(gyro_ap(1))
            gyro_ap(1) = 0;
            indices_nan_ap = indices_nan_ap(2:end);
        end
        if ~isempty(indices_nan_ap) && isnan(gyro_ap(end))
            gyro_ap(end) = 0;
            indices_nan_ap = indices_nan_ap(1:end-1);
        end
    end

    % Interpolación en cada NaN
    for idx = indices_nan_ap
        desplazamiento = 1;
        while isnan(gyro_ap(idx + desplazamiento))
            desplazamiento = desplazamiento + 1;
        end
        salto = gyro_ap(idx + desplazamiento) - gyro_ap(idx - 1);
        paso = salto / (desplazamiento + 1);
        gyro_ap(idx) = gyro_ap(idx - 1) + paso;
    end

    %% Salida de calidad
    calidad_seniales = [n_nan_ml, n_nan_ap];
end

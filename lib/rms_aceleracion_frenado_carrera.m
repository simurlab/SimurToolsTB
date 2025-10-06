function [rms_acc_frenado_segmentos, rms_acc_frenado_moda] = rms_aceleracion_frenado_carrera(ic, fc, acc_ap, gyr_ml)
%RMS_ACELERACION_FRENADO_CARRERA Calcula la RMS de la aceleración de frenado durante la carrera.
%
%   [rms_acc_frenado_segmentos, rms_acc_frenado_moda] = rms_aceleracion_frenado_carrera(ic, fc, acc_ap, gyr_ml)
%
%   Esta función calcula la raíz cuadrática media (RMS) de la aceleración de
%   frenado en segmentos específicos de la carrera. Cada segmento se define
%   entre el evento de contacto inicial (IC, foot-strike) y el instante de
%   máxima velocidad angular en el eje mediolateral, antes del toe-off.
%
%   INPUT:
%       ic      : vector con las muestras de contacto inicial (foot-strike).
%       fc      : vector con las muestras de toe-off.
%       acc_ap  : vector con la aceleración en el eje anteroposterior [m/s²].
%       gyr_ml  : vector con la velocidad angular en el eje mediolateral [°/s].
%
%   OUTPUT:
%       rms_acc_frenado_segmentos : vector con los valores RMS de aceleración
%                                   de frenado en cada segmento [Gs].
%       rms_acc_frenado_moda      : valor más frecuente (moda) de los RMS
%                                   obtenidos [Gs].
%
%   EJEMPLO:
%       ic = [100 250 400];
%       fc = [200 350 500];
%       acc_ap = randn(1,600); % señal ficticia
%       gyr_ml = randn(1,600) * 100;
%       [rms_vals, moda_val] = rms_aceleracion_frenado_carrera(ic, fc, acc_ap, gyr_ml);
%
%   See also: rms, mode
%
% Author:   (original) Diego
% History:  xx.yy.zz    versión inicial
%           29.09.2025  normalizada y modernizada

    % Asegurar que son vectores columna
    ic = ic(:);
    fc = fc(:);

    % Inicialización
    rms_acc_frenado_segmentos = [];
    g_teorica = 9.81; % [m/s²] → para pasar a múltiplos de g

    % Calcular RMS en cada segmento
    for i = 1:length(ic)
        % Segmento giroscopio mediolateral (IC → FC)
        gyr_ml_seg = gyr_ml(ic(i):fc(i));

        % Índice del máximo
        [~, idx_max] = max(gyr_ml_seg);

        % Segmento aceleración (IC → máximo)
        acc_seg = acc_ap(ic(i):ic(i) + idx_max) / g_teorica;

        % RMS del segmento
        rms_acc_frenado_segmentos(i) = rms(acc_seg); %#ok<AGROW>
    end

    % Moda de los valores RMS
    rms_acc_frenado_moda = mode(rms_acc_frenado_segmentos);

    % Representación gráfica
    figure
    plot(rms_acc_frenado_segmentos, 'k*')
    title('RMS de aceleración de frenado (carrera)')
    xlabel('Eventos de foot-strike')
    ylabel('RMS [Gs]')
    grid on
end

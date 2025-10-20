function [rms_acc_impacto_segmentos, rms_acc_impacto_moda] = rms_aceleracion_impacto_carrera(ic, fc, acc_vert, gyr_ml, plot_graph)
%RMS_ACELERACION_IMPACTO_CARRERA Calcula la RMS de la aceleración de impacto durante la carrera.
%
%   [rms_acc_impacto_segmentos, rms_acc_impacto_moda] = rms_aceleracion_impacto_carrera(ic, fc, acc_vert, gyr_ml)
%
%   Esta función calcula la raíz cuadrática media (RMS) de la aceleración
%   de impacto en el eje vertical durante la carrera. Cada segmento se define
%   entre el evento de contacto inicial (IC, foot-strike) y el instante de
%   máxima velocidad angular en el eje mediolateral, antes del toe-off.
%
%   INPUT:
%       ic       : vector con las muestras de contacto inicial (foot-strike).
%       fc       : vector con las muestras de toe-off.
%       acc_vert : vector con la aceleración en el eje vertical [m/s²].
%       gyr_ml   : vector con la velocidad angular en el eje mediolateral [°/s].
%
%   OUTPUT:
%       rms_acc_impacto_segmentos : vector con los valores RMS de aceleración
%                                   de impacto en cada segmento [Gs].
%       rms_acc_impacto_moda      : valor más frecuente (moda) de los RMS
%                                   obtenidos [Gs].
%
%   EJEMPLO:
%       ic = [100 250 400];
%       fc = [200 350 500];
%       acc_vert = randn(1,600) * 9.81; % señal ficticia
%       gyr_ml = randn(1,600) * 100;
%       [rms_vals, moda_val] = rms_aceleracion_impacto_carrera(ic, fc, acc_vert, gyr_ml);
%
%   See also: rms_aceleracion_frenado_carrera, rms, mode
%
% Author:   (original) Diego
% History:  xx.yy.zz    versión inicial
%           29.09.2025  normalizada y modernizada

    % ------------------ Valores por defecto ------------------
    if nargin < 5
        plot_graph = false;
    end

    % Asegurar que son vectores columna
    ic = ic(:);
    fc = fc(:);

    % Inicialización
    rms_acc_impacto_segmentos = [];
    g_teorica = 9.81; % [m/s²] → para pasar a múltiplos de g

    % Calcular RMS en cada segmento
    for i = 1:length(ic)
        % Segmento giroscopio mediolateral (IC → FC)
        gyr_ml_seg = gyr_ml(ic(i):fc(i));

        % Índice del máximo
        [~, idx_max] = max(gyr_ml_seg);

        % Segmento aceleración vertical (IC → máximo)
        acc_seg = acc_vert(ic(i):ic(i) + idx_max) / g_teorica;

        % RMS del segmento
        rms_acc_impacto_segmentos(i) = rms(acc_seg); %#ok<AGROW>
    end

    % Moda de los valores RMS
    rms_acc_impacto_moda = mode(rms_acc_impacto_segmentos);

    % Representación gráfica
    if plot_graph
        figure
        plot(rms_acc_impacto_segmentos, 'b*')
        title('RMS de aceleración de impacto (carrera)')
        xlabel('Eventos de foot-strike')
        ylabel('RMS [Gs]')
        grid on
    end
end

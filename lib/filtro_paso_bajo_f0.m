function y = filtro_paso_bajo_f0(datos, orden, corte)
% FILTRO_PASO_BAJO_F0 Implementa un filtro FIR paso bajo de fase cero.
%
%   y = filtro_paso_bajo_f0(datos, orden, corte)
%
% INPUT:
%   datos : vector con la señal de entrada a filtrar.
%   orden : orden del filtro FIR (número de coeficientes - 1).
%   corte : frecuencia de corte normalizada (0–1), donde 1 corresponde a la mitad
%           de la frecuencia de muestreo (Nyquist).
%
% OUTPUT:
%   y : señal filtrada tras aplicar el FIR paso bajo con fase cero.
%
% EXAMPLE:
%   % Filtrar una señal muestreada a 100 Hz con corte en 2.5 Hz:
%   fc = 2.5 / (100/2);              % Normalización respecto a Nyquist
%   y_filtrada = filtro_paso_bajo_f0(x, 60, fc);
%
% HISTORY:
%   Creado por Diego (??.??.20??).
%   Reestructurado y documentado en formato estándar por Gonzalo (2025-10-02).
%

    % Diseño del filtro FIR paso bajo
    b = fir1(orden, corte, 'low');

    % Filtrado de fase cero (hacia delante y hacia atrás en el tiempo)
    warning off
    y = filtfilt(b, 1, datos);
    warning on
end

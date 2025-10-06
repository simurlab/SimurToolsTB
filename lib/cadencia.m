function cadencia = cadencia(ic, freq, metodo)
% CADENCIA Calcula la cadencia a partir de eventos IC (foot-strike).
%
%   cadencia = cadencia(ic, freq, metodo)
%
% INPUT:
%   ic     - Índices de contacto inicial (IC).
%   freq   - Frecuencia de muestreo en Hz.
%   metodo - 'global' o 'ciclo' (opcional, por defecto 'global').
%
% OUTPUT:
%   cadencia - 
%       - Si metodo = 'global' → valor único de cadencia [pasos/min].
%       - Si metodo = 'ciclo'  → vector con la cadencia de cada ciclo [pasos/min].
%
% EXAMPLE:
%   % Calcular cadencia ciclo a ciclo:
%   cadencia = cadencia(ic, 100, 'ciclo');
%
% Author:   Gonzalo
% History:  29.09.25    creación del archivo
%

    if nargin < 3
        metodo = 'global';
    end

    % Asegurar que ic es numérico
    if iscell(ic)
        ic = cell2mat(ic);
    end

    % Tiempo total (segundos)
    tiempo_total = (ic(end)-ic(1)) / freq;

    % Número de pasos
    n_pasos = length(ic);

    switch metodo
        case 'global'
            % Cadencia global = pasos / tiempo_total * 60
            cadencia = (n_pasos / tiempo_total) * 60;

        case 'ciclo'
            % Intervalo entre IC consecutivos
            intervalos = diff(ic) / freq; % [s]
            cadencia = 60 ./ intervalos;  % [pasos/min]

        otherwise
            error('Método no reconocido. Usa "global" o "ciclo".');
    end
end

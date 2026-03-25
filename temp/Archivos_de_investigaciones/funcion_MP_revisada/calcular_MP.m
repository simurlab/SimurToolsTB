function MP = calcular_MP(method, gyrpron, MVP, IC, FC, minimospron)
% -----------------------------------------------------
% Cálculo del evento MP (Máxima Pronación / Mínima Variabilidad)
% -----------------------------------------------------
% Entradas:
%   method       -> 1, 2 o 3 según el método de detección
%   gyrpron      -> señal de giroscopio en eje de pronación
%   MVP          -> índices de eventos MVP (para método 3)
%   IC, FC       -> índices de Contacto Inicial y Final (para método 1 y 2)
%   minimospron  -> mínimos de la señal (para método 1)
%
% Salida:
%   MP -> índices de los eventos MP detectados
%
% Métodos disponibles:
%   1 = Buscar mínimo entre IC y FC
%   2 = Ventana deslizante + STD con umbral
%   3 = Ventana deslizante + Coeficiente de Variación
% -----------------------------------------------------

    switch method
        
        % ==================================================
        % MÉTODO 1: Buscar mínimo entre IC y FC
        % ==================================================
        case 1
            MP = [];
            for i = 1:length(IC)
                mp = minimospron(minimospron > IC(i) & minimospron < FC(i));
                if ~isempty(mp)
                    MP(end+1) = mp(1); %#ok<AGROW>
                else
                    MP(end+1) = NaN;
                end
            end

        % ==================================================
        % MÉTODO 2: Ventana deslizante + STD
        % ==================================================
        case 2
            windowSize = 4;    % muestras
            umbral = 20;       % [°/s]
            
            std_gyroant = movstd(gyrpron, windowSize);
            posibles_MP = find(std_gyroant < umbral);
            
            MP_segmentados = cell(length(IC), 1);
            for i = 1:length(IC)
                aux = posibles_MP(posibles_MP >= IC(i) & posibles_MP <= FC(i));
                if ~isempty(aux)
                    MP_segmentados{i} = aux(1);
                else
                    MP_segmentados{i} = NaN;
                end
            end
            MP = cell2mat(MP_segmentados)';
            
        % ==================================================
        % MÉTODO 3: Ventana deslizante + Coeficiente de Variación
        % ==================================================
        case 3
            windowSize = 4;
            cvThreshold = 0.1;

            cvValues = movstd(gyrpron, windowSize) ./ movmean(gyrpron, windowSize);
            constantCV = cvValues < cvThreshold;
            aux = find(constantCV);

            MP = [];
            for i = 1:length(MVP)
                mins_after = aux(aux > MVP(i));
                if ~isempty(mins_after)
                    MP(end+1) = mins_after(1);
                else
                    MP(end+1) = NaN;
                end
            end
            
        otherwise
            error('Método no válido. Usa 1, 2 o 3.');
    end

end
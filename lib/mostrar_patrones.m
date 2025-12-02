function patrones = mostrar_patrones(ic, senyal, cortePasosIniciales, cortePasosFinales)
% MOSTRAR_PATRONES
%   Extrae pasos de una señal usando los índices de IC, los reescala a
%   una longitud común y dibuja todos los patrones, así como la media y
%   una banda de ±2·desviación estándar.
%
%   patrones = mostrar_patrones(ic, senyal, cortePasosIniciales, cortePasosFinales)
%
%   ENTRADAS:
%       ic                  : vector de índices de inicio de paso (IC)
%       senyal              : vector con la señal original
%       cortePasosIniciales : nº de pasos a descartar desde el inicio
%       cortePasosFinales   : nº de pasos a descartar desde el final
%
%   SALIDA:
%       patrones : cell array, cada celda es un patrón (paso) reescalado
%                  a la misma longitud (column vector)

    %--------------------------------------------------------------
    % 1) Comprobaciones básicas y nº de pasos útiles
    %--------------------------------------------------------------
    ic     = ic(:);        % vector columna
    senyal = senyal(:);    % vector columna

    if numel(ic) < 2
        error('mostrar_patrones:MuyPocosIC', ...
              'Se necesitan al menos 2 IC para definir un paso.');
    end

    if nargin < 3 || isempty(cortePasosIniciales)
        cortePasosIniciales = 0;
    end
    if nargin < 4 || isempty(cortePasosFinales)
        cortePasosFinales = 0;
    end

    numPasosTotales   = numel(ic) - 1;
    pasosInteresantes = numPasosTotales - cortePasosIniciales - cortePasosFinales;
    if pasosInteresantes <= 0
        error('mostrar_patrones:SinPasos', ...
              'No quedan pasos después de aplicar los cortes inicial/final.');
    end

    %--------------------------------------------------------------
    % 2) Extraer los segmentos (uno por paso)
    %--------------------------------------------------------------
    cachoOrigen = cell(1, pasosInteresantes);

    for i = 1:pasosInteresantes
        idxPaso = cortePasosIniciales + i;
        ini = ic(idxPaso);
        fin = ic(idxPaso + 1);

        ini = max(1, min(ini, numel(senyal)));
        fin = max(1, min(fin, numel(senyal)));

        if fin <= ini
            warning('mostrar_patrones:IndicesInvalidos', ...
                    'Paso %d ignorado: fin <= ini (%d <= %d).', i, fin, ini);
            cachoOrigen{i} = [];
            continue;
        end

        cachoOrigen{i} = senyal(ini:fin);
    end

    cachoOrigen = cachoOrigen(~cellfun(@isempty, cachoOrigen));
    if isempty(cachoOrigen)
        error('mostrar_patrones:SinSegmentosValidos', ...
              'No se ha podido extraer ningún paso válido.');
    end

    %--------------------------------------------------------------
    % 3) Redimensionar todos los segmentos a la misma longitud
    %--------------------------------------------------------------
    % Puedes usar el máximo real:
    % maslarga = max(cellfun(@length, cachoOrigen));
    maslarga = 100;  % fijo a 100 muestras

    patrones = cell(1, numel(cachoOrigen));
    for i = 1:numel(cachoOrigen)
        segmento = cachoOrigen{i}(:);
        [p, q] = rat(maslarga / length(segmento));
        patrones{i} = resample(segmento, p, q);
    end

    %--------------------------------------------------------------
    % 4) Dibujar todos los patrones superpuestos
    %--------------------------------------------------------------
    figure('Visible','on');
    hold on; grid on;

    title(inputname(2), 'Interpreter', 'none');
    xlabel('Muestra (normalizada)');
    ylabel('Amplitud');

    for i = 1:numel(patrones)
        plot(patrones{i}, 'LineWidth', 1.0);
    end

    %--------------------------------------------------------------
    % 5) Calcular media y varianza punto a punto
    %--------------------------------------------------------------
    % Cada celda de 'patrones' es un vector columna de longitud L.
    % cell2mat(patrones) -> matriz L x N (L = muestras, N = nº de pasos)
    signalMatrix = cell2mat(patrones);   % [L x N]

    mediaPorInstante    = mean(signalMatrix, 2);          % [L x 1]
    varianzaPorInstante = var(signalMatrix, 0, 2);        % [L x 1]

    %--------------------------------------------------------------
    % 6) Dibujar media + banda de ±2·desviación estándar
    %--------------------------------------------------------------
    figure('Visible','on');
    hold on; grid on;

    x = (1:length(mediaPorInstante)).';

    desv    = sqrt(varianzaPorInstante);
    y_upper = mediaPorInstante + 2*desv;
    y_lower = mediaPorInstante - 2*desv;

    fill([x; flipud(x)], [y_upper; flipud(y_lower)], ...
         [0.7 0.7 1.0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    plot(x, mediaPorInstante, 'k', 'LineWidth', 2);

    title(inputname(2), 'Interpreter', 'none');
    xlabel('Muestra (normalizada)');
    ylabel('Amplitud');
    legend({'±2·σ', 'Media'}, 'Location','best');

end
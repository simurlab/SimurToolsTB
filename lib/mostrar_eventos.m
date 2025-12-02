function mostrar_eventos(m_eventos, senial, cortePasosIniciales, cortePasosFinales)
% MOSTRAR_EVENTOS  Representa una señal y marcas de eventos en varias filas.
%
%   mostrar_eventos(m_eventos, senial, cortePasosIniciales, cortePasosFinales)
%
%   ENTRADAS:
%       m_eventos : matriz F x N, donde F es el nº de tipos de evento (filas)
%                   y N el nº de eventos. Cada fila contiene índices de muestra
%                   sobre 'senial' (por ejemplo: fila 1 = IC, fila 2 = FC, etc.)
%
%       senial              : vector con la señal (p.ej. giroscopio)
%       cortePasosIniciales : nº de evento (sobre la 1ª fila) desde el inicio
%       cortePasosFinales   : nº de evento (sobre la 1ª fila) desde el final
%
%   COMPORTAMIENTO:
%       - Filtra la señal.
%       - Dibuja señal original y filtrada.
%       - Para cada fila de m_eventos, dibuja marcadores en color/forma distinta.
%       - Usa la 1ª fila (m_eventos(1,:)) para poner las líneas verticales
%         de corte (inicio/fin de rango).
%
%   NOTA:
%       Requiere la función externa: filtro_paso_bajo_f0( senial, orden, fc )

    %----------------------------
    % 1. Parámetros por defecto
    %----------------------------
    if nargin < 3 || isempty(cortePasosIniciales)
        cortePasosIniciales = 1;
    end

    if nargin < 4 || isempty(cortePasosFinales)
        cortePasosFinales = 1;
    end

    %----------------------------
    % 2. Preparar señal y filtrado
    %----------------------------
    senial = senial(:);          % Aseguramos vector columna
    freq   = 120;                % Frecuencia de muestreo (Hz)
    orden  = 5;                  % Orden del filtro
    fc     = 6 / freq;           % Frecuencia de corte normalizada

    senalFiltrada = filtro_paso_bajo_f0(senial, orden, fc);

    %----------------------------
    % 3. Info sobre m_eventos
    %----------------------------
    [nFilas, ~] = size(m_eventos);
    if nFilas == 0
        warning('mostrar_eventos:SinEventos', ...
                'm_eventos está vacío. No se representan eventos.');
    end

    % Permitimos hasta 6 tipos de evento (6 filas)
    maxFilas = min(nFilas, 6);

    % Marcadores y nombres por defecto para las filas
    marcadores = {'v','^','o','s','d','x'};  % hasta 6 tipos
    nombresDefecto = { ...
        'Evento 1 (fila 1)', ...
        'Evento 2 (fila 2)', ...
        'Evento 3 (fila 3)', ...
        'Evento 4 (fila 4)', ...
        'Evento 5 (fila 5)', ...
        'Evento 6 (fila 6)'};

    % Colores para cada tipo de evento
    colores = lines(maxFilas);

    %----------------------------
    % 4. Crear figura y dibujar señal
    %----------------------------
    figure;
    hold on; grid on;

    plot(senial, 'Color',[0.7 0.7 0.7], 'LineWidth', 1.5, ...
         'DisplayName','Señal original');

    plot(senalFiltrada, 'b', 'LineWidth', 2, ...
         'DisplayName','Señal filtrada');

    %----------------------------
    % 5. Dibujar eventos de cada fila
    %----------------------------
    for f = 1:maxFilas

        idxEventos = m_eventos(f, :);

        % Filtrar índices no válidos (NaN, <=0, fuera de rango)
        idxValidos = idxEventos(~isnan(idxEventos) & ...
                                idxEventos > 0 & ...
                                idxEventos <= numel(senalFiltrada));

        if isempty(idxValidos)
            continue;   % nada que dibujar en esta fila
        end

        plot(idxValidos, senalFiltrada(idxValidos), ...
             marcadores{f}, ...
             'MarkerSize',     10, ...
             'MarkerFaceColor', colores(f,:), ...
             'MarkerEdgeColor', colores(f,:), ...
             'LineStyle',      'none', ...
             'DisplayName',    nombresDefecto{f});
    end

    %----------------------------
    % 6. Líneas de corte usando la 1ª fila (IC)
    %----------------------------
    if nFilas >= 1
        ic = m_eventos(1, :);

        % limpiamos índices no válidos
        icValidos = ic(~isnan(ic) & ic > 0 & ic <= numel(senalFiltrada));

        if ~isempty(icValidos)
            % Proteger cortes para no salirnos de rango
            cortePasosIniciales = max(1, min(cortePasosIniciales, numel(icValidos)));
            cortePasosFinales   = max(1, min(cortePasosFinales,   numel(icValidos)));

            % Evento desde el inicio
            idxIniPaso = icValidos(cortePasosIniciales);

            % Evento desde el final:
            %   cortePasosFinales = 1 -> último
            %   cortePasosFinales = 2 -> penúltimo, etc.
            idxFinPaso = icValidos(end - cortePasosFinales + 1);

            xline(idxIniPaso, 'LineWidth', 2, 'Color','m', 'LineStyle','--', ...
                  'DisplayName','Inicio rango');

            xline(idxFinPaso, 'LineWidth', 2, 'Color','y', 'LineStyle','--', ...
                  'DisplayName','Fin rango');
        end
    end

    %----------------------------
    % 7. Etiquetas y leyenda
    %----------------------------
    xlabel('Muestra');
    ylabel('Amplitud');
    title('Señal con eventos (hasta 6 filas en m\_eventos)');
    legend('Location','bestoutside');

    hold off;
end
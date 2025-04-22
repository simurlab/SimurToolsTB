nombreArchivo='Ángela García_Contacto-Vuelo.txt';
% Carga los datos
    datos = readtable(nombreArchivo, 'FileType', 'text', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);

    % Mapea las velocidades disponibles (orden de columnas)
    velocidades = [10, 13, 16, 19, 22];  % km/h
    colContact = 2:2:11;
    colFlight  = 3:2:11;

    % Pedir velocidad al usuario
    v = input('Introduce la velocidad a analizar (en kph: 10, 13, 16, 19, 22): ');

    % Comprobar que existe
    idx = find(velocidades == v);
    if isempty(idx)
        error('Velocidad no disponible.');
    end

    % Extraer datos
    contactTime = datos{:, colContact(idx)};
    flightTime  = datos{:, colFlight(idx)};

    % Limpiar NaNs
    contactTime = contactTime(~isnan(contactTime));
    flightTime  = flightTime(~isnan(flightTime));

    % Análisis
    fprintf('Velocidad analizada: %d kph\n', v);
    fprintf('Tiempo medio de contacto: %.4f s\n', mean(contactTime));
    fprintf('Tiempo medio de vuelo:    %.4f s\n', mean(flightTime));
    fprintf('Ratio Contacto/Vuelo:     %.4f\n', mean(contactTime) / mean(flightTime));

    % Asimetría o variabilidad
    asimetContact = std(contactTime) / mean(contactTime);
    asimetFlight  = std(flightTime) / mean(flightTime);
    fprintf('Asimetría tiempo contacto: %.4f\n', asimetContact);
    fprintf('Asimetría tiempo vuelo:    %.4f\n', asimetFlight);

    % Graficas
    figure;
    subplot(2,1,1);
    plot(contactTime, '-o');
    title('Tiempo de Contacto por paso');
    ylabel('s');
    grid on;

    subplot(2,1,2);
    plot(flightTime, '-o');
    title('Tiempo de Vuelo por paso');
    ylabel('s');
    grid on;

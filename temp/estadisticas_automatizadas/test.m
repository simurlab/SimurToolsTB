function [zona1, zona2, zona3, vz1, vz2, vz3, eventos]=test (gyroml, inifin, numero_serie,gyroant)
    % TEST Function to analyze gyroscope data and categorize events
    %
    % Input Arguments:
    %     gyroml - gyroscope measurement data
    %     inifin - array containing start and end indices
    %     numero_serie - series number for the experiment
    %
    % Output Arguments:
    %     zona1 - count of events in zone 1
    %     zona2 - count of events in zone 2
    %     zona3 - count of events in zone 3
    %     vz1 - values in zone 1
    %     vz2 - values in zone 2
    %     vz3 - values in zone 3
    %     eventos - table containing event data

    freq=120;               % Sampling frequency in Hz
    inicio=1000*inifin(1);  % Start time in milliseconds
    final=1000*inifin(2);   % End time in milliseconds
    
    % filtro: 
    th=150;                                      % Threshold value for event detection
    [IC,FC,MaxS,MinS,MVP,MP]=eventospie_carrera(gyroml,th,freq,gyroant);  % Detect events based on threshold
    
    % TC en ms:
    TC=1000*(FC-IC)/freq;                        % Calculate event times in milliseconds

    % TV en ms:
    TV=1000*(IC(2:end)-FC(1:end-1))/freq;
    
    % Definir los valores de separación en ms:
    a = round(1+(1000/freq));                    % Threshold for one sample or coincident events, in ms  
    b = 80;                                      % Threshold for ambiguous cases
    
    % Contar los elementos en cada zona
    zona1 = sum(TC < a);                         % Count events less than threshold a
    zona2 = sum(TC >= a & TC <= b);              % Count events between thresholds a and b (inclusive)
    zona3 = sum(TC > b);                         % Count events greater than threshold b
    
    vz1 = TC((TC < a));                          % Values of events less than threshold a
    vz2 = TC((TC >= a & TC <= b));               % Values of events between thresholds a and b (inclusive)
    vz3 = TC((TC > b));                          % Values of events greater than threshold b
    
    % Recoger eventos IC, FC y TC en una tabla
    N = length(TC);  % Number of events
    % Crear tabla incluyendo el número de experimento como columna
    eventos = table(repmat(numero_serie, N, 1), repmat(inicio,N,1), repmat(final,N,1), IC', FC', TC', repmat(zona3,N,1), ...
                    repmat(zona1,N,1), repmat(zona2,N,1), [0;TV'], repmat(N,N,1), ...
                    'VariableNames', {'Serie número [-]', 'Muestra de Inicio del Intervalo [-]', ...
                    'Muestra de Fin del Intervalo [-]', 'IC muestra [-]', 'FC muestra [-]', 'TC [ms]', 'Acierto (TC > 80 [ms])', ...
                    'Fallo (TC  <  9 [ms])', 'Duda (9 [ms] < TC < 80 [ms])', 'TV [ms]', 'Número TOTAL de pasos en la serie [-]'});
    
    % Mostrar resultados
    fprintf('Inicio: %0.f; Fin: %0.f; Eventos detectados: %d\n', inicio, final, length(TC));
    fprintf('Fallo (TC  <  %d): %d (media: %.1f)\n', a, zona1, mean(vz1));
    fprintf('Duda (%d <TC< %d): %d (media: %.1f)\n', a, b, zona2, mean(vz2));
    fprintf('Acierto (TC> %d): %d  (media: %.1f) \n', b, zona3, mean(vz3));
end
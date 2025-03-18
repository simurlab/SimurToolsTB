%% ESTUDIO CONCRETO

function [zona1, zona2, zona3, vz1, vz2, vz3]=ftest_ep (gyroml, inifin, freq)

% freq=120;

inicio=1000*inifin(1);
final=1000*inifin(2);

% filtro y deteccion (requiere la TB de SP de Matlab): 
th=150;
[IC,FC]=eventospie_carrera(gyroml,th,freq);

% TC en ms:
TC=1000*(FC-IC)/freq;

% Definir los valores de separación en ms:
a = round(1+(1000/freq)); % una muestra o coincidentes, en ms  
b = 80;  % menos de esos ms, caso dudoso

% Contar los elementos en cada zona
zona1 = sum(TC < a);        % Menores que a
zona2 = sum(TC >= a & TC <= b);  % Entre a y b (inclusive)
zona3 = sum(TC > b);        % Mayores que b

vz1 = TC((TC < a));        % Menores que a
vz2 = TC((TC >= a & TC <= b));  % Entre a y b (inclusive)
vz3 = TC((TC > b));        % Mayores que b

% Mostrar resultados
fprintf('Inicio: %0.f; Fin: %0.f; Eventos detectados: %d\n', inicio, final, length(TC));
fprintf('Fallo (TC  <  %d): %d (media: %.1f)\n', a, zona1, mean(vz1));
fprintf('Duda (%d <TC< %d): %d (media: %.1f)\n', a, b, zona2, mean(vz2));
fprintf('Acierto (TC> %d): %d  (media: %.1f) \n', b, zona3, mean(vz3));


orden=5;
corte=6/freq;
gyr2fil=filtro0(gyroml,orden,corte);







%% VISUALIZACIONES DE POSIBLE INTERES
%

% Detecciones:

figure
plot(gyroml, 'LineWidth',4)
grid
hold on
plot(gyr2fil, 'LineWidth',4)
plot(IC, gyr2fil(IC), 'v', 'MarkerSize', 25, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
plot(FC, gyr2fil(FC), '^', 'MarkerSize', 25, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
decora4K(freq);


annotation('textbox', [0.15, 0.8, 0.1, 0.1], ... % [x y width height]
    'String', sprintf('Ini: %.0f   Fin: %.0f', inicio, final), ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', 'yellow', ...
    'FontSize', 18, 'FontWeight', 'bold', ...
    'EdgeColor', 'black');

annotation('textbox', [0.55, 0.8, 0.1, 0.1], ... % [x y width height]
    'String', sprintf('Resultado: %d %d %d', zona1, zona2, zona3), ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', 'green', ...
    'FontSize', 18, 'FontWeight', 'bold', ...
    'EdgeColor', 'black');


% figure
% plot(TC, 'LineWidth',4);
% grid;
% decora4K(freq);

% figure
% plot(8+(250-TC)/9);
% grid;
% decora4K(freq);


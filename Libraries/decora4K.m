function decora (freq)

% Engordar lineas:
h = findobj(gca, 'Type', 'Line'); % Find the line object

% Eje x en segundos 
for i = 1:length(h)
    h(i).XData = h(i).XData * (1/freq);
end
hAx = gca; % Handle to current axes

% Adjust font sizes
hAx.FontSize = 18;                          % Axis ticks
hAx.XLabel.FontSize = 18;                   % X-axis label
hAx.YLabel.FontSize = 18;                   % Y-axis label
hAx.Title.FontSize = 18;                    % Title
%legend(hPlot, 'sin(x)', 'FontSize', 14);    % Legend
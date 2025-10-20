function [acc_medio_lateral_footstrike, acc_medio_lateral_footstrike_moda] = aceleracion_mediolateral_carrera(IC, acc_medio_lateral)
% ACELERACION_MEDIOLATERAL_CARRERA Calcula la aceleración medio-lateral durante foot-strike.
%
%   [acc_medio_lateral_footstrike, acc_medio_lateral_footstrike_moda] = ...
%       aceleracion_mediolateral_carrera(IC, acc_medio_lateral)
%
% INPUT:
%   IC                  - Array de celdas con las muestras de los eventos 
%                         de foot-strike (talonazo).
%   acc_medio_lateral   - Vector con la aceleración en el eje medio-lateral.
%
% OUTPUT:
%   acc_medio_lateral_footstrike       - Vector con los valores de aceleración
%                                        medio-lateral en cada evento de foot-strike,
%                                        normalizados en Gs.
%   acc_medio_lateral_footstrike_moda  - Valor más frecuente (moda) de la 
%                                        aceleración medio-lateral en foot-strike.
%
% EXAMPLE:
%   % A partir de señales y eventos detectados:
%   [acc_fs, acc_fs_moda] = aceleracion_mediolateral_carrera(IC, acc_medio_lateral);
%
% Author:   Alejandro
% History:  01.07.25    creación del archivo
%           29.09.25    normalizada y modernizada
%


    % Convertimos IC de celda a matriz para facilitar el acceso a los datos
    IC = cell2mat(IC);
    
    % Guardamos los índices de los eventos de foot-strike en una variable
    muestras_footstrike = IC;
    
    % Definimos la aceleración de la gravedad en [m/s^2] para normalizar los datos
    g_teorica = 9.81;  
    
    % Extraemos los valores de aceleración en el eje medio-lateral en los eventos de foot-strike
    % y los normalizamos dividiéndolos por la gravedad para obtener unidades en [Gs]
    acc_medio_lateral_footstrike = acc_medio_lateral(muestras_footstrike) / g_teorica;  
    
    % Calculamos la moda de la aceleración medio-lateral en los eventos de foot-strike
    acc_medio_lateral_footstrike_moda = mode(acc_medio_lateral_footstrike);  

    % Representación gráfica de la aceleración medio-lateral en cada foot-strike
    figure
    plot(acc_medio_lateral_footstrike, 'b*')  % Se usa '*' para marcar cada punto
    title('Medio lateral Gs de lado a lado - Gs pico en FootStrike')
    xlabel('Eventos de foot-strike')
    ylabel('Aceleración medio-lateral (Gs)')

end

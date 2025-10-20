function [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr, th, freq, gyr_pron)
% EVENTOS_PIE_CARRERA Detecta los eventos IC y FC a partir de la velocidad angular en el eje mediolateral
% durante la carrera.
%
%   [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr, th, freq, gyr_pron)
%
%   Esta función toma como base la velocidad angular del eje mediolateral y realiza un proceso
%   de filtrado (usando filtro_paso_bajo_f0). A partir de la señal resultante identifica los
%   eventos de contacto inicial y final del pie (IC y FC), así como otros eventos relevantes del ciclo.
%
% INPUT:
%   gyr        : vector con la velocidad angular en el eje mediolateral (°/s).
%   th         : velocidad mínima para detectar eventos. (Recomendado: 150)
%   freq       : frecuencia de muestreo (Hz).
%   gyr_pron   : velocidad angular en el eje de pronación (°/s) [opcional].
%                Si no se proporciona, MVP y MP se devolverán vacíos.
%
% OUTPUT:
%   ic     : índices de contacto inicial (Initial Contact / Foot-Strike).
%   fc     : índices de contacto final (Final Contact / Toe-Off).
%   max_s  : índices de máximo swing (pie hacia adelante).
%   min_s  : índices de mínimo swing (pie hacia atrás).
%   mvp    : índices de máxima velocidad de pronación.
%   mp     : índices de máxima pronación.
%
% EXAMPLE:
%   load('pie_data.mat')
%   [ic, fc, max_s, min_s, mvp, mp] = eventos_pie_carrera(gyr_ml, 150, 200, gyr_fr);
%   plot(gyr_ml); hold on;
%   plot(ic, gyr_ml(ic), 'g*');
%   plot(fc, gyr_ml(fc), 'r*');
%   legend('Velocidad angular','IC','FC')
%
% HISTORY:
%   Original:  Diego Álvarez
%   

    % -------------------- FILTRADO DE SEÑALES --------------------
    orden = 8 + floor(freq / 100);       % orden mínimo 3; a mayor fm, mayor orden
    corte = 6 / freq;                    % frecuencia de corte normalizada

    gyr = filtro_paso_bajo_f0(gyr, orden, corte);
    if nargin == 4
        gyr_pron = filtro_paso_bajo_f0(gyr_pron, orden, corte);
    else
        gyr_pron = [];
    end

    tam = length(gyr);

    % -------------------- DETECCIÓN DE CRUCES Y EXTREMOS --------------------
    datos2 = gyr(2:tam) - gyr(1:tam-1);
    datos2 = datos2 >= 0;
    datos2 = datos2(1:tam-2) - datos2(2:tam-1);

    maximos = find(datos2 == 1) + 1;
    minimos = find(datos2 == -1) + 1;
    minimos = minimos(gyr(minimos) < 0);

    max_paso = maximos(1);

    ic = [];
    fc = [];
    max_s = [];
    min_s = [];
    mvp = [];
    mp  = [];

    pasos_cero_maxs = find(diff(gyr > 0) == -1);
    pasos_cero_mins = find(diff(gyr > 0) == +1);

    % -------------------- SI EXISTE GIRO DE PRONACIÓN --------------------
    if nargin == 4 && ~isempty(gyr_pron)
        datos3 = gyr_pron(2:tam) - gyr_pron(1:tam-1);
        datos3 = datos3 >= 0;
        datos3 = datos3(1:tam-2) - datos3(2:tam-1);

        maximos_pron = find(datos3 == 1) + 1;

        pasos_cero_pron = find(diff(gyr_pron < 0) == 1);
        for i = 1:length(pasos_cero_pron)
            if abs(gyr_pron(pasos_cero_pron(i))) > abs(gyr_pron(pasos_cero_pron(i)+1))
                pasos_cero_pron(i) = pasos_cero_pron(i) + 1;
            end
        end
    else
        maximos_pron = [];
        pasos_cero_pron = [];
    end

    % -------------------- DETECCIÓN DE EVENTOS --------------------
    for i = 2:length(maximos)
        if gyr(maximos(i)) >= th
            mins_paso = minimos(minimos > max_paso(end) & minimos < maximos(i));

            if length(mins_paso) >= 2
                max_paso = [max_paso, maximos(i)];

                % Contactos iniciales y finales
                [~, ifc] = min(gyr(mins_paso(2:end)));
                fc = [fc, mins_paso(ifc + 1)];
                ic = [ic, mins_paso(1)];

                % Máximo swing antes del siguiente paso
                maxs = pasos_cero_maxs(pasos_cero_maxs > max_paso(end));
                if ~isempty(maxs)
                    max_s = [max_s, maxs(1)];
                else
                    max_s = [max_s, NaN];
                end

                % Mínimo swing entre FC y siguiente máximo
                mins = pasos_cero_mins(pasos_cero_mins > fc(end) & pasos_cero_mins < max_paso(end));
                if ~isempty(mins)
                    min_s = [min_s, mins(end)];
                else
                    min_s = [min_s, NaN];
                end

                % Eventos de pronación
                if nargin == 4 && ~isempty(maximos_pron)
                    mvp_local = maximos_pron(maximos_pron > ic(end) & maximos_pron < fc(end));
                    if ~isempty(mvp_local)
                        mvp = [mvp, mvp_local(1)];
                        mp_local = pasos_cero_pron(pasos_cero_pron > mvp(end) & pasos_cero_pron < fc(end));
                        if ~isempty(mp_local)
                            mp = [mp, mp_local(1)];
                        else
                            mp = [mp, NaN];
                        end
                    else
                        mvp = [mvp, NaN];
                        mp = [mp, NaN];
                    end
                end
            end
        end
    end
end

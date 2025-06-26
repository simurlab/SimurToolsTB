function f_segmenta()
% F_SEGMENTA Interactivamente segmenta zonas estáticas e intentos por ubicación.
% Genera archivos tipo h0101.mat, h0102.mat, etc., incluyendo la zona estática.

    datos = load('h01.mat');
    campos = fieldnames(datos);
    ubicaciones = unique(regexprep(campos, '_\d+(_metadata)?$', ''));

    % Estructuras para guardar zonas estáticas y segmentos por ubicación
    zonasEstaticas = struct();
    segmentosPorUbicacion = struct();
    intentosGlobales = [];

    for i = 1:numel(ubicaciones)
        ubic = ubicaciones{i};
        nombreTabla = sprintf('%s_1', ubic);
        nombreMeta = sprintf('%s_1_metadata', ubic);

        if ~isfield(datos, nombreTabla) || ~isfield(datos, nombreMeta)
            warning('⚠️ Falta tabla o metadata para %s. Se omite.', ubic);
            continue;
        end

        tabla = datos.(nombreTabla);
        metadata = datos.(nombreMeta);

        % ----------- Zona estática -----------
        figure('Name', [ubic ' - Zona Estática']); clf;
        plot(tabla.Acc_X); hold on;
        plot(tabla.Acc_Y); plot(tabla.Acc_Z);
        legend({'Acc_X', 'Acc_Y', 'Acc_Z'}); grid on;
        title(['Selecciona zona estática para ' ubic]);

        while true
            entrada = input('Intervalo estático [i1 i2]: ', 's');
            partes = sscanf(entrada, '%f');
            if numel(partes) == 2 && partes(1) < partes(2)
                i1 = max(1, floor(partes(1)));
                i2 = min(height(tabla), floor(partes(2)));
                if (i2 - i1 + 1) < 50
                    warning('❌ Mínimo 50 muestras requeridas.');
                    continue;
                end
                zonasEstaticas.(ubic) = tabla(i1:i1+49, :);
                break;
            else
                warning('❌ Entrada inválida. Intenta de nuevo.');
            end
        end

        % ----------- Intentos -----------
        segmentos = {};
        intento = 1;
        while true
            prompt = sprintf('Intento %02d [%d-%d] (Enter=salta, q=salir): ', intento, 1, height(tabla));
            entrada = input(prompt, 's');

            if strcmpi(entrada, 'q')
                break;
            elseif isempty(entrada)
                intento = intento + 1;
                continue;
            end

            partes = sscanf(entrada, '%f');
            if numel(partes) == 2 && partes(1) < partes(2)
                i1 = max(1, floor(partes(1)));
                i2 = min(height(tabla), floor(partes(2)));
                segmento = [zonasEstaticas.(ubic); tabla(i1:i2, :)];
                segmentos{intento} = segmento;

                intentosGlobales = [intentosGlobales; struct( ...
                    'intento', intento, ...
                    'ubicacion', ubic, ...
                    'inicio', i1, ...
                    'fin', i2, ...
                    'inicio_estatico', i1, ...
                    'fin_estatico', i1 + 49 ...
                )];

                intento = intento + 1;
            else
                warning('❌ Intervalo inválido. Intenta de nuevo.');
            end
        end

        segmentosPorUbicacion.(ubic) = segmentos;
    end

    % ----------- Guardado agrupado por intento global -----------
    intentosUnicos = unique([intentosGlobales.intento]);
    nombreBase = 'h01';

    for i = 1:numel(intentosUnicos)
        idIntento = intentosUnicos(i);
        fragmento = struct();

        for j = 1:numel(ubicaciones)
            ubic = ubicaciones{j};
            segmentos = segmentosPorUbicacion.(ubic);
            if idIntento > numel(segmentos)
                continue;
            end

            tablaIntento = segmentos{idIntento};
            nombreCampo = sprintf('%s_1', ubic);
            fragmento.(nombreCampo) = tablaIntento;

            metaCampo = sprintf('%s_1_metadata', ubic);
            meta = datos.(metaCampo);
            meta.intervaloIntento = [intentosGlobales([intentosGlobales.intento] == idIntento & strcmp({intentosGlobales.ubicacion}, ubic)).inicio, ...
                                     intentosGlobales([intentosGlobales.intento] == idIntento & strcmp({intentosGlobales.ubicacion}, ubic)).fin];
            fragmento.(metaCampo) = meta;
        end

        nombreArchivo = sprintf('%s%02d.mat', nombreBase, idIntento);
        save(nombreArchivo, '-struct', 'fragmento');
        fprintf('📁 Guardado: %s\n', nombreArchivo);
    end
end

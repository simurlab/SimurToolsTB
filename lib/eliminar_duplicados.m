function [ic, fc] = eliminar_duplicados(ic, fc)
% ELIMINAR_DUPLICADOS Depura listas de eventos IC y FC eliminando duplicados.
%
%   [ic, fc] = eliminar_duplicados(ic, fc)
%
%   Esta función corrige listas de eventos de contacto inicial (IC) y
%   contacto final (FC), eliminando duplicados y asegurando que cada IC
%   tenga un FC asociado en el orden correcto.
%
% INPUT:
%   ic : vector con índices de contacto inicial.
%   fc : vector con índices de contacto final.
%
% OUTPUT:
%   ic : vector corregido de contactos iniciales.
%   fc : vector corregido de contactos finales.
%
% NOTAS:
%   - Elimina FC no deseados al principio si aparecen antes del primer IC.
%   - Elimina IC no deseados al final si aparecen después del último FC.
%   - Depura casos en los que un IC aparece después de un FC o viceversa.
%
% EJEMPLO:
%   IC = [10 30 50 70];
%   FC = [5 20 40 55 80];
%   [ICc, FCc] = eliminar_duplicados(IC, FC);
%
% Author:   (original) Diego
% History:  (sin fecha en original)
%           29.09.2025   normalizada y modernizada
%

    % -------------------- Eliminar FC indeseados al inicio --------------------
    while fc(1) < ic(1)
        fc = fc(2:end);
    end

    % -------------------- Eliminar IC indeseados al final --------------------
    while ic(end) > fc(end)
        ic = ic(1:end-1);
    end
    
    % -------------------- Depuración de duplicados --------------------
    correcto = false;
    while ~correcto
        for i = 1:length(ic)
            if ic(i) > fc(i)
                fc = [fc(1:i-1), fc(i+1:end)];
                break
            end
            if i < length(ic)-1
                if ic(i+1) < fc(i)
                    ic = [ic(1:i-1), ic(i+1:end)];
                    break
                end
            end
        end
        if i == length(ic)
            correcto = true;
        end
    end 
    
    % -------------------- Ajuste final de longitudes --------------------
    if length(fc) > length(ic)
        fc = fc(1:length(ic));
    end
end

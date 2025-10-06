function [retardo_hs, retardo_to] = eventos_cog_tiempo_real_caminar(acc_ap, acc_vert, reset)
%EVENTOS_COG_TIEMPO_REAL_CAMINAR Detección en tiempo real de IC y TO a partir de aceleraciones del COG.
%
%   [retardo_hs, retardo_to] = eventos_cog_tiempo_real_caminar(acc_ap, acc_vert, reset)
%
%   Esta función detecta en tiempo real los eventos de Initial Contact (IC/HS)
%   y Toe Off (TO) a partir de las aceleraciones anteroposterior y vertical
%   del centro de gravedad (COG). Debe llamarse secuencialmente en cada muestra.
%
%   IMPORTANTE:
%       - La señal debe estar muestreada a 100 Hz.
%       - Es imprescindible llamar con el argumento "reset" para reiniciar
%         las variables persistentes al inicio de cada experimento.
%
% INPUT:
%   acc_ap   : valor de la última muestra de aceleración anteroposterior.
%   acc_vert : valor de la última muestra de aceleración vertical.
%   reset    : si se pasa, reinicia las variables persistentes.
%
% OUTPUT:
%   retardo_hs : nº de muestras hasta el último evento de IC detectado
%                (0 si no hay evento en esta llamada).
%   retardo_to : nº de muestras hasta el último evento de TO detectado
%                (0 si no hay evento en esta llamada).
%
% EJEMPLO:
%   eventos_cog_tiempo_real_caminar(0,0,true); % reset inicial
%   for i = 1:length(data)
%       [hs,to] = eventos_real_caminar(accAP(i), accV(i));
%       if hs > 0, fprintf('IC detectado con retardo %d\n', hs); end
%       if to > 0, fprintf('TO detectado con retardo %d\n', to); end
%   end
%
% Author:   Diego
% History:  xx.yy.zz   creación del archivo
%           29.09.2025 normalizada y modernizada
%

    % -------------------- Parámetros --------------------
    filtro = [0.0365 0.0374 0.0375 0.0382 0.0381 0.0385 0.0381 0.0382 0.0375 0.0374 0.0365];
    TROZO = 200;     % nº máximo de muestras en buffer RT
    INTERVALO = 11;  % nº mínimo de muestras positivas previas a ZC

    % -------------------- Variables persistentes --------------------
    persistent pers_data_ap pers_data_filt pers_data_vert pers_ultimo_hs
    if nargin > 2
        pers_data_ap = [];
        pers_data_filt = [];
        pers_data_vert = [];
        pers_ultimo_hs = 0;
    end
    if isempty(pers_ultimo_hs)
        pers_ultimo_hs = 0;
    end

    % -------------------- Gestión de buffer --------------------
    if length(pers_data_ap) == TROZO
        aux = 2;
        pers_ultimo_hs = pers_ultimo_hs - 1;
    else
        aux = 1;
    end
    pers_data_ap = [pers_data_ap(aux:end) acc_ap];
    pers_data_vert = [pers_data_vert(aux:end) acc_vert];

    % -------------------- Señal filtrada (fase lineal, corte 2 Hz) --------------------
    L = min([length(pers_data_ap), length(filtro)]);
    valor = sum(filtro(1:L) .* pers_data_ap(end-L+1:end));
    pers_data_filt = [pers_data_filt(aux:end) valor];

    % -------------------- Inicialización --------------------
    retardo_hs = 0;
    retardo_to = 0;

    % -------------------- Detección de HS (zero-crossing) --------------------
    if length(pers_data_ap) > INTERVALO
        if pers_data_filt(end) < 0 && pers_data_filt(end-1) > 0
            if sum(sign(pers_data_filt(end-INTERVALO+1:end-1))) == INTERVALO-1
                % Buscar picos candidatos
                peaks = localmaxima(pers_data_ap, 2);
                peaks = peaks .* (pers_data_ap(peaks) > 0.95) ...
                             .* (pers_data_vert(peaks) >= 9.8) ...
                             .* (pers_data_ap(peaks) / max(pers_data_ap) > 0.3);
                peaks = peaks(peaks > length(pers_data_ap)-15);
                if ~isempty(peaks)
                    evento = peaks(end);
                    retardo_hs = length(pers_data_ap) - evento;
                    pers_ultimo_hs = evento;
                end
            end
        end
    end

    % -------------------- Detección de TO --------------------
    if pers_ultimo_hs > 0 && length(pers_data_ap) - pers_ultimo_hs >= 25
        maximos = localmaxima(pers_data_vert(pers_ultimo_hs-5:pers_ultimo_hs+11), 2);
        if ~isempty(maximos)
            ff = maximos(1) - 5;
            minimos = localmaxima(-pers_data_vert(pers_ultimo_hs+ff:pers_ultimo_hs+22), 2);
            if ~isempty(minimos)
                evento = minimos(1) + pers_ultimo_hs + ff - 1;
                retardo_to = length(pers_data_vert) - evento;
            else
                retardo_to = 10; % estimación aproximada
            end
        else
            retardo_to = 10; % estimación aproximada
        end
        pers_ultimo_hs = 0; % reiniciar detección TO
    end
end

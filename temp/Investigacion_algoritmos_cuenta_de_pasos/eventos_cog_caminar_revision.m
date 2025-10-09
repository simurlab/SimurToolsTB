function tiempos = eventos_cog_caminar_revision(acc_hor, acc_vert, freq)
%EVENTOS_COG_CAMINAR Detecta eventos de la marcha a partir de aceleraciones del COG.
%
%   tiempos = eventos_cog_caminar(acc_hor, acc_vert, freq)
%
%   Esta función detecta cinco eventos de la marcha usando las aceleraciones
%   anteroposterior y vertical del centro de gravedad (COG). El algoritmo está
%   basado en Auvinet, con correcciones que renombran los eventos según validaciones
%   posteriores:
%       - FF : Foot Flat
%       - HS : Heel Strike
%       - TO : Toe Off
%       - MS : Mid Stance (antes Push-Off en Auvinet)
%       - NI : Evento no identificado (antes Mid Stance en Auvinet)
%
% INPUT:
%   acc_hor  : vector con la aceleración anteroposterior.
%   acc_vert : vector con la aceleración vertical.
%   freq     : frecuencia de muestreo en Hz (opcional, por defecto 100).
%
% OUTPUT:
%   tiempos : matriz Nx8 con:
%       tiempos(:,1) = acc_vert
%       tiempos(:,2) = acc_hor
%       tiempos(:,3) = FF
%       tiempos(:,4) = HS
%       tiempos(:,5) = TO
%       tiempos(:,6) = MS
%       tiempos(:,7) = NI
%       tiempos(:,8) = reservado (ceros)
%
% EJEMPLO:
%   t = 0:0.01:10;
%   acc_hor = sin(2*pi*1*t) + 0.1*randn(size(t));
%   acc_vert = cos(2*pi*1*t) + 0.1*randn(size(t));
%   tiempos = eventos_cog_caminando(acc_hor, acc_vert, 100);
%   plot(acc_vert); hold on;
%   plot(find(tiempos(:,4)), acc_vert(tiempos(:,4)==1), 'ro') % HS
%
% See also: eventos_cog_carrera, busca_maximos, busca_maximos_umbral
%
% Author:   Diego
% History:  v0.1   Versión original para IMU-Pro
%           v0.2   Versión genérica para IMU-Pro y XSens
%           v0.3   Antonio: añadidos eventos PO y MS
%           v0.4   JC: comentarios
%           v0.5   Diego: afinada detección de FF y TO
%           v0.6   Diego: método alternativo para Push-Off
%           v1.0   Diego: nuevo algoritmo HS y FF (robusto)
%           v1.1   Rafa & Diego: correcciones de bugs múltiples
%           v1.2   JC: renombrados MS → NI y PO → MS
%           v1.2.1 Diego: bug corregido en ajuste de frecuencias
%           29.09.2025   normalizada y modernizada
%

    if nargin < 3
        freq = 100;
    end

    % -------------------- Inicialización matriz --------------------
    n = length(acc_vert);
    tiempos = zeros(n, 8);
    tiempos(:,1) = acc_vert;
    tiempos(:,2) = acc_hor;

    % -------------------- Foot Flat (FF) preliminar --------------------
    datos_filt = filtro0(acc_vert, 60, 5/freq);
    ff = busca_maximos_umbral(datos_filt, 10.5);
    ff = find(ff == 1);

    % -------------------- Heel Strike (HS) --------------------
    m_inferior = -0.10; 
    m_superior = -0.00;
    resto = 1;
    if ff(1) <= -1*m_inferior*freq
        hs(1) = 1; %#ok<AGROW>
        resto = 2;
    end
    for i = resto:length(ff)
        [~, punto] = max(acc_hor(ff(i)+ceil(m_inferior*freq):ff(i)+floor(m_superior*freq)));
        hs(i) = ff(i) + ceil(m_inferior*freq) + punto - 1; %#ok<AGROW>
    end
    % Postprocesamiento HS (eliminar eventos espurios)
    for i = (length(hs)-1):-1:1
        if abs(hs(i)-hs(i+1)) < 0.2*freq
            [~, idx] = max([acc_hor(hs(i)), acc_hor(hs(i+1))]);
            hs(i) = hs(i+idx-1);
            hs = hs([1:i, i+2:end]);
        end
    end
    tiempos(hs,4) = 1;

    % -------------------- Inicialización --------------------
    ff = zeros(size(hs));
    to = zeros(size(hs));
    ms = zeros(size(hs));

    % -------------------- FF tras HS --------------------
    m_inferior = 0.01; 
    m_superior = 0.06;
    eliminado = 0;
    if (hs(end)+m_superior*freq > n)
        ff(end) = n-3;
        eliminado = 1;
    end
    for i = 1:length(hs)-eliminado
        [~, punto] = max(acc_vert(max(hs(i)+ceil(m_inferior*freq),1):min(hs(i)+floor(m_superior*freq),n)));
        ff(i) = hs(i) + ceil(m_inferior*freq) + punto - 1;
    end
    tiempos(ff,3) = 1;

    % -------------------- Toe Off (TO) --------------------
    m_inf_m = 0.10; m_sup_m = 0.20;
    m_inf_t = 0.02; m_sup_t = -0.02;
    eliminado = 0;
    if (ff(end)+m_sup_m*freq > n)
        to(end) = n-2;
        eliminado = 1;
    end
    for i = 1:length(ff)-eliminado
        [~, punto] = max(acc_vert(ff(i)+ceil(m_inf_m*freq):ff(i)+floor(m_sup_m*freq)));
        to(i) = ff(i) + ceil(m_inf_m*freq) + punto - 1;
        [~, punto] = min(acc_vert(ff(i)+ceil(m_inf_t*freq):to(i)+floor(m_sup_t*freq)));
        to(i) = ff(i) + ceil(m_inf_t*freq) + punto - 1;
    end
    tiempos(to,5) = 1;

    % -------------------- Mid Stance (MS) --------------------
    ipo = busca_maximos(-datos_filt);
    ipo = find(ipo == 1);
    if ipo(1) < to(1), ipo = ipo(2:end); end
    if length(ipo) < length(to), ipo = [ipo; n]; end
    tiempos(ipo,6) = 1;

    if length(ipo) ~= length(ff)
        warning('⚠️ Los eventos detectados son incongruentes. ¿Todos los datos corresponden a caminar?')
    end
    min_eventos = min(length(ipo), length(ff));

    % -------------------- Evento NI (No Identificado) --------------------
    for k = 1:min_eventos
        if to(k) < ipo(k)
            [~, pos_max] = max(acc_vert(to(k):ipo(k)));
            ms(k) = pos_max + to(k) - 1;
        else
            warning('⚠️ Toe Off < Mid Stance en muestras %d %d', to(k), ipo(k))
            to(k) = ipo(k)-2;
            ms(k) = ipo(k)-1;
        end
    end
    tiempos(ms,7) = 1;
end

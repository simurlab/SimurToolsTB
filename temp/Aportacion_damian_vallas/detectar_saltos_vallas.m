function saltos = detectar_saltos_vallas(gyr_pie, acc_cog, freq, opciones)
% DETECTAR_SALTOS_VALLAS  Detecta eventos de salto de valla con IMUs en pie y COG.
%
%   saltos = detectar_saltos_vallas(gyr_pie, acc_cog, freq)
%   saltos = detectar_saltos_vallas(gyr_pie, acc_cog, freq, opciones)
%
%   Fusión heurística de dos señales independientes basado en:
%   
%     · Pie  → RFA (aceleración resultante) para detectar aterrizajes (IC_pie)
%     · COG  → v_z integrada por segmentos para detectar despegues (TO)
%
%   Un salto se valida cuando un TO va seguido de un IC_pie con un tiempo
%   de vuelo dentro del rango [FT_MIN_MS, FT_MAX_MS].
%
% ─── DEPENDENCIAS ────────────────────────────────────────────────────────────
%   filtro_paso_bajo_f0, eventos_pie_carrera  
%
% ─── EJEMPLO DE USO ──────────────────────────────────────────────────────────
%   load('g0102')
%   saltos = detectar_saltos_vallas(FL_1, COG_1, 120);
%   fprintf('%d saltos detectados\n', saltos.n);
%
% Author:  Damian / SiMuR  —  2026-04
% ─────────────────────────────────────────────────────────────────────────────

%% ── 0. ARGUMENTOS Y DEFAULTS ────────────────────────────────────────────────
if nargin < 3 || isempty(freq),    freq = 120;        end
if nargin < 4 || isempty(opciones), opciones = struct; end

RFA_THRESH = op(opciones, 'RFA_THRESH',  100);
FT_MIN_MS  = op(opciones, 'FT_MIN_MS',   550);
FT_MAX_MS  = op(opciones, 'FT_MAX_MS',   850);
TAU_MS     = op(opciones, 'TAU_MS',     2000);
INICIO_MIN = op(opciones, 'INICIO_MIN',  500);
P_UMBRAL   = op(opciones, 'P_UMBRAL_TO',  88);
PIE        = op(opciones, 'PIE',          '');
if ~ismember(PIE, {'izdo','dcho'})
    error('detectar_saltos_vallas: opciones.PIE debe ser ''izdo'' o ''dcho''');
end
VERBOSE    = op(opciones, 'VERBOSE',     true);
G          = 9.81;

FT_MIN = round(FT_MIN_MS / 1000 * freq);
FT_MAX = round(FT_MAX_MS / 1000 * freq);
TAU    = round(TAU_MS    / 1000 * freq);

N = min(height_or_length(gyr_pie), height_or_length(acc_cog));

if VERBOSE
    fprintf('=== detectar_saltos_vallas ===\n');
    fprintf('N=%d muestras  freq=%d Hz\n', N, freq);
    fprintf('RFA umbral: %.0f m/s²  FT: %d–%d ms  TAU: %d ms  Pie: %s\n', ...
        RFA_THRESH, FT_MIN_MS, FT_MAX_MS, TAU_MS, PIE);
end

%% ── 1. SEÑALES FILTRADAS ─────────────────────────────────────────────────────
acc_z_raw  = col(acc_cog.Acc_Z, N);
acc_z_20hz = filtro_paso_bajo_f0(acc_z_raw, 6, 20/freq);   % integración COG

acc_x_pie  = filtro_paso_bajo_f0(col(gyr_pie.Acc_X, N), 6, 15/freq);
acc_y_pie  = filtro_paso_bajo_f0(col(gyr_pie.Acc_Y, N), 6, 15/freq);
acc_z_pie  = filtro_paso_bajo_f0(col(gyr_pie.Acc_Z, N), 6, 15/freq);

%% ── 2. IC DEL PIE (segmentación de la integración) ──────────────────────────
% Pie derecho: Gyr_X invertido respecto al izquierdo en Xsens DOT
gyr_x_ic = col(gyr_pie.Gyr_X, N);
if strcmpi(PIE, 'dcho'), gyr_x_ic = -gyr_x_ic; end
[IC, ~, ~, ~, ~, ~] = eventos_pie_carrera(gyr_x_ic, 150, freq);
IC = unique(round(IC(IC > 1 & IC <= N)));
IC = IC(:)';

if VERBOSE, fprintf('IC pie detectados: %d\n', length(IC)); end

%% ── 3. RFA + IC_PIE ─────────────────────────────────────────────────────────
RFA = sqrt(acc_x_pie.^2 + acc_y_pie.^2 + acc_z_pie.^2);

da     = diff(RFA);
cambio = diff(da >= 0);
picos  = find(cambio == -1) + 1;
IC_pie = picos(RFA(picos) >= RFA_THRESH);

% Suprimir picos demasiado cercanos (< 15 muestras ≈ 125 ms)
i = 1;
while i < length(IC_pie)
    if IC_pie(i+1) - IC_pie(i) < 15
        if RFA(IC_pie(i)) >= RFA(IC_pie(i+1))
            IC_pie(i+1) = [];
        else
            IC_pie(i)   = [];
        end
    else
        i = i + 1;
    end
end

if VERBOSE
    fprintf('IC_pie (RFA >= %.0f m/s²): %d\n', RFA_THRESH, length(IC_pie));
end

%% ── 4. VELOCIDAD VERTICAL SIN DRIFT (segmento a segmento) ───────────────────
v_z    = zeros(N, 1);
n_seg  = length(IC) - 1;
for k = 1:n_seg
    i1   = IC(k);   i2 = IC(k+1);
    seg  = acc_z_20hz(i1:i2) - G;
    v_s  = cumtrapz(seg) / freq;
    % Corrección de drift lineal (fuerza v=0 en ambos extremos)
    tend = linspace(v_s(1), v_s(end), length(v_s))';
    v_z(i1:i2) = v_s - tend;
end

%% ── 5. DETECCIÓN DE TO ───────────────────────────────────────────────────────
max_por_seg = zeros(1, n_seg);
for k = 1:n_seg
    max_por_seg(k) = max(v_z(IC(k):IC(k+1)));
end
umbral_to = prctile(max_por_seg, P_UMBRAL);

TO_cog = zeros(1, n_seg);
for k = 1:n_seg
    i1 = IC(k); i2 = IC(k+1);
    [val, idx] = max(v_z(i1:i2));
    if val >= umbral_to
        TO_cog(k) = i1 + idx - 1;
    end
end
TO_cog = TO_cog(TO_cog > 0);

if VERBOSE, fprintf('TO candidatos: %d\n', length(TO_cog)); end

%% ── 6. FUSIÓN TO + IC_PIE → SALTOS VALIDADOS ────────────────────────────────
sal_TO = [];  sal_IC = [];  sal_FT = [];

for t = 1:length(TO_cog)
    if TO_cog(t) < INICIO_MIN, continue; end
    to  = TO_cog(t);
    cands = IC_pie(IC_pie >= to + FT_MIN & IC_pie <= to + FT_MAX);
    if ~isempty(cands)
        sal_TO = [sal_TO, to];              %#ok<AGROW>
        sal_IC = [sal_IC, cands(1)];        %#ok<AGROW>
        sal_FT = [sal_FT, cands(1) - to];  %#ok<AGROW>
    end
end

% Suprimir duplicados más cercanos que TAU
i = 1;
while i < length(sal_TO)
    if sal_TO(i+1) - sal_TO(i) < TAU
        if sal_FT(i) >= sal_FT(i+1)
            sal_TO(i+1)=[]; sal_IC(i+1)=[]; sal_FT(i+1)=[];
        else
            sal_TO(i)  =[]; sal_IC(i)  =[]; sal_FT(i)  =[];
        end
    else
        i = i + 1;
    end
end

%% ── 7. EMPAQUETAR SALIDA ────────────────────────────────────────────────────
saltos.TO    = sal_TO;
saltos.IC    = sal_IC;
saltos.FT_ms = sal_FT / freq * 1000;
saltos.n     = length(sal_TO);

% Señales internas (útiles para diagnóstico / figura)
saltos.diag.v_z    = v_z;
saltos.diag.RFA    = RFA;
saltos.diag.IC_pie = IC_pie;
saltos.diag.IC_cog = IC;
saltos.diag.TO_cog = TO_cog;

if VERBOSE
    fprintf('\n%-5s %-8s %-8s %-10s\n','#','TO','IC_pie','FT(ms)');
    fprintf('%s\n', repmat('-',1,33));
    for s = 1:saltos.n
        fprintf('%-5d %-8d %-8d %-10.1f\n', s, sal_TO(s), sal_IC(s), saltos.FT_ms(s));
    end
    fprintf('\nSaltos detectados: %d\n', saltos.n);
end

end % ── FIN FUNCIÓN PRINCIPAL ─────────────────────────────────────────────────


%% ══════════════════════════════════════════════════════════════════════════════
%  HELPERS LOCALES
% ══════════════════════════════════════════════════════════════════════════════

function v = op(s, campo, def)
% Devuelve s.(campo) si existe, si no def
    if isfield(s, campo) && ~isempty(s.(campo))
        v = s.(campo);
    else
        v = def;
    end
end

function x = col(x, N)
% Asegura columna y recorta a N muestras
    x = x(:);
    x = x(1:N);
end

function n = height_or_length(s)
% Acepta tabla o struct con campos vectoriales
    if istable(s)
        n = height(s);
    else
        fn = fieldnames(s);
        n  = length(s.(fn{1}));
    end
end

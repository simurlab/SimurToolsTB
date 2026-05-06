function visualizar_saltos_vallas(saltos, eval_result, etiquetas_gt, freq, acc_z_raw)
% VISUALIZAR_SALTOS_VALLAS  Figura diagnóstica de 3 paneles para saltos de valla.
%
%   visualizar_saltos_vallas(saltos, [], [], freq)
%   visualizar_saltos_vallas(saltos, eval_result, etiquetas_gt, freq)
%   visualizar_saltos_vallas(saltos, eval_result, etiquetas_gt, freq, acc_z_raw)
%
% ─── ENTRADAS ────────────────────────────────────────────────────────────────
%   saltos       : struct de detectar_saltos_vallas (necesita campo .diag)
%   eval_result  : struct de evaluar_saltos_vallas  (puede ser [] → sin GT)
%   etiquetas_gt : Kx2 GT [inicio fin]              (puede ser [])
%   freq         : frecuencia de muestreo [Hz]
%   acc_z_raw    : señal cruda de Acc_Z COG (opcional, para panel 3)
%
% Panel 1 → v_z con TO candidatos y saltos confirmados
% Panel 2 → RFA del pie con IC candidatos y aterrizajes confirmados
% Panel 3 → Acc_Z COG con ventanas de vuelo
%
% Author:  Damian / SiMuR  —  2026-04
% ─────────────────────────────────────────────────────────────────────────────

%% Colores
cr = [0.95 0.30 0.20];   % rojo  → detección
cg = [0.10 0.65 0.20];   % verde → GT
co = [1.00 0.55 0.00];   % naranja → candidatos

%% Señales internas del diagnóstico
v_z    = saltos.diag.v_z;
RFA    = saltos.diag.RFA;
IC_pie = saltos.diag.IC_pie;
TO_cog = saltos.diag.TO_cog;

N    = length(v_z);
t_ax = (0:N-1) / freq;

%% Determinar VPs
n_det = saltos.n;
if ~isempty(eval_result) && isfield(eval_result,'es_VP')
    es_VP = eval_result.es_VP;
else
    es_VP = true(1, n_det);   % sin GT, todo se trata como VP
end

show_gt = ~isempty(etiquetas_gt);
n_gt    = 0;
if show_gt, n_gt = size(etiquetas_gt,1); end

%% ── Panel 1: v_z ─────────────────────────────────────────────────────────────
figure('Name','Detector Saltos Valla','NumberTitle','off'); clf
sgtitle('Detector Saltos Valla — Fusión COG (v_z) + Pie (RFA)', 'FontSize',11)

sp1 = subplot(3,1,1); hold on
y1 = [min(v_z)*1.3, max(v_z)*1.3];
if y1(1)==y1(2), y1=[-1 1]; end

if show_gt
    for g = 1:n_gt
        x1=etiquetas_gt(g,1)/freq; x2=etiquetas_gt(g,2)/freq;
        patch([x1 x2 x2 x1],[y1(1) y1(1) y1(2) y1(2)], ...
            cg,'FaceAlpha',0.18,'EdgeColor',cg,'LineWidth',1.2);
    end
end

plot(t_ax, v_z, 'Color',[0.15 0.15 0.85],'LineWidth',1.1)
plot(TO_cog/freq, v_z(TO_cog), '^','MarkerSize',8, ...
    'MarkerFaceColor',co,'MarkerEdgeColor',[0.7 0.3 0], ...
    'DisplayName','TO cand.')

for s = 1:n_det
    c = cr; if ~es_VP(s), c=[0.5 0.5 0.5]; end
    plot(saltos.TO(s)/freq, v_z(saltos.TO(s)), 'd','MarkerSize',11, ...
        'MarkerFaceColor',c,'MarkerEdgeColor',[0.4 0.1 0.1],'LineWidth',1.5)
    text(saltos.TO(s)/freq, y1(2)*0.82, sprintf('S%d',s), ...
        'HorizontalAlignment','center','FontSize',9, ...
        'FontWeight','bold','Color',cr,'BackgroundColor',[1 1 1 0.7])
end

ylim(y1); grid on; ylabel('v_z (m/s)')
title('Velocidad vertical pelvis — verde=GT (Cuando se tiene), naranja=TO candidatos., rojo=salto VP')

h1=patch(NaN,NaN,cg,'FaceAlpha',0.3,'EdgeColor',cg);
h2=plot(NaN,NaN,'^','MarkerFaceColor',co,'MarkerEdgeColor',[0.7 0.3 0],'MarkerSize',7);
h3=plot(NaN,NaN,'d','MarkerFaceColor',cr,'MarkerEdgeColor',[0.4 0.1 0.1],'MarkerSize',8);
legend([h1 h2 h3],{'GT','TO cand.','Salto VP'},'Location','northwest','FontSize',8)

%% ── Panel 2: RFA ─────────────────────────────────────────────────────────────
sp2 = subplot(3,1,2); hold on
RFA_thresh_val = min(RFA(IC_pie));   % umbral mínimo observado
y2 = [0, max(RFA)*1.1];

if show_gt
    for g = 1:n_gt
        x1=etiquetas_gt(g,1)/freq; x2=etiquetas_gt(g,2)/freq;
        patch([x1 x2 x2 x1],[y2(1) y2(1) y2(2) y2(2)], ...
            cg,'FaceAlpha',0.18,'EdgeColor',cg,'LineWidth',1.2);
    end
end

plot(t_ax, RFA, 'Color',[0.15 0.15 0.15],'LineWidth',0.9)
yline(RFA_thresh_val,'r--','LineWidth',1.5, ...
    'Label',sprintf('Umbral %.0f m/s²',RFA_thresh_val),'LabelHorizontalAlignment','left')
plot(IC_pie/freq, RFA(IC_pie),'v','MarkerSize',7, ...
    'MarkerFaceColor',[0.2 0.6 1],'MarkerEdgeColor',[0.1 0.3 0.7])

for s = 1:n_det
    c = cr; if ~es_VP(s), c=[0.5 0.5 0.5]; end
    plot(saltos.IC(s)/freq, RFA(saltos.IC(s)), 's','MarkerSize',11, ...
        'MarkerFaceColor',c,'MarkerEdgeColor',[0.4 0.1 0.1],'LineWidth',1.5)
end

ylim(y2); grid on; ylabel('RFA (m/s²)')
title('Aceleración resultante pie — azul=IC  rojo=aterrizaje confirmado')

%% ── Panel 3: COG Acc_Z + ventanas de vuelo ────────────────────────────────────
sp3 = subplot(3,1,3); hold on

if nargin < 5 || isempty(acc_z_raw)
    % Si no se pasa señal cruda, usar v_z como referencia visual
    sig_raw = v_z;
    lbl = 'v_z (m/s)';
else
    sig_raw = acc_z_raw(:);
    sig_raw = sig_raw(1:N);
    lbl = 'Acc\_Z COG (m/s²)';
end

y3 = [min(sig_raw)*1.1, max(sig_raw)*1.1];
if y3(1)==y3(2), y3=[-1 1]; end

if show_gt
    for g = 1:n_gt
        x1=etiquetas_gt(g,1)/freq; x2=etiquetas_gt(g,2)/freq;
        patch([x1 x2 x2 x1],[y3(1) y3(1) y3(2) y3(2)], ...
            cg,'FaceAlpha',0.18,'EdgeColor',cg,'LineWidth',1.2);
    end
end

for s = 1:n_det
    x1 = saltos.TO(s)/freq;  x2 = saltos.IC(s)/freq;
    c  = cr; if ~es_VP(s), c=[0.7 0.5 0.5]; end
    patch([x1 x2 x2 x1],[y3(1) y3(1) y3(2) y3(2)], ...
        c,'FaceAlpha',0.22,'EdgeColor','none')
    text((x1+x2)/2, y3(2)*0.80, sprintf('FT=%.0fms',saltos.FT_ms(s)), ...
        'HorizontalAlignment','center','FontSize',8,'Color',cr, ...
        'BackgroundColor',[1 1 1 0.7])
end

plot(t_ax, sig_raw,'Color',[0.15 0.35 0.80],'LineWidth',1.2)
ylim(y3); grid on; ylabel(lbl); xlabel('Tiempo (s)')
title('COG — sombreado = ventana de vuelo TO→IC\_pie')

linkaxes([sp1 sp2 sp3], 'x')
xlim([0 N/freq])
end

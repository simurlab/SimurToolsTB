function eval = evaluar_saltos_vallas(saltos, etiquetas_gt, freq, ventana_eval)
% EVALUAR_SALTOS_VALLAS  Compara detecciones con Ground Truth y calcula métricas.
%
%   eval = evaluar_saltos_vallas(saltos, etiquetas_gt, freq)
%   eval = evaluar_saltos_vallas(saltos, etiquetas_gt, freq, ventana_eval)
%
% ─── ENTRADAS ────────────────────────────────────────────────────────────────
%   saltos        : struct devuelto por detectar_saltos_vallas
%   etiquetas_gt  : matriz Kx2  [muestra_inicio, muestra_fin]  de cada salto GT
%   freq          : frecuencia de muestreo [Hz]
%   ventana_eval  : tolerancia ± muestras para VP  (default 180 = 1.5 s a 120 Hz)
%
% ─── SALIDA ──────────────────────────────────────────────────────────────────
%   eval : struct con campos
%       .TP, .FP, .FN
%       .precision, .recall, .f1
%       .es_VP         [1 x n_det] booleano por detección
%       .gt_cubierto   [1 x n_gt]  booleano por evento GT
%       .err_FT_ms     error de FT respecto al centro GT [ms]  (solo VP)
%
% ─── EJEMPLO ─────────────────────────────────────────────────────────────────
%   gt = [793 875; 1296 1381; 1814 1901];
%   e  = evaluar_saltos_vallas(saltos, gt, 120);
%   fprintf('F1 = %.3f\n', e.f1);
%
% Author:  Damian / SiMuR  —  2026-04
% ─────────────────────────────────────────────────────────────────────────────

if nargin < 4 || isempty(ventana_eval), ventana_eval = 180; end

n_det = saltos.n;
n_gt  = size(etiquetas_gt, 1);

es_VP      = false(1, n_det);
gt_cubierto = false(1, n_gt);
err_FT_ms  = NaN(1, n_det);

for s = 1:n_det
    for g = 1:n_gt
        centro = round(mean(etiquetas_gt(g,:)));
        ft_gt  = (etiquetas_gt(g,2) - etiquetas_gt(g,1)) / freq * 1000;
        if abs(saltos.TO(s) - centro) < ventana_eval || ...
           abs(saltos.IC(s) - centro) < ventana_eval
            es_VP(s)       = true;
            gt_cubierto(g) = true;
            err_FT_ms(s)   = saltos.FT_ms(s) - ft_gt;
            break
        end
    end
end

TP = sum(es_VP);
FP = sum(~es_VP);
FN = sum(~gt_cubierto);

prec = TP / max(TP + FP, 1);
rec  = TP / max(TP + FN, 1);
f1   = 2 * prec * rec / max(prec + rec, eps);

eval.TP          = TP;
eval.FP          = FP;
eval.FN          = FN;
eval.precision   = prec;
eval.recall      = rec;
eval.f1          = f1;
eval.es_VP       = es_VP;
eval.gt_cubierto = gt_cubierto;
eval.err_FT_ms   = err_FT_ms;

fprintf('\n=== EVALUACIÓN vs GT ===\n');
fprintf('GT: %d  |  Detectados: %d\n', n_gt, n_det);
fprintf('TP=%d  FP=%d  FN=%d\n', TP, FP, FN);
fprintf('Precisión : %.0f%%\n', 100*prec);
fprintf('Recall    : %.0f%%\n', 100*rec);
fprintf('F1-score  : %.3f\n',   f1);
if any(~isnan(err_FT_ms))
    fprintf('Error FT  : %.1f ± %.1f ms (VP)\n', ...
        mean(err_FT_ms,'omitnan'), std(err_FT_ms,'omitnan'));
end
end

%% DEMO_SALTOS_VALLAS
%  Script de demostración — muestra cómo usar las tres funciones del pipeline.
%
%  Se utiliza el archivo de la prueba g102 Mestas Vallas
%
%  Funciones utilizadas:
%    detectar_saltos_vallas   → detección principal (siempre)
%  
%    visualizar_saltos_vallas → figura diagnóstica  (siempre)
%    GT= Datos segmentados manualmente
% ─────────────────────────────────────────────────────────────────────────────
clc; clear; close all;

freq = 120;

%% ── 1. CARGA ─────────────────────────────────────────────────────────────────
load('g 2025-06 - Las Mestas Vallas/Pruebas/01 Prueba/g0102')

%% ── 2. DETECCIÓN ─────────────────────────────────────────────────────────────
%  Modifica opciones para explorar parámetros sin tocar la función principal.

opc.PIE         = 'izdo';  % 'izdo' (FL_1) o 'dcho' (FR_1)  ← OBLIGATORIO
opc.RFA_THRESH  = 100;    % [m/s²]  umbral RFA para aterrizajes
opc.FT_MIN_MS   = 550;    % [ms]    tiempo de vuelo mínimo
opc.FT_MAX_MS   = 850;    % [ms]    tiempo de vuelo máximo
opc.TAU_MS      = 2000;   % [ms]    separación mínima entre saltos
opc.P_UMBRAL_TO = 88;     % [%]     percentil para umbral de despegue
opc.VERBOSE     = true;

saltos = detectar_saltos_vallas(FL_1, COG_1, freq, opc);

N = min(height(FL_1), height(COG_1));

%% ── 3. EVALUACIÓN vs GROUND TRUTH (OPCIONAL) ────────────────────────────────
%
%  Si tienes etiquetas manuales, defínelas aquí y activa TENGO_GT = true.
%  Si no tienes GT (trial nuevo, exploración, etc.), pon TENGO_GT = false
%  y el pipeline funciona igual — simplemente no calcula métricas.

TENGO_GT = true;   % ← cambia a false si no hay GT

if TENGO_GT
    etiquetas_gt = [
         793,  875;
        1296, 1381;
        1814, 1901;
        2336, 2424;
        2859, 2948;
        3393, 3484;
        3953, 4047;
        4523, 4616;
    ];
    ev = evaluar_saltos_vallas(saltos, etiquetas_gt, freq);
else
    etiquetas_gt = [];
    ev = [];
end

%% ── 4. VISUALIZACIÓN ─────────────────────────────────────────────────────────
%  Con GT → sombreado verde + marcadores VP/FP
%  Sin GT → solo señales y detecciones (igualmente útil)
visualizar_saltos_vallas(saltos, ev, etiquetas_gt, freq, COG_1.Acc_Z(1:N));
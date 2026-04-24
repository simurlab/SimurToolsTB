function [duracion, altura, energia] = evalua_cog_salto(eventos, freq, peso)
%EVALUA_COG_SALTO Calcula duración, altura y energía de saltos verticales.
%
%   [duracion, altura, energia] = evalua_cog_salto(eventos, freq, peso)
%
%   A partir de la matriz de eventos generada por eventos_cog_salto,
%   calcula para cada salto su duración, la altura alcanzada y la energía
%   potencial desarrollada.
%
%   La altura se estima mediante la ecuación de caída libre a partir del
%   tiempo de vuelo (intervalo entre inicio y fin del salto):
%       h = g · t² / 8
%
%   La energía corresponde a la energía potencial gravitatoria:
%       E = m · g · h
%
% INPUT:
%   eventos : matriz devuelta por eventos_cog_salto. Cada columna:
%               col 2 — inicio del salto (mínimo de aceleración)
%               col 4 — fin del salto (máximo de impacto)
%   freq    : frecuencia de muestreo [Hz]. Por defecto 100 Hz.
%   peso    : masa del atleta (más carga si la hay) [kg]. Por defecto 75 kg.
%
% OUTPUT:
%   duracion : vector con la duración de cada salto [s].
%   altura   : vector con la altura alcanzada en cada salto [m].
%   energia  : vector con la energía potencial de cada salto [J].
%
% EJEMPLO:
%   ev = eventos_cog_salto(acc_v, 100);
%   [dur, alt, ene] = evalua_cog_salto(ev, 100, 70);
%   fprintf('Altura media: %.2f m\n', mean(alt));
%
% See also: eventos_cog_salto
%
% Author:   SiMuR Lab (basado en evaluasalto de Alberto Castañon)
% History:  xx.xx.200x  versión original (evaluasalto)
%           24.04.2026  normalizada y modernizada

    if nargin < 2, freq = 100; end
    if nargin < 3, peso = 75;  end

    g = 9.81;

    inicios = find(eventos(:, 2));
    finales = find(eventos(:, 4));

    n        = min(numel(inicios), numel(finales));
    duracion = (finales(1:n) - inicios(1:n)) / freq;
    altura   = g * duracion.^2 / 8;
    energia  = peso * g * altura;

end

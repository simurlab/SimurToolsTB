%% corrige_eventos_pie
%
% Utilidad para testear NaNs en la deteccion de eventos de un experimento,
% y sustitucion por "valores razonables".
%

function [mat_eventos, ccalidad]=corrige_eventos_pie(mat_eventos, freq)


% NaNs en la detección de eventos:
%
numNaN = sum(isnan(mat_eventos), 'all');
vnumNaN=sum(isnan(mat_eventos)');

% El último numero es el numero de detecciones
vnumNaN=[vnumNaN size(mat_eventos,2) ];

% % Sustitucion del evento MP por 1/3-2/3:
% %
m=mat_eventos;
% mat_eventos(3,:)=m(1,:)+round(mean(m(4,:)-m(1,:))/3);

% Sustitucion de eventos NaN por los anteriores:
%
[row, col] = find(isnan(m));
if ~isempty(row)
    for iii = 1:length(row)
        %fprintf('Row %d, Column %d\n', row(i), col(i));
        if col(iii)==1,
            salto_siguiente = m(row(iii),col(iii)+1) - m(row(iii)+1,col(iii)+1);
            m(row(iii),col(iii))=  m(row(iii)-1,col(iii)) + salto_siguiente;
        else
            salto_anterior = m(row(iii),col(iii)-1) - m(row(iii)-1,col(iii)-1);
            m(row(iii),col(iii))=  m(row(iii)-1,col(iii)) + salto_anterior;
        end
    end
    mat_eventos=m;
end

%% Medidas de la calidad en señales y detecciones crudas:
%
ccalidad=vnumNaN;

% Volcado crudo, optimo para cortar y pegar en una hoja de cálculo:
% 
%fprintf('%.0f  \t', ccalidad);
%fprintf('\n');

% Volcado legible:
% 
%fprintf('NaNs sustituídos en cada evento: ');
%fprintf('%.0f  \t', ccalidad);
%fprintf('\n');

%a = 42;
%assignin('base', 'cal_eventos', ccalidad);  % Guarda ccalidad en el workspace base

end
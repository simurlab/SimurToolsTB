
% Vector de caracteres
%chars = {'A1', 'A2', 'A3', 'A4', 'A5', 'A6'};

chars = {'A2', 'A3', 'A4', 'A6'};

for ch = chars
    [a_cal, g_cal, Intervalos]=carga_calibra(ch{1},'N');
    testall_eventospie6;
end

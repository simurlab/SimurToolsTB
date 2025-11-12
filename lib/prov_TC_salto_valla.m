%Estimación del instante de contacto. 
%Usar solo para el paso de batida en la valla.
%  Esta es una primera estimación provisional

function t_contacto=prov_TC_salto_valla(acc_vert_raw,saltos)
    t_contacto=[];
    %tiempo desde el evento hasta el mínimo absoluto en 250ms??
    for salto=saltos
        [~, indice] = min(acc_vert_raw(salto:salto+30));
        tiempo=indice*1000/120;
        t_contacto = [t_contacto, tiempo]; %#ok<AGROW>
    end
end
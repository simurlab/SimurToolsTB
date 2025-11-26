%Estimación del instante de contacto. 
%Usar solo para el paso de batida en la valla.
%  Esta es una primera estimación provisional

function t_contacto=prov_TC_salto_valla2(acc_vert_tot,saltos)
    t_contacto=[];
    %tiempo desde el evento hasta el mínimo absoluto en 250ms??
    for salto=saltos
        indice = find(acc_vert_tot(salto+5:salto+30)<20,1);
        tiempo=(indice+5)*1000/120;
        t_contacto = [t_contacto, tiempo]; %#ok<AGROW>
    end
end
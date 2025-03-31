function [datos_out, R]=anatomical2ISB(datos_in,orden)

orden=[1 3 -2];
R=zeros(3,3);
for k=1:3
    R(k,abs(orden(k)))=sign(orden(k));
end

datos_out=datos_in*R';
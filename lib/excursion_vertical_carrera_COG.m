function desplazamientos=excursion_vertical_carrera_COG(MPL,MPR,acc_Z,fm)
    %%% Necesitamos los eventos MP de pie izquierdo y pie derecho.
    %%% Se calcula la excursión vertical entre apoyo y apoyo
    %%% Como la diferencia entre el valor máximo y mínimo de la doble
    %%% integral

    %recopilamos todos los MP
    MP=sort([MPL,MPR]); 
    desplazamientos=0*MP;
    for k=1:length(MP)-1
        acc_vert=acc_Z(MP(k):MP(k+1));
        meanAccVert = mean(acc_vert); 
        acc_vert=acc_vert-meanAccVert;
        vel_vert=cumsum(acc_vert)/fm;
        meanVelVert= mean(vel_vert);
        vel_vert=vel_vert-meanVelVert;
        posvert=cumsum(vel_vert)/fm;
        %plot(posvert);
        despvert=max(posvert)-min(posvert);
        % Store the maximum displacement for each segment
        desplazamientos(k) = despvert; 
    end
end

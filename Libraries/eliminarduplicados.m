

function [IC,FC]=eliminarduplicados(IC,FC)

    %Eliminamos FC indeseados al principio. El primer par queda bien
    while FC(1)<IC(1)
        FC=FC(2:end);
    end
    %Eliminamos IC indeseados al final. El último par queda bien
    while IC(end)>FC(end)
        IC=IC(1:end-1);
    end
    
    %Quitamos FC duplicados entre dos IC
    correcto=false;
    while ~correcto
        for i=1:length(IC)
            if IC(i)>FC(i)
                FC=[FC(1:i-1),FC(i+1:end)];
                break
            end
            if i<length(IC)-1
                if IC(i+1)<FC(i)
                    IC=[IC(1:i-1),IC(i+1:end)];
                    break
                end
            end
        end
        if i==length(IC)
            correcto=true;
        end
    end 
    if length(FC)>length(IC)
        FC=FC(1:length(IC));
    end

end


% Vector de caracteres
%chars = {'A1', 'A2', 'A3', 'A4', 'A5', 'A6'};

% chars = {'A2', 'A3', 'A4', 'A6'};
chars = {'A3'};

for ch = chars
    [a_cal, g_cal, Intervalos, quat_cal]=carga_calibra(ch{1},'N');
    testall_eventospie6;

    %%%%%%%%%%%%%%%%%%%%
    % Establecer las muestras de contacto inicial del pie
    muestras_contacto_inicial = initial_contact;
    for i=1:10:length(muestras_contacto_inicial{1})-1
        inicio_paso = muestras_contacto_inicial{1}(i);
        final_paso = muestras_contacto_inicial{1}(i+1);

        % ejemplo_primera_muestra = muestras_contacto_inicial{2}(30) + muestras_contacto_inicial{1}(end);
        % ejemplo_segunda_muestra = muestras_contacto_inicial{2}(31) + muestras_contacto_inicial{1}(end);

        % Crear cuaterniones de orientación usando los índices definidos
        % q_orientacion = quaternion(quat_cal);

        % Número de cuaterniones
        % n_cuaterniones = length(q_orientacion);

        % Inicializar el array de matrices de transformación homogénea
        % matrices_transformacion = zeros(4, 4, n_cuaterniones);
        %
        % eul_deg = {};
        %
        % delta_x=0;
        % % Iterar sobre cada cuaternión para calcular su matriz de transformación
        % for i = 1:n_cuaterniones
        %     q = q_orientacion(i);  % Obtener el cuaternión actual
        %     T=quat2tform(q);
        %     T(1,end) = delta_x;
        %     % Almacenar la matriz de transformación
        %     matrices_transformacion(:,:,i) = T;
        %     delta_x=delta_x+0.5;
        %
        %     % ángulos de Euler
        %     eul_deg{i,1} = eulerd(q, 'ZYX', 'frame');  % dimensiones mx3
        % end
        % matrices_transformacion(:,:,5)  % ejemplo de T

        % figure
        % grid on
        % view(-60,30)
        % for i=1:2:length(matrices_transformacion)
        %     pframe(matrices_transformacion(:,:,i),'c',1.4);
        %     hold on
        % end
        % axis([0 200 -5 5 -5 5])
        % axis equal
        %
        % %%%%%
        % angulos_de_Euler_matriz=cell2mat(eul_deg)
        % figure
        % plot(angulos_de_Euler_matriz, 'LineWidth',2)
        % grid on
        % xlabel('Muestra [-]'), ylabel('Ángulo rotado [°]')
        % title('Orientación entre dos foot-strikes consecutivos')

        %%%%%%
        % acc
        figure
        plot([a_cal(inicio_paso:final_paso,1), a_cal(inicio_paso:final_paso,2), a_cal(inicio_paso:final_paso,3)], 'LineWidth', 2)
        grid on
        xlabel('Muestra [-]'), ylabel('Aceleración [m/s^2]')
        title('Acelerómetro')
        % legend('x','y','z')

        %%%%%%
        % gyro
        figure
        plot([g_cal(inicio_paso:final_paso,1), g_cal(inicio_paso:final_paso,2), g_cal(inicio_paso:final_paso,3)], 'LineWidth', 2)
        grid on
        xlabel('Muestra [-]'), ylabel('Velocidad angular de giro [°/s]')
        title('Giroscopio')
    end
end

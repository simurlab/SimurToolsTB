% Vamos a analizar las señales del IMU colocado en el muslo.

ruta_csv_muslo = 'C:\Users\wwwal\OneDrive - Universidad de Oviedo\Archivos de JUAN CARLOS ALVAREZ ALVAREZ - SimurTools\Base de Datos\j 2025-10- Pasillo Departamental JC\Pruebas\THIGH_RIGHT_1\';
[IMU_MUSLOD, info_muslo] = carga_dot('ruta_carpeta', ruta_csv_muslo, 'save', 'y', 'orientacion', [1 2 3]);

% Pinta los datos del IMU del muslo
acc_z_muslo = IMU_MUSLOD.Acc_Z;
acc_y_muslo = IMU_MUSLOD.Acc_Y;
acc_x_muslo = IMU_MUSLOD.Acc_X;

figure;
subplot(3,1,1);
plot(acc_x_muslo, 'LineWidth',1.5);
title('Aceleración en X');
xlabel('Tiempo');
ylabel('Aceleración (m/s^2)');
xlim([1.5e4, 1.55e4])

subplot(3,1,2);
plot(acc_y_muslo, 'LineWidth',1.5);
title('Aceleración en Y');
xlabel('Tiempo');
ylabel('Aceleración (m/s^2)');
xlim([1.5e4, 1.55e4])

subplot(3,1,3);
plot(acc_z_muslo, 'LineWidth',1.5);
title('Aceleración en Z');
xlabel('Tiempo');
ylabel('Aceleración (m/s^2)');
xlim([1.5e4, 1.55e4])

% Calcular la magnitud de la aceleración
magnitud_aceleracion = sqrt(acc_x_muslo.^2 + acc_y_muslo.^2 + acc_z_muslo.^2);

% Calcular la FFT de la magnitud de la aceleración
N = length(magnitud_aceleracion);
Fs = 100; % Frecuencia de muestreo (ajustar según sea necesario)
f = (0:N-1)*(Fs/N); % Vector de frecuencias
Y = fft(magnitud_aceleracion); % FFT de la magnitud
P2 = abs(Y/N); % Amplitud de la FFT
P1 = P2(1:N/2+1); % Mantener solo la mitad positiva
P1(2:end-1) = 2*P1(2:end-1); % Duplicar amplitudes

% Pinta la FFT
figure;
plot(f(1:N/2+1), P1, 'LineWidth', 1.5);
title('FFT de la Magnitud de la Aceleración');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
xlim([0, Fs/2]);
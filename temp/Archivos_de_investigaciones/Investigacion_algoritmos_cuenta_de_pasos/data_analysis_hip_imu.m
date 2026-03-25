% Vamos a analizar las señales del IMU colocado en la cadera.

ruta_csv_cadera = 'C:\Users\wwwal\OneDrive - Universidad de Oviedo\Archivos de JUAN CARLOS ALVAREZ ALVAREZ - SimurTools\Base de Datos\j 2025-10- Pasillo Departamental JC\Pruebas\COG_1';
[IMU_CADERA, info_cadera] = carga_dot('ruta_carpeta', ruta_csv_cadera, 'save', 'y', 'orientacion', [1 2 3]);

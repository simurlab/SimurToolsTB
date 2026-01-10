% SiMur Toolbox v1.5.0   (06/10/2025)
%
% Toolbox de análisis de marcha, carrera, saltos y movimiento humano.
% Incluye funciones para procesar señales de IMUs, detectar eventos,
% estimar orientación y representar gráficamente datos biomecánicos.
%
% Las funciones están organizadas por TIPO DE ACTIVIDAD FÍSICA.
%
% ===================== CARRERA (Running) =====================
% Funciones específicas para análisis de carrera con IMU en pie o COG.
%
% eventos_pie_carrera                  - Detecta IC, FC, máximos/mínimos del ciclo de zancada
% eventos_cog_carrera                  - Eventos biomecánicos desde el centro de gravedad
% eventos_COG_vallas                   - Detección de eventos en carrera con vallas
% tiempos_eventos_carrera              - Calcula tiempos de fase (contacto, vuelo, swing)
% amplitud_impacto_carrera             - Pico de aceleración vertical en heel-strike
% amplitud_frenado_carrera             - Deceleración tras contacto inicial
% rms_aceleracion_impacto_carrera      - RMS de aceleración en fase de impacto
% rms_aceleracion_frenado_carrera      - RMS de aceleración en fase de frenado
% aceleracion_mediolateral_carrera     - Análisis de estabilidad lateral
% excursion_vertical_carrera_COG       - Oscilación vertical del centro de gravedad
% corrige_eventos_pie                  - Corrige valores perdidos en eventos detectados
% corrige_seniales_pie                 - Corrige NaN en señales de giroscopio del pie
%
% ===================== MARCHA / CAMINAR (Walking/Gait) =====================
% Funciones para análisis de marcha normal y estimación de distancia.
%
% eventos_cog_caminar                  - Detecta IC, TO y eventos intermedios (método Auvinet)
% eventos_cog_tiempo_real_caminar      - Detección online muestra a muestra
% distancia_pendulo                    - Estimación de distancia con modelo de péndulo invertido
% distancia_pendulo_parcial            - Péndulo con corrección en fase de doble apoyo
% distancia_arco                       - Modelo de arco angular para estimación de paso
% distancia_raiz_cuarta                - Modelo empírico de Weinberg
%
% ===================== SALTOS (Jumping) =====================
% Para análisis de salto vertical, vallas y pliometría.
%
% eventos_salto_vertical               - Detecta inicio, despegue, vuelo y aterrizaje
% eventos_COG_vallas                   - Identificación de saltos y caídas en carrera con obstáculos
%
% ===================== ACTIVIDADES CON MUÑECA (Wrist-based / Wearables) =====================
% Para smartwatches, pulseras de actividad o IMU en muñeca.
%
% contar_pasos_muneca                  - Conteo de pasos desde acelerómetro de muñeca
% contar_pasos_muneca_fusion           - Conteo con fusión de múltiples sensores
% stepcount                            - Algoritmo general de conteo de pasos
%
% ===================== ANÁLISIS DE SEGMENTOS CORPORALES (3D Body Segments) =====================
% Para sistemas MOCAP, orientación de extremidades y biomecánica articular.
%
% orientacion_giroscopo                - Integración de velocidad angular
% orientacion_compas                   - Estimación de heading desde magnetómetro
% orientacion_kalman                   - Fusión sensor mediante filtro de Kalman
% estimacion_rotacion_triad            - Algoritmo TRIAD (acelerómetro + magnetómetro)
% mostrar_orientacion_solido_rigido    - Visualización animada de cuaterniones
% mostrar_marcadores_solido_rigido     - Trayectorias de marcadores de MOCAP
% trayectoria_marcador                 - Representación de path 3D de un punto
% extraer_info_mocab                   - Parser de archivos de captura de movimiento
%
% ===================== LOCOMOCIÓN GENERAL (Transversal) =====================
% Funciones aplicables a cualquier actividad de desplazamiento.
%
% cadencia                             - Cálculo de pasos/min desde eventos IC/FC
% doble_integracion                    - Integración básica de aceleración a posición
% doble_integracion_ddi                - Método DDI (Drift Detection Integration)
% doble_integracion_lri                - Método LRI (Sabatini, 2005)
% doble_integracion_msi                - Método MSI (Mean Subtraction Integration)
% doble_integracion_ofi                - Método OFI (Optimal Frequency Integration)
% doble_integracion_zijlstra           - Método de Zijlstra/Kose
% distancia_recorrida_extremos         - Desplazamiento entre máximos y mínimos
% distancia_recorrida_marcador         - Distancia acumulada de un marcador
%
% ===================== CARGA DE DATOS =====================
% Lectura de archivos de distintos sensores comerciales.
%
% carga_IMUstd                         - Carga archivo en formato IMUstd estandarizado
% carga_dot                            - Carga archivos Xsens DOT (.csv)
% carga_shimmer                        - Carga archivos Shimmer (.csv)
% carga_bimu                           - Carga archivos B-IMU (.bin)
% carga_silop                          - Carga archivos SILOP (.sl)
% lectura_archivo_csv                  - Lectura de CSV genérico sin cabecera
%
% ===================== GESTIÓN DE BASES DE DATOS =====================
% Creación y gestión de datasets en formato IMUstd.
%
% db_prueba                            - Crea estructura de prueba desde archivos raw
% db_intentos                          - Organiza intentos/trials en estructura de BD
% resume_intentos                      - Genera resumen estadístico de intentos
%
% ===================== PREPROCESAMIENTO =====================
% Filtrado, limpieza y corrección de señales.
%
% filtro_paso_bajo_f0                  - Filtro FIR paso bajo de fase cero
% eliminar_duplicados                  - Elimina eventos IC/FC duplicados
% int_acumulada_cam_simp               - Integral acumulada con regla de Cavalieri-Simpson
%
% ===================== DETECCIÓN DE PICOS =====================
% Búsqueda de máximos y mínimos en señales.
%
% busca_maximos                        - Busca máximos locales en una señal
% busca_maximos_local                  - Busca máximos en un entorno de N vecinos
% busca_maximos_umbral                 - Busca máximos que superen un umbral
%
% ===================== TRANSFORMACIONES =====================
% Conversiones de sistemas de referencia y utilidades matemáticas.
%
% anatomical_to_isb                    - Conversión de sistema anatómico a ISB
% separar_celda_por_fila               - Separa filas de una celda en archivos .mat
%
% ===================== VISUALIZACIÓN =====================
% Representación gráfica de datos biomecánicos.
%
% mostrar_eventos                      - Dibuja eventos detectados sobre señales
% mostrar_patrones                     - Superpone ciclos normalizados con media y bandas
% dibujar_sistema_referencia           - Dibuja sistema de referencia 3D con flechas
% dibujar_voxel                        - Dibuja un voxel 3D en una figura
% esfera_3d                            - Proyección de datos sobre esfera 3D
% crear_solido_prismatico              - Crea sólido prismático para representación
%

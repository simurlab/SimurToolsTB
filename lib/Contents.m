% SiMur Toolbox v1.5.0   (06/10/2025)
%
% Toolbox de análisis de marcha, carrera y movimiento
% Incluye funciones para procesar señales, detectar eventos,
% estimar orientación y representar gráficamente datos biomecánicos.
%
% ===================== Procesamiento de señales =====================
% filtro_paso_bajo_f0                  - Filtro FIR paso bajo de fase cero (fase 0)
% integracion_acumulada_cav_simpson    - Integral acumulada con regla de Cavalieri-Simpson
% doble_integracion                    - Doble integración genérica de señales
% doble_integracion_ddi                - Doble integración método DDI
% doble_integracion_lri                - Doble integración método LRI
% doble_integracion_msi                - Doble integración método MSI
% doble_integracion_ofi                - Doble integración método OFI
% doble_integracion_zijlstra           - Doble integración método Zijlstra
% eliminar_duplicados                  - Elimina valores repetidos en señales
%
% ===================== Eventos y parámetros de marcha/carrera =====================
% eventos_pie_carrera                  - Detecta IC y TO en el pie durante carrera
% eventos_pie_old_carrera              - Versión anterior de detección de eventos del pie
% eventos_cog_carrera                  - Detecta eventos en el COG durante carrera
% eventos_cog_caminar                  - Detecta eventos en el COG durante la marcha
% eventos_cog_tiempo_real_caminar      - Eventos del COG en tiempo real durante la marcha
% eventos_salto_vertical               - Detecta fases principales de un salto vertical
% corrige_eventos_pie                  - Corrige los eventos de IC/TO detectados
% corrige_seniales_pie                 - Corrige señales del pie en carrera
% tiempos_eventos_carrera              - Calcula intervalos temporales entre eventos
% cadencia                             - Calcula la cadencia de la marcha/carrera
% aceleracion_mediolateral_carrera     - Aceleración mediolateral en carrera
% amplitud_frenado_carrera             - Amplitud de la aceleración de frenado
% amplitud_impacto_carrera             - Amplitud de la aceleración de impacto
% rms_aceleracion_frenado_carrera      - RMS de la aceleración de frenado
% rms_aceleracion_impacto_carrera      - RMS de la aceleración de impacto
%
% ===================== Orientación =====================
% orientacion_compas                   - Estima orientación con compás (vector magnético)
% orientacion_giroscopo                - Estima orientación con giroscopio
% orientacion_kalman                   - Orientación fusionando compás y giroscopio (Kalman)
% estimacion_rotacion_triad            - Estimación de rotación con algoritmo TRIAD
%
% ===================== Distancias y métricas =====================
% distancia_arco                       - Distancia por arco de circunferencia
% distancia_pendulo                    - Distancia usando modelo de péndulo invertido
% distancia_pendulo_parcial            - Distancia con péndulo en intervalos parciales
% distancia_raiz_cuarta                - Distancia mediante método de la raíz cuarta
% distancia_recorrida_extremos         - Distancia entre extremos de segmentos
% distancia_recorrida_marcador         - Distancia recorrida por un marcador
%
% ===================== Entrada/salida y carga de datos =====================
% carga_bimu                           - Carga de datos de sensores B-IMU
% carga_dot                            - Carga de archivos DOT
% carga_sensores                       - Carga general de sensores
% carga_shimmer                        - Carga de datos Shimmer
% carga_silop                          - Carga de datos SILOP
% extraer_info_mocab                   - Extrae información de un archivo MoCap con cabecera
% lectura_archivo_csv                  - Lectura de archivo CSV sin cabecera
% segmenta_intentos                    - Segmentación de intentos de IMUs
% separar_celda_por_fila               - Separa filas de una celda en archivos .mat
%
% ===================== Visualización =====================
% dibujar_sistema_referencia           - Dibuja un sistema de referencia 3D
% dibujar_voxel                        - Dibuja un voxel 3D en una figura
% crear_solido_prismatico              - Crea un sólido prismático para representación
% mostrar_marcadores_solido_rigido     - Representa marcadores de un sólido rígido
% mostrar_orientacion_solido_rigido    - Visualiza orientación de un sólido rígido
% trayectoria_marcador                 - Traza la trayectoria de un marcador en 3D
% esfera_3d                            - Proyección 3D de datos sobre una esfera
%
% ===================== Utilidades varias =====================
% busca_maximos                        - Busca máximos locales en una señal
% busca_maximos_local                  - Busca máximos locales en un entorno definido
% busca_maximos_umbral                 - Busca máximos que superen un umbral
% anatomical_to_isb                    - Conversión anatómica a sistema ISB

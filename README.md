

![logo](./img/logoIA2.png)
# 🧠 SiMuR Tools — MATLAB Toolbox para el Análisis de Movimiento

**Grupo:** SiMuR — Universidad de Oviedo  
**Versión:** 1.5 (Octubre 2025)  
 
---

## 📘 Descripción General

**SiMuR Tools TB** es un conjunto de funciones en MATLAB diseñadas para facilitar el procesamiento, análisis y visualización de datos provenientes de sensores en estudios de biomecánica y control del movimiento humano, especialmente sensores inerciales tipo IMUs (Xsens DOT, Shimmer, Bimu, etc.) 

El toolbox permite desde la **carga y preprocesamiento de señales**, hasta la **detección automática de eventos**, el **cálculo de parámetros espacio-temporales** y la **estimación de orientación** y **ángulos articulares** en tiempo real.

---

## 🧩 Estructura del Toolbox

Las funciones están organizadas por **bloques funcionales**, lo que facilita su uso modular dentro de pipelines personalizados de análisis.

| Categoría | Funciones Principales | Descripción |
|------------|-----------------------|--------------|
| **Preprocesamiento** | `filtro_paso_bajo_f0`, `eliminar_duplicados`, `corrige_eventos_pie`, `corrige_seniales_pie` | Limpieza y filtrado de señales, corrección de eventos y duplicados. |
| **Cálculo Espacial / Cinemático** | `doble_integracion`, `doble_integracion_ddi`, `doble_integracion_lri`, `doble_integracion_msi`, `doble_integracion_ofi`, `doble_integracion_zijlstra`, `distancia_pendulo`, `distancia_arco`, `distancia_recorrida_extremos`, `trayectoria_marcador` | Integración de aceleraciones y cálculo de distancias y trayectorias. |
| **Eventos y Segmentación** | `eventos_pie_carrera`, `eventos_cog_carrera`, `eventos_cog_caminar`, `eventos_salto_vertical`, `segmenta_intentos`, `tiempos_eventos_carrera` | Detección automática de eventos de pie, centro de gravedad o salto, y segmentación de intentos. |
| **Parámetros de Rendimiento** | `cadencia`, `amplitud_impacto_carrera`, `amplitud_frenado_carrera`, `rms_aceleracion_frenado_carrera`, `rms_aceleracion_impacto_carrera`, `aceleracion_mediolateral_carrera` | Extracción de variables biomecánicas de interés para análisis de carrera o marcha. |
| **Orientación y Estimación Angular** | `orientacion_giroscopo`, `orientacion_compas`, `orientacion_kalman`, `estimacion_rotacion_triad` | Estimación de orientación de sólidos rígidos a partir de IMUs mediante distintos métodos (complementario, Kalman, TRIAD). |
| **Visualización 3D** | `dibujar_sistema_referencia`, `mostrar_marcadores_solido_rigido`, `mostrar_orientacion_solido_rigido`, `dibujar_voxel`, `esfera_3d`, `crear_solido_prismatico` | Representación gráfica de sistemas de referencia, marcadores y volúmenes 3D. |
| **Utilidades y Matemática General** | `busca_maximos`, `busca_maximos_local`, `busca_maximos_umbral`, `anatomical_to_isb`, `separar_celda_por_fila`, `distancia_raiz_cuarta`, `integracion_acumulada_cav_simpson` | Funciones auxiliares para optimización, búsqueda de picos y transformaciones anatómicas. |
| **Gestión de Bases de Datos** |  `carga_bimu`, `carga_shimmer`, `carga_dot`, `carga_sensores`,  `carga_silop`, `lectura_archivo_csv` | Lectura y formateo de archivos provenientes de distintos dispositivos de medida, para la creación y mantenimiento de Bases de Datos específicas. |

---

## 🚀 Instalación

  Se puede instalar mediante el AddsOn Manager propio de Matlab

---

## 🧪 Ejemplo de Uso

```matlab
% Ejemplo básico de pipeline con datos de carrera

% 1. Filtrar aceleraciones
data.acc = filtro_paso_bajo_f0(data.acc, 20, data.freq);

% 2. Detectar eventos de pie
[ic, fc, maxS, minS, mvp, mp] = eventos_pie_carrera(data.gyr, 10, data.freq);

% 3. Calcular tiempos de fase
tiempos = tiempos_eventos_carrera(ic, fc, maxS, minS, mvp, mp, data.freq);

% 4. Calcular cadencia
cad = cadencia(ic, fc, data.freq);

% 5. Visualizar resultados
dibujar_sistema_referencia();
```

---

## 🧱 Convenciones y Estructura de Carpetas

```
SimurTools/
│
├── carga_*                 % Funciones de lectura de datos
├── eventos_*               % Detección de eventos biomecánicos
├── orientacion_*           % Estimación de orientación
├── dibujar_*, mostrar_*    % Visualización 3D
├── doble_integracion_*     % Métodos de integración
├── amplitud_*, rms_*       % Parámetros de rendimiento
├── Contents.m              % Índice automático del toolbox
└── README.md               % Este archivo
```

---

## 🧩 Dependencias

* MATLAB R2020a o superior
* Toolboxes recomendados:

  * **Signal Processing Toolbox**
  * **Optimization Toolbox**
  * **Aerospace Toolbox** *(para algunos cálculos de orientación)*
 
**En caso de tener la Robotic Toolbox se recomienta desinstalarla o evitar sus funciones para cálculos de cuaterniones, ya que utiliza diferentes esquema**

---

## 📚 Cita y Atribución

Si utilizas este toolbox en una publicación científica, cita de la siguiente manera:

>  *SiMuR Tools: MATLAB Toolbox para el análisis biomecánico*, SiMuR, Universidad de Oviedo, 2025.

---

## 🧠 Créditos

Desarrollado en el **SiMuR Lab** (Simulación y Movimiento Humano) — Universidad de Oviedo.
Contacto: [[juan@uniovi.es](mailto:juan@uniovi.es)]

---



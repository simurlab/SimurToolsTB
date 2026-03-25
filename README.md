![logo](img/logoIA3mini.jpeg)
# 🧠 SiMuR Tools — MATLAB Toolbox para el Análisis de Movimiento

**Grupo:** SiMuR — Universidad de Oviedo  
**Versión:** 1.5.1 (Marzo 2026)  
 
---

## 📘 Descripción General

**SiMuR Tools TB** es un conjunto de funciones en MATLAB diseñadas para facilitar el procesamiento, análisis y visualización de datos provenientes de sensores en estudios de biomecánica y control del movimiento humano, especialmente sensores inerciales tipo IMUs (Xsens DOT, Shimmer, Bimu, etc.) 

El toolbox permite desde la **carga y preprocesamiento de señales**, hasta la **detección automática de eventos**, el **cálculo de parámetros espacio-temporales** y la **estimación de orientación** y **ángulos articulares** en tiempo real.

Las herramientas sirven tanto para trabajar con archivos de datos generados por sensores comerciales, como con datos estandarizados en el formato **IMUstd**, que se describe más adelante. 

---

## 🧩 Estructura del Toolbox

Las funciones están organizadas por **tipo de actividad física**, lo que facilita identificar rápidamente las herramientas disponibles para cada aplicación.

### 🏃 Carrera (Running)
Funciones específicas para análisis de carrera con IMU en pie o centro de gravedad.

| Función | Descripción |
|---------|-------------|
| `eventos_pie_carrera` | Detecta IC, FC, máximos/mínimos del ciclo de zancada |
| `eventos_cog_carrera` | Eventos biomecánicos desde el centro de gravedad |
| `tiempos_eventos_carrera` | Calcula tiempos de fase (contacto, vuelo, swing) |
| `amplitud_impacto_carrera` | Pico de aceleración vertical en heel-strike |
| `amplitud_frenado_carrera` | Deceleración tras contacto inicial |
| `rms_aceleracion_impacto_carrera` | RMS de aceleración en fase de impacto |
| `rms_aceleracion_frenado_carrera` | RMS de aceleración en fase de frenado |
| `aceleracion_mediolateral_carrera` | Análisis de estabilidad lateral |
| `excursion_vertical_carrera_COG` | Oscilación vertical del centro de gravedad |
| `eventos_COG_vallas` | Detección de eventos en carrera con vallas |

### 🚶 Marcha / Caminar (Walking/Gait)
Funciones para análisis de marcha normal y estimación de distancia.

| Función | Descripción |
|---------|-------------|
| `eventos_cog_caminar` | Detecta IC, TO y eventos intermedios (método Auvinet) |
| `eventos_cog_tiempo_real_caminar` | Detección online muestra a muestra |
| `distancia_pendulo` | Estimación de distancia con modelo de péndulo invertido |
| `distancia_pendulo_parcial` | Péndulo con corrección en fase de doble apoyo |
| `distancia_arco` | Modelo de arco angular para estimación de paso |
| `distancia_raiz_cuarta` | Modelo empírico de Weinberg |

### 🦘 Saltos (Jumping)
Para análisis de salto vertical, vallas y pliometría.

| Función | Descripción |
|---------|-------------|
| `eventos_salto_vertical` | Detecta inicio, despegue, vuelo y aterrizaje |
| `eventos_COG_vallas` | Identificación de saltos y caídas en carrera con obstáculos |

### ⌚ Actividades con Muñeca (Wrist-based / Wearables)
Para smartwatches, pulseras de actividad o IMU en muñeca.

| Función | Descripción |
|---------|-------------|
| `contar_pasos_muneca` | Conteo de pasos desde acelerómetro de muñeca |
| `contar_pasos_muneca_fusion` | Conteo con fusión de múltiples sensores |
| `stepcount` | Algoritmo general de conteo de pasos |

### 🦴 Análisis de Segmentos Corporales (3D Body Segments)
Para sistemas MOCAP, orientación de extremidades y biomecánica articular.

| Función | Descripción |
|---------|-------------|
| `orientacion_giroscopo` | Integración de velocidad angular |
| `orientacion_compas` | Estimación de heading desde magnetómetro |
| `orientacion_kalman` | Fusión sensor mediante filtro de Kalman |
| `estimacion_rotacion_triad` | Algoritmo TRIAD (acelerómetro + magnetómetro) |
| `mostrar_orientacion_solido_rigido` | Visualización animada de cuaterniones |
| `mostrar_marcadores_solido_rigido` | Trayectorias de marcadores de MOCAP |
| `trayectoria_marcador` | Representación de path 3D de un punto |
| `extraer_info_mocab` | Parser de archivos de captura de movimiento |

### 🔄 Locomoción General (Transversal)
Funciones aplicables a cualquier actividad de desplazamiento.

| Función | Descripción |
|---------|-------------|
| `cadencia` | Cálculo de pasos/min desde eventos IC/FC |
| `doble_integracion` | Integración básica de aceleración a posición |
| `doble_integracion_ddi` | Método DDI (Drift Detection Integration) |
| `doble_integracion_lri` | Método LRI (Sabatini, 2005) |
| `doble_integracion_msi` | Método MSI (Mean Subtraction Integration) |
| `doble_integracion_ofi` | Método OFI (Optimal Frequency Integration) |
| `doble_integracion_zijlstra` | Método de Zijlstra/Kose |
| `distancia_recorrida_extremos` | Desplazamiento entre máximos y mínimos |
| `distancia_recorrida_marcador` | Distancia acumulada de un marcador |

### ⚙️ Infraestructura Común (Core/Utils)
Carga de datos, preprocesamiento y visualización universal.

| Categoría | Funciones |
|-----------|-----------|
| **Carga de datos** | `carga_IMUstd`, `carga_dot`, `carga_shimmer`, `carga_bimu`, `carga_silop`, `lectura_archivo_csv` |
| **Base de datos** | `db_prueba`, `db_intentos`, `resume_intentos` |
| **Preprocesamiento** | `filtro_paso_bajo_f0`, `eliminar_duplicados`, `corrige_eventos_pie`, `corrige_seniales_pie` |
| **Detección de picos** | `busca_maximos`, `busca_maximos_local`, `busca_maximos_umbral` |
| **Transformaciones** | `anatomical_to_isb`, `separar_celda_por_fila`, `int_acumulada_cam_simp` |
| **Visualización** | `mostrar_eventos`, `mostrar_patrones`, `dibujar_sistema_referencia`, `dibujar_voxel`, `esfera_3d`, `crear_solido_prismatico` |

### 📊 Resumen por Actividad

```
SimurToolsTB (70+ funciones)
├── 🏃 Carrera .............. 10 funciones
├── 🚶 Marcha ............... 6 funciones
├── 🦘 Saltos ............... 2 funciones
├── ⌚ Muñeca/Wearables ..... 3 funciones
├── 🦴 Segmentos 3D ......... 8 funciones
├── 🔄 Locomoción general ... 9 funciones
└── ⚙️ Infraestructura ...... 20+ funciones
```

---

## 🧱 Convenciones y Estructura de Carpetas

```
SimurTools/
│
├── carga_*                 % Funciones de lectura de datos
├── eventos_*               % Detección de eventos biomecánicos
├── db_*                       % Creación de Bases de Datos en el formato IMUstd 
├── orientacion_*           % Estimación de orientación
├── dibujar_*, mostrar_*    % Visualización 3D
├── doble_integracion_*     % Métodos de integración
├── amplitud_*, rms_*       % Parámetros de rendimiento
├── Contents.m              % Índice automático del toolbox
└── README.md               % Este archivo
```

---

## ⚙️ El formato IMU estándar (IMUstd)

 El formato **IMUstd** es un tipo de dato estandarizado, especialmente útil para trabajar con la **SIMUR Tools TB**. 
 Se define para homogeneizar la información proveniente de la gran diversidad de IMUs disponibles en el mercado.
  
 Un **IMUstd** es un sensor colocado de cierta manera, en una cierta localización del cuerpo, y con ciertas propiedades. 
 Se define con una estructura que consta de dos partes: datos y metadatos.
 
### Datos: 
las señales de los sensores ordenadas en columnas:

| Tipo de dato | Etiqueta Principales | Unidades |
|------------|-----------------------|----------------------|
| Acelerómetro | "Acc_X", "Acc_Y", "Acc_Z" |ms |
| Giroscopio | "Gyr_X", "Gyr_Y", "Gyr_Z"|ms |
| Magnético |"Mag_X", "Mag_Y", "Mag_Z"|ms |
|Ángulos de Euler | "Eul_X", "Eul_Y", "Eul_Z"|ms |
|Cuaternion|"Quat_W", "Quat_X", "Quat_Y", "Quat_Z"|ms |
|Número de muestra|"PacketCounter"| ms |
|Instante de la muestra|"Time"| ms |
|Estado de la batería|"Battery"| ms |
|Código de estado|"Status"| ms |
|Uso reservado|"Var24"| - |
|Uso reservado|"Index"| - |

### Metadatos: 
información referida al tipo de sensor y su colocación:

| Metadato |  Información | Ejemplo |
|------------|-----------------------|----------------------|
|IMU | ID del sensor utilizado  | 'DOT8' |
|ubicacion | Dónde se colocó el sensor | 'FL' 'FR' 'COG' |
|modelo | Etiqueta del modelo comercial | 'Xsens Dot' |
|frecuencia | muestreo del sensor | 30, 60, 100, 120... Hz |
|orientacion | relativa respecto al **sistema de referencia IMUstd**, de convenio {V, ML, AP} ("anatómico") | [3,-1,2] |
|intervaloIntento | muestra inicial y final de interés, del archivo raiz | [600, 14000] |

La función *carga_IMUstd* de la TB está pensada para leer un archivo de un **IMUstd** y devolver las señales de acelerómetros y giroscopios referidas a
un sistema de referencia *anatómico*, de convenio (V, ML, AP).

![El sistema de referencia de IMUstd {V, ML, AP}](img/IMUstd_mini.png)

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



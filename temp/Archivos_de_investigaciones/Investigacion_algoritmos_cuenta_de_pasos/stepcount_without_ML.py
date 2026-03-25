# Septiembre 2025.

# En este script se implementa una versión simplificada del método Stepcount, eliminando la parte correspondiente
# al modelo de clasificación.

# Vamos a suponer que los datos que alimentan al algoritmo de cuenta de pasos se corresponden con la actividad
# "caminar usual speed" de un dataset PMP.


import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
from scipy.signal import find_peaks, peak_prominences



def butter_lowpass_normalized(cutoff_norm, order=4):
    """
    Crea un filtro paso-bajo Butterworth con frecuencia de corte normalizada (sin emplear
    la frecuencia de muestreo fs).
    
    :param cutoff_norm: Frecuencia de corte normalizada entre 0 y 1.
    :param order: Orden del filtro.
    :return: Coeficientes del filtro Butterworth.
    """
    
    b, a = butter(order, cutoff_norm, btype='low')
    return b, a


def apply_lowpass_filter(data, cutoff_norm, order=4):
    """
    Aplica el filtro paso-bajo con frecuencia de corte normalizada.
    
    :param data: Señal de entrada.
    :param cutoff_norm: Frecuencia de corte normalizada (sin necesidad de utilizar fs).
    :param order: Orden del filtro.
    :return: Señal filtrada.
    """
    
    b, a = butter_lowpass_normalized(cutoff_norm, order)
    y = filtfilt(b, a, data)
    return y


# --------------------------------------------------------------------------------------------------
# Algoritmos propuestos por Koffman and Muschelli - Step counting algorithm evaluation
# --------------------------------------------------------------------------------------------------

def stepcount(X_PMP, identificacion_dataset):
    """
    Implementación manual del algoritmo Stepcount para la contabilización del número de pasos.
    Este algoritmo identifica el número de pasos dividiendo el análisis en 2 fases:
    1.- Filtrado paso-bajo. Se realiza un "suavizado" de la señal que elimine las componentes 
        de alta frecuencia y minimice la detección de falsos positivos. Se ha tomado una
        frecuencia de corte de 2 [Hz] para analizar el gait.
    2.- En la señal filtrada se detectarán los máximos locales, cuya contabilización permite
        obtener el número total de pasos.
    La cuenta de pasos se realiza para una única actividad de estudio.
    
    - Variables de entrada:
    ---------------------------------
    * X_PMP: np.array de dimensiones (m muestras, número de características, tamaño de ventana).
      Esta variable contiene los datos de acelerometría que se utilizarán para la cuenta de pasos.
      Asumiremos que los datos se corresponden con una actividad etiquetada de caminar.

    * identificacion_dataset: variable de tipo string que contiene el identificador del dataset
      que se está analizando. Este dato se utilizará en el mensaje informativo a imprimir al
      final de la función.
      
    - Variables de salida devueltas:
    ---------------------------------
    * numero_de_pasos: variable de tipo int que contiene el número de pasos dados por la persona monitorizada.
    """
    
    # Para identificar el número de pasos no necesitamos las señales del giroscopio. La cuenta de pasos puede efectuarse a partir
    # de la componente vertical del acelerómetro. Indexamos todas las muestras de la ventana y la última columna del acelerómetro (eje Z)
    X_subset_PMP_acelerometro_eje_z = []                                                                                   # Vector de aceleración vertical (eje Z)
    for i in range(X_PMP.shape[0]):                                                                                   # Para muestra de datos de la actividad en estudio --> HACER:                                            # Última columna (Acc Z) de la muestra i-ésima
      X_subset_PMP_acelerometro_eje_z.append(X_PMP[i, 2, :])   # aceleración en el eje Z, IMU 1
      
    X_subset_PMP_acelerometro_eje_z = np.array(X_subset_PMP_acelerometro_eje_z)                                  # Convertir la lista a un array de NumPy
    print(f"Dimensiones de los datos X_subset_PMP_acelerometro_eje_Z: {X_subset_PMP_acelerometro_eje_z.shape}")  # Imprimir las dimensiones de dicho array
    
    # El enventanado se había realizado sin solapamiento. Por tanto, no es necesario deshacer el enventanado.
    # Representación gráfica de los datos (componente vertical, eje Z, de la aceleración)
    # Crear una figura con 2 filas y 1 columna
    fig, axes = plt.subplots(2, 1, figsize=(6, 8))                           # 2 filas, 1 columna

    acc_z_PMP = X_subset_PMP_acelerometro_eje_z.ravel()                      # Tras aplicar el método ravel, el eje Z de aceleración se expresa como un vector (obtenido a partir de una matriz)
    axes[0].plot(acc_z_PMP)                                                  # Representar aceleración filtrada
    axes[0].set_xlabel('Sample [-]')                                         # Etiqueta eje X
    axes[0].set_ylabel('Accelerometer data [g]. Z axis')                     # Etiqueta eje Y
    axes[0].grid(True)                                                       # Activación de rejilla
    # axes[0].xlim([2000, 2100])  
    axes[0].set_title(f'Acc Z. {identificacion_dataset} dataset')            # Título de la gráfica
    
    # Inicialmente, vamos a realizar una implementación manual del algoritmo "Stepcount"; dividida en 2 fases:
    # ----------------------------------------------------------------------------------------------------------
    # * Fase 1: Filtrado paso-bajo de las señales de acelerometría. Vamos a evitar emplear la frecuencia de
    #           muestreo durante el filtrado de la señal. En su defecto, usaremos una frecuencia normalizada.
    # ----------------------------------------------------------------------------------------------------------
    
    # Configuramos el filtro Paso-Bajo con una frecuencia de corte normalizada.
    # Cálculo de la frecuencia de corte normalizada: los datos están muestreados a una frecuencia de 25 Hz, mientras
    # que el gait puede analizarse con una cadencia de 2.5 Hz o 2 Hz. Por tanto, la frecuencia de corte normalizada a emplear será:
    frecuencia_de_corte_normalizada = 2/25                                                  # Es decir, tomamos la 0.08 parte de la frecuencia de muestreo (aproximadamente 25 [Hz])
    acc_z_PMP_filtrada = apply_lowpass_filter(acc_z_PMP, frecuencia_de_corte_normalizada)   # Aplicación del filtro paso-bajo (Butterworth)
    
    # *******************************************************************************************
    # * IMPORTANTE: Se considera que una frecuencia de corte de 2 Hz es adecuada para realizar  *    
    # *             la cuenta de passos.                                                        *
    # *******************************************************************************************
    
    # ----------------------------------------------------------------------------------------------------------
    # * Fase 3: Identificación y contabilización de los "picos" existentes en la señal filtrada.
    #           Nos centraremos en la componente vertical (eje Z) de la aceleración registrada en el muslo.
    # ----------------------------------------------------------------------------------------------------------
    
    # Para detectar picos en la señal de acelerometría utilizamos la función find_peaks de la librería scipy.signal
    maximos, _ = find_peaks(acc_z_PMP_filtrada)                                           # Encontrar máximos en la señal de aceleración vertical (eje Z)
    
    # 3.1.- Eliminación de los falsos positivos existentes en los máximos identificados
    diff_maximos = np.diff(maximos)                                                                 # Calcular las diferencias entre índices consecutivos de los máximos
    distancia_minima_entre_maximos = 20                                                             # Número mínimo de muestras que debe haber entre cada par de máximos
    mask = diff_maximos < distancia_minima_entre_maximos                                            # Esta máscara es True para las diferencias que son menores a 20
    maximos_sin_falsos_positivos = np.delete(maximos, np.where(mask)[0] + 1)                        # Eliminar los elementos que no cumplen la condición. Esto se logra 
                                                                                                    # eliminando el siguiente elemento en los pares donde la diferencia es menor a 20 muestras.
    # Aquellos máximos que sean menores que un umbral dado también los eliminaremos de la detección.
    # Inicialmente, tomamos como umbral 0.5 g.
    # Calcular prominencias de los máximos
    prominencias = peak_prominences(acc_z_PMP_filtrada, maximos_sin_falsos_positivos)[0]                      # Calculamos las prominencias de cada máximo local respecto a las muestras de su entorno
    umbral_prominencia = 0.1                                                                                  # Indicamos el umbral de prominencia de los máximos a aplicar en el filtrado
    maximos_sin_falsos_positivos_filtrados = maximos_sin_falsos_positivos[prominencias >= umbral_prominencia] # Se seleccionan aquellos máximos cuya prominencia sea mayor que el umbral indicado
    
    # ----------------------------------------------------------------------------------------------------------
    # * Fase 4: Representación gráfica de los resultados obtenidos para la detección de máximos y 
    #           cuenta de pasos.
    # ----------------------------------------------------------------------------------------------------------
    
    axes[1].plot(acc_z_PMP_filtrada)                                                                                                # Pintamos la señal de aceleración (eje Z) filtrada
    
    for idx in maximos_sin_falsos_positivos_filtrados:                                                                                        # Para cada máximo --> HACER:
      axes[1].axvline(x=idx, color='red', linestyle='--', linewidth=1, label=f'Línea en x={idx}')                                             # Dibujar una línea vertical para cada mínimo
    
    axes[1].plot(maximos_sin_falsos_positivos_filtrados, acc_z_PMP_filtrada[maximos_sin_falsos_positivos_filtrados], 'ro', label="Máximos Detectados")  # Destacamos con un punto cada máximo detectado
    axes[1].set_xlabel('Sample [-]')                                                      # Etiqueta eje X
    axes[1].set_ylabel('Accelerometer data filtered [g]. Z axis')                         # Etiqueta eje Y
    axes[1].grid(True)                                                                    # Activación de rejilla
    axes[1].set_title(f'Vertical component of acceleration (FILTERED). {identificacion_dataset} dataset')   # Título de la gráfica

    # RESULTADO DEL ALGORITMO: El número de pasos dados será la longitud del vector minimos.
    # Debe refinarse el algoritmo para evitar la detección de falsos positivos.
    numero_de_pasos = len(maximos_sin_falsos_positivos_filtrados)                         # El número de pasos es la longitud del vector maximos
    print(f"\nEl número de pasos dados por el sujeto del dataset {identificacion_dataset} durante la actividad es: {numero_de_pasos} pasos.")
    
    # Insertar en la figura texto informativo sobre el número de pasos
    texto_informativo = 'Número de pasos contabilizados: '
    axes[1].text(0.5, 0.1, f'{texto_informativo}{numero_de_pasos}', fontsize=12, color='blue', ha='center', va='center', transform=axes[1].transAxes)
    plt.tight_layout()                         # Ajustar espacio entre subplots
    plt.show()                                 # Mostrar la figura generada
    
    return numero_de_pasos                     # Retornamos la cuenta sobre el número de pasos


# Tests de la función
# if __name__=="__main__":
    
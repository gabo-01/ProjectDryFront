Este proyecto representa la interfaz frontend de una solución de Machine Learning aplicada a procesos de secado en entornos metalúrgicos. Su objetivo es facilitar la toma de decisiones mediante la predicción inteligente del comportamiento del filtro de secado a partir de variables clave del proceso.

Arquitectura del Proyecto

El frontend ha sido desarrollado con un enfoque modular y se compone principalmente de tres clases fundamentales:

🔹 APIService

Encargada de la comunicación con el backend. Esta clase gestiona el consumo del API, el envío de parámetros necesarios para el modelo, y la recepción de las respuestas generadas por el sistema de Machine Learning.

🔹 ContentView

Es la vista principal de la aplicación. Desde aquí se genera y despliega la muestra de datos de forma aleatoria, los cuales son enviados al endpoint correspondiente para ser procesados por el modelo predictivo. Esta vista ofrece una experiencia de usuario sencilla, intuitiva y eficiente.

🔹 ModalView

Responsable del manejo de las respuestas del modelo. Incluye funcionalidades para procesar y visualizar los resultados obtenidos del endpoint, así como una función adicional para el envío de resultados por correo electrónico a los usuarios o responsables del proceso.

⸻

Objetivo General

Integrar una solución inteligente y accesible que permita predecir condiciones óptimas del proceso de secado metalúrgico, mejorando así la eficiencia operativa y la calidad del producto final.

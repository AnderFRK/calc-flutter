# Calculadora Multiusos

Una aplicación móvil construida con Flutter que fusiona la versatilidad de un bloc de notas con el poder de una calculadora financiera. Ideal para llevar presupuestos, listas de compras o cuentas rápidas combinando texto descriptivo y expresiones matemáticas de forma natural.

## ✨ Características Principales

* **Lógica Mixta:** Escribe texto y operaciones matemáticas en la misma celda (ej. `Zapatos \n 45 * 2`). La app extrae automáticamente los números y calcula el resultado.
* **Teclados Inteligentes:** Alterna fluidamente entre el teclado nativo de Android (para texto) y una **botonera matemática personalizada** (para cálculos rápidos).
* **Resaltado de Sintaxis:** Los operadores matemáticos (`+`, `-`, `*`, `/`) se pintan de color naranja en tiempo real para distinguirlos de los números.
* **Diseño Dinámico (Multiline):** Las filas se expanden automáticamente hacia abajo usando saltos de línea (`↵`), manteniendo el número de lista arriba y el resultado abajo.
* **Cálculo en Tiempo Real:** El resultado individual de cada fila y el Total General se actualizan instantáneamente con cada pulsación.

## 📱 Capturas de Pantalla

> **Nota para ti:** *Aquí puedes reemplazar estos enlaces con imágenes reales de tu app subidas a GitHub. Solo arrastra tus capturas a esta sección cuando edites el archivo en GitHub.*
> 
> ![Captura 1](URL_DE_TU_IMAGEN_1) | ![Captura 2](URL_DE_TU_IMAGEN_2)

## 🛠️ Tecnologías Utilizadas

* **Framework:** [Flutter](https://flutter.dev/)
* **Lenguaje:** Dart
* **Paquetes Externos:** * [`math_expressions`](https://pub.dev/packages/math_expressions): Para el análisis y evaluación de las ecuaciones matemáticas como texto.

## 📁 Estructura del Proyecto

El proyecto sigue una arquitectura limpia para separar la lógica de negocio de la interfaz de usuario:

```text
lib/
├── models/
│   └── calc_row.dart          # Modelo de datos y controladores por fila
├── screens/
│   └── calculator_screen.dart # Pantalla principal y lógica de evaluación
├── utils/
│   └── math_controller.dart   # Controlador de texto con resaltado de sintaxis
├── widgets/
│   └── custom_keypad.dart     # Componente UI del teclado personalizado
└── main.dart                  # Punto de entrada de la aplicación

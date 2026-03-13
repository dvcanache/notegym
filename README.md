# NoteGym 🏋️‍♀️🧘‍♂️

¡Bienvenido a **NoteGym**! Una aplicación minimalista, fluida y en español para llevar el control total de tus entrenamientos. 

Diseñada con un moderno estilo *glassmorphism* y animada para ofrecer una experiencia de usuario (UX) premium. Olvídate de llevar papel y lápiz al gimnasio; NoteGym te permite registrar series, pesos, descansos y analizar tu progreso de forma inteligente.

## ✨ Características Principales

*   **Autenticación Sencilla:** Inicio de sesión rápido y seguro mediante de tu cuenta de Google.
*   **Rutinas Predeterminadas:** Explora y utiliza rutinas de ejemplo listas para usar (Fuerza básica, Cardio HIIT, Glúteos y piernas, Yoga, etc.).
*   **Rutinas Personalizadas:** Crea tus propias rutinas desde cero. Selecciona ejercicios, ajusta series, repeticiones y pesos iniciales.
*   **Importación y Exportación (.xlsx):** ¿Tienes tu rutina en Excel o Google Sheets? Impórtala fácilmente y empieza a entrenar. También puedes descargar una plantilla, o exportar y compartir tus rutinas por redes sociales o correo.
*   **Seguimiento en Tiempo Real:** Interfaz viva para llevar tu entrenamiento actual. Marca las series completadas mientras el **temporizador de descanso** automático lleva la cuenta para tu próxima serie.
*   **Estadísticas y Progreso:** Analiza tu rendimiento semanal, revisa tu volumen de carga y rompe tus propios récords personales (PRs).
*   **Historial Completo:** Revisa todos los entrenamientos anteriores con sus datos exactos agrupados por mes/semana.
*   **Modo Claro y Oscuro Personalizable:** Ajusta la apariencia general eligiendo tu tema favorito (Claro, Oscuro o automático según el sistema), conservando los increíbles elementos *glass* e iconos vibrantes.

## 🛠 Entorno y Tecnologías 

Este proyecto está construido 100% sobre **Flutter SDK**. Integra numerosas herramientas potentes para su correcto funcionamiento:

- **[Flutter Riverpod](https://pub.dev/packages/flutter_riverpod):** El gestor de estado principal. Reactividad y control absoluto de cada componente.
- **[GoRouter](https://pub.dev/packages/go_router):** Rutas estables, controladas y con parámetros para una navegación declarativa y moderna.
- **[Firebase & cloud_firestore](https://firebase.google.com/):** Integración rápida de Auth mediante Google Sign-in y alojamiento en Firestore Database (o uso completamente local de Hive dependiendo de su configuración inicial).
- **[Excel (Dart package)](https://pub.dev/packages/excel):** Creación y manipulación estructurada de plantillas `xlsx`.
- **[Fl Chart](https://pub.dev/packages/fl_chart):** Gráficos impresionantes de estadísticas y barras vectorizadas.
- **[Flutter Animate](https://pub.dev/packages/flutter_animate):** Animaciones fluidas listas para implementarse en todos los apartados gráficos.
- **Arquitectura Mantenible:** Modelos escalables (`Routine`, `WorkoutLog`, `UserProfile`, `Exercise`) separados de los Features y Componentes Reusables (Ej. `GlassCard`, `GradientButton`).

## 🚀 Empezando

Asegúrate de tener instalado y configurado **Flutter SDK (>3.11.1)** y conexión a internet. 

### Instalación 

1. Clona el proyecto en tu máquina local.
   ```bash
   git clone https://github.com/tu_usuario/notegym.git
   cd notegym
   ```
2. Instala todas las dependencias.
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación en tu dispositivo o simulador habitual.
   ```bash
   flutter run
   ```

> **!Nota:** Puesto que la lógica actual depende de `google_sign_in` y se proyecta usar `Firestore`, necesitarás que tu entorno local disponga del archivo `google-services.json` de tu proyecto personal de Firebase. Sin él, el flujo en `android/app` lanzará una excepción.

## 🎨 Apariencia

NoteGym se desvía del típico diseño plano (`Flat`) de las apps habituales en favor del **Glassmorphism**, el concepto central detras del nuevo Fluent Design. Utiliza desenfoques sutiles del fondo (blur), bordes de cristal semitransparentes, paletas compuestas purpúras (`#7C3AED`) y naranjas (`#F97316`) y la tipografía inter de `Google_fonts`. 

### Componentes Exclusivos Destacados

- **ThemeExtension dinámica**: El tema global adapta todo el motor gráfico (`context.colors`), ya sea un cambio a modo nocturno o sistema. 
- **Timer de Entrenamiento (con vibración contextual):** Una vez cierras tu set de ejercicio, un contador con `GlassCard` grande invadirá la pantalla ofreciendo la cuenta atrás exacta preconfigurada.

---

### Tareas Pendientes o Roadmap a futuro

- [ ] Incluir un selector de idioma adicional (EN/ES/PT).
- [ ] Opciones para importar el registro físico directamente desde un escáner OR/Cámara.
- [ ] Ampliaciones de la librería interna de Ejercicios.
- [ ] Agregar mapa muscular dinámico en las estadísticas, mostrando con calor qué músculos hemos entrenado más. 

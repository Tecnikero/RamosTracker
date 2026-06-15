# RamosTracker 🎓

**RamosTracker** es una aplicación móvil nativa desarrollada en Flutter, diseñada para ayudar a estudiantes universitarios a sobrevivir al semestre. Permite gestionar asignaturas, llevar un control exacto de las notas, organizar el horario de clases y almacenar material de estudio localmente.

Ideal para carreras con alta carga de lectura y análisis de casos, como Administración de Empresas, donde tener los porcentajes claros y los PDFs a mano es vital.

##Características Principales

* **Gestión de Asignaturas (CRUD):** Crea, edita y elimina ramos configurando sus días y horas de clases.
* **Horario Dinámico Inteligente:** Una vista de agenda que calcula automáticamente las posiciones de las tarjetas de clase según la hora y hace auto-scroll hacia el día actual.
* **Lector de Material Integrado:** Adjunta y abre archivos (PDFs, Word, Excel) directamente desde la app usando el lector nativo del dispositivo sin consumir datos de internet.
* **Calculadora de Notas en Tiempo Real:** * Calcula tu promedio actual y la "nota meta" para aprobar.
  * Simulador de escenarios (¿Qué pasa si me saco un 2.0 en este certamen?).
  * Soporte avanzado para asignaturas evaluadas por Resultados de Aprendizaje (RA).
* **Almacenamiento Offline-First:** Toda la información, horarios y rutas de archivos se guardan permanentemente en el teléfono utilizando una base de datos local súper rápida.

##Tecnologías y Paquetes Utilizados

* **[Flutter](https://flutter.dev/):** Framework principal para el desarrollo de la interfaz.
* **[Hive](https://pub.dev/packages/hive):** Base de datos NoSQL ligera y rápida para persistencia de datos locales.
* **[File_Picker](https://pub.dev/packages/file_picker):** Para explorar y seleccionar archivos desde el almacenamiento nativo.
* **[Open_Filex](https://pub.dev/packages/open_filex):** Para invocar a las aplicaciones nativas del SO al momento de abrir documentos.
* **[Table_Calendar](https://pub.dev/packages/table_calendar):** Motor visual para la renderización del calendario de evaluaciones.

##Cómo ejecutar el proyecto

Si deseas compilar este proyecto en tu propia máquina, asegúrate de tener el [SDK de Flutter](https://docs.flutter.dev/get-started/install) instalado.

1. Clona este repositorio:
   ```bash
   git clone [https://github.com/tu_usuario/ramo_tracker.git](https://github.com/tu_usuario/ramo_tracker.git)

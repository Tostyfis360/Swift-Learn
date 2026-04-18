# Swift Learn

> Una app iOS para aprender Swift — de Junior a Mid Developer, un día a la vez.

Swift Learn es una app de aprendizaje basada en cuestionarios, construida íntegramente en SwiftUI. Cubre los temas de Swift e iOS que marcan la diferencia entre un desarrollador junior y uno de nivel medio, usando repetición espaciada, progresión por XP y cinco formatos de pregunta distintos para que el aprendizaje sea eficaz y motivador.

---

## Capturas de pantalla

<p align="center">
  <img src="https://github.com/user-attachments/assets/61be7347-e773-4986-8f2f-e0eaf966ee84" width="220">
  <img src="https://github.com/user-attachments/assets/ab662def-1317-43b0-b1de-f6a051c5cde8" width="220">
  <img src="https://github.com/user-attachments/assets/5159ae21-b362-45b1-8336-75392ad658f0" width="220">
</p>

---

## Funcionalidades

- **5 tipos de pregunta** — Opción múltiple, completar código, identificar el error, verdadero/falso y reordenar pasos arrastrando
- **Repetición espaciada** — Las preguntas falladas se reprograman automáticamente a intervalos de 1h → 4h → 24h
- **XP y niveles** — Gana 10 XP por cada respuesta correcta y avanza de Aprendiz → Junior → Mid → Senior
- **Rachas de estudio** — Seguimiento de racha diaria para consolidar el hábito de aprendizaje
- **Duración de sesión** — Corta (5 preguntas · ~3 min), Normal (10 preguntas · ~7 min) o Intensa (20 preguntas · ~15 min)
- **7 logros** — Se desbloquean según rachas, velocidad de respuesta, precisión y módulos completados
- **Vista de progreso** — Estadísticas por módulo, precisión global y cuadrícula de logros
- **100% offline** — Todo el contenido está incluido en la app; no requiere conexión

---

## Stack tecnológico

| | |
|---|---|
| **Lenguaje** | Swift 5.10 |
| **UI** | SwiftUI |
| **Persistencia** | SwiftData |
| **iOS mínimo** | iOS 17 |
| **Arquitectura** | MVVM |
| **Datos** | Banco de preguntas en JSON |
| **Dependencias** | Ninguna — solo frameworks de Apple |

---

## Arquitectura

El proyecto sigue **MVVM** con una capa de servicios que mantiene toda la lógica de datos fuera de las vistas.

```
App
├── Models          — Structs de Swift y modelos SwiftData
│   ├── Question    — Question, QuestionOption, QuizModule, QuestionBank
│   ├── Session     — SessionLength, SessionResult, AnswerRecord
│   ├── UserProgress — UserProgress, ModuleProgress, FailedQuestion (SwiftData)
│   └── Achievement — Achievement, catálogo Achievements
│
├── Services        — Lógica de negocio, sin dependencias de SwiftUI
│   ├── QuestionBankService   — Carga el JSON y construye sesiones con sesgo de repetición espaciada
│   └── ProgressService       — Registra resultados, evalúa logros y resetea datos
│
├── ViewModels      — @Observable · @MainActor
│   ├── HomeViewModel         — Lista de módulos, XP y cola de revisión
│   ├── QuizViewModel         — Máquina de estados del quiz, envío de respuestas y fin de sesión
│   └── ProgressViewModel     — Agregación de estadísticas para la pantalla de progreso
│
└── Views
    ├── Home        — HomeView, ModuleCardView
    ├── Quiz        — QuizView, SessionSetupView, MultipleChoiceView,
    │                 OrderStepsView, ExplanationView, SessionResultView
    ├── Progress    — StudyProgressView, SettingsView
    └── Components  — ProgressRingView, XPBarView, CodeBlockView,
                      AchievementBadgeView, ViewExtensions (AppColors)
```

### Decisiones de diseño clave

- **`QuizViewModel` es una máquina de estados** — `QuizState` dirige la UI: `.idle → .question → .explanation(wasCorrect:) → .finished`. La vista reacciona al estado; nunca lo conduce.
- **`ProgressService` gestiona todas las mutaciones de datos** — el registro de sesiones, la evaluación de logros, las actualizaciones de racha y el reseteo de progreso viven en el servicio. Las vistas solo llaman a métodos del servicio a través de su ViewModel.
- **Repetición espaciada en `QuestionBankService.buildSession`** — hasta el 50% de cada sesión se rellena con preguntas previamente falladas, con prioridad sobre las nuevas. La proporción disminuye de forma natural a medida que el usuario domina el contenido.
- **Los modelos SwiftData no llegan a las vistas** — `UserProgress`, `ModuleProgress` y `FailedQuestion` son clases `@Model` con reglas de eliminación en cascada. Los ViewModels exponen propiedades computadas simples; las vistas nunca acceden directamente a tipos SwiftData.

---

## Contenido

### Módulos (142 preguntas)

| Módulo | Temas |
|---|---|
| 🧱 **Swift** | Variables, opcionales, closures, protocolos, genéricos, manejo de errores |
| 🎨 **SwiftUI** | Vistas, modificadores, gestión de estado, navegación, listas, animaciones |
| 🏛 **Patrones** | MVC, MVVM, coordinator, delegate, singleton, inyección de dependencias |
| 📐 **Principios** | SOLID, Clean Architecture, DRY, KISS, separación de responsabilidades |
| ⚡ **Concurrencia** | async/await, actores, Task, concurrencia estructurada, Swift 6 |

### Tipos de pregunta

| Tipo | Descripción |
|---|---|
| `multiple_choice` | Selecciona la respuesta correcta entre 4 opciones |
| `code_completion` | Rellena el hueco dentro de un fragmento de código |
| `true_false` | Evalúa si un enunciado es correcto o incorrecto |
| `identify_error` | Localiza el bug en un bloque de código |
| `order_steps` | Arrastra los elementos hasta colocarlos en el orden correcto |

### Niveles de XP

| Nivel | Rango de XP |
|---|---|
| Aprendiz | 0 – 99 |
| Junior | 100 – 299 |
| Mid | 300 – 599 |
| Senior | 600 + |

### Logros

| | Título | Condición |
|---|---|---|
| 🔥 | En Racha | 3 días de estudio consecutivos |
| ⚡ | Velocista | 5 respuestas correctas en menos de 30 s cada una |
| 🎯 | Sin Fallos | Completar una sesión sin ningún error |
| 🧠 | Memoria de Elefante | Responder correctamente una pregunta que antes fallaste |
| 💎 | Perfeccionista | 100% de precisión en cualquier módulo |
| 🔄 | Persistente | Racha de estudio de 7 días |
| 🏆 | Graduado | Completar los 5 módulos |

---

## Primeros pasos

### Requisitos

- Xcode 16+
- Simulador o dispositivo con iOS 17+

### Ejecución

```bash
git clone https://github.com/<tu-usuario>/SwiftLearn.git
cd SwiftLearn
open SwiftLearn.xcodeproj
```

Selecciona un simulador o dispositivo y pulsa **⌘R**. Sin gestores de paquetes ni scripts de configuración.

---

## Añadir preguntas

Todo el contenido reside en `SwiftLearn/Resources/QuestionBank.json`. Cada pregunta sigue este esquema:

```json
{
  "id": "id_unico",
  "type": "multiple_choice",
  "topic": "Nombre del tema",
  "difficulty": "junior",
  "question": "Texto de la pregunta",
  "options": [
    { "id": "A", "text": "Opción A" },
    { "id": "B", "text": "Opción B" }
  ],
  "correctId": "A",
  "explanation": "Por qué A es correcta...",
  "codeExample": "// fragmento de Swift opcional",
  "tags": ["tag1", "tag2"]
}
```

Valores de `type` admitidos: `multiple_choice`, `code_completion`, `true_false`, `identify_error`, `order_steps`.

Para preguntas de tipo `order_steps`, usa `steps` (array de strings) y `correctOrder` (array de enteros) en lugar de `options`.

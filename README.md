# Swift Learn

> An iOS app to learn Swift — from Junior to Middle Developer, one day at a time.

Swift Learn is a quiz-based learning app built entirely in SwiftUI. It covers the Swift and iOS topics that bridge the gap between junior and mid-level developers, using spaced repetition, XP progression, and five different question formats to keep learning effective and engaging.

---

## Features

- **5 question types** — Multiple choice, code completion, identify the error, true/false, and drag-to-reorder steps
- **Spaced repetition** — Failed questions are automatically rescheduled for review at 1h → 4h → 24h intervals
- **XP & levels** — Earn 10 XP per correct answer and progress through Aprendiz → Junior → Mid → Senior
- **Study streaks** — Daily streak tracking to build a consistent learning habit
- **Session lengths** — Short (5q · ~3 min), Normal (10q · ~7 min), or Intense (20q · ~15 min)
- **7 achievements** — Unlocked based on streaks, answer speed, accuracy, and module completion
- **Progress view** — Per-module stats, global accuracy, and achievement grid
- **Fully offline** — All content is bundled; no network required

---

## Tech Stack

| | |
|---|---|
| **Language** | Swift 5.10 |
| **UI** | SwiftUI |
| **Persistence** | SwiftData |
| **Minimum iOS** | iOS 17 |
| **Architecture** | MVVM |
| **Data** | JSON bundled question bank |
| **Dependencies** | None — Apple frameworks only |

---

## Architecture

The project follows **MVVM** with a service layer that keeps all data logic out of views.

```
App
├── Models          — Plain Swift structs & SwiftData models
│   ├── Question    — Question, QuestionOption, QuizModule, QuestionBank
│   ├── Session     — SessionLength, SessionResult, AnswerRecord
│   ├── UserProgress — UserProgress, ModuleProgress, FailedQuestion (SwiftData)
│   └── Achievement — Achievement, Achievements catalog
│
├── Services        — Business logic, zero SwiftUI dependency
│   ├── QuestionBankService   — Loads JSON, builds sessions with spaced repetition bias
│   └── ProgressService       — Records results, evaluates achievements, resets data
│
├── ViewModels      — @Observable · @MainActor
│   ├── HomeViewModel         — Module list, XP display, review queue
│   ├── QuizViewModel         — Quiz state machine, answer submission, session finish
│   └── ProgressViewModel     — Stats aggregation for the progress screen
│
└── Views
    ├── Home        — HomeView, ModuleCardView
    ├── Quiz        — QuizView, SessionSetupView, MultipleChoiceView,
    │                 OrderStepsView, ExplanationView, SessionResultView
    ├── Progress    — StudyProgressView, SettingsView
    └── Components  — ProgressRingView, XPBarView, CodeBlockView,
                      AchievementBadgeView, ViewExtensions (AppColors)
```

### Key design decisions

- **`QuizViewModel` is a state machine** — `QuizState` drives the UI: `.idle → .question → .explanation(wasCorrect:) → .finished`. The view reacts to state; it never drives it.
- **`ProgressService` owns all data mutations** — session recording, achievement evaluation, streak updates, and progress reset all live in the service. Views call service methods only through their ViewModel.
- **Spaced repetition in `QuestionBankService.buildSession`** — up to 50% of each session is filled with previously failed questions, prioritised before fresh ones. The ratio decreases naturally as the user masters content.
- **SwiftData models stay out of views** — `UserProgress`, `ModuleProgress`, and `FailedQuestion` are `@Model` classes with cascade delete rules. ViewModels expose plain computed properties; views never touch SwiftData types directly.

---

## Content

### Modules (142 questions)

| Module | Topics |
|---|---|
| 🧱 **Swift** | Variables, optionals, closures, protocols, generics, error handling |
| 🎨 **SwiftUI** | Views, modifiers, state management, navigation, lists, animations |
| 🏛 **Patrones** | MVC, MVVM, coordinator, delegate, singleton, dependency injection |
| 📐 **Principios** | SOLID, Clean Architecture, DRY, KISS, separation of concerns |
| ⚡ **Concurrencia** | async/await, actors, Task, structured concurrency, Swift 6 |

### Question types

| Type | Description |
|---|---|
| `multiple_choice` | Select the correct answer from 4 options |
| `code_completion` | Fill in the blank inside a code snippet |
| `true_false` | Evaluate whether a statement is correct |
| `identify_error` | Spot the bug in a code block |
| `order_steps` | Drag items into the correct sequence |

### XP levels

| Level | XP range |
|---|---|
| Aprendiz | 0 – 99 |
| Junior | 100 – 299 |
| Mid | 300 – 599 |
| Senior | 600 + |

### Achievements

| | Title | Condition |
|---|---|---|
| 🔥 | En Racha | 3 consecutive study days |
| ⚡ | Velocista | 5 correct answers under 30s each |
| 🎯 | Sin Fallos | Complete a session without any mistakes |
| 🧠 | Memoria de Elefante | Answer correctly a question you previously failed |
| 💎 | Perfeccionista | 100% accuracy on any module |
| 🔄 | Persistente | 7-day study streak |
| 🏆 | Graduado | Complete all 5 modules |

---

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+ simulator or device

### Run

```bash
git clone https://github.com/<your-username>/SwiftLearn.git
cd SwiftLearn
open SwiftLearn.xcodeproj
```

Select a simulator or device and press **⌘R**. No package manager, no setup scripts.

---

## Adding questions

All content lives in `SwiftLearn/Resources/QuestionBank.json`. Each question follows this schema:

```json
{
  "id": "unique_id",
  "type": "multiple_choice",
  "topic": "Topic name",
  "difficulty": "junior",
  "question": "Question text",
  "options": [
    { "id": "A", "text": "Option A" },
    { "id": "B", "text": "Option B" }
  ],
  "correctId": "A",
  "explanation": "Why A is correct...",
  "codeExample": "// optional Swift snippet",
  "tags": ["tag1", "tag2"]
}
```

Supported `type` values: `multiple_choice`, `code_completion`, `true_false`, `identify_error`, `order_steps`.

For `order_steps` questions, use `steps` (string array) and `correctOrder` (int array) instead of `options`.

---

## License

MIT

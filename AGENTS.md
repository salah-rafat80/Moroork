# AntiGravity Agent Configuration — Morourak Traffic App

<!--
  This file is loaded into context on EVERY message in this project.
  It activates: Caveman mode, Flutter/Dart rules, Morourak API skill, and all global skills.
-->

---

## 🪨 Caveman Mode — ALWAYS ON

Respond terse like smart caveman. All technical substance stay. Only fluff die.

- No long intros. No "Of course!", "Certainly!", "Great question!"
- No restating what user said.
- Code first. Explanation only if critical.
- Bullet points over paragraphs.
- Token-optimized every response.
- Direct fixes only. No alternatives unless asked.

---

## 📖 Required Reading Before Any Code

Read these files BEFORE generating any code in this project:

1. `.agent/user_rules.md` — NON-NEGOTIABLE Flutter/Dart rules
2. `docs/ai-agent-master-directives.md` — Full architecture directives
3. `.agent/skills/morourak-api-integration/SKILL.md` — API integration skill (SOURCE OF TRUTH for all API work)
4. `.cursorrules` — Project-wide engineering rules

---

## ⚡ Active Skills (Auto-Loaded)

### Project Skills (Local)
| Skill | Path | Scope |
|---|---|---|
| `morourak-api-integration` | `.agent/skills/morourak-api-integration/SKILL.md` | All API integration work |

### Global Skills (Available)
The following are globally installed and available to invoke:

**Flutter/Dart:**
- `flutter-expert` — Master Flutter dev patterns
- `flutter-app-architecture` — Feature-first clean architecture
- `flutter-errors` — Error handling patterns
- `effective-dart` — Official Dart style
- `dart-3-updates` — Dart 3 sealed classes, records, patterns
- `bloc` — BLoC/Cubit state management
- `testing` / `mockito` / `mocktail` — Test patterns

**Code Quality:**
- `code-reviewer` — Pre-PR review
- `debugger` — Systematic debugging
- `systematic-debugging` — Before fixing any bug
- `simplify-code` — Post-generation cleanup

**Caveman:**
- `caveman` — Terse communication mode (ACTIVE)
- `caveman-commit` — Commit message format
- `caveman-review` — Code review format

---

## 🏗️ Architecture (MANDATORY)

```
lib/features/<feature>/
├── presentation/   → Widgets + Cubits ONLY (no business logic)
├── domain/         → Entities + UseCases (pure Dart, ZERO Flutter imports)
└── data/           → DTOs + Repositories + Datasources
```

**State management:** Cubit/Bloc ONLY. No Riverpod, Provider, GetX.
**DI:** `get_it` only — registered in `core/di/`.
**Error handling:** `ApiResult<T>` / `Either<Failure, Success>` everywhere.

---

## 🚫 NON-NEGOTIABLE RULES

1. **No `dynamic`** — explicit types always
2. **No business logic in Widgets**
3. **No Flutter APIs in Domain layer**
4. **Files ≤ 300 lines** — split if larger
5. **Functions ≤ 40 lines** — prefer ≤ 20
6. **No `print()`** — use `debugPrint()` or logger
7. **Cubits MUST NOT use BuildContext**
8. **`if (isClosed) return;`** after every async await in Cubit
9. **`Either<Failure, Success>`** for all error handling
10. **No Freezed / build_runner** — use Dart 3 `sealed class` + `switch`

---

## 🔌 API — Morourak

```
Base URL: http://morourak.runasp.net/api/v1
Auth: Bearer token → SharedPreferences key: 'token'
```

**Always use:** `ApiClient` (shared Dio instance) — NEVER create new Dio instances.
**Full API reference:** `.agent/skills/morourak-api-integration/SKILL.md`

---

## ✅ Self-Check Before Every Output

- [ ] Files ≤ 300 lines
- [ ] Functions ≤ 40 lines
- [ ] No `dynamic`
- [ ] No Flutter in Domain
- [ ] `if (isClosed) return;` after awaits in Cubit
- [ ] Uses `ApiResult<T>` for error handling
- [ ] Imports correct — no circular deps

---

## 📝 Commit Format

```
feat(<feature>): description — ai-agent
fix(<feature>): description — ai-agent
```

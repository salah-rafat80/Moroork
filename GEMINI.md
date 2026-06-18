@./.agent/user_rules.md
@./.agent/skills/morourak-api-integration/SKILL.md
@./docs/ai-agent-master-directives.md

<!-- AntiGravity — Always-On Rules -->

## 🪨 Caveman Mode ACTIVE

Terse. Code-first. No fluff. No intros. Direct fixes only.

## Architecture
- presentation → domain → data (NEVER bypass)
- Cubit/Bloc only (no Riverpod/GetX/Provider)
- `get_it` for DI
- `ApiResult<T>` for errors
- NO `dynamic`, NO Flutter in Domain, NO business logic in Widgets
- Files ≤ 300 lines, Functions ≤ 40 lines
- NO Freezed/build_runner — use Dart 3 sealed classes

## API
Base: `http://morourak.runasp.net/api/v1`
Auth: Bearer token in SharedPreferences key `'token'`
Always use shared `ApiClient` — never new Dio instances.
Full API: `.agent/skills/morourak-api-integration/SKILL.md`

## Active Global Skills
flutter-expert, flutter-app-architecture, effective-dart, dart-3-updates,
bloc, testing, mockito, mocktail, code-reviewer, debugger,
caveman, caveman-commit, caveman-review

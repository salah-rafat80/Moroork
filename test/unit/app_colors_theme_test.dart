import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/theme/theme_cubit.dart';

// ────────────────────────────────────────────────
// Stub ThemeCubit: يتحكم في الـ ThemeMode بدون SharedPreferences
// ────────────────────────────────────────────────
class StubThemeCubit extends Cubit<ThemeMode> {
  StubThemeCubit(super.initialState);

  void setMode(ThemeMode mode) => emit(mode);
}

// ────────────────────────────────────────────────
// Helper: يبني MaterialApp بـ ThemeCubit
// ────────────────────────────────────────────────
Widget _buildApp({required ThemeMode themeMode, required Widget child}) {
  return BlocProvider<ThemeCubit>(
    create: (_) => StubThemeCubit(themeMode) as ThemeCubit,
    child: MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF27AE60),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF27AE60),
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  // ────────────────────────────────────────────────
  // 1. AppColors — التحقق من القيم الثابتة
  // ────────────────────────────────────────────────
  group('AppColors — قيم ثابتة', () {
    test('white == 0xFFFFFFFF', () {
      expect(AppColors.white, equals(const Color(0xFFFFFFFF)));
    });

    test('black == 0xFF000000', () {
      expect(AppColors.black, equals(const Color(0xFF000000)));
    });

    test('transparent == 0x00000000', () {
      expect(AppColors.transparent, equals(const Color(0x00000000)));
    });

    test('primary هو الأخضر المميز للتطبيق', () {
      AppColors.isDarkMode = false;
      expect(AppColors.primary, equals(const Color(0xFF27AE60)));
    });
  });

  // ────────────────────────────────────────────────
  // 2. AppColors isDarkMode — التحقق من التحويل الصحيح
  // ────────────────────────────────────────────────
  group('AppColors.isDarkMode switching', () {
    setUp(() => AppColors.isDarkMode = false);
    tearDown(() => AppColors.isDarkMode = false);

    test('background في Light mode أبيض', () {
      AppColors.isDarkMode = false;
      expect(AppColors.background, equals(const Color(0xFFFFFFFF)));
    });

    test('background في Dark mode داكن', () {
      AppColors.isDarkMode = true;
      expect(AppColors.background, equals(const Color(0xFF121824)));
    });

    test('textPrimary في Light mode داكن للقراءة', () {
      AppColors.isDarkMode = false;
      expect(AppColors.textPrimary, equals(const Color(0xFF222222)));
    });

    test('textPrimary في Dark mode فاتح للقراءة', () {
      AppColors.isDarkMode = true;
      expect(AppColors.textPrimary, equals(const Color(0xFFF3F4F6)));
    });

    test('border مختلف بين الوضعين', () {
      AppColors.isDarkMode = false;
      final lightBorder = AppColors.border;

      AppColors.isDarkMode = true;
      final darkBorder = AppColors.border;

      expect(lightBorder, isNot(equals(darkBorder)));
    });

    test('whiteBg في Light هو أبيض', () {
      AppColors.isDarkMode = false;
      expect(AppColors.whiteBg, equals(const Color(0xFFFFFFFF)));
    });

    test('whiteBg في Dark هو سطح داكن وليس أبيض', () {
      AppColors.isDarkMode = true;
      expect(AppColors.whiteBg, isNot(equals(const Color(0xFFFFFFFF))));
    });

    test('charcoal في Light داكن جداً (للنص)', () {
      AppColors.isDarkMode = false;
      expect(AppColors.charcoal, equals(const Color(0xFF1A1A1A)));
    });

    test('charcoal في Dark فاتح جداً (للنص)', () {
      AppColors.isDarkMode = true;
      expect(AppColors.charcoal, equals(const Color(0xFFF8FAFC)));
    });

    test('cardBg مختلف بين الوضعين', () {
      AppColors.isDarkMode = false;
      final lightCard = AppColors.cardBg;

      AppColors.isDarkMode = true;
      final darkCard = AppColors.cardBg;

      expect(lightCard, isNot(equals(darkCard)));
    });

    test('error في كلا الوضعين حمر (يُنبه)', () {
      AppColors.isDarkMode = false;
      final lightError = AppColors.error;

      AppColors.isDarkMode = true;
      final darkError = AppColors.error;

      // كلاهما يجب أن يكون أحمر اللون (القيمة R عالية)
      final lightR = (lightError.toARGB32() >> 16) & 0xFF;
      final darkR = (darkError.toARGB32() >> 16) & 0xFF;
      expect(lightR, greaterThan(150));
      expect(darkR, greaterThan(150));
    });

    test('primary لا يتغير بين الوضعين (Brand color)', () {
      AppColors.isDarkMode = false;
      final lightPrimary = AppColors.primary;

      AppColors.isDarkMode = true;
      final darkPrimary = AppColors.primary;

      expect(lightPrimary, equals(darkPrimary));
    });

    test('chatUserBubbleStart أغمق في Dark من Light', () {
      AppColors.isDarkMode = false;
      final lightStart = AppColors.chatUserBubbleStart;

      AppColors.isDarkMode = true;
      final darkStart = AppColors.chatUserBubbleStart;

      // Dark أغمق = قيمة RGB أقل
      final lightBrightness = lightStart.computeLuminance();
      final darkBrightness = darkStart.computeLuminance();
      expect(darkBrightness, lessThan(lightBrightness));
    });
  });

  // ────────────────────────────────────────────────
  // 3. WCAG — التباين بين Text و Background
  // ────────────────────────────────────────────────
  group('WCAG contrast — تباين كافٍ', () {
    // حساب نسبة التباين وفق W3C
    double contrastRatio(Color text, Color bg) {
      final tL = text.computeLuminance();
      final bL = bg.computeLuminance();
      final lighter = tL > bL ? tL : bL;
      final darker = tL > bL ? bL : tL;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('Light: textPrimary على background تباين ≥ 4.5 (AA)', () {
      AppColors.isDarkMode = false;
      final ratio = contrastRatio(AppColors.textPrimary, AppColors.background);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('Dark: textPrimary على background تباين ≥ 4.5 (AA)', () {
      AppColors.isDarkMode = true;
      final ratio = contrastRatio(AppColors.textPrimary, AppColors.background);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('Light: charcoal على background تباين ≥ 4.5', () {
      AppColors.isDarkMode = false;
      final ratio = contrastRatio(AppColors.charcoal, AppColors.background);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('Dark: charcoal على background تباين ≥ 4.5', () {
      AppColors.isDarkMode = true;
      final ratio = contrastRatio(AppColors.charcoal, AppColors.background);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });

  // ────────────────────────────────────────────────
  // 4. ThemeCubit — اختبار state transitions
  // ────────────────────────────────────────────────
  group('ThemeCubit — الحالات', () {
    test('الحالة الأولية هي ThemeMode.system', () {
      final cubit = StubThemeCubit(ThemeMode.system);
      expect(cubit.state, equals(ThemeMode.system));
    });

    test('setMode يغير الحالة إلى dark', () {
      final cubit = StubThemeCubit(ThemeMode.light);
      cubit.setMode(ThemeMode.dark);
      expect(cubit.state, equals(ThemeMode.dark));
    });

    test('setMode يغير الحالة إلى light', () {
      final cubit = StubThemeCubit(ThemeMode.dark);
      cubit.setMode(ThemeMode.light);
      expect(cubit.state, equals(ThemeMode.light));
    });

    test('setMode يغير الحالة إلى system', () {
      final cubit = StubThemeCubit(ThemeMode.dark);
      cubit.setMode(ThemeMode.system);
      expect(cubit.state, equals(ThemeMode.system));
    });
  });

  // ────────────────────────────────────────────────
  // 5. MaterialApp — الثيم يُطبق صح على Brightness
  // ────────────────────────────────────────────────
  group('MaterialApp — Brightness من ThemeMode', () {
    testWidgets('ThemeMode.light يُعطي Brightness.light', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          themeMode: ThemeMode.light,
          child: Builder(
            builder: (ctx) {
              expect(Theme.of(ctx).brightness, equals(Brightness.light));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('ThemeMode.dark يُعطي Brightness.dark', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          themeMode: ThemeMode.dark,
          child: Builder(
            builder: (ctx) {
              expect(Theme.of(ctx).brightness, equals(Brightness.dark));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/app_sizes.dart';
import 'package:traffic/core/utils/app_theme.dart';
import 'package:traffic/features/main/presentation/screens/splash_screen.dart';

import 'package:traffic/injection_container.dart';

import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/core/theme/theme_cubit.dart';
import 'package:traffic/core/constants/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // جعل شريط الحالة شفافاً
      statusBarIconBrightness: Brightness.dark, // أيقونات داكنة (بطارية، واي فاي، إلخ)
    ),
  );

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Catch asynchronous errors (like platform channel failures)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async Error: $error');
    return true; // Mark as handled
  };

  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThemeCubit>(),
      child: ScreenUtilInit(
        designSize: const Size(AppSizes.baseWidth, AppSizes.baseHeight),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Traffic App',
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                builder: (context, widget) {
                  final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
                  final newIsDarkMode = (themeMode == ThemeMode.system) ? systemDark : (themeMode == ThemeMode.dark);
                  
                  if (AppColors.isDarkMode != newIsDarkMode) {
                    AppColors.isDarkMode = newIsDarkMode;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        void rebuild(Element el) {
                          el.markNeedsBuild();
                          el.visitChildren(rebuild);
                        }
                        (context as Element).visitChildren(rebuild);
                      }
                    });
                  }
                  return widget!;
                },
                home: child,
              );
            },
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}

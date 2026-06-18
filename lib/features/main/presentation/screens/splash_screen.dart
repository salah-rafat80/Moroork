import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/auth/presentation/screens/onboarding_screen/onboarding_screen.dart';
import 'package:traffic/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:traffic/features/examiner_dashboard/presentation/screens/daily_tests_screen.dart';
import 'package:traffic/injection_container.dart';

import 'package:traffic/features/profile/data/repositories/profile_repository.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Wait for 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Check authentication status
      final authRepository = getIt<AuthRepository>();
      final isAuthenticated = await authRepository.hasToken();

      if (!mounted) return;

      if (isAuthenticated) {
        // Verify token validity by calling getProfile
        final profileRepository = getIt<ProfileRepository>();
        final profileResult = await profileRepository.getProfile();

        if (profileResult.isSuccess) {
          final roles = await authRepository.getRoles();
          final isStaff = roles.any(
            (r) => ['INSPECTOR', 'DOCTOR', 'EXAMINATOR'].contains(r),
          );

          if (!mounted) return;
          if (isStaff) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DailyTestsScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
            );
          }
        } else {
          // Token validation failed. Let's see if it's an authorization issue
          final errorMessage = profileResult.error ?? '';
          final isUnauthorized =
              errorMessage.contains('غير مصرح') ||
              errorMessage.contains('401') ||
              errorMessage.contains('تسجيل الدخول');

          if (isUnauthorized) {
            debugPrint(
              '⚠️ Token is expired or unauthorized: $errorMessage. Logging out.',
            );
            await authRepository.logout(); // Clear token and cache

            if (!mounted) return;
            // Redirect straight to LoginScreen because the user already finished Onboarding before
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            // It's a network issue or temporary server failure (not 401).
            // Let the user in anyway because they already have a token saved.
            debugPrint(
              '🌐 Network issue or server error: $errorMessage. Allowing entry.',
            );
            final roles = await authRepository.getRoles();
            final isStaff = roles.any(
              (r) => ['INSPECTOR', 'DOCTOR', 'EXAMINATOR'].contains(r),
            );

            if (!mounted) return;
            if (isStaff) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DailyTestsScreen(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            }
          }
        }
      } else {
        // Navigate to onboarding screen (first-time user)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e, stack) {
      debugPrint('🚨 CRITICAL ERROR during SplashScreen init: $e');
      debugPrint('Stack trace: $stack');

      if (!mounted) return;
      // If error occurs, fallback to onboarding to avoid stuck splash
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive logo size
    final logoSize = 250.r;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          'assets/لوجو_2-removebg-preview (2).png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

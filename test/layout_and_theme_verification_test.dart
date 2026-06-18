import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/theme/theme_cubit.dart';
import 'package:traffic/features/home/presentation/screens/home_screen.dart';
import 'package:traffic/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:traffic/features/driving_license/presentation/screens/driving_license_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/vehicle_license_screen.dart';
import 'package:traffic/features/smart_assistant/presentation/screens/smart_assistant_screen.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';

import 'package:traffic/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_state.dart';
import 'package:traffic/features/orders/presentation/cubits/my_orders_cubit.dart';
import 'package:traffic/features/orders/presentation/cubits/my_orders_state.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_cubit.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_state.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_renewal_cubit.dart';
import 'package:traffic/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:traffic/features/profile/presentation/cubits/profile_state.dart';

import 'package:traffic/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_license_repository.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_renewal_repository.dart';
import 'package:traffic/features/vehicle_license/data/repositories/vehicle_license_repository.dart';
import 'package:traffic/features/orders/data/repositories/service_requests_repository.dart';
import 'package:traffic/features/profile/data/repositories/profile_repository.dart';

// Fake implementations to prevent dependency issues during tests
class FakeAuthCubit extends AuthCubit {
  FakeAuthCubit()
      : super(
          authRepository: FakeAuthRepository(),
          drivingLicenseRepository: FakeDrivingLicenseRepository(),
        );

  @override
  Stream<AuthState> get stream => const Stream.empty();
}

class FakeMyOrdersCubit extends MyOrdersCubit {
  FakeMyOrdersCubit() : super(FakeServiceRequestsRepository());

  @override
  Future<void> fetchMyOrders() async {}

  @override
  Stream<MyOrdersState> get stream => const Stream.empty();
}

class FakeVehicleLicenseCubit extends VehicleLicenseCubit {
  FakeVehicleLicenseCubit()
      : super(FakeVehicleLicenseRepository(), FakeProfileRepository());

  @override
  Future<void> fetchInitData() async {}

  @override
  Stream<VehicleLicenseState> get stream => const Stream.empty();
}

class FakeDrivingRenewalCubit extends DrivingRenewalCubit {
  FakeDrivingRenewalCubit()
      : super(
          dataHandler: FakeDrivingLicenseRenewalDataHandler(),
          profileRepository: FakeProfileRepository(),
        );

  @override
  Stream<DrivingRenewalState> get stream => const Stream.empty();
}

class FakeProfileCubit extends ProfileCubit {
  FakeProfileCubit() : super(FakeProfileRepository());

  @override
  Future<void> loadProfile() async {}

  @override
  Stream<ProfileState> get stream => const Stream.empty();
}

class FakeDrivingLicenseRenewalDataHandler implements DrivingLicenseRenewalDataHandler {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeDrivingLicenseRepository implements DrivingLicenseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeVehicleLicenseRepository implements VehicleLicenseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeServiceRequestsRepository implements ServiceRequestsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class StubThemeCubit extends Cubit<ThemeMode> implements ThemeCubit {
  StubThemeCubit(super.initialState);

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
  }
}

void main() {
  setUp(() {
    getIt.registerFactory<AuthCubit>(() => FakeAuthCubit());
    getIt.registerFactory<MyOrdersCubit>(() => FakeMyOrdersCubit());
    getIt.registerFactory<VehicleLicenseCubit>(() => FakeVehicleLicenseCubit());
    getIt.registerFactory<DrivingRenewalCubit>(() => FakeDrivingRenewalCubit());
    getIt.registerFactory<ProfileCubit>(() => FakeProfileCubit());
    getIt.registerLazySingleton<DrivingLicenseRenewalDataHandler>(
      () => FakeDrivingLicenseRenewalDataHandler(),
    );
    getIt.registerLazySingleton<ThemeCubit>(() => StubThemeCubit(ThemeMode.light));
  });

  tearDown(() {
    getIt.reset();
  });

  // Helper widget wrapper for the tests
  Widget createTestWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return BlocProvider<ThemeCubit>.value(
          value: getIt<ThemeCubit>(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: mode,
                builder: (context, widget) {
                  final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
                  final newIsDarkMode = (mode == ThemeMode.system) ? systemDark : (mode == ThemeMode.dark);
                  
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
          ),
        );
      },
    );
  }

  group('Layout & Theme Verification — Small Screens (320x568)', () {
    testWidgets('HomeScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      // Ensure no layout exceptions/overflows were thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('DrivingLicenseScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const DrivingLicenseScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('VehicleLicenseScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const VehicleLicenseScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('SmartAssistantScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const SmartAssistantScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      final exception = tester.takeException();
      if (exception != null) {
        print('EXCEPTION: $exception');
      }
      expect(exception, isNull);
    });

    testWidgets('MainNavigationScreen should render without layout overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const MainNavigationScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('Color & Theme Compliance — Anti-mixing verification', () {
    testWidgets('HomeScreen dynamically reacts to theme changes and updates AppColors fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      // Switch theme to Dark Mode
      getIt<ThemeCubit>().setThemeMode(ThemeMode.dark);
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      // Ensure that AppColors is configured correctly for Dark Mode
      expect(AppColors.isDarkMode, isTrue);
      final darkBackground = AppColors.background;

      // Switch theme to Light Mode
      getIt<ThemeCubit>().setThemeMode(ThemeMode.light);
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      expect(AppColors.isDarkMode, isFalse);
      final lightBackground = AppColors.background;

      // Verify they do not mix and are distinct
      expect(darkBackground, isNot(equals(lightBackground)));
    });

    testWidgets('Verify that dynamic theme colors do not mix inside widgets', (WidgetTester tester) async {
      // Light Mode Check
      getIt<ThemeCubit>().setThemeMode(ThemeMode.light);
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      // Fetch Scaffold properties or custom sections
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppColors.background));

      // Dark Mode Check
      getIt<ThemeCubit>().setThemeMode(ThemeMode.dark);
      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();

      final darkScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(darkScaffold.backgroundColor, equals(AppColors.background));
    });
  });
}

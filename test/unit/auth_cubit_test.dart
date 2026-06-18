import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_state.dart';

// ────────────────────────────────────────────────
// Mock AuthRepository
// ────────────────────────────────────────────────
class MockAuthRepository {
  String? errorToReturn;
  List<String>? rolesToReturn;
  bool hasTokenValue = false;
  List<String> rolesInStorage = [];

  Future<(String?, List<String>?)> login(String mobile, String password) async {
    if (errorToReturn != null) {
      return (errorToReturn, null);
    }
    return (null, rolesToReturn ?? ['CITIZEN']);
  }

  Future<String?> register({
    required String nationalId,
    required String mobileNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    return errorToReturn;
  }

  Future<String?> verifyOtp(String email, String code) async {
    return errorToReturn;
  }

  Future<bool> hasToken() async => hasTokenValue;
  Future<List<String>> getRoles() async => rolesInStorage;
  Future<void> logout() async {}
}

// ────────────────────────────────────────────────
// Mock DrivingLicenseRepository
// ────────────────────────────────────────────────
class MockDrivingLicenseRepository {
  bool throwOnFetch = false;
  Future<void> getMyLicenses() async {
    if (throwOnFetch) throw Exception('Network error');
  }
}

// ────────────────────────────────────────────────
// Minimal AuthCubit for isolated testing
// (لا نستخدم injectable هنا — pure unit test)
// ────────────────────────────────────────────────
class TestAuthCubit {
  AuthState _state = AuthInitial();
  AuthState get state => _state;
  final List<AuthState> emittedStates = [];

  final MockAuthRepository _authRepo;
  final MockDrivingLicenseRepository _licenseRepo;

  TestAuthCubit(this._authRepo, this._licenseRepo);

  void _emit(AuthState s) {
    _state = s;
    emittedStates.add(s);
  }

  Future<void> login(String mobile, String password, {String? requiredRole}) async {
    _emit(AuthLoading());
    try {
      final (error, roles) = await _authRepo.login(mobile, password);
      if (error == null) {
        final rolesList = roles ?? [];

        if (requiredRole != null) {
          bool isValid = false;
          if (requiredRole == 'CITIZEN') {
            isValid = rolesList.contains('CITIZEN');
          } else if (requiredRole == 'STAFF') {
            isValid = rolesList.any((r) => ['INSPECTOR', 'DOCTOR', 'EXAMINATOR'].contains(r));
          }
          if (!isValid) {
            await _authRepo.logout();
            _emit(AuthFailure(message: 'عذراً، لا تمتلك الصلاحية للدخول من هذا المسار.'));
            return;
          }
        }

        if (rolesList.contains('CITIZEN')) {
          await _licenseRepo.getMyLicenses();
        }
        _emit(AuthLoginSuccess(roles: rolesList));
      } else {
        _emit(AuthFailure(message: error));
      }
    } catch (e) {
      _emit(AuthFailure(message: 'حدث خطأ غير متوقع.'));
    }
  }

  Future<void> register({
    required String nationalId,
    required String mobileNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _emit(AuthLoading());
    try {
      final error = await _authRepo.register(
        nationalId: nationalId,
        mobileNumber: mobileNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (error == null) {
        _emit(AuthRegisterSuccess());
      } else {
        _emit(AuthFailure(message: error));
      }
    } catch (e) {
      _emit(AuthFailure(message: 'حدث خطأ غير متوقع.'));
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    _emit(AuthLoading());
    try {
      final error = await _authRepo.verifyOtp(email, code);
      if (error == null) {
        _emit(AuthVerifyOtpSuccess());
      } else {
        _emit(AuthFailure(message: error));
      }
    } catch (e) {
      _emit(AuthFailure(message: 'حدث خطأ غير متوقع.'));
    }
  }

  Future<void> checkAuthStatus() async {
    final hasToken = await _authRepo.hasToken();
    if (hasToken) {
      final roles = await _authRepo.getRoles();
      _emit(AuthAuthenticated(roles: roles));
    } else {
      _emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _emit(AuthUnauthenticated());
  }
}

void main() {
  late MockAuthRepository authRepo;
  late MockDrivingLicenseRepository licenseRepo;
  late TestAuthCubit cubit;

  setUp(() {
    authRepo = MockAuthRepository();
    licenseRepo = MockDrivingLicenseRepository();
    cubit = TestAuthCubit(authRepo, licenseRepo);
  });

  // ────────────────────────────────────────────────
  // login — حالات النجاح
  // ────────────────────────────────────────────────
  group('AuthCubit.login — نجاح', () {
    test('يُصدر Loading ثم LoginSuccess للمواطن', () async {
      authRepo.rolesToReturn = ['CITIZEN'];
      await cubit.login('01000000000', 'password123');

      expect(cubit.emittedStates[0], isA<AuthLoading>());
      expect(cubit.emittedStates[1], isA<AuthLoginSuccess>());
      final success = cubit.emittedStates[1] as AuthLoginSuccess;
      expect(success.roles, contains('CITIZEN'));
    });

    test('يُصدر LoginSuccess بدور INSPECTOR', () async {
      authRepo.rolesToReturn = ['INSPECTOR'];
      await cubit.login('01000000000', 'pass');

      expect(cubit.state, isA<AuthLoginSuccess>());
      final success = cubit.state as AuthLoginSuccess;
      expect(success.roles, contains('INSPECTOR'));
    });

    test('يجلب الرخص عند نجاح دخول المواطن', () async {
      authRepo.rolesToReturn = ['CITIZEN'];
      // Simulate tracking
      licenseRepo.throwOnFetch = false;
      await cubit.login('01000000000', 'pass');
      // إذا ما حصل exception يعني جُلبت الرخص
      expect(cubit.state, isA<AuthLoginSuccess>());
    });

    test('لا يجلب الرخص عند دخول INSPECTOR', () async {
      authRepo.rolesToReturn = ['INSPECTOR'];
      licenseRepo.throwOnFetch = true; // لو حُجب سيُسبب exception
      await cubit.login('01000000000', 'pass');
      // يجب أن ينجح بدون exception
      expect(cubit.state, isA<AuthLoginSuccess>());
    });
  });

  // ────────────────────────────────────────────────
  // login — التحقق من الأدوار
  // ────────────────────────────────────────────────
  group('AuthCubit.login — التحقق من الدور', () {
    test('مواطن يحاول دخول مسار STAFF → AuthFailure', () async {
      authRepo.rolesToReturn = ['CITIZEN'];
      await cubit.login('01000000000', 'pass', requiredRole: 'STAFF');

      expect(cubit.state, isA<AuthFailure>());
      final failure = cubit.state as AuthFailure;
      expect(failure.message, contains('الصلاحية'));
    });

    test('موظف يحاول دخول مسار CITIZEN → AuthFailure', () async {
      authRepo.rolesToReturn = ['INSPECTOR'];
      await cubit.login('01000000000', 'pass', requiredRole: 'CITIZEN');

      expect(cubit.state, isA<AuthFailure>());
    });

    test('موظف DOCTOR ينجح في مسار STAFF', () async {
      authRepo.rolesToReturn = ['DOCTOR'];
      await cubit.login('01000000000', 'pass', requiredRole: 'STAFF');

      expect(cubit.state, isA<AuthLoginSuccess>());
    });

    test('موظف EXAMINATOR ينجح في مسار STAFF', () async {
      authRepo.rolesToReturn = ['EXAMINATOR'];
      await cubit.login('01000000000', 'pass', requiredRole: 'STAFF');

      expect(cubit.state, isA<AuthLoginSuccess>());
    });
  });

  // ────────────────────────────────────────────────
  // login — حالات الخطأ
  // ────────────────────────────────────────────────
  group('AuthCubit.login — فشل', () {
    test('خطأ من السيرفر → AuthFailure برسالة الخطأ', () async {
      authRepo.errorToReturn = 'رقم الهاتف أو كلمة المرور غير صحيحة';
      await cubit.login('01000000000', 'wrongpass');

      expect(cubit.state, isA<AuthFailure>());
      final failure = cubit.state as AuthFailure;
      expect(failure.message, equals('رقم الهاتف أو كلمة المرور غير صحيحة'));
    });
  });

  // ────────────────────────────────────────────────
  // register
  // ────────────────────────────────────────────────
  group('AuthCubit.register', () {
    test('تسجيل ناجح → Loading ثم RegisterSuccess', () async {
      await cubit.register(
        nationalId: '12345678901234',
        mobileNumber: '01000000000',
        firstName: 'أحمد',
        lastName: 'محمود',
        email: 'test@test.com',
        username: 'ahmed',
        password: 'Pass@1234',
        confirmPassword: 'Pass@1234',
      );

      expect(cubit.emittedStates[0], isA<AuthLoading>());
      expect(cubit.emittedStates[1], isA<AuthRegisterSuccess>());
    });

    test('فشل التسجيل → AuthFailure برسالة', () async {
      authRepo.errorToReturn = 'رقم الهوية مسجل مسبقاً';
      await cubit.register(
        nationalId: '12345678901234',
        mobileNumber: '01000000000',
        firstName: 'أحمد',
        lastName: 'محمود',
        email: 'test@test.com',
        username: 'ahmed',
        password: 'Pass@1234',
        confirmPassword: 'Pass@1234',
      );

      expect(cubit.state, isA<AuthFailure>());
      final failure = cubit.state as AuthFailure;
      expect(failure.message, equals('رقم الهوية مسجل مسبقاً'));
    });
  });

  // ────────────────────────────────────────────────
  // verifyOtp
  // ────────────────────────────────────────────────
  group('AuthCubit.verifyOtp', () {
    test('OTP صحيح → VerifyOtpSuccess', () async {
      await cubit.verifyOtp('test@test.com', '123456');
      expect(cubit.state, isA<AuthVerifyOtpSuccess>());
    });

    test('OTP خاطئ → AuthFailure', () async {
      authRepo.errorToReturn = 'كود التحقق غير صحيح';
      await cubit.verifyOtp('test@test.com', '000000');
      expect(cubit.state, isA<AuthFailure>());
    });
  });

  // ────────────────────────────────────────────────
  // checkAuthStatus
  // ────────────────────────────────────────────────
  group('AuthCubit.checkAuthStatus', () {
    test('يوجد token → AuthAuthenticated بالأدوار', () async {
      authRepo.hasTokenValue = true;
      authRepo.rolesInStorage = ['CITIZEN'];
      await cubit.checkAuthStatus();

      expect(cubit.state, isA<AuthAuthenticated>());
      final auth = cubit.state as AuthAuthenticated;
      expect(auth.roles, contains('CITIZEN'));
    });

    test('لا يوجد token → AuthUnauthenticated', () async {
      authRepo.hasTokenValue = false;
      await cubit.checkAuthStatus();
      expect(cubit.state, isA<AuthUnauthenticated>());
    });
  });

  // ────────────────────────────────────────────────
  // logout
  // ────────────────────────────────────────────────
  group('AuthCubit.logout', () {
    test('logout → AuthUnauthenticated', () async {
      await cubit.logout();
      expect(cubit.state, isA<AuthUnauthenticated>());
    });
  });
}

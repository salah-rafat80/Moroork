import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:traffic/core/widgets/custom_appbar.dart';
import 'package:traffic/features/auth/presentation/screens/signup_screen/signup_screen.dart';
import 'package:traffic/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_state.dart';
import 'package:traffic/features/examiner_dashboard/presentation/screens/daily_tests_screen.dart';

/// Pixel-perfect Login Screen with real-time validation.
/// All sizes are responsive using flutter_screenutil.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Controllers ---
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- Focus Nodes ---
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // --- Validation State ---
  String? _phoneError;
  String? _passwordError;
  bool _obscurePassword = true;
  String? _loadingRole; // 'CITIZEN' or 'STAFF'

  // --- Colors ---
  static final Color _green = AppColors.primary;
  static final Color _errorRed = AppColors.error;
  static final Color _textPrimary = AppColors.textPrimary;
  static final Color _textSecondary = AppColors.textSecondary;
  static final Color _borderGrey = AppColors.border;
  static final Color _white = AppColors.background;
  static final Color _hintColor = AppColors.greyIcon;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _passwordController.addListener(_validatePassword);
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  Color _getBorderColor(bool hasError, FocusNode focusNode) {
    if (hasError) return _errorRed;
    if (focusNode.hasFocus) return _green;
    return _borderGrey;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    setState(() {
      if (phone.isEmpty) {
        _phoneError = null; // No error when empty
      } else if (phone.length < 10) {
        _phoneError = 'الرجاء إدخال رقم هاتف صحيح.';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
        _phoneError = 'الرجاء إدخال رقم هاتف صحيح.';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = null; // No error when empty
      } else if (password.length < 6) {
        _passwordError = 'كلمة السر غير صحيحة.';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _phoneController.text.trim().length >= 10 &&
        _passwordController.text.length >= 6 &&
        _phoneError == null &&
        _passwordError == null;
  }

  void _onLogin(BuildContext context, {String? requiredRole}) {
    // Validate before login
    _validatePhone();
    _validatePassword();

    if (_isFormValid) {
      setState(() => _loadingRole = requiredRole);
      context.read<AuthCubit>().login(
        _phoneController.text.trim(),
        _passwordController.text,
        requiredRole: requiredRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _white,
          body: Builder(
            builder: (context) => BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthLoginSuccess) {
                  // Check roles to determine navigation
                  final isOfficer = state.roles.any(
                    (r) =>
                        r == 'INSPECTOR' || r == 'DOCTOR' || r == 'EXAMINATOR',
                  );

                  if (isOfficer) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyTestsScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, textAlign: TextAlign.right),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomAppbar(
                          onBackPressed: () {},
                          title: 'تسجيل الدخول',
                        ),
                        SizedBox(height: 32.h),
                        _buildPhoneField(),
                        SizedBox(height: 24.h),
                        _buildPasswordField(),
                        SizedBox(height: 32.h),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return _buildLoginButtons(context, isLoading);
                          },
                        ),
                        SizedBox(height: 24.h),

                        // _buildSocialButtons(),
                        // SizedBox(height: 48.h),
                        _buildFooter(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Phone Field ---
  Widget _buildPhoneField() {
    final hasError = _phoneError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 52.h,
          child: Row(
            children: [
              // Country code box
              Container(
                width: 60.w,
                height: 52.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(hasError, _phoneFocus),
                    width: (hasError || _phoneFocus.hasFocus) ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+20',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Phone input
              Expanded(
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getBorderColor(hasError, _phoneFocus),
                      width: (hasError || _phoneFocus.hasFocus) ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: _textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '000 000 0000',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        color: _hintColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            _phoneError!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: _errorRed,
            ),
          ),
        ],
      ],
    );
  }

  // --- Password Field ---
  Widget _buildPasswordField() {
    final hasError = _passwordError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة السر',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getBorderColor(hasError, _passwordFocus),
              width: (hasError || _passwordFocus.hasFocus) ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'ادخل كلمة السر',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                color: _hintColor,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textSecondary,
                  size: 22.r,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Error message (if any)
            if (hasError)
              Expanded(
                child: Text(
                  _passwordError!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _errorRed,
                  ),
                ),
              )
            else
              const Spacer(),
            // Forgot password link
            GestureDetector(
              onTap: () {
                // TODO: Navigate to forgot password
              },
              child: Text(
                'نسيت كلمة السر ؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: _green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Login Buttons ---
  Widget _buildLoginButtons(BuildContext context, bool isLoading) {
    return Column(
      children: [
        PrimaryButton(
          label: 'تسجيل الدخول',
          height: 60.h,
          onPressed: () => _onLogin(context, requiredRole: 'CITIZEN'),
          isLoading: isLoading && _loadingRole == 'CITIZEN',
        ),
      ],
    ); /*
      children: [
        SizedBox(
          height: 60.h,
          width: double.infinity,
          //inkwell button
          child: InkWell(
            onTap: isLoading
                ? null
                : () => _onLogin(context, requiredRole: 'CITIZEN'),
            child: Container(
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: (isLoading && _loadingRole == 'CITIZEN')
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CustomLoadingIndicator(
                          color: _white,
                          strokeWidth: 2,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: _white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        // SizedBox(height: 16.h),
      ],
    );
  */
  }

  // // --- Social Buttons ---
  // Widget _buildSocialButtons() {
  //   return Row(
  //     children: [
  //       // Apple button
  //       Expanded(
  //         child: Container(
  //           height: 52.h,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: _borderGrey),
  //             borderRadius: BorderRadius.circular(12.r),
  //           ),
  //           child: Center(
  //             child: Icon(Icons.apple, size: 28.r, color: _textPrimary),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 16.w),
  //       // Google button
  //       Expanded(
  //         child: Container(
  //           height: 52.h,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: _borderGrey),
  //             borderRadius: BorderRadius.circular(12.r),
  //           ),
  //           child: Center(
  //             child: Text(
  //               'G',
  //               style: TextStyle(fontFamily: 'Cairo',
  //                 fontSize: 24.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: AppColors.googleBlue,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // --- Footer ---
  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.w,
      children: [
        Text(
          'ليس لديك حساب ؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          child: Text(
            'إنشاء حساب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _green,
              decoration: TextDecoration.underline,
              decorationColor: _green,
            ),
          ),
        ),
      ],
    );
  }
}

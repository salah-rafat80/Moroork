import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:traffic/core/widgets/custom_appbar.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/otp_controller.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/otp_styles.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/widgets/otp_header.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/widgets/otp_inputs_row.dart';
import 'package:traffic/features/auth/presentation/screens/otp_screen/widgets/otp_timer_resend.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:traffic/features/auth/presentation/cubits/auth_state.dart';
import 'package:traffic/injection_container.dart';

/// OTP verification screen with three states: initial, error, and success.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  /// Email passed from Signup Step 1 (will be masked for display)
  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late OtpController _controller;
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _controller = OtpController(
      email: widget.email,
      onComplete: (otp) {
        _authCubit.verifyOtp(widget.email, otp);
      },
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: OtpStyles.backgroundColor,
          body: Builder(
            builder: (context) {
              return BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthVerifyOtpSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'تم تفعيل الحساب بنجاح. يرجى تسجيل الدخول.',
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false, // Remove all previous screens
                    );
                  } else if (state is AuthFailure) {
                    _controller.setError(true, state.message);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          // AppBar
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: OtpStyles.horizontalPadding,
                            ),
                            child: CustomAppbar(
                              title: "أدخل رمز التحقق",
                              onBackPressed: () => Navigator.pop(context),
                            ),
                          ),

                          SizedBox(height: OtpStyles.appBarToTextSpacing),

                          // Instruction text
                          OtpHeader(maskedEmail: _controller.maskedEmail),

                          SizedBox(height: OtpStyles.textToInputSpacing),

                          // OTP Input Row
                          OtpInputsRow(controller: _controller),

                          // Error message
                          if (_controller.showError) ...[
                            SizedBox(height: OtpStyles.errorMessageSpacing),
                            Text(
                              _controller.errorMessage ??
                                  'الرمز خاطئ يرجى المحاولة مرة اخرى',
                              style: OtpStyles.errorMessageStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],

                          SizedBox(height: OtpStyles.inputToTimerSpacing),

                          // Timer and Resend
                          OtpTimerResend(
                            formattedTimer: _controller.formattedTimer,
                            canResend: _controller.canResend,
                            onResend: _controller.resendOtp,
                          ),
                        ],
                      ),
                    ),
                    // Loading Overlay
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return Container(
                            color: AppColors.textMuted,
                            child: const Center(
                              child: CustomLoadingIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

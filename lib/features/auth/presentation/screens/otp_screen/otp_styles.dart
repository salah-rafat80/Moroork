import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extracted styles for OTP screen - ensures UI consistency.
/// All values are responsive using flutter_screenutil.
class OtpStyles {
  OtpStyles._();

  // ─────────────────────────────────────────────────────────────────
  // Colors
  // ─────────────────────────────────────────────────────────────────
  static Color get backgroundColor => AppColors.background;
  static final Color primaryGreen = AppColors.primary;
  static final Color textPrimary = AppColors.textPrimary;
  static final Color textSecondary = AppColors.textSecondary;
  static final Color borderDefault = AppColors.border;
  static final Color errorRed = AppColors.error;
  static final Color resendDisabled = AppColors.greenOpacityBg; // 50% opacity green
  static final Color barrierColor = AppColors.blackOpacityBg; // 50% black

  // ─────────────────────────────────────────────────────────────────
  // Sizes (using getters for responsive values)
  // ─────────────────────────────────────────────────────────────────
  static double get inputBoxWidth => 48.w;
  static double get inputBoxHeight => 52.h;
  static double get inputBoxRadius => 8.r;
  static double get inputBoxBorderWidth => 1.5;
  static double get successCircleSize => 80.r;
  static double get successIconSize => 44.r;
  static double get sheetRadius => 24.r;

  // ─────────────────────────────────────────────────────────────────
  // Spacing (using getters for responsive values)
  // ─────────────────────────────────────────────────────────────────
  static double get horizontalPadding => 16.w;
  static double get appBarToTextSpacing => 24.h;
  static double get emailToInstructionSpacing => 4.h;
  static double get instructionToConfirmSpacing => 16.h;
  static double get textToInputSpacing => 32.h;
  static double get errorMessageSpacing => 16.h;
  static double get inputToTimerSpacing => 24.h;
  static double get timerToResendSpacing => 16.h;
  static double get inputBoxSpacing => 12.w;
  static double get sheetVerticalPadding => 48.h;
  static double get successCircleToTextSpacing => 24.h;
  static double get resendTextSpacing => 4.w;

  // ─────────────────────────────────────────────────────────────────
  // Text Styles (using getters for responsive font sizes)
  // ─────────────────────────────────────────────────────────────────
  static TextStyle get instructionStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get emailStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get confirmInstructionStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get errorMessageStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: primaryGreen, // As per original code
  );

  static TextStyle get timerStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get noCodeReceivedStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle resendStyle({required bool enabled}) => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: enabled ? primaryGreen : resendDisabled,
    decoration: TextDecoration.underline,
    decorationColor: enabled ? primaryGreen : resendDisabled,
  );

  static TextStyle get otpInputStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: primaryGreen,
  );

  static TextStyle get successTitleStyle => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────
  // Input Decoration Helpers
  // ─────────────────────────────────────────────────────────────────
  static InputDecoration otpInputDecoration({
    required bool hasError,
    required bool hasValue,
  }) {
    Color borderColor;
    if (hasError) {
      borderColor = errorRed;
    } else if (hasValue) {
      borderColor = primaryGreen;
    } else {
      borderColor = borderDefault;
    }

    return InputDecoration(
      counterText: '',
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBoxRadius),
        borderSide: BorderSide(
          color: hasError ? errorRed : borderDefault,
          width: inputBoxBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBoxRadius),
        borderSide: BorderSide(color: borderColor, width: inputBoxBorderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBoxRadius),
        borderSide: BorderSide(color: primaryGreen, width: inputBoxBorderWidth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBoxRadius),
        borderSide: BorderSide(color: errorRed, width: inputBoxBorderWidth),
      ),
    );
  }
}

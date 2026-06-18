import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

final Color _kBorderDefault = AppColors.greyBorder;
final Color _kBorderFocused = AppColors.primary;
final Color _kBorderError = AppColors.alertRed;
final Color _kHintColor = AppColors.greyIcon;
final Color _kLabelColor = AppColors.textPrimary;
final Color _kTextColor = AppColors.textPrimary;
final Color _kFillColor = AppColors.whiteBg;
final Color _kErrorTextColor = AppColors.alertRed;

// ── Widget ────────────────────────────────────────────────────────────────────

/// A styled Arabic [TextFormField] used inside [Form] widgets.
///
/// Features:
/// - RTL-aware right-aligned hint and input text.
/// - Default grey border → focused green border → error red border.
/// - Red error helper text shown below the field (matching Figma 149).
/// - Optional [minLines] / [maxLines] for multiline (textarea) mode.
///
/// Usage:
/// ```dart
/// CustomTextFormField(
///   labelText: 'المحافظة',
///   hintText: 'اكتب المحافظة',
///   controller: _governorateController,
///   validator: (v) => (v == null || v.trim().isEmpty)
///       ? 'برجاء إدخال اسم محافظة صحيح'
///       : null,
/// )
/// ```
class CustomTextFormField extends StatelessWidget {
  /// Field label shown above the input box.
  final String labelText;

  /// Placeholder text shown inside the input box when empty.
  final String hintText;

  /// Controller that holds the field's current value.
  final TextEditingController controller;

  /// Validator callback; return a non-null string to show an error.
  final FormFieldValidator<String>? validator;

  /// Minimum visible lines (default 1). Set > 1 for multiline/textarea.
  final int minLines;

  /// Maximum lines before scrolling (default 1). Set null for unlimited.
  final int? maxLines;

  /// Keyboard type (default [TextInputType.text]).
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Label ───────────────────────────────────────────────────────────
        Text(
          labelText,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            color: _kLabelColor,
          ),
        ),

        SizedBox(height: 8.h),

        // ── Input ────────────────────────────────────────────────────────────
        TextFormField(
          controller: controller,
          validator: validator,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _kTextColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: _kHintColor,
            ),
            // Error text styling — red, Cairo 10sp bold (matches Figma 149).
            errorStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _kErrorTextColor,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            filled: true,
            fillColor: _kFillColor,
            // ── Borders ─────────────────────────────────────────────────────
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                color: _kBorderDefault,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                color: _kBorderFocused,
                width: 1.5.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                color: _kBorderError,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                color: _kBorderError,
                width: 1.5.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


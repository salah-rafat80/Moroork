import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A tappable form field that mimics a dropdown selector.
///
/// Displays [value] when a selection has been made, or [hint] when empty.
/// Wrapped in a green-bordered rounded rectangle matching the Figma design.
/// Triggers [onTap] on press — typically used to show a [showModalBottomSheet].
///
/// **Example:**
/// ```dart
/// CustomDropdownField(
///   label: 'المحافظة',
///   hint: 'اختر محافظتك',
///   value: _selectedGovernorate,
///   onTap: _showGovernorateSheet,
/// )
/// ```
class CustomDropdownField extends StatelessWidget {
  /// Label text displayed above the field.
  final String label;

  /// Placeholder text shown when [value] is null or empty.
  final String hint;

  /// Currently selected value. Displayed in place of [hint] when non-null.
  final String? value;

  /// Callback fired when the user taps the field.
  final VoidCallback onTap;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Field label ───────────────────────────────────────────────────
        Text(
          label,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17.sp,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),

        // ── Tappable field ────────────────────────────────────────────────
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: ShapeDecoration(
              color: AppColors.inputFieldBg,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.w, color: AppColors.primary),
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Row(
              // RTL: chevron on the left, text on the right
              textDirection: TextDirection.rtl,
              children: [
                // ── Selected value or hint ──────────────────────────────
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.greyIcon,
                      fontSize: 15.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // ── Chevron icon (left side in RTL layout) ──────────────
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A "dumb" checkbox row that lets the user agree to the Terms & Conditions.
///
/// All state is held externally (e.g. in a [StatefulWidget] or Cubit).
/// The widget simply reflects [isAgreed] and fires [onChanged] on interaction.
class AgreementCheckbox extends StatelessWidget {
  /// Whether the checkbox is currently checked.
  final bool isAgreed;

  /// Called when the user taps the checkbox.
  /// Receives the new value. Pass `null` to disable interaction.
  final ValueChanged<bool>? onChanged;

  const AgreementCheckbox({super.key, required this.isAgreed, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        SizedBox(
          width: 24.r,
          height: 24.r,
          child: Checkbox(
            value: isAgreed,
            onChanged: onChanged != null ? (v) => onChanged!(v ?? false) : null,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: BorderSide(
              color: AppColors.charcoal,
              width: 1.5.r,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: 8.w),

        // ── Label ─────────────────────────────────────────────────────────
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'أوافق على جميع ',
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 13.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'الشروط والأحكام',
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 13.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          textDirection: TextDirection.rtl,
        ),

        // ── Checkbox ─────────────────────────────────────────────────────
      ],
    );
  }
}

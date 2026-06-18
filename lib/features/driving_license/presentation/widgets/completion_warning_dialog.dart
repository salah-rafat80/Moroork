import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// **Completion Warning Dialog** — appears at the end of the practical test booking flow.
///
/// Displays a warning message that the user cannot complete the license issuance
/// until they pass both the theory test and practical driving test.
///
/// **Navigation:**
/// - When "العودة للشاشة الرئيسية" is pressed, dismisses the dialog and
///   navigates back to the home screen (first route).
class CompletionWarningDialog extends StatelessWidget {
  const CompletionWarningDialog({super.key});

  /// Shows this dialog using [showDialog].
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CompletionWarningDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowOverlay,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Warning icon ─────────────────────────────────────────────
              SvgPicture.asset(
                'assets/worrn.svg',
                width: 64.w,
                height: 64.h,
              ),
              SizedBox(height: 32.h),

              // ── Warning message ──────────────────────────────────────────
              Text(
                'لن تتمكن من استكمال إصدار الرخصة إلا بعد اجتياز اختبار الإشارات النظري، واختبار القيادة العملي',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),

              // ── Return to home button ────────────────────────────────────
              InkWell(
                onTap: () {
                  // Dismiss dialog first
                  Navigator.of(context).pop();
                  // Then pop all routes until home (first route)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border.all(
                      width: 1.w,
                      color: AppColors.primary,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'العودة للشاشة الرئيسية',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


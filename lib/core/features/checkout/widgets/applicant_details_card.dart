import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/widgets/info_row_item.dart';

/// Displays the applicant's personal data in a styled card.
///
/// An optional [onEditPressed] callback drives the "تعديل" button at the top.
/// When null the button is hidden.
class ApplicantDetailsCard extends StatelessWidget {
  final ApplicantDetails details;

  /// Callback invoked when the user taps the "تعديل" (edit) button.
  /// Pass null to hide the button entirely.
  final VoidCallback? onEditPressed;

  const ApplicantDetailsCard({
    super.key,
    required this.details,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      title: 'بيانات صاحب الطلب',
      trailing: onEditPressed != null
          ? _EditButton(onPressed: onEditPressed!)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRowItem(label: 'الاسم', value: details.name),
          InfoRowItem(label: 'الرقم القومي', value: details.nationalId),
          InfoRowItem(label: 'رقم الهاتف', value: details.phone),
          InfoRowItem(
            label: 'البريد الالكتروني',
            value: details.email,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            'تعديل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal reusable card shell used by all three checkout cards.
class _CheckoutCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _CheckoutCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card header ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1.h, thickness: 1.h, color: AppColors.greyBorder),
          // ── Card body ────────────────────────────────────────────────────
          child,
        ],
      ),
    );
  }
}

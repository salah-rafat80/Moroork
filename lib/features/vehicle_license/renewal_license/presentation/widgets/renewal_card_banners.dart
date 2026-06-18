import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/renewal_vehicle_license_model.dart';

// ── Info Row ──────────────────────────────────────────────────────────────────

class RenewalInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const RenewalInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class RenewalBadge extends StatelessWidget {
  final String text;
  final Color color;

  const RenewalBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class RenewalStatusBadge extends StatelessWidget {
  final RenewalLicenseStatus status;

  const RenewalStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case RenewalLicenseStatus.valid:
        text = 'سارية';
        color = AppColors.primary;
        break;
      case RenewalLicenseStatus.expired:
        text = 'منتهية';
        color = AppColors.alertRed;
        break;
      case RenewalLicenseStatus.suspended:
        text = 'موقوفة';
        color = AppColors.warningOrange;
        break;
      case RenewalLicenseStatus.withdrawn:
        text = 'مسحوبة';
        color = AppColors.warningOrange;
        break;
    }

    return RenewalBadge(text: text, color: color);
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class RenewalDivider extends StatelessWidget {
  const RenewalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
      child: Container(height: 1, color: AppColors.greyBorder),
    );
  }
}

// ── Warning Banner (violations) ───────────────────────────────────────────────

class RenewalWarningBanner extends StatelessWidget {
  final String message;
  final String linkText;
  final VoidCallback onLinkTap;

  const RenewalWarningBanner({
    super.key,
    required this.message,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.alertRedLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.alertRed,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onLinkTap,
            child: Text(
              linkText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.alertRed,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Banner (inspection / insurance) ──────────────────────────────────────

class RenewalInfoBanner extends StatelessWidget {
  final String message;
  final Color color;
  final Color textColor;

  const RenewalInfoBanner({
    super.key,
    required this.message,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

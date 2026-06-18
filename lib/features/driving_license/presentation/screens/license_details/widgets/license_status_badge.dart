import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';

/// A coloured pill badge that reflects the driving licence status.
///
/// | Status     | Colour     | Arabic label |
/// |------------|------------|--------------|
/// | valid      | Green      | سارية        |
/// | expired    | Red        | منتهية       |
/// | withdrawn  | Orange     | مسحوبة       |
class LicenseStatusBadge extends StatelessWidget {
  final LicenseStatus status;

  const LicenseStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        _badgeLabel,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.cardBg,
        ),
      ),
    );
  }

  Color get _badgeColor {
    switch (status) {
      case LicenseStatus.valid:
        return AppColors.primary;
      case LicenseStatus.expired:
        return AppColors.alertRed;
      case LicenseStatus.withdrawn:
        return AppColors.warningOrange;
      case LicenseStatus.suspended:
        return AppColors.warningOrange;
    }
  }

  String get _badgeLabel {
    switch (status) {
      case LicenseStatus.valid:
        return 'سارية';
      case LicenseStatus.expired:
        return 'منتهية';
      case LicenseStatus.withdrawn:
        return 'مسحوبة';
      case LicenseStatus.suspended:
        return 'موقوفة';
    }
  }
}

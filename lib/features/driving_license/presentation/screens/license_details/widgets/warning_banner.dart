import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';

/// Renders a contextual warning banner below the licence info card.
///
/// | Status     | Banner behaviour                                          |
/// |------------|-----------------------------------------------------------|
/// | valid      | Hidden (`SizedBox.shrink`)                                |
/// | expired    | Red banner + warning text + "عرض المخالفات" tap link     |
/// | withdrawn  | Red banner + "لا يمكن اصدار بدل لهذه الرخصة"             |
class WarningBanner extends StatelessWidget {
  final DrivingLicenseModel license;

  /// Callback invoked when the user taps "عرض المخالفات" (expired only).
  final VoidCallback? onViewViolationsTap;

  const WarningBanner({
    super.key,
    required this.license,
    this.onViewViolationsTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (license.status) {
      case LicenseStatus.valid:
      case LicenseStatus.expired:
        return _buildBanner(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'توجد مخالفات غير مدفوعة علي هذه الرخصة تمنع استكمال تجديد الرخصة.',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alertRed,
                ),
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: onViewViolationsTap,
                child: Text(
                  'عرض المخالفات',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.alertRed,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.alertRed,
                  ),
                ),
              ),
            ],
          ),
        );

      case LicenseStatus.withdrawn:
        return _buildBanner(
          child: Text(
            'لا يمكن اصدار بدل لهذه الرخصة',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.alertRed,
            ),
          ),
        );

      case LicenseStatus.suspended:
        return _buildBanner(
          child: Text(
            'هذه الرخصة موقوفة. لا يمكن استكمال تجديدها أو استخراج بدل لها.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.alertRed,
            ),
          ),
        );
    }
  }

  Widget _buildBanner({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.alertRedLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}

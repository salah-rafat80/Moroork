import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/radio_dot.dart';
import '../../data/models/renewal_vehicle_license_model.dart';
import 'renewal_card_banners.dart';

// ── Public widget ─────────────────────────────────────────────────────────────

class RenewalVehicleLicenseCard extends StatelessWidget {
  final RenewalVehicleLicenseModel vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onShowViolations;

  const RenewalVehicleLicenseCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.onShowViolations,
  });

  bool get _isRestricted =>
      vehicle.status == RenewalLicenseStatus.suspended ||
      vehicle.status == RenewalLicenseStatus.withdrawn;

  bool get _canSelect => vehicle.canRenew;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: _canSelect ? onTap : null,
        child: Opacity(
          opacity: _isRestricted ? 0.6 : 1.0,
          child: Container(
            padding: EdgeInsetsDirectional.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.greyBorder,
                width: isSelected ? 2.w : 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_canSelect) RadioDot(isSelected: isSelected),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      'رقم اللوحة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    RenewalBadge(
                      text: vehicle.plateNumber,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const RenewalDivider(),
                RenewalInfoRow(
                  label: 'نوع المركبة',
                  value: vehicle.vehicleType,
                ),
                const RenewalDivider(),
                RenewalInfoRow(
                  label: 'تاريخ انتهاء',
                  value: vehicle.expiryDate,
                ),
                const RenewalDivider(),
                RenewalInfoRow(
                  label: 'حالة الرخصة',
                  valueWidget: RenewalStatusBadge(status: vehicle.status),
                ),
                if (vehicle.hasUnpaidViolations) ...[
                  SizedBox(height: 10.h),
                  RenewalWarningBanner(
                    message:
                        'يوجد مخالفات غير مدفوعة على هذه الرخصة تمنع استكمال تجديد الرخصة.',
                    linkText: 'عرض المخالفات',
                    onLinkTap: onShowViolations ?? () {},
                  ),
                ],
                if (vehicle.needsTechnicalInspection) ...[
                  SizedBox(height: 10.h),
                  RenewalInfoBanner(
                    message: 'يجب إجراء فحص فني للمركبة قبل التجديد',
                    color: AppColors.lightOrangeBg,
                    textColor: AppColors.orangeText,
                  ),
                ],
                if (vehicle.needsInsuranceRenewal) ...[
                  SizedBox(height: 10.h),
                  RenewalInfoBanner(
                    message: 'اكتمل ملف التأمين، يرجى التأكد قبل الاستمرار',
                    color: AppColors.lightOrangeBg,
                    textColor: AppColors.orangeText,
                  ),
                ],
                if (vehicle.status == RenewalLicenseStatus.valid) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'لا يمكن تجديد رخصة المركبة لأنها ما زالت سارية.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.alertRed,
                    ),
                  ),
                ],
                if (_isRestricted) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'لا يمكن اصدار بدل لهذه الرخصة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.alertRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

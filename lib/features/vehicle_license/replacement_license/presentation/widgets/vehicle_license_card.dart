import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/radio_dot.dart';
import '../../data/models/vehicle_license_model.dart';

class VehicleLicenseCard extends StatelessWidget {
  final VehicleLicenseModel vehicle;
  final bool isSelected;
  final bool showRadioDot;
  final VoidCallback? onTap;
  final VoidCallback? onShowViolations;

  const VehicleLicenseCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.showRadioDot = true,
    this.onTap,
    this.onShowViolations,
  });

  bool get _isRestricted =>
      vehicle.status == VehicleLicenseStatus.suspended ||
      vehicle.status == VehicleLicenseStatus.withdrawn;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: _isRestricted ? null : onTap,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!_isRestricted && showRadioDot) ...[RadioDot(isSelected: isSelected)],
                // ── Top Row (Radio & Plate Number) ──────────────────────────
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
                    _Badge(
                      text: vehicle.plateNumber,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const _Divider(),

                // ── Info Rows ───────────────────────────────────────────────
                _InfoRow(label: 'نوع المركبة', value: vehicle.vehicleType),
                const _Divider(),
                _InfoRow(label: 'تاريخ انتهاء', value: vehicle.expiryDate),
                const _Divider(),
                _InfoRow(
                  label: 'حالة الرخصة',
                  valueWidget: _StatusBadge(status: vehicle.status),
                ),

                // ── Violations Warning ──────────────────────────────────────
                if (vehicle.hasUnpaidViolations) ...[
                  SizedBox(height: 12.h),
                  _ViolationsWarning(onShowViolations: onShowViolations),
                ],

                // ── Restricted Label ────────────────────────────────────────
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({required this.label, this.value, this.valueWidget});

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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

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

class _StatusBadge extends StatelessWidget {
  final VehicleLicenseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case VehicleLicenseStatus.valid:
        text = 'سارية';
        color = AppColors.primary;
        break;
      case VehicleLicenseStatus.expired:
        text = 'منتهية';
        color = AppColors.alertRed;
        break;
      case VehicleLicenseStatus.suspended:
        text = 'موقوفة';
        color = AppColors.warningOrange;
        break;
      case VehicleLicenseStatus.withdrawn:
        text = 'مسحوبة';
        color = AppColors.warningOrange;
        break;
    }

    return _Badge(text: text, color: color);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
      child: Container(height: 1, color: AppColors.greyBorder),
    );
  }
}

class _ViolationsWarning extends StatelessWidget {
  final VoidCallback? onShowViolations;

  const _ViolationsWarning({this.onShowViolations});

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
              'توجد مخالفات غير مدفوعة علي هذه الرخصة تمنع اصدار البدل',
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
            onTap: onShowViolations,
            child: Text(
              'عرض المخالفات',
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

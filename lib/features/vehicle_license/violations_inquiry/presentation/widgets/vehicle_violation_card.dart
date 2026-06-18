import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/radio_dot.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import '../../../violations_inquiry/data/models/vehicle_license_violation_model.dart';

/// Card widget for the vehicle violations inquiry selection screen.
/// Uses the exact same UI as [RenewalVehicleLicenseCard]:
/// RTL layout, radio dot, plate badge, info rows with Spacer, status chip.
class VehicleViolationCard extends StatelessWidget {
  final VehicleLicenseViolationModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleViolationCard({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
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
              // ── Radio dot ────────────────────────────────────────────────
              RadioDot(isSelected: isSelected),
              SizedBox(height: 10.h),

              // ── رقم اللوحة ───────────────────────────────────────────────
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

              // ── Info rows ────────────────────────────────────────────────
              _InfoRow(label: 'نوع المركبة', value: vehicle.vehicleType),
              const _Divider(),
              _InfoRow(label: 'تاريخ انتهاء', value: vehicle.expiryDate),
              const _Divider(),
              _InfoRow(
                label: 'حالة الرخصة',
                valueWidget: _StatusBadge(status: vehicle.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

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
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final LicenseStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (status) {
      case LicenseStatus.valid:
        text = 'سارية';
        color = AppColors.primary;
        break;
      case LicenseStatus.expired:
        text = 'منتهية';
        color = AppColors.alertRed;
        break;
      case LicenseStatus.withdrawn:
        text = 'مسحوبة';
        color = AppColors.warningOrange;
        break;
      case LicenseStatus.suspended:
        text = 'موقوفة';
        color = AppColors.warningOrange;
        break;
    }
    return _Badge(text: text, color: color);
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

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

// ── Divider ───────────────────────────────────────────────────────────────────

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

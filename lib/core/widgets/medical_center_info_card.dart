import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A card that displays a facility's name, address, and working hours after
/// a booking has been made.
///
/// Originally designed for medical centres but generic enough to represent
/// any facility (e.g. a traffic unit).
///
/// **Usage (medical):**
/// ```dart
/// MedicalCenterInfoCard(
///   centerName: 'مستشفي السلام',
///   address: 'شارع التسعين , العاشر من رمضان , الشرقية',
///   workingHours: '9 ص الي 3 م (الاحد -الخميس)',
/// )
/// ```
/// **Usage (traffic unit):**
/// ```dart
/// MedicalCenterInfoCard(
///   centerName: 'العاشر من رمضان',
///   address: 'شارع التسعين , العاشر من رمضان , الشرقية',
///   workingHours: '9 ص الي 3 م (الاحد -الخميس)',
/// )
/// ```
class MedicalCenterInfoCard extends StatelessWidget {
  /// Primary name displayed as the card heading.
  final String centerName;

  /// Full address string.
  final String address;

  /// Working-hours string.
  final String workingHours;

  const MedicalCenterInfoCard({
    super.key,
    required this.centerName,
    required this.address,
    required this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: AppColors.primary),
          borderRadius: BorderRadius.circular(5.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Centre name ────────────────────────────────────────────────
          Text(
            centerName,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),

          // ── Address row ────────────────────────────────────────────────
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: 'العنوان : $address',
          ),
          SizedBox(height: 8.h),

          // ── Working hours row ──────────────────────────────────────────
          _InfoRow(
            icon: Icons.access_time_outlined,
            text: 'مواعيد العمل : $workingHours',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper: icon + text row (RTL)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.deepGrey,
              fontSize: 12.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

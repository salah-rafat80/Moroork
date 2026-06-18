import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The secondary "رفع صورة من المعرض" (Upload from Gallery) button.
/// Triggers [onPressed] when tapped.
class InspectionUploadButton extends StatelessWidget {
  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  const InspectionUploadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 1.5.w),
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        icon: Icon(
          Icons.photo_library_outlined,
          size: 20.r,
        ),
        label: Text(
          'رفع صورة من الاستوديو',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

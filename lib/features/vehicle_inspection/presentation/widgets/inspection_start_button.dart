import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The primary "بدء الفحص" (Start Inspection) button.
/// Triggers [onPressed] when tapped.
class InspectionStartButton extends StatelessWidget {
  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  const InspectionStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'بدء الفحص',
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

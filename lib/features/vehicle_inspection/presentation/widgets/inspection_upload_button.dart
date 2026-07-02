import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The secondary button to upload a photo from the gallery.
class InspectionUploadButton extends StatelessWidget {
  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  const InspectionUploadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark 
                ? AppColors.primary.withValues(alpha: 0.5) 
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1.5.w,
          ),
          foregroundColor: AppColors.textPrimary,
          backgroundColor: isDark 
              ? const Color(0xFF1E293B) 
              : const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 20.r,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'رفع صورة من الاستوديو',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

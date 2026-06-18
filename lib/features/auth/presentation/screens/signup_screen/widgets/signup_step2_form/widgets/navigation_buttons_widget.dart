import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final bool isValid;
  final double buttonHeight;

  const NavigationButtonsWidget({
    super.key,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.isValid,
    required this.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Next button
        Expanded(
          child: InkWell(
            onTap: isValid ? onNextPressed : null,
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: isValid
                    ? AppColors.primary
                    : AppColors.mutedGrey,
              ),
              child: Center(
                child: Text(
                  'التالي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Previous button
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: onPreviousPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'السابق',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

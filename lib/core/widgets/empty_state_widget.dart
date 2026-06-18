import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// A premium, highly aesthetic empty state widget that renders the 'Empty List.json' Lottie animation.
class EmptyStateWidget extends StatelessWidget {
  /// The descriptive message displayed under the animation.
  final String message;

  /// Optional size override for the Lottie animation.
  final double? size;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/Empty List.json',
              width: size ?? 200.w,
              height: size ?? 200.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

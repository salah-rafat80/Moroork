import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimelineStepItem extends StatelessWidget {
  final String title;
  final String dateSubtitle;
  final String descSubtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFailed;
  final bool isLastStep;

  const TimelineStepItem({
    super.key,
    required this.title,
    required this.dateSubtitle,
    required this.descSubtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isFailed = false,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isFailed ? AppColors.darkRed : AppColors.charcoal,
                    fontSize: 14.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // SizedBox(height: 2.h),
                Text(
                  dateSubtitle,
                  style: TextStyle(
                    color: isFailed ? AppColors.darkRed : AppColors.mediumGrey,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (descSubtitle.isNotEmpty) ...[
                  // SizedBox(height: 2.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      descSubtitle,
                      style: TextStyle(
                        color: isFailed
                            ? AppColors.alertRedBg
                            : AppColors.mediumGrey,
                        fontSize: 12.sp,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (!isLastStep) SizedBox(height: 16.h),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: ShapeDecoration(
                  color: isFailed
                      ? AppColors.errorLightBg
                      : isCompleted
                      ? AppColors.lightGreenBg
                      : isCurrent
                      ? AppColors.skyBlueLight
                      : AppColors.dividerGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Center(
                  child: isFailed
                      ? Icon(Icons.cancel, color: AppColors.darkRed, size: 16.r)
                      : isCompleted
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 16.r,
                        )
                      : isCurrent
                      ? Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: ShapeDecoration(
                            color: AppColors.primaryBlue,
                            shape: const OvalBorder(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (!isLastStep)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: isCompleted
                        ? AppColors
                              .lightGreenBg // completed line color
                        : isFailed
                        ? AppColors
                              .errorLightBg // failed line color
                        : AppColors.dividerGrey, // inactive line color
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

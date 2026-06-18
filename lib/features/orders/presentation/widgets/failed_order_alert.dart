import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FailedOrderAlert extends StatelessWidget {
  final String statusLabel;

  const FailedOrderAlert({
    super.key,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.alertRedLightBg,
        border: Border.all(
          color: AppColors.alertRedBorder,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              statusLabel.isNotEmpty
                  ? statusLabel
                  : 'لا يمكنك استكمال الطلب لعدم اجتياز الكشف الطبي.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.alertRedBg,
                fontSize: 14.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.alertRedBg,
          ),
        ],
      ),
    );
  }
}

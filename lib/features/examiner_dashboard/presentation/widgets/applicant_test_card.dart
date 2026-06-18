import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicantTestCard extends StatelessWidget {
  final String orderNo;
  final String applicantName;
  final String time;
  final String buttonText;
  final String requestNumberLabel;
  final VoidCallback onViewDetails;

  const ApplicantTestCard({
    super.key,
    required this.orderNo,
    required this.applicantName,
    required this.time,
    required this.buttonText,
    required this.requestNumberLabel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: AppColors.primary, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4.r,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        // textDirection: TextDirection.rtl,
        children: [
          _buildInfoRow(requestNumberLabel, orderNo),
          SizedBox(height: 10.h),
          _buildInfoRow('الرقم القومي', applicantName),
          SizedBox(height: 10.h),
          _buildInfoRow('الوقت', time),
          SizedBox(height: 10.h),
          Divider(color: AppColors.greyBorder),
          SizedBox(height: 5.h),
          GestureDetector(
            onTap: onViewDetails,
            child: Row(
              children: [
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 12.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

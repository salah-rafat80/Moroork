import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/custom_text_field.dart';

class PhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const PhoneFieldWidget({
    super.key,
    required this.controller,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: controller,
            hintText: '1234567',
            textAlign: TextAlign.right,
            keyboardType: TextInputType.phone,
            hasError: error != null,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: error != null
                  ? AppColors.error
                  : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '+20',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.charcoal,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }
}

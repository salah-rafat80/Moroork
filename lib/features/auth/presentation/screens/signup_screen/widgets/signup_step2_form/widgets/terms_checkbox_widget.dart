import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsCheckboxWidget extends StatelessWidget {
  final bool acceptedTerms;
  final ValueChanged<bool?> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.acceptedTerms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'أوافق على جميع الشروط والأحكام',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.charcoal,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 24.r,
          height: 24.r,
          child: Checkbox(
            value: acceptedTerms,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: BorderSide(
              color: AppColors.charcoal,
              width: 1.5.r,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ],
    );
  }
}

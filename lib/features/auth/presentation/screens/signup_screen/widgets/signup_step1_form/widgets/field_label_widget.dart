import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';

class FieldLabelWidget extends StatelessWidget {
  final String label;

  const FieldLabelWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.charcoal,
        fontFamily: 'Tajawal',
      ),
    );
  }
}

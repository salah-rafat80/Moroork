// path: lib/features/home/presentation/widgets/section_title.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      ),
    );
  }
}

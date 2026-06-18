import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Animation<Color?>? valueColor;
  final double strokeWidth;

  const CustomLoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.color,
    this.valueColor,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Lottie.asset(
          'assets/animations/Sandy Loading.json',
          width: width ?? 150.w,
          height: height ?? 150.h,
        ),
      ),
    );
  }
}

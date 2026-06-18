import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/constants/colors.dart';

class PulsingAiHero extends StatelessWidget {
  final Animation<double> glowAnimation;

  const PulsingAiHero({super.key, required this.glowAnimation});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.whiteBg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue
                    .withValues(alpha: isDarkMode ? 0.4 : 0.15),
                blurRadius: glowAnimation.value * 2,
                spreadRadius: glowAnimation.value / 2,
              ),
              BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: isDarkMode ? 0.3 : 0.1),
                blurRadius: glowAnimation.value * 3,
                spreadRadius: glowAnimation.value / 3,
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/ai_robot.svg',
              width: 55.w,
              height: 55.w,
            ),
          ),
        );
      },
    );
  }
}

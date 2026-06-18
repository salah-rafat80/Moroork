import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/constants/colors.dart';
import 'dart:math' as math;

class AiThinkingIndicator extends StatefulWidget {
  const AiThinkingIndicator({super.key});

  @override
  State<AiThinkingIndicator> createState() => _AiThinkingIndicatorState();
}

class _AiThinkingIndicatorState extends State<AiThinkingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late AnimationController _bubbleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutQuad,
    ));

    _bubbleController.forward();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isRtl) ...[
                  _buildAiAvatar(),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBg,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? AppColors.black.withValues(alpha: 0.2)
                              : AppColors.shadowColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0),
                        SizedBox(width: 4.w),
                        _buildDot(1),
                        SizedBox(width: 4.w),
                        _buildDot(2),
                      ],
                    ),
                  ),
                ),
                if (isRtl) ...[
                  SizedBox(width: 8.w),
                  _buildAiAvatar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/ai_robot.svg',
          width: 20.w,
          height: 20.w,
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final double phase = (index * 0.2);
        double value = _dotsController.value - phase;
        if (value < 0) value += 1.0;
        
        final double offset = math.sin(value * math.pi * 2);
        final double yPos = offset < 0 ? offset * 4 : 0;
        
        return Transform.translate(
          offset: Offset(0, yPos),
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

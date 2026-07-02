import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// An animated holographic AI scanning card to replace the plain camera icon.
class InspectionCameraIconCard extends StatefulWidget {
  const InspectionCameraIconCard({super.key});

  @override
  State<InspectionCameraIconCard> createState() => _InspectionCameraIconCardState();
}

class _InspectionCameraIconCardState extends State<InspectionCameraIconCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Holographic Scan Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/ai_car_scan.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Neon HUD Scanning Line
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 200.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 12.r,
                          spreadRadius: 2.r,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0),
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // HUD Target Corners
            Positioned(
              top: 15.h,
              left: 15.w,
              child: _buildHUDCorner(top: true, left: true),
            ),
            Positioned(
              top: 15.h,
              right: 15.w,
              child: _buildHUDCorner(top: true, left: false),
            ),
            Positioned(
              bottom: 15.h,
              left: 15.w,
              child: _buildHUDCorner(top: false, left: true),
            ),
            Positioned(
              bottom: 15.h,
              right: 15.w,
              child: _buildHUDCorner(top: false, left: false),
            ),
            
            // AI Active Indicator
            Positioned(
              top: 15.h,
              right: 35.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    _BlinkingIndicator(),
                    SizedBox(width: 6.w),
                    Text(
                      'مسح تفاعلي نشط',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tech Model label
            Positioned(
              bottom: 15.h,
              left: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  'MODEL: AI-VISION-v2.1',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDCorner({required bool top, required bool left}) {
    const double length = 12.0;
    const double thickness = 2.0;
    final color = AppColors.primary.withValues(alpha: 0.6);
    
    return SizedBox(
      width: length.w,
      height: length.w,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: 0,
            right: 0,
            child: Container(
              height: thickness.h,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: thickness.w,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingIndicator extends StatefulWidget {
  @override
  State<_BlinkingIndicator> createState() => _BlinkingIndicatorState();
}

class _BlinkingIndicatorState extends State<_BlinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          color: Color(0xFF4ADE80),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4ADE80),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ]
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A tall service card with icon on top and label below,
/// used in the "الخدمات" grid section.
class ServiceCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool isAssistant;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isAssistant = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.borderLight),
        ),
        child: isAssistant
            ? _AssistantContent(icon: icon, title: title)
            : _ServiceContent(icon: icon, title: title),
      ),
    );
  }
}

class _ServiceContent extends StatelessWidget {
  final String icon;
  final String title;
  const _ServiceContent({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 38.w, height: 38.w),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantContent extends StatelessWidget {
  final String icon;
  final String title;
  const _AssistantContent({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.rtl,
      children: [
        SvgPicture.asset(icon, width: 28.w, height: 28.w),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Cairo', 
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable card representing a selectable payment method option.
class PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAssetPath;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoAssetPath,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.greyBorder,
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Title & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 12.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Logo
            Image.asset(
              logoAssetPath,
              width: 54.w,
              height: 30.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if asset is missing
                return Icon(Icons.credit_card, size: 30.w, color: Colors.grey);
              },
            ),
          ],
        ),
      ),
    );
  }
}

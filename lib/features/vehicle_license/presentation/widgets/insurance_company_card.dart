import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InsuranceCompanyCard extends StatelessWidget {
  final String companyName;
  final String details;
  final String logoAssetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const InsuranceCompanyCard({
    super.key,
    required this.companyName,
    required this.details,
    required this.logoAssetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.greyBorder,
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo area
            SizedBox(
              height: 100.h,
              width: double.infinity,
              child: Image.asset(
                logoAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found
                  return Container(
                    color: AppColors.cardBg,
                    alignment: Alignment.center,
                    child: Image.asset("assets/الشركة المصرية للتأمين .png"),
                  );
                },
              ),
            ),

            // Details and Radio
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          companyName,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          details,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.deepGrey,
                            fontSize: 10.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Radio Indicator
                  Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightGreenBg
                          : AppColors.cardBg,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.greyBorder,
                              width: 1.w,
                            ),
                    ),
                    child: isSelected
                        ? Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

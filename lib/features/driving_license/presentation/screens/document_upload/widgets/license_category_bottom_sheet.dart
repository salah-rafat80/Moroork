import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet that lists all available driving-licence categories.
///
/// **Usage:**
/// ```dart
/// final selected = await showModalBottomSheet<String>(
///   context: context,
///   builder: (_) => const LicenseCategoryBottomSheet(),
/// );
/// if (selected != null) { /* update state */ }
/// ```
///
/// Tapping any row calls [Navigator.pop] with the selected category string.
class LicenseCategoryBottomSheet extends StatelessWidget {
  const LicenseCategoryBottomSheet({super.key});

  // ── Data ──────────────────────────────────────────────────────────────────

  static const List<String> _categories = [
    'قيادة خاصة',
    'دراجة نارية',
    'مهنية درجة ثالثة',
    'مهنية درجة ثانية',
    'مهنية درجة أولى',
    'قيادة معدات ثقيلة',
    'قيادة جرار زراعي',
  ];

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 12.h,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.greyBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'اختر فئة الرخصة',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // ── Category list ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: Material(
                  color: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColors.greyBorder,
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _categories.length; i++) ...[
                        InkWell(
                          onTap: () => Navigator.pop(context, _categories[i]),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              child: Text(
                                _categories[i],
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.sp,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < _categories.length - 1)
                          Divider(
                            height: 1.h,
                            thickness: 1.h,
                            color: AppColors.greyBorder,
                            indent: 0,
                            endIndent: 0,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

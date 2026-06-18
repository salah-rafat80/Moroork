import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/custom_appbar.dart';

class SignupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String step;
  final String? nextStepText; // "التالي : البيانات الشخصية"
  final VoidCallback? onBackPressed;

  const SignupAppBar({
    super.key,
    required this.step,
    this.nextStepText,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(150.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.background,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
            children: [
              CustomAppbar(onBackPressed: onBackPressed, title: "إنشاء حساب"),
              SizedBox(height: 12.h),
              Row(children: _buildProgressBars()),
              SizedBox(height: 8.h),
              // Row 3: Step number + Next step text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step number - RIGHT side (Child 0 in RTL)
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.softGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  // Next step text - LEFT side (Child 1 in RTL)
                  if (nextStepText != null)
                    Flexible(
                      child: Text(
                        nextStepText!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.inputHint,
                          fontFamily: 'Tajawal',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgressBars() {
    final int currentStep = _getCurrentStep();
    return List.generate(3, (index) {
      final bool isActive = index < currentStep;
      return Expanded(
        child: Container(
          height: 4.h,
          margin: EdgeInsets.only(left: index == 2 ? 0 : 3.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.dividerGrey,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      );
    });
  }

  int _getCurrentStep() {
    final parsed = int.tryParse(step);
    if (parsed != null && parsed >= 1 && parsed <= 3) return parsed;
    if (step.contains('1')) return 1;
    if (step.contains('2')) return 2;
    if (step.contains('3')) return 3;
    return 1;
  }
}

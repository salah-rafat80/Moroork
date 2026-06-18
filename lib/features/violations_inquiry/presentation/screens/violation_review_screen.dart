import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/violations_inquiry/data/models/violation_model.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/bottom_action_buttons.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/review_summary_card.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_item_card.dart';

/// Review screen that shows a summary of selected violations before payment.
///
/// Displays:
/// - Total violations count & total amount due (ReviewSummaryCard)
/// - A list of selected violations (ViolationItemCard)
/// - Bottom action buttons: "التالي" and "تعديل الاختيارات" (BottomActionButtons)
class ViolationReviewScreen extends StatelessWidget {
  /// The selected violations to review before payment.
  final List<ViolationModel> selectedViolations;

  /// Called when the user taps "التالي" (Next).
  final VoidCallback onNext;

  /// Called when the user taps "تعديل الاختيارات" (Edit selections).
  final VoidCallback onEdit;

  const ViolationReviewScreen({
    super.key,
    required this.selectedViolations,
    required this.onNext,
    required this.onEdit,
  });

  double get _totalAmount =>
      selectedViolations.fold(0.0, (sum, v) => sum + v.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Builder(
        builder: (innerContext) {
          return Column(
            children: [
              // ── App bar ──
              ServiceScreenAppBar(
                title: 'سداد مخالفات رخصة المركبة',
                onMenuPressed: () =>
                    Scaffold.of(innerContext).openDrawer(),
              ),

              SizedBox(height: 5.h),

              // ── Scrollable content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── Section label: مراجعة الطلب ──
                      Text(
                        'مراجعة الطلب',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Summary card ──
                      ReviewSummaryCard(
                        totalViolations: selectedViolations.length,
                        totalAmount: _totalAmount,
                      ),

                      SizedBox(height: 24.h),

                      // ── Section label: المخالفات المحددة ──
                      Text(
                        'المخالفات المحددة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Violations list ──
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectedViolations.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, index) {
                          final v = selectedViolations[index];
                          return ViolationItemCard(
                            title: v.title,
                            violationNumber: v.violationNumber,
                            amount: v.amount,
                          );
                        },
                      ),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // ── Bottom action buttons ──
              BottomActionButtons(
                onNext: onNext,
                onEdit: onEdit,
              ),
            ],
          );
        },
      ),
    );
  }
}


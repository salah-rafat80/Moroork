import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/violations_inquiry/data/models/violation_model.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_detail_row.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_illustration.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_status_tag.dart';

/// A card that displays the complete details of a violation.
///
/// Shows the violation title, payment status tag, an SVG illustration,
/// and rows for date/time, location, legal article, amount, and violation number.
class ViolationDetailsCard extends StatelessWidget {
  /// The violation model containing all detail fields.
  final ViolationModel violation;

  const ViolationDetailsCard({super.key, required this.violation});

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Divider(color: AppColors.greyBorder, height: 1),
  );

  @override
  Widget build(BuildContext context) {
    final v = violation;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            // ── Title + Status Tag row ──
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    v.title,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                ViolationStatusTag(isPaid: v.isPaid),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Violation Illustration ──
            ViolationIllustration(violationTitle: v.title),

            _divider(),

            // ── Date & Time ──
            ViolationDetailRow(
              label: 'التاريخ والوقت',
              value: '${v.time} , ${v.date}',
              iconAsset: 'assets/stash_data-date-light.svg',
            ),

            _divider(),

            // ── Location ──
            ViolationDetailRow(
              label: 'الموقع',
              value: v.location,
              iconAsset: 'assets/search.svg',
            ),

            _divider(),

            // ── Legal Article ──
            ViolationDetailRow(
              label: 'المادة/ القانون',
              value: '${v.articleNumber} /  ${v.articleText}',
              iconAsset: 'assets/file_s.svg',
            ),

            _divider(),

            // ── Violation Amount ──
            ViolationDetailRow(
              label: 'قيمة المخالفة',
              value: '${v.amount.toInt()} جنية مصري',
              iconAsset: 'assets/cart_payment.svg',
            ),

            _divider(),

            // ── Violation Number ──
            ViolationDetailRow(
              label: 'رقم المخالفة',
              value: v.violationNumber,
              iconAsset: 'assets/mingcute_ticket-line.svg',
            ),

            // ── Payment Date (paid only) ──
            if (v.isPaid && v.paymentDate != null) ...[
              _divider(),
              ViolationDetailRow(
                label: 'تاريخ وقت السداد',
                value: v.paymentDate!,
                iconAsset: 'assets/stash_data-date-light.svg',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

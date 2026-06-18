import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/widgets/info_row_item.dart';

/// Displays the high-level order summary (type, payment method, order ID).
class OrderSummaryCard extends StatelessWidget {
  final OrderSummary summary;

  const OrderSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return _OrderCardShell(
      title: 'ملخص الطلب',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRowItem(label: 'نوع الطلب', value: summary.orderType),
          InfoRowItem(label: 'طريقة السداد', value: summary.paymentMethod),
          InfoRowItem(
            label: 'رقم الطلب',
            value: summary.orderId,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

// ── Private card shell (scoped to this file) ─────────────────────────────────

class _OrderCardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _OrderCardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                title,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Divider(height: 1.h, thickness: 1.h, color: AppColors.greyBorder),
          child,
        ],
      ),
    );
  }
}

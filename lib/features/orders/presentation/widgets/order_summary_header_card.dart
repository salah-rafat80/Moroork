import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/order_model.dart';

class OrderSummaryHeaderCard extends StatelessWidget {
  final OrderModel order;

  const OrderSummaryHeaderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(5.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.title,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 16.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الحالة : ",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(child: _OrderStatusBadge(order: order)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم الطلب',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  order.id,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ التقديم',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  order.date,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final OrderModel order;

  const _OrderStatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text = order.statusLabel.isNotEmpty
        ? order.statusLabel
        : 'قيد التنفيذ';

    switch (order.status) {
      case OrderStatus.pending:
        bgColor = AppColors.skyBlueLight;
        textColor = AppColors.primaryBlue;
        if (order.statusLabel.isEmpty) text = 'قيد التنفيذ';
        break;
      case OrderStatus.completed:
        bgColor = AppColors.lightGreenBg;
        textColor = AppColors.primary;
        if (order.statusLabel.isEmpty) text = 'مكتمل';
        break;
      case OrderStatus.needsData:
        bgColor = AppColors.warningOrangeLightBg;
        textColor = AppColors.warningOrangeText;
        if (order.statusLabel.isEmpty) text = 'بحاجة لبيانات';
        break;
      case OrderStatus.awaitingService:
        bgColor = AppColors.skyBlueLight;
        textColor = AppColors.primaryBlue;
        if (order.statusLabel.isEmpty) text = 'بانتظار الموعد';
        break;
      case OrderStatus.passed:
        bgColor = AppColors.lightGreenBg;
        textColor = AppColors.primary;
        if (order.statusLabel.isEmpty) text = 'ناجح';
        break;
      case OrderStatus.failed:
        bgColor = AppColors.errorRedLightBg;
        textColor = AppColors.errorRedText;
        if (order.statusLabel.isEmpty) text = 'راسب';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: textColor,
          fontSize: 14.sp,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

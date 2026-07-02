import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import '../../domain/entities/order_model.dart';

class OrderItemCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderItemCard({super.key, required this.order, required this.onTap});

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getNeonColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.awaitingService:
      case OrderStatus.needsData:
        return const Color.fromARGB(255, 255, 234, 0);
      case OrderStatus.completed:
      case OrderStatus.passed:
        return AppColors.primary;
      case OrderStatus.failed:
        return Colors.redAccent;
    }
  }

  BoxShadow _getGlowShadow(bool isDarkMode) {
    if (!isDarkMode) {
      return BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      );
    }

    final Color neonColor = _getNeonColor(widget.order.status);

    return BoxShadow(
      color: neonColor.withValues(alpha: 0.5),
      blurRadius: _glowAnimation.value,
      spreadRadius: _glowAnimation.value / 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(5.r),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.cardBg,
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                color: isDarkMode ? Colors.transparent : AppColors.greyBorder,
                width: 1.r,
              ),
              boxShadow: [_getGlowShadow(isDarkMode)],
            ),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        widget.order.title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
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
                    Flexible(
                      child: _buildStatusBadge(widget.order.status, isDarkMode),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13.r,
                      color: isDarkMode ? Colors.white70 : AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${widget.order.date} :التاريخ ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : AppColors.deepGrey,
                        fontSize: 11.sp,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: isDarkMode ? Colors.white24 : AppColors.greyBorder,
            thickness: 1.r,
            height: 1.r,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  _getActionText(widget.order.status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.primary,
                    fontSize: 14.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, bool isDarkMode) {
    Color bgColor;
    Color textColor;
    Color? borderColor;

    if (isDarkMode) {
      final neonColor = _getNeonColor(status);
      bgColor = neonColor.withValues(alpha: 0.15);
      borderColor = neonColor.withValues(alpha: 0.5);
      textColor = neonColor;
    } else {
      final colors = switch (status) {
        OrderStatus.pending => (AppColors.skyBlueLight, AppColors.primaryBlue),
        OrderStatus.completed => (AppColors.lightGreenBg, AppColors.primary),
        OrderStatus.needsData => (
          AppColors.alertOrangeLightBg,
          AppColors.alertOrangeText,
        ),
        OrderStatus.awaitingService => (
          AppColors.skyBlueLight,
          AppColors.primaryBlue,
        ),
        OrderStatus.passed => (AppColors.lightGreenBg, AppColors.primary),
        OrderStatus.failed => (AppColors.alertRedLight, AppColors.alertRed),
      };
      bgColor = colors.$1;
      textColor = colors.$2;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        widget.order.statusLabel,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.completed:
      case OrderStatus.awaitingService:
        return 'عرض التفاصيل';
      case OrderStatus.needsData:
      case OrderStatus.passed:
        return 'استكمال الطلب';
      case OrderStatus.failed:
        return 'حجز اعادة الاختبار';
    }
  }
}

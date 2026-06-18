import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/widgets/info_row_item.dart';

/// Dynamically renders a list of fee rows and highlights the total in green.
class FeesDetailsCard extends StatefulWidget {
  final FeesDetails fees;

  const FeesDetailsCard({super.key, required this.fees});

  @override
  State<FeesDetailsCard> createState() => _FeesDetailsCardState();
}

class _FeesDetailsCardState extends State<FeesDetailsCard> {
  bool _isExpanded = false;

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header (Interactive) ─────────────────────────────────────────
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الرسوم',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 20.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1.h, thickness: 1.h, color: AppColors.greyBorder),

          // ── Fee rows (Expanded only) ─────────────────────────────────────
          if (_isExpanded) ...[
            ...widget.fees.items.asMap().entries.map((entry) {
              final bool isLast = entry.key == widget.fees.items.length - 1;
              return InfoRowItem(
                label: entry.value.label,
                value: entry.value.amount,
                showDivider: !isLast,
              );
            }),
            Divider(height: 1.h, thickness: 1.h, color: AppColors.greyBorder),
          ],

          // ── Total footer ─────────────────────────────────────────────────
          _TotalFooter(total: widget.fees.total),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _TotalFooter extends StatelessWidget {
  final String total;
  const _TotalFooter({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightGreenBg,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label – right (RTL start)
          Text(
            'اجمالي الرسوم',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          // Amount – left (RTL end), highlighted in green
          Flexible(
            child: Text(
              total,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


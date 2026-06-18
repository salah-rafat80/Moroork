import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single labelled row used inside info cards (e.g. licence details card).
///
/// Layout (RTL):
///   [value widget]  ←—————————→  [label text]
///
/// An optional [Divider] is rendered below unless [showDivider] is false.
class InfoRowItem extends StatelessWidget {
  /// The right-aligned label (e.g. 'نوع الرخصة').
  final String label;

  /// Optional plain-text value. Mutually exclusive with [valueWidget].
  final String? value;

  /// Optional widget override for the value slot (e.g. a status badge).
  /// Takes precedence over [value] when provided.
  final Widget? valueWidget;

  /// Whether to render a divider below the row. Defaults to `true`.
  final bool showDivider;

  const InfoRowItem({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.showDivider = true,
  }) : assert(
         value != null || valueWidget != null,
         'Provide either value or valueWidget.',
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Label (right in RTL) ──────────────────────────────────────
              Flexible(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // ── Value (left in RTL) ───────────────────────────────────────
              Flexible(
                flex: 3,
                child:
                    valueWidget ??
                    Text(
                      value!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: AppColors.greyBorder,
            indent: 16.w,
            endIndent: 16.w,
          ),
      ],
    );
  }
}

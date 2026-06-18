import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/Radio_dot.dart';

/// A tappable option card used on selection screens.
///
/// Renders a rounded card with:
/// - a [RadioDot] on the leading (left in RTL) side showing selection state.
/// - an [icon] container on the trailing side.
/// - [title] and [subtitle] text in the center.
///
/// When [isSelected] is `true` the card border turns green [AppColors.primary]
/// and the [RadioDot] shows a filled green inner circle.
/// When `false` the border is grey [AppColors.greyBorder] and the dot is empty.
class SelectionOptionCard extends StatelessWidget {
  /// Primary label, e.g. "بدل فاقد"
  final String title;

  /// Secondary label, e.g. "استبدال الرخصة المفقودة"
  final String subtitle;

  /// Icon widget rendered inside a rounded grey container on the trailing side.
  final Widget icon;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// Callback fired when the user taps the card.
  final VoidCallback onTap;

  const SelectionOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  // ── Colours ──────────────────────────────────────────────────────────────
  static final Color _selectedBorder = AppColors.primary;
  static final Color _unselectedBorder = AppColors.greyBorder;
  static final Color _cardBackground = AppColors.cardBg;
  static final Color _iconBackground = AppColors.extraLightGrey;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          decoration: ShapeDecoration(
            color: _cardBackground,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: isSelected ? 1.5.w : 1.w,
                color: isSelected ? _selectedBorder : _unselectedBorder,
              ),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              // RTL: radio on right, icon container on left
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Radio dot (leading in RTL = right side) ──────────────────
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: ShapeDecoration(
                    color: _iconBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: Center(child: icon),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                RadioDot(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

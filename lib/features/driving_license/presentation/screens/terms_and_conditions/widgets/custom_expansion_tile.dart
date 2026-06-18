import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A fully custom, reusable expansion tile that matches the Figma design for
/// the Terms & Conditions screen of the License Renewal flow.
///
/// **Visual anatomy (RTL layout):**
/// ```
/// ┌──────────────────────────────────────────┐
/// │ [chevron ↓]  [title]              [icon] │  ← header row
/// │──────────────────────────────────────────│  ← separator
/// │  [content text — shown when expanded]    │  ← animated body
/// └──────────────────────────────────────────┘
/// ```
///
/// ### Usage
/// ```dart
/// CustomExpansionTile(
///   title: 'الأهلية العامة',
///   content: 'الخدمة متاحة فقط للمركبات...',
///   icon: Image.asset('assets/icon_eligibility.png', width: 28.w),
/// )
/// ```
class CustomExpansionTile extends StatefulWidget {
  /// The section title displayed in the header row.
  final String title;

  /// The body text revealed when the tile is expanded.
  final String content;

  /// An icon widget shown on the right side of the header (RTL).
  /// Typically an [Image] or [Icon].
  final Widget icon;

  /// Whether this tile starts in the expanded state.
  final bool initiallyExpanded;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.initiallyExpanded = false,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  // ── Animation ────────────────────────────────────────────────────────────

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotateAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Chevron rotates 0° (pointing down) → 180° (pointing up) when expanded.
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Interaction ──────────────────────────────────────────────────────────

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          // Background transitions from transparent → light grey when expanded.
          color: Color.lerp(
            Colors.transparent,
            AppColors.dividerLight,
            _expandAnimation.value,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header row ───────────────────────────────────────────────
              GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // Icon container on the far right (RTL)
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.extraLightGrey,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(child: widget.icon),
                      ),

                      SizedBox(width: 10.w),

                      // Title — grows to fill remaining space
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Animated chevron on the far left (RTL)
                      RotationTransition(
                        turns: _rotateAnimation,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24.r,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Animated content body ────────────────────────────────────
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 16.w,
                    left: 16.w,
                    bottom: 16.h,
                  ),
                  child: Text(
                    widget.content,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 12.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

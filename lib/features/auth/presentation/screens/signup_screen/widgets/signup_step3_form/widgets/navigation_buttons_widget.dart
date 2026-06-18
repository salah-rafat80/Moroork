import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationButtonsWidget extends StatefulWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final bool isValid;
  final double buttonHeight;
  final bool isLoading;

  const NavigationButtonsWidget({
    super.key,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.isValid,
    required this.buttonHeight,
    this.isLoading = false,
  });

  @override
  State<NavigationButtonsWidget> createState() => _NavigationButtonsWidgetState();
}

class _NavigationButtonsWidgetState extends State<NavigationButtonsWidget> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(covariant NavigationButtonsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
      } else {
        _hideOverlay();
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),
          const Center(
            child: CustomLoadingIndicator(
              width: 180,
              height: 180,
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isClickable = widget.isValid && !widget.isLoading;
    return Row(
      children: [
        // Next button
        Expanded(
          child: InkWell(
            onTap: isClickable ? widget.onNextPressed : null,
            child: Container(
              height: widget.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: isClickable
                    ? AppColors.primary
                    : AppColors.mutedGrey,
              ),
              child: Center(
                child: Text(
                  'التالي',
                  style: TextStyle(
                    color: widget.isLoading ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Previous button
        Expanded(
          child: SizedBox(
            height: widget.buttonHeight,
            child: OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onPreviousPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'السابق',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

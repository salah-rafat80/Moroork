import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NextButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isValid;
  final double height;
  final bool isLoading;
  final String label;

  const NextButtonWidget({
    super.key,
    required this.onPressed,
    required this.isValid,
    required this.height,
    this.isLoading = false,
    this.label = 'التالي',
  });

  @override
  State<NextButtonWidget> createState() => _NextButtonWidgetState();
}

class _NextButtonWidgetState extends State<NextButtonWidget> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(covariant NextButtonWidget oldWidget) {
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
    return InkWell(
      onTap: isClickable ? widget.onPressed : null,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: isClickable ? AppColors.primary : AppColors.mutedGrey,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isLoading ? Colors.white.withValues(alpha: 0.5) : Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable primary action button with consistent styling.
/// Used across the app for main actions like "التالي", "حفظ", etc.
class PrimaryButton extends StatefulWidget {
  /// The button label text
  final String label;

  /// Callback invoked when the button is pressed
  final VoidCallback? onPressed;

  /// Optional custom background color (defaults to green #2E7D32)
  final Color? backgroundColor;

  /// Optional custom text color (defaults to white)
  final Color? textColor;

  /// Optional custom disabled background color (defaults to grey #BDBDBD)
  final Color? disabledBackgroundColor;

  /// Optional custom disabled text color (defaults to white70)
  final Color? disabledTextColor;

  /// Optional custom height (defaults to 52.h)
  final double? height;

  /// Optional custom font size (defaults to 17.sp)
  final double? fontSize;

  /// Whether the button is currently in a loading state
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.height,
    this.fontSize,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(covariant PrimaryButton oldWidget) {
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
          // Fully transparent touch-absorbing background
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
    final bool isEnabled = widget.onPressed != null;
    final Color currentBackgroundColor = isEnabled
        ? (widget.backgroundColor ?? AppColors.primary)
        : (widget.disabledBackgroundColor ?? AppColors.mutedGrey);
    final Color currentTextColor = isEnabled
        ? (widget.textColor ?? Colors.white)
        : (widget.disabledTextColor ?? Colors.white70);

    return InkWell(
      onTap: widget.isLoading ? null : widget.onPressed,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        height: widget.height ?? 52.h,
        decoration: BoxDecoration(
          color: currentBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: widget.fontSize ?? 18.sp,
                fontWeight: FontWeight.w600,
                color: widget.isLoading ? currentTextColor.withValues(alpha: 0.5) : currentTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

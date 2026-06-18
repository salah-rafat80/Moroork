import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A circular shutter button used to capture a photo.
///
/// Displays a camera icon in its idle state and a [CircularProgressIndicator]
/// while [isCapturing] is true.
class CameraCaptureButton extends StatelessWidget {
  /// Whether a capture is currently in progress.
  final bool isCapturing;

  /// Callback invoked when the button is tapped.
  final VoidCallback onTap;

  const CameraCaptureButton({
    super.key,
    required this.isCapturing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isCapturing
            ? Padding(
                padding: EdgeInsets.all(18.w),
                child: const CustomLoadingIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(Icons.camera_alt, size: 30.w, color: Colors.white),
      ),
    );
  }
}

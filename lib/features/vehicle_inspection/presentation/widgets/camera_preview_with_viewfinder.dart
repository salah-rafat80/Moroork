import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/viewfinder_painter.dart';

/// The main camera preview area with a viewfinder-bracket overlay.
///
/// Accepts the [CameraController] and renders:
/// - A loading placeholder while the camera initialises.
/// - An error placeholder when [errorMessage] is non-null.
/// - The live [CameraPreview] once ready.
class CameraPreviewWithViewfinder extends StatelessWidget {
  /// Null until the camera is ready.
  final CameraController? cameraController;

  /// True once [cameraController] has been fully initialised.
  final bool isCameraInitialized;

  /// Non-null when camera initialisation failed.
  final String? errorMessage;

  const CameraPreviewWithViewfinder({
    super.key,
    required this.cameraController,
    required this.isCameraInitialized,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPreviewContent(),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CustomPaint(
                    painter: ViewfinderPainter(
                      strokeWidth: 3.5,
                      cornerLength: 35.w,
                      cornerRadius: 14.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (errorMessage != null) {
      return Container(
        color: AppColors.lightGreyBg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 50.w,
                color: AppColors.chatBgDark,
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14.sp,
                    color: AppColors.inputHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isCameraInitialized || cameraController == null) {
      return Container(
        color: AppColors.lightGreyBg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CustomLoadingIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'جاري تشغيل الكاميرا...',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14.sp,
                  color: AppColors.inputHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(cameraController!);
  }
}

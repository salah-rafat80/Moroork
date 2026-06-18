import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/captured_image_preview.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_analyze_button.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_retake_button.dart';

/// Screen 3 — Preview / Analysis screen.
///
/// Displays the captured vehicle image and offers two actions:
/// "تحليل المركبة" (Analyze) and "اعادة التصوير" (Retake).
class VehicleInspectionPreviewScreen extends StatefulWidget {
  final String imagePath;

  const VehicleInspectionPreviewScreen({super.key, required this.imagePath});

  @override
  State<VehicleInspectionPreviewScreen> createState() =>
      _VehicleInspectionPreviewScreenState();
}

class _VehicleInspectionPreviewScreenState
    extends State<VehicleInspectionPreviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ServiceScreenAppBar(
            title: 'فحص المركبة بالذكاء الاصطناعي',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(height: 5.h),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // ── Captured image preview ──
                  CapturedImagePreview(imagePath: widget.imagePath),

                  SizedBox(height: 24.h),

                  // ── Analyze button ──
                  InspectionAnalyzeButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'جاري تحليل المركبة...',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  // ── Retake button ──
                  InspectionRetakeButton(
                    onPressed: () => Navigator.pop(context),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

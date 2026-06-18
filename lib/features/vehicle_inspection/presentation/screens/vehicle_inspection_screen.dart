import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/vehicle_inspection/presentation/screens/vehicle_inspection_camera_screen.dart';
import 'package:traffic/features/vehicle_inspection/presentation/screens/vehicle_inspection_preview_screen.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_bullet_point.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_camera_icon_card.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_start_button.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_upload_button.dart';

/// Screen 1 — Landing / Start screen for AI vehicle inspection.
///
/// Shows a camera-icon card, three feature bullet points, and buttons to
/// EITHER start the camera OR pick a photo from the gallery.
class VehicleInspectionScreen extends StatefulWidget {
  const VehicleInspectionScreen({super.key});

  @override
  State<VehicleInspectionScreen> createState() =>
      _VehicleInspectionScreenState();
}

class _VehicleInspectionScreenState extends State<VehicleInspectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _pickImageFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.path == null) return;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleInspectionPreviewScreen(imagePath: file.path!),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء اختيار الصورة. يرجى المحاولة مجدداً.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13.sp,
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

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

                  // ── Camera icon card ──
                  const InspectionCameraIconCard(),

                  SizedBox(height: 32.h),

                  // ── Feature bullet points ──
                  const InspectionBulletPoint(
                    text: 'صوّر سيارتك أو ارفع صورة للحصول على تقرير فوري عن حالتها.',
                  ),
                  SizedBox(height: 16.h),
                  const InspectionBulletPoint(
                    text: 'اكتشف أي مشاكل محتملة قبل الذهاب للمرور.',
                  ),
                  SizedBox(height: 16.h),
                  const InspectionBulletPoint(
                    text: 'فحص سريع وبسيط لتتأكد أن سيارتك جاهزة وآمنة.',
                  ),

                  const Spacer(),

                  // ── Start inspection button ──
                  InspectionStartButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleInspectionCameraScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  // ── Upload from gallery button ──
                  InspectionUploadButton(
                    onPressed: _pickImageFromGallery,
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


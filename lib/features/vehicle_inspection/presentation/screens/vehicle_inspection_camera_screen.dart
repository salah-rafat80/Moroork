import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/vehicle_inspection/presentation/screens/vehicle_inspection_preview_screen.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/camera_capture_button.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/camera_guidance_chip.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/camera_preview_with_viewfinder.dart';

/// Screen 2 — In-app camera screen with live preview.
///
/// Shows a live camera feed with viewfinder corner brackets overlay,
/// a guidance message, and a capture button.
class VehicleInspectionCameraScreen extends StatefulWidget {
  const VehicleInspectionCameraScreen({super.key});

  @override
  State<VehicleInspectionCameraScreen> createState() =>
      _VehicleInspectionCameraScreenState();
}

class _VehicleInspectionCameraScreenState
    extends State<VehicleInspectionCameraScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      setState(() {
        _isCameraInitialized = false;
        _cameraController = null;
      });
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'لا توجد كاميرا متاحة على هذا الجهاز');
        return;
      }

      // Use the back camera
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر فتح الكاميرا. تأكد من منح الإذن.';
        });
      }
    }
  }

  Future<void> _captureImage() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await controller.takePicture();

      // Save to a permanent path
      final dir = await getTemporaryDirectory();
      final fileName = 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = p.join(dir.path, fileName);
      await photo.saveTo(savedPath);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VehicleInspectionPreviewScreen(imagePath: savedPath),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'حدث خطأ أثناء التقاط الصورة. حاول مرة أخرى.',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Camera preview with viewfinder overlay ──
                CameraPreviewWithViewfinder(
                  cameraController: _cameraController,
                  isCameraInitialized: _isCameraInitialized,
                  errorMessage: _errorMessage,
                ),

                SizedBox(height: 20.h),

                // ── Guidance text ──
                const CameraGuidanceChip(
                  message: 'تأكد من ظهور المركبة بالكامل',
                ),

                const Spacer(flex: 2),

                // ── Camera capture button ──
                CameraCaptureButton(
                  isCapturing: _isCapturing,
                  onTap: _captureImage,
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

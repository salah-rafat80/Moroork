import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/vehicle_inspection/data/repositories/inspection_repository.dart';
import 'package:traffic/features/vehicle_inspection/presentation/cubits/inspection_cubit.dart';
import 'package:traffic/features/vehicle_inspection/presentation/screens/vehicle_inspection_result_screen.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/captured_image_preview.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_analyze_button.dart';
import 'package:traffic/features/vehicle_inspection/presentation/widgets/inspection_retake_button.dart';

/// Screen 3 — Preview / Analysis screen.
///
/// Displays the captured vehicle image and offers two actions:
/// "تحليل المركبة" (Analyze) and "اعادة التصوير" (Retake).
class VehicleInspectionPreviewScreen extends StatelessWidget {
  final String imagePath;

  const VehicleInspectionPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InspectionCubit(InspectionRepositoryImpl()),
      child: _VehicleInspectionPreviewView(imagePath: imagePath),
    );
  }
}

class _VehicleInspectionPreviewView extends StatefulWidget {
  final String imagePath;
  const _VehicleInspectionPreviewView({required this.imagePath});

  @override
  State<_VehicleInspectionPreviewView> createState() =>
      _VehicleInspectionPreviewViewState();
}

class _VehicleInspectionPreviewViewState
    extends State<_VehicleInspectionPreviewView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showErrorBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: 20.h + MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Warning Icon Container
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.alertRedLightBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.alertRedBorder,
                    width: 1.5.w,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.alertRedBg,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'فشل فحص الصورة الذكي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              // Error Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: AppColors.charcoal,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Tips card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.lightGreyBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'نصائح لالتقاط صورة مقبولة:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTipRow('تأكد من تصوير السيارة بالكامل داخل إطار الصورة.'),
                    SizedBox(height: 6.h),
                    _buildTipRow('التقط الصورة في إضاءة جيدة وتجنب التظليل القوي.'),
                    SizedBox(height: 6.h),
                    _buildTipRow('يجب أن تكون السيارة واضحة وبدون اهتزاز أو تغبيش.'),
                    SizedBox(height: 6.h),
                    _buildTipRow('تأكد من عدم رفع صور مستندات أو لافتات أو أشخاص.'),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext); // Close sheet
                        Navigator.pop(context); // Close preview screen to retake/reselect
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary, width: 1.5.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'إعادة تصوير',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext); // Close sheet
                        context.read<InspectionCubit>().analyzeVehicle(widget.imagePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipRow(String tip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            tip,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InspectionCubit, InspectionState>(
      listener: (context, state) {
        if (state is InspectionSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VehicleInspectionResultScreen(result: state.result),
            ),
          );
        } else if (state is InspectionFailure) {
          _showErrorBottomSheet(context, state.message);
        }
      },
      child: BlocBuilder<InspectionCubit, InspectionState>(
        builder: (context, state) {
          final isLoading = state is InspectionLoading;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            drawer: const AppDrawer(),
            body: Column(
              children: [
                ServiceScreenAppBar(
                  title: 'فحص المركبة بالذكاء الاصطناعي',
                  onMenuPressed: () =>
                      _scaffoldKey.currentState?.openDrawer(),
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

                        SizedBox(height: 16.h),

                        // ── File size info ──
                        _FileSizeInfo(imagePath: widget.imagePath),

                        SizedBox(height: 24.h),

                        // ── Analyze button ──
                        isLoading
                            ? _LoadingAnalyzeWidget()
                            : InspectionAnalyzeButton(
                                onPressed: () {
                                  context
                                      .read<InspectionCubit>()
                                      .analyzeVehicle(widget.imagePath);
                                },
                              ),

                        SizedBox(height: 12.h),

                        // ── Retake button (disabled while loading) ──
                        if (!isLoading)
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
        },
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _FileSizeInfo extends StatelessWidget {
  final String imagePath;
  const _FileSizeInfo({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final sizeKb = (File(imagePath).lengthSync() / 1024).toStringAsFixed(0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 14.r, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          'حجم الصورة: $sizeKb KB',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LoadingAnalyzeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'جاري تحليل المركبة...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

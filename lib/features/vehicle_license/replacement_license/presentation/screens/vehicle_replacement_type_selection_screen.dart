import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import '../widgets/selection_option_card.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import 'vehicle_delivery_method_screen.dart';

enum VehicleReplacementType { lost, damaged }

class VehicleReplacementTypeSelectionScreen extends StatefulWidget {
  final VehicleLicenseModel vehicle;

  const VehicleReplacementTypeSelectionScreen({super.key, required this.vehicle});

  @override
  State<VehicleReplacementTypeSelectionScreen> createState() =>
      _VehicleReplacementTypeSelectionScreenState();
}

class _VehicleReplacementTypeSelectionScreenState
    extends State<VehicleReplacementTypeSelectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VehicleReplacementType? selectedType;

  void _onOptionTap(VehicleReplacementType type) {
    setState(() => selectedType = type);
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDeliveryMethodScreen(
          vehicle: widget.vehicle,
          replacementType: selectedType!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ServiceScreenAppBar(
            title: 'اصدار بدل فاقد / تالف رخصة مركبة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'نوع طلب الاستبدال',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SelectionOptionCard(
                    title: 'بدل فاقد',
                    subtitle: 'استبدال رخصة المركبة المفقودة',
                    isSelected: selectedType == VehicleReplacementType.lost,
                    onTap: () => _onOptionTap(VehicleReplacementType.lost),
                    icon: SvgPicture.asset(
                      'assets/file.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: 'بدل تالف',
                    subtitle: 'استبدال رخصة المركبة التالفة',
                    isSelected: selectedType == VehicleReplacementType.damaged,
                    onTap: () => _onOptionTap(VehicleReplacementType.damaged),
                    icon: SvgPicture.asset(
                      'assets/file.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: PrimaryButton(
              label: 'التالي',
              onPressed: selectedType != null ? _onNextPressed : null,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import '../widgets/vehicle_license_card.dart';
import 'vehicle_replacement_type_selection_screen.dart';

class VehicleLicenseDetailsScreen extends StatefulWidget {
  final VehicleLicenseModel vehicle;

  const VehicleLicenseDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleLicenseDetailsScreen> createState() =>
      _VehicleLicenseDetailsScreenState();
}

class _VehicleLicenseDetailsScreenState
    extends State<VehicleLicenseDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNextPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VehicleReplacementTypeSelectionScreen(vehicle: widget.vehicle),
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
                    'تفاصيل رخصة المركبة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  VehicleLicenseCard(
                    vehicle: widget.vehicle,
                    isSelected: true,
                    showRadioDot: false,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: PrimaryButton(
              label: 'التالي',
              onPressed: () => _onNextPressed(context),
              height: 48.h,
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

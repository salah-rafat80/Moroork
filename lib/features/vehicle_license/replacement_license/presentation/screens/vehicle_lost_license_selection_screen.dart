import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/empty_state_widget.dart';
import 'package:traffic/features/vehicle_license/data/repositories/vehicle_license_repository.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import 'package:traffic/features/violations_inquiry/data/repositories/violations_repository.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/data/models/vehicle_license_violation_model.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/presentation/screens/vehicle_violations_list_screen.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import '../widgets/vehicle_license_card.dart';
import 'vehicle_license_details_screen.dart';
import 'package:traffic/injection_container.dart';

class VehicleLostLicenseSelectionScreen extends StatefulWidget {
  const VehicleLostLicenseSelectionScreen({super.key});

  @override
  State<VehicleLostLicenseSelectionScreen> createState() =>
      _VehicleLostLicenseSelectionScreenState();
}

class _VehicleLostLicenseSelectionScreenState
    extends State<VehicleLostLicenseSelectionScreen> {
  int? _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<VehicleLicenseModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = getIt<VehicleLicenseRepository>();
      final violationsRepo = getIt<ViolationsRepository>();

      // Fetch fresh from API directly
      final result = await repository.getMyLicenses();
      if (result.isSuccess && result.data != null) {
        final List<VehicleLicenseModel> licenses = result.data!;
        final List<VehicleLicenseModel> updatedLicenses = [];

        for (final license in licenses) {
          bool hasUnpaid = license.hasUnpaidViolations;
          try {
            final violationsResult = await violationsRepo.getVehicleLicenseViolations(
              licenseNumber: license.vehicleLicenseNumber,
            );
            if (violationsResult.isSuccess && violationsResult.data != null) {
              hasUnpaid = violationsResult.data!.violations.any((v) => !v.isPaid);
            }
          } catch (_) {
            // fallback if fetch fails
          }
          updatedLicenses.add(license.copyWith(hasUnpaidViolations: hasUnpaid));
        }

        if (mounted) {
          setState(() {
            _vehicles = updatedLicenses;
            _isLoading = false;
            
            // Auto-select if there is exactly 1 vehicle that is not restricted and has no unpaid violations
            if (_vehicles.length == 1) {
              final firstModel = _vehicles[0];
              final isRestricted = firstModel.status == LicenseStatus.suspended || firstModel.status == LicenseStatus.withdrawn;
              if (!isRestricted && !firstModel.hasUnpaidViolations) {
                _selectedIndex = 0;
              } else {
                _selectedIndex = null;
              }
            } else {
              _selectedIndex = null;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = result.error ?? 'فشل تحميل الرخص';
            _selectedIndex = null;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ غير متوقع';
          _selectedIndex = null;
        });
      }
    }
  }

  String _formatVehicleType(String category, String brand, String model) {
    final cleanCategory = category.trim();
    final cleanBrand = brand.trim();
    final cleanModel = model.trim();

    final brandModel = [cleanBrand, cleanModel]
        .where((s) => s.isNotEmpty)
        .join(' ');

    if (cleanCategory.isNotEmpty && brandModel.isNotEmpty) {
      return '$cleanCategory - $brandModel';
    } else if (cleanCategory.isNotEmpty) {
      return cleanCategory;
    } else {
      return brandModel;
    }
  }

  VehicleLicenseModel? get _selectedVehicle => _selectedIndex != null
      ? _vehicles[_selectedIndex!]
      : null;

  bool get _canProceed {
    final lic = _selectedVehicle;
    if (lic == null) return false;
    final isRestricted = lic.status == LicenseStatus.suspended || lic.status == LicenseStatus.withdrawn;
    return !isRestricted && !lic.hasUnpaidViolations;
  }

  void _onNextPressed() {
    if (_selectedVehicle == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleLicenseDetailsScreen(vehicle: _selectedVehicle!),
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
            child: _isLoading
                ? const Center(child: CustomLoadingIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40.h),
                            Icon(
                              _errorMessage!.contains('اتصال')
                                  ? Icons.wifi_off_rounded
                                  : Icons.error_outline_rounded,
                              size: 64.r,
                              color: AppColors.redError,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyGrey,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              onPressed: _loadVehicles,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                'إعادة المحاولة',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                  ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      )
                    : _vehicles.isEmpty
                        ? const EmptyStateWidget(
                            message: 'لا توجد رخص مركبات مسجلة حالياً',
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 16.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                      ..._vehicles.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final license = entry.value;
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 12.h),
                                          child: VehicleLicenseCard(
                                            vehicle: license,
                                            isSelected: _selectedIndex == index,
                                            onTap: () => setState(() =>
                                                _selectedIndex = index),
                                            onShowViolations: () {
                                              final violationModel =
                                                  VehicleLicenseViolationModel(
                                                id: license.id,
                                                vehicleLicenseNumber: license
                                                    .vehicleLicenseNumber,
                                                plateNumber: license
                                                        .plateNumber ??
                                                    license
                                                        .vehicleLicenseNumber,
                                                vehicleType: _formatVehicleType(
                                                    license.category,
                                                    license.brand,
                                                    license.model),
                                                brand: license.brand,
                                                model: license.model,
                                                status: license.status,
                                                issueDate: license.issueDate,
                                                expiryDate: license.expiryDate,
                                                hasUnpaidViolations: license
                                                    .hasUnpaidViolations,
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VehicleViolationsListScreen(
                                                    vehicle: violationModel,
                                                  ),
                                                ),
                                              ).then((_) => _loadVehicles());
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16.w, 8.h, 16.w, 24.h),
                                child: PrimaryButton(
                                  label: 'التالي',
                                  onPressed:
                                      _canProceed ? _onNextPressed : null,
                                  height: 48.h,
                                  backgroundColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

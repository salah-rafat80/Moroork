import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/empty_state_widget.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import 'package:traffic/features/vehicle_license/data/repositories/vehicle_license_repository.dart';
import 'package:traffic/features/violations_inquiry/data/repositories/violations_repository.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/data/models/vehicle_license_violation_model.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/presentation/screens/vehicle_violations_list_screen.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import '../../data/models/renewal_vehicle_license_model.dart';
import '../widgets/renewal_vehicle_license_card.dart';
import 'vehicle_technical_inspection_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubits/vehicle_renewal_cubit.dart';
import '../../../presentation/cubits/vehicle_renewal_state.dart';
import 'package:traffic/core/widgets/loading_overlay.dart';
import 'package:traffic/injection_container.dart';

/// Step 2 – Vehicle selection screen.
/// Loads real data from GET /VehicleLicense/my-licenses using cache-first strategy.
class RenewalVehicleSelectionScreen extends StatefulWidget {
  const RenewalVehicleSelectionScreen({super.key});

  @override
  State<RenewalVehicleSelectionScreen> createState() =>
      _RenewalVehicleSelectionScreenState();
}

class _RenewalVehicleSelectionScreenState
    extends State<RenewalVehicleSelectionScreen> {
  int? _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<VehicleLicenseModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
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
            // fallback to model status if fetch fails
          }
          updatedLicenses.add(license.copyWith(hasUnpaidViolations: hasUnpaid));
        }

        if (mounted) {
          setState(() {
            _vehicles = updatedLicenses;
            _isLoading = false;
            if (_vehicles.length == 1) {
              final firstModel = _toRenewalModel(_vehicles[0]);
              if (firstModel.canRenew) {
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
            _selectedIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error ?? 'فشل تحميل الرخص')),
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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

  /// Maps VehicleLicenseModel status to RenewalLicenseStatus for the card widget.
  RenewalVehicleLicenseModel _toRenewalModel(VehicleLicenseModel v) {
    RenewalLicenseStatus renewalStatus;
    switch (v.status) {
      case LicenseStatus.expired:
        renewalStatus = RenewalLicenseStatus.expired;
        break;
      case LicenseStatus.withdrawn:
        renewalStatus = RenewalLicenseStatus.withdrawn;
        break;
      case LicenseStatus.suspended:
        renewalStatus = RenewalLicenseStatus.suspended;
        break;
      default:
        renewalStatus = RenewalLicenseStatus.valid;
    }
    return RenewalVehicleLicenseModel(
      plateNumber: (v.plateNumber != null && v.plateNumber!.isNotEmpty) ? v.plateNumber! : v.vehicleLicenseNumber,
      vehicleType: _formatVehicleType(v.category, v.brand, v.model),
      expiryDate: v.expiryDate,
      status: renewalStatus,
      hasUnpaidViolations: v.hasUnpaidViolations,
    );
  }

  RenewalVehicleLicenseModel? get _selectedModel =>
      _selectedIndex != null ? _toRenewalModel(_vehicles[_selectedIndex!]) : null;

  bool get _canProceed => _selectedModel?.canRenew ?? false;

  void _onNextPressed(BuildContext context) {
    if (_selectedIndex == null) return;
    final license = _vehicles[_selectedIndex!];
    context.read<VehicleRenewalCubit>().renewVehicleLicense(
          licenseNumber: license.vehicleLicenseNumber,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VehicleRenewalCubit>(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<VehicleRenewalCubit, VehicleRenewalState>(
            listener: (context, state) {
              if (state is VehicleRenewalSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<VehicleRenewalCubit>(),
                      child: VehicleTechnicalInspectionScreen(
                        vehicle: _selectedModel!,
                        requestNumber: state.response.requestNumber,
                        successMessage: state.response.message,
                      ),
                    ),
                  ),
                );
              } else if (state is VehicleRenewalFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, textDirection: TextDirection.rtl),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return LoadingOverlay(
                isLoading: state is VehicleRenewalLoading,
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: AppColors.lightGreyBg,
                  drawer: const AppDrawer(),
                  body: Column(
                    children: [
                      ServiceScreenAppBar(
                        title: 'تجديد رخصة مركبة',
                        onMenuPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CustomLoadingIndicator())
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
                                              ..._vehicles
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final index = entry.key;
                                                final model =
                                                    _toRenewalModel(
                                                        entry.value);
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 12.h),
                                                  child:
                                                      RenewalVehicleLicenseCard(
                                                    vehicle: model,
                                                    isSelected:
                                                        _selectedIndex == index,
                                                    onTap: model.canRenew
                                                        ? () => setState(() =>
                                                            _selectedIndex =
                                                                index)
                                                        : null,
                                                    onShowViolations: () {
                                                      final license =
                                                          entry.value;
                                                      final violationModel =
                                                          VehicleLicenseViolationModel(
                                                        id: license.id,
                                                        vehicleLicenseNumber:
                                                            license
                                                                .vehicleLicenseNumber,
                                                        plateNumber: license
                                                                .plateNumber ??
                                                            license
                                                                .vehicleLicenseNumber,
                                                        vehicleType:
                                                            _formatVehicleType(
                                                                license
                                                                    .category,
                                                                license.brand,
                                                                license.model),
                                                        brand: license.brand,
                                                        model: license.model,
                                                        status: license.status,
                                                        issueDate:
                                                            license.issueDate,
                                                        expiryDate:
                                                            license.expiryDate,
                                                        hasUnpaidViolations:
                                                            license
                                                                .hasUnpaidViolations,
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              VehicleViolationsListScreen(
                                                            vehicle:
                                                                violationModel,
                                                          ),
                                                        ),
                                                      ).then((_) =>
                                                          _loadVehicles());
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
                                          onPressed: _canProceed
                                              ? () => _onNextPressed(context)
                                              : null,
                                          height: 48.h,
                                          backgroundColor: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

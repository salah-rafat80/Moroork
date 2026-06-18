import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/generic_document_upload_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_cubit.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_state.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/vehicle_inspection_booking_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_renewal_cubit.dart';
import 'package:traffic/injection_container.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_type_model.dart';
import '../widgets/insurance_company_card.dart';

class VehicleInsuranceScreen extends StatefulWidget {
  final List<DocumentItemModel> documents;
  final Map<String, String> selectedDropdowns;

  const VehicleInsuranceScreen({
    super.key,
    required this.documents,
    required this.selectedDropdowns,
  });

  @override
  State<VehicleInsuranceScreen> createState() => _VehicleInsuranceScreenState();
}

class _VehicleInsuranceScreenState extends State<VehicleInsuranceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? _selectedCompanyIndex;
  List<InsuranceCompanyModel> _companies = const [];

  @override
  void initState() {
    super.initState();
    context.read<VehicleLicenseCubit>().fetchInsuranceCompanies();
  }

  void _onNextPressed() {
    FocusScope.of(context).unfocus();

    if (_selectedCompanyIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار شركة التأمين أولاً',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedCompany = _companies[_selectedCompanyIndex!];
    final companyId = selectedCompany.id.toString();

    // Map documents by index (matches the order defined in VehicleLicenseScreen)
    // [0] OwnershipProof, [1] VehicleDataCertificate, [2] IdCard,
    // [3] CustomClearance (optional), [4] InsuranceCertificate (optional)
    final docs = widget.documents;
    final ownershipPath = docs.isNotEmpty ? docs[0].filePath ?? '' : '';
    final vehicleDataPath = docs.length > 1 ? docs[1].filePath ?? '' : '';
    final idCardPath = docs.length > 2 ? docs[2].filePath ?? '' : '';
    final customClearancePath = docs.length > 3 ? docs[3].filePath : null;
    final insuranceCertPath = docs.length > 4 ? docs[4].filePath : null;

    // The API requires the English enum name for VehicleType
    // (e.g. "PrivateCar", "Truck") — not the Arabic display name.
    // Look it up from the cached types list using the Arabic name the user picked.
    final cubit = context.read<VehicleLicenseCubit>();
    final selectedAr = widget.selectedDropdowns['نوع المركبة'] ?? '';
    String vehicleTypeEnum = selectedAr;

    if (cubit.cachedVehicleTypes.isNotEmpty) {
      try {
        vehicleTypeEnum = cubit.cachedVehicleTypes
            .firstWhere(
              (t) => t.displayName == selectedAr || t.name == selectedAr,
            )
            .name; // English enum name: "PrivateCar", "Truck", etc.
      } catch (_) {
        vehicleTypeEnum = selectedAr; // fallback — pass as-is
      }
    }

    // Similarly resolve brand and model to their English names.
    String brandName = widget.selectedDropdowns['الماركة'] ?? '';
    String modelName = widget.selectedDropdowns['الموديل'] ?? '';

    if (cubit.cachedVehicleTypes.isNotEmpty) {
      for (final type in cubit.cachedVehicleTypes) {
        for (final brand in type.brands) {
          if (brand.displayName == brandName || brand.name == brandName) {
            brandName = brand.name;
            for (final model in brand.models) {
              if (model.displayName == modelName || model.name == modelName) {
                modelName = model.name;
              }
            }
          }
        }
      }
    }

    cubit.uploadDocuments(
      vehicleType: vehicleTypeEnum,
      brand: brandName,
      model: modelName,
      ownershipProofPath: ownershipPath,
      vehicleDataCertificatePath: vehicleDataPath,
      idCardPath: idCardPath,
      insuranceCompanyId: companyId,
      customClearancePath: customClearancePath,
      insuranceCertificatePath: insuranceCertPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleLicenseCubit, VehicleLicenseState>(
      listener: (context, state) {
        if (state is VehicleLicenseInsuranceLoaded) {
          setState(() => _companies = state.companies);
        } else if (state is VehicleLicenseUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم رفع المستندات بنجاح. رقم الطلب: ${state.requestNumber}',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<VehicleRenewalCubit>(
                create: (_) => getIt<VehicleRenewalCubit>(),
                child: VehicleInspectionBookingScreen(requestNumber: state.requestNumber),
              ),
            ),
          );
        } else if (state is VehicleLicenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUploadLoading = state is VehicleLicenseLoading;
        final isInsuranceLoading = state is VehicleLicenseInsuranceLoading;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.lightGreyBg,
          drawer: const AppDrawer(),
          body: Column(
            children: [
              ServiceScreenAppBar(
                title: 'اصدار رخصة مركبة',
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              if (isUploadLoading)
                const Expanded(
                  child: Center(child: CustomLoadingIndicator()),
                )
              else if (isInsuranceLoading)
                const Expanded(
                  child: Center(child: CustomLoadingIndicator()),
                )
              else
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'التأمين علي المركبة',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17.sp,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'اختيار شركة التأمين',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 16.sp,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      ...List.generate(_companies.length, (index) {
                        final company = _companies[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: InsuranceCompanyCard(
                            companyName: company.displayName,
                            details: company.displayDescription,
                            logoAssetPath:
                                'assets/images/insurance_logo.png',
                            isSelected: _selectedCompanyIndex == index,
                            onTap:
                                () => setState(
                                  () => _selectedCompanyIndex = index,
                                ),
                          ),
                        );
                      }),

                      SizedBox(height: 24.h),
                      PrimaryButton(
                        onPressed: _selectedCompanyIndex != null
                            ? _onNextPressed
                            : null,
                        label: 'التالي',
                        height: 48.h,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

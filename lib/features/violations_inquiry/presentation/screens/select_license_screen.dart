import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/empty_state_widget.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_license_repository.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/violations_list_screen.dart';
import 'package:traffic/features/driving_license/presentation/screens/license_details/widgets/license_info_card.dart';
import 'package:traffic/injection_container.dart';

class SelectLicenseScreen extends StatefulWidget {
  const SelectLicenseScreen({super.key});

  @override
  State<SelectLicenseScreen> createState() => _SelectLicenseScreenState();
}

class _SelectLicenseScreenState extends State<SelectLicenseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DrivingLicenseModel> _licenses = [];
  int? _selectedIndex;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = getIt<DrivingLicenseRepository>();
      final result = await repository.getMyLicenses();
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _licenses = result.data!;
          _isLoading = false;
          if (_licenses.length == 1) {
            _selectedIndex = 0;
          } else {
            _selectedIndex = null;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? 'فشل تحميل الرخص';
          _selectedIndex = null;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ غير متوقع';
        _selectedIndex = null;
      });
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
            title: 'استعلام عن مخالفات رخصة القيادة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(height: 5.h,),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 16.h),

                  // ── Section title ──
                  Center(
                    child: Text(
                      'تفاصيل رخصة القيادة',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── License cards ──
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    Center(
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
                            onPressed: _loadLicenses,
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    )
                  else if (_licenses.isEmpty)
                    const EmptyStateWidget(
                      message: 'لا توجد رخص مسجلة حالياً',
                    )
                  else
                    ...List.generate(_licenses.length, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: LicenseInfoCard(
                            data: _licenses[index],
                            isSelected: _selectedIndex == index,
                          ),
                        ),
                      );
                    }),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Next button ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            child: PrimaryButton(
              label: 'التالي',
              onPressed: _isLoading || _licenses.isEmpty || _selectedIndex == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViolationsListScreen(
                            license: _licenses[_selectedIndex!],
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

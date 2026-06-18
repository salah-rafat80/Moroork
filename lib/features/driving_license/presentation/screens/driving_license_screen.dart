import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/core/widgets/service_list_item.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/generic_terms_screen.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_renewal_repository.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'package:traffic/features/driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_renewal_cubit.dart';
import 'package:traffic/features/driving_license/presentation/screens/license_details/license_details_screen.dart';
import 'package:traffic/features/driving_license/presentation/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:traffic/features/driving_license/presentation/screens/practical_test/practical_test_booking_screen.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/select_license_screen.dart';
import 'package:traffic/injection_container.dart';

import '../../../lost_license/presentation/screens/lost_license_selection_screen.dart';
import '../widgets/completion_warning_dialog.dart';

class DrivingLicenseScreen extends StatefulWidget {
  final bool startWithRenewal;
  const DrivingLicenseScreen({super.key, this.startWithRenewal = false});

  @override
  State<DrivingLicenseScreen> createState() => _DrivingLicenseScreenState();
}

class _DrivingLicenseScreenState extends State<DrivingLicenseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DrivingRenewalCubit _drivingRenewalCubit;
  late final DrivingLicenseRenewalDataHandler _renewalDataHandler;

  @override
  void initState() {
    super.initState();
    _renewalDataHandler = getIt<DrivingLicenseRenewalDataHandler>();
    _drivingRenewalCubit = getIt<DrivingRenewalCubit>();
    if (widget.startWithRenewal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openRenewalFlow();
      });
    }
  }

  void _openRenewalFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericTermsScreen(
          appBarTitle: 'تجديد رخصة القيادة',
          subtitle:
              'يرجى قراءة الشروط بعناية قبل متابعة التجديد.',
          disclaimer:
              'قبل المتابعة، يرجى التأكد أن المركبة تستوفي جميع الشروط المطلوبة. في حال عدم استيفاء أي شرط، لن تتمكن من إتمام التجديد إلكترونيًا.',
          termsData: const [
            TermsSection(
              title: 'الأهلية العامة',
              content:
                  'الخدمة متاحة فقط للمركبات المسجلة باسم صاحب الحساب.\nيجب أن تكون المركبة من الفئات المسموح لها بالتجديد إلكترونيًا.',
              iconData: Icons.person_outline_rounded,
            ),
            TermsSection(
              title: 'المخالفات والرسوم',
              content:
                  'يجب سداد جميع المخالفات المرورية قبل إتمام عملية التجديد.\nفي حال وجود مخالفات، سيتم توجيهك لخطوة السداد قبل المتابعة.',
              iconData: Icons.receipt_long_outlined,
            ),
            TermsSection(
              title: 'التأمين والفحص الفني',
              content:
                  'يشترط وجود تأمين إلزامي ساري المفعول.\nقد يتطلب الفحص الفني حسب سنة الصنع أو حالة المركبة.',
              iconData: Icons.verified_user_outlined,
            ),
            TermsSection(
              title: 'حالات تمنع التجديد الإلكتروني',
              content:
                  'لا يمكن التجديد إلكترونيًا إذا كانت الرخصة مسحوبة أو موقوفة.\nلا يمكن التجديد في حالة وجود أمر قضائي أو حجز على المركبة.\nفي حالة عدم تطابق بيانات المالك، يلزم التوجه إلى وحدة المرور.',
              iconData: Icons.receipt_outlined,
            ),
            TermsSection(
              title: 'الاستلام والتوصيل',
              content:
                  'يمكنك اختيار استلام الرخصة من وحدة المرور أو طلب توصيلها للعنوان.\nرسوم التوصيل تُحتسب حسب المحافظة والعنوان.',
              iconData: Icons.local_shipping_outlined,
            ),
          ],
          onNextPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LicenseDetailsScreen(
                  onNextWithSelectedLicense:
                      _submitRenewalAfterLicenseSelection,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _drivingRenewalCubit.close();
    super.dispose();
  }

  Future<void> _completeRenewalAfterBooking({
    required BookingFlowData bookingData,
    required String renewalRequestNumber,
  }) async {
    if (!mounted) {
      return;
    }

    final String appointmentReference =
        bookingData.requestNumber ?? bookingData.bookingNumber ?? '-';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ موعدك بنجاح. رقم طلب التجديد: $renewalRequestNumber - مرجع الموعد: $appointmentReference',
          textDirection: TextDirection.rtl,
        ),
      ),
    );

    await CompletionWarningDialog.show(context);
  }

  Future<void> _submitRenewalAfterLicenseSelection(
    DrivingLicenseModel selectedLicense,
  ) async {
    final String selectedLicenseNumber = selectedLicense.drivingLicenseNumber
        .trim();
    if (selectedLicenseNumber.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحديد رقم الرخصة المختارة.',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    await _drivingRenewalCubit.submitRenewalRequestFromUi(
      isTermsAccepted: true,
      selectedLicenseNumber: selectedLicenseNumber,
      selectedGovernorate: selectedLicense.governorate,
      selectedTrafficUnit: selectedLicense.licensingUnit,
      selectedAppointmentDate: null,
      selectedAppointmentSlot: null,
    );

    if (!mounted) {
      return;
    }

    final DrivingRenewalState state = _drivingRenewalCubit.state;
    if (state is DrivingRenewalSuccess) {
      final String requestNumber = state.response.requestNumber;

      final BookingFlowData? bookingData =
          await Navigator.push<BookingFlowData>(
            context,
            MaterialPageRoute(
              builder: (_) => PracticalTestBookingScreen(
                appBarTitle: 'تجديد رخصة القيادة',
                loadGovernorates: _loadGovernorates,
                loadTrafficUnits: _loadTrafficUnits,
                loadSlotsForDate: _loadDrivingSlots,
              ),
            ),
          );

      if (bookingData != null && mounted) {
        await _completeRenewalAfterBooking(
          bookingData: bookingData,
          renewalRequestNumber: requestNumber,
        );
      }
      return;
    }

    if (state is DrivingRenewalFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message, textDirection: TextDirection.rtl),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تعذر إكمال طلب التجديد. الرجاء المحاولة مرة أخرى.',
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Future<List<BookingSelectionOption>> _loadGovernorates() async {
    final result = await _renewalDataHandler.fetchGovernoratesForUi();
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تحميل المحافظات.');
    }

    return result.data!
        .map(
          (LocationLookupModel item) =>
              BookingSelectionOption(id: item.id, label: item.name),
        )
        .toList(growable: false);
  }

  Future<List<BookingSelectionOption>> _loadTrafficUnits(
    String governorateId,
  ) async {
    final result = await _renewalDataHandler.fetchTrafficUnitsForUi(
      governorateId: governorateId,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تحميل وحدات المرور.');
    }

    return result.data!
        .map(
          (LocationLookupModel item) =>
              BookingSelectionOption(id: item.id, label: item.name),
        )
        .toList(growable: false);
  }

  Future<List<String>> _loadDrivingSlots(DateTime selectedDate) async {
    final result = await _renewalDataHandler.fetchSlotsForUi(
      date: selectedDate,
      type: AppointmentType.driving,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تحميل المواعيد المتاحة.');
    }

    return result.data!
        .map((AppointmentSlotModel item) => item.displayLabel)
        .toList(growable: false);
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
            title: 'رخصة القيادة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(height: 5.h),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  ServiceListItem(
                    title: 'اصدار رخصة قيادة لأول مرة',
                    icon: 'assets/license_s.svg',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsAndConditionsScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ServiceListItem(
                    title: 'تجديد رخصة القيادة',
                    icon: 'assets/loding.svg',
                    onTap: _openRenewalFlow,
                  ),
                  SizedBox(height: 24.h),
                  ServiceListItem(
                    title: 'اصدار بدل فاقد / تالف رخصة',
                    icon: "assets/file_s.svg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LostLicenseSelectionScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ServiceListItem(
                    title: 'استعلام وسداد مخالفات رخصة القيادة',
                    icon: "assets/search.svg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectLicenseScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // ServiceListItem(
                  //   title: 'سداد مخالفات رخصة القيادة',
                  //   icon: "assets/cart_payment.svg",
                  // ),
                  // SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

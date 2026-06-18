import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/widgets/generic_document_upload_screen.dart';
import 'package:traffic/features/orders/presentation/cubits/my_orders_cubit.dart';
import '../../cubits/driving_license_cubit.dart';
import '../../cubits/driving_license_state.dart';
import '../medical_check/medical_check_screen.dart';
import '../practical_test/practical_test_booking_screen.dart';
import 'widgets/first_license_booking_helper.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/injection_container.dart';

class DrivingLicenseUploadDocumentsScreen extends StatelessWidget {
  const DrivingLicenseUploadDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DrivingLicenseCubit>(),
      child: const _UploadContent(),
    );
  }
}

class _UploadContent extends StatefulWidget {
  const _UploadContent();

  @override
  State<_UploadContent> createState() => _UploadContentState();
}

class _UploadContentState extends State<_UploadContent> {
  late final List<DocumentItemModel> _documents;
  late final FirstLicenseBookingHelper _booking;
  bool _isBookingLoading = false;

  @override
  void initState() {
    super.initState();
    _booking = getIt<FirstLicenseBookingHelper>();
    _documents = [
      DocumentItemModel(title: 'شهادة المؤهل الدراسي', isRequired: true),
      DocumentItemModel(title: 'صور شخصية حديثة', isRequired: true),
      DocumentItemModel(
        title: 'صورة البطاقة الشخصية (وجه + ظهر)',
        isRequired: true,
      ),
      DocumentItemModel(title: 'إثبات محل الإقامة', isRequired: false),
      DocumentItemModel(title: 'شهادة طبية', isRequired: false),
    ];
  }

  String? _getFilePath(String title) =>
      _documents.firstWhere((d) => d.title == title).filePath;

  void _onProceed(Map<String, String> selectedDropdowns) {
    final personalPhoto = _getFilePath('صور شخصية حديثة');
    final idCard = _getFilePath('صورة البطاقة الشخصية (وجه + ظهر)');
    final educationalCert = _getFilePath('شهادة المؤهل الدراسي');

    if (personalPhoto == null || idCard == null || educationalCert == null) {
      return;
    }

    context.read<DrivingLicenseCubit>().uploadDocuments(
      category: selectedDropdowns['فئة الرخصة'] ?? '',
      personalPhotoPath: personalPhoto,
      idCardPath: idCard,
      educationalCertificatePath: educationalCert,
      residenceProofPath: _getFilePath('إثبات محل الإقامة'),
      medicalCertificatePath: _getFilePath('شهادة طبية'),
    );
  }

  // ── Navigation chain ─────────────────────────────────────────────────────

  Future<void> _goToMedical(BuildContext ctx, String requestNumber) async {
    final BookingFlowData? medicalData = await Navigator.push<BookingFlowData>(
      ctx,
      MaterialPageRoute(
        builder: (_) => MedicalCheckScreen(
          appBarTitle: 'اصدار رخصة قيادة',
          loadGovernorates: _booking.loadGovernorates,
          loadMedicalCenters: _booking.loadTrafficUnits,
          loadSlotsForDate: _booking.loadMedicalSlots,
        ),
      ),
    );

    if (medicalData == null || !ctx.mounted) return;

    setState(() => _isBookingLoading = true);

    try {
      await _booking.submitMedicalAppointment(
        medicalData.selectedGovernorateId ?? '',
        medicalData.selectedSecondaryId ?? '',
        medicalData.selectedDate,
        medicalData.selectedSlot,
        requestNumber,
      );
    } catch (e) {
      if (ctx.mounted) {
        setState(() => _isBookingLoading = false);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }
      return;
    }

    if (!ctx.mounted) return;
    setState(() => _isBookingLoading = false);
    _goToPractical(ctx, requestNumber);
  }

  Future<void> _goToPractical(BuildContext ctx, String requestNumber) async {
    final BookingFlowData? practicalData = await Navigator.push<BookingFlowData>(
      ctx,
      MaterialPageRoute(
        builder: (_) => PracticalTestBookingScreen(
          appBarTitle: 'اصدار رخصة قيادة',
          loadGovernorates: _booking.loadGovernorates,
          loadTrafficUnits: _booking.loadTrafficUnits,
          loadSlotsForDate: _booking.loadDrivingSlots,
        ),
      ),
    );

    if (practicalData == null || !ctx.mounted) return;

    setState(() => _isBookingLoading = true);

    try {
      await _booking.submitDrivingAppointment(
        practicalData.selectedGovernorateId ?? '',
        practicalData.selectedSecondaryId ?? '',
        practicalData.selectedDate,
        practicalData.selectedSlot,
        requestNumber,
      );
    } catch (e) {
      if (ctx.mounted) {
        setState(() => _isBookingLoading = false);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }
      return;
    }

    if (!ctx.mounted) return;
    setState(() => _isBookingLoading = false);
    _goToOrders(ctx);
  }

  Future<void> _goToOrders(BuildContext ctx) async {
    // Refresh the Orders cubit if it is in scope (provided by MainNavigationScreen)
    try {
      ctx.read<MyOrdersCubit>().fetchMyOrders();
    } catch (_) {
      // MyOrdersCubit may not be in scope here; orders will refresh on tab tap
    }
    Navigator.of(ctx).popUntil((route) => route.isFirst);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تقديم طلبك بنجاح! يمكنك متابعة حالته من قسم "طلباتي".',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  /// Persists the [requestNumber] returned from upload-documents so it can be
  /// retrieved later from the Tracking / Orders screen for finalization.
  Future<void> _saveRequestNumber(String requestNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_license_request_number', requestNumber);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DrivingLicenseCubit, DrivingLicenseState>(
      listener: (context, state) {
        if (state is DrivingLicenseUploadSuccess) {
          // Persist the request number for later use on the Tracking screen
          _saveRequestNumber(state.requestNumber);
          _goToMedical(context, state.requestNumber);
        } else if (state is DrivingLicenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            GenericDocumentUploadScreen(
              appBarTitle: 'اصدار رخصة قيادة',
              subtitle:
                  'يرجى رفع المستندات التالية لإتمام إجراءات إصدار رخصة قيادة. يجب أن تكون الصور واضحة ومقروءة.',
              dropdowns: const [
                DropdownConfig(
                  title: 'فئة الرخصة',
                  hint: 'اختر فئة الرخصة',
                  options: [
                    'قيادة خاصة',
                    'دراجة نارية',
                    'مهنية درجة ثالثة',
                    'مهنية درجة ثانية',
                    'مهنية درجة أولى',
                    'قيادة معدات ثقيلة',
                    'قيادة جرار زراعي',
                  ],
                ),
              ],
              documents: _documents,
              onNextPressed: _onProceed,
            ),
            if (state is DrivingLicenseLoading || _isBookingLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(child: CustomLoadingIndicator()),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/core/widgets/loading_overlay.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_renewal_cubit.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_renewal_state.dart';
import 'package:traffic/features/driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/core/utils/date_time_formatter.dart';

class VehicleInspectionBookingScreen extends StatelessWidget {
  final String? requestNumber;

  const VehicleInspectionBookingScreen({
    super.key,
    this.requestNumber,
  });

  Future<void> _onNextWithBookingData(
      BuildContext context, BookingFlowData data) async {
    final cubit = context.read<VehicleRenewalCubit>();
    await cubit.bookAppointment(
      governorateId: data.selectedGovernorateId ?? data.selectedGovernorate,
      trafficUnitId: data.selectedSecondaryId ?? data.selectedSecondary,
      date: data.selectedDate,
      startTime: DateTimeFormatter.extractRawStartTime(data.selectedSlot),
      requestNumber: requestNumber ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleRenewalCubit, VehicleRenewalState>(
      listener: (context, state) {
        if (state is VehicleRenewalSuccess) {
          _showInspectionWarningDialog(context);
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
        final cubit = context.read<VehicleRenewalCubit>();
        return LoadingOverlay(
          isLoading: state is VehicleRenewalLoading,
          child: GenericBookingScreen(
            appBarTitle: 'اصدار رخصة مركبة',
            headerTitle: 'الفحص الفني للمركبة',
            bookingCardTitle: 'حجز موعد الفحص الفني',
            appointmentCardTitle: 'موعد الفحص الفني',
            secondaryDropdown: const SecondaryDropdownConfig(
              label: 'وحدة المرور',
              hint: 'اختر وحدة المرور',
              sheetTitle: 'اختر وحدة المرور',
              items: [], // Will be loaded by loader
            ),
            loadGovernorates: () async {
              final result = await cubit.repository.fetchGovernorates();
              if (result.isSuccess) {
                return result.data!
                    .map((LocationLookupModel e) =>
                        BookingSelectionOption(id: e.id, label: e.name))
                    .toList();
              }
              throw Exception(result.error);
            },
            loadSecondaryOptions: (govId) async {
              final result = await cubit.repository.fetchTrafficUnits(govId);
              if (result.isSuccess) {
                return result.data!
                    .map((LocationLookupModel e) =>
                        BookingSelectionOption(id: e.id, label: e.name))
                    .toList();
              }
              throw Exception(result.error);
            },
            loadSlotsForDate: (date) async {
              final result =
                  await cubit.repository.fetchAvailableSlots(date, 'Technical');
              if (result.isSuccess) {
                return result.data!
                    .map((AppointmentSlotModel slot) => slot.displayLabel)
                    .toList();
              }
              throw Exception(result.error);
            },
            onNextWithBookingData: (data) => _onNextWithBookingData(context, data),
          ),
        );
      },
    );
  }

  void _showInspectionWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.background,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.amberWarning,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'لا يمكن استكمال إصدار رخصة المركبة إلا بعد إجراء الفحص الفني بنجاح للمركبة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () {
                  // Navigate back to home or similar
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'العودة للصفحة الرئيسية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

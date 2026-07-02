import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/core/widgets/loading_overlay.dart';
import '../../data/models/renewal_vehicle_license_model.dart';
import '../../../presentation/cubits/vehicle_renewal_cubit.dart';
import '../../../presentation/cubits/vehicle_renewal_state.dart';
import '../../../../driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/core/utils/date_time_formatter.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// **Vehicle Technical Inspection Booking Screen** — thin wrapper around
/// [GenericBookingScreen].
class VehicleTechnicalInspectionScreen extends StatelessWidget {
  final RenewalVehicleLicenseModel vehicle;
  final String requestNumber;
  final String? successMessage;

  const VehicleTechnicalInspectionScreen({
    super.key,
    required this.vehicle,
    required this.requestNumber,
    this.successMessage,
  });

  Future<void> _onNextWithBookingData(
      BuildContext context, BookingFlowData data) async {
    final cubit = context.read<VehicleRenewalCubit>();
    await cubit.bookAppointment(
      governorateId: data.selectedGovernorateId ?? data.selectedGovernorate,
      trafficUnitId: data.selectedSecondaryId ?? data.selectedSecondary,
      date: data.selectedDate,
      startTime: DateTimeFormatter.extractRawStartTime(data.selectedSlot),
      requestNumber: requestNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleRenewalCubit, VehicleRenewalState>(
      listener: (context, state) {
        if (state is VehicleRenewalSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.response.message ??
                    'تم تقديم طلب التجديد بنجاح. يمكنك متابعة الطلب واستكماله من قائمة "طلباتي".',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
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
            appBarTitle: 'تجديد رخصة مركبة',
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
            loadSlotsForDate: (date, trafficUnitId) async {
              final result =
                  await cubit.repository.fetchAvailableSlots(date, 'Technical', trafficUnitId);
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
}

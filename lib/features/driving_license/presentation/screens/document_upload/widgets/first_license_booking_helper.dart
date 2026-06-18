import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/features/driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_renewal_repository.dart';
import 'package:injectable/injectable.dart';

/// Provides appointment booking data-fetch callbacks for the
/// First-Time Driving License issuance flow.
///
/// Extracted here to keep [DrivingLicenseUploadDocumentsScreen] under 300 lines.
@injectable
class FirstLicenseBookingHelper {
  final DrivingLicenseRenewalDataHandler _handler;

  FirstLicenseBookingHelper(this._handler);

  Future<List<BookingSelectionOption>> loadGovernorates() async {
    final result = await _handler.fetchGovernoratesForUi();
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

  Future<List<BookingSelectionOption>> loadTrafficUnits(
    String governorateId,
  ) async {
    final result = await _handler.fetchTrafficUnitsForUi(
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

  Future<List<String>> loadMedicalSlots(DateTime selectedDate) async {
    final result = await _handler.fetchSlotsForUi(
      date: selectedDate,
      type: AppointmentType.medical,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تحميل مواعيد الكشف الطبي.');
    }
    return result.data!
        .map((AppointmentSlotModel item) => item.displayLabel)
        .toList(growable: false);
  }

  Future<List<String>> loadDrivingSlots(DateTime selectedDate) async {
    final result = await _handler.fetchSlotsForUi(
      date: selectedDate,
      type: AppointmentType.driving,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تحميل مواعيد الاختبار.');
    }
    return result.data!
        .map((AppointmentSlotModel item) => item.displayLabel)
        .toList(growable: false);
  }

  Future<AppointmentBookingMeta?> submitMedicalAppointment(
    String governorateId,
    String trafficUnitId,
    DateTime selectedDate,
    String selectedSlot, [
    String? requestNumber,
  ]) async {
    final result = await _handler.bookAppointmentFromUi(
      governorateId: governorateId,
      trafficUnitId: trafficUnitId,
      date: selectedDate,
      selectedSlot: selectedSlot,
      type: AppointmentType.medical,
      requestNumber: requestNumber,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تأكيد موعد الكشف الطبي.');
    }
    final data = result.data!;
    return AppointmentBookingMeta(
      bookingNumber: data.serviceNumber,
      requestNumber: data.applicationId,
      trafficUnitAddress: data.trafficUnitAddress,
      workingHours: data.workingHours,
    );
  }

  Future<AppointmentBookingMeta?> submitDrivingAppointment(
    String governorateId,
    String trafficUnitId,
    DateTime selectedDate,
    String selectedSlot, [
    String? requestNumber,
  ]) async {
    final result = await _handler.bookAppointmentFromUi(
      governorateId: governorateId,
      trafficUnitId: trafficUnitId,
      date: selectedDate,
      selectedSlot: selectedSlot,
      type: AppointmentType.driving,
      requestNumber: requestNumber,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'تعذر تأكيد موعد الاختبار.');
    }
    final data = result.data!;
    return AppointmentBookingMeta(
      bookingNumber: data.serviceNumber,
      requestNumber: data.applicationId,
      trafficUnitAddress: data.trafficUnitAddress,
      workingHours: data.workingHours,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/features/driving_license/presentation/widgets/completion_warning_dialog.dart';

// ── Dummy data ─────────────────────────────────────────────────────────────────

const List<String> _kTrafficUnits = [
  'العاشر من رمضان',
  'وحدة مرور الدقي',
  'وحدة مرور مدينة نصر',
  'وحدة مرور المعادي',
  'وحدة مرور الإسكندرية',
];

// ── Screen ─────────────────────────────────────────────────────────────────────

/// **Practical Test Booking Screen** — thin wrapper around [GenericBookingScreen].
///
/// Injects the practical-test-specific labels and delegates "التالي" to the
/// caller-provided [onNextPressed], defaulting to [CompletionWarningDialog].
class PracticalTestBookingScreen extends StatelessWidget {
  /// The app bar title for this screen (e.g. "تجديد رخصة القيادة").
  final String appBarTitle;


  final Future<List<BookingSelectionOption>> Function()? loadGovernorates;
  final Future<List<BookingSelectionOption>> Function(String governorateId)?
      loadTrafficUnits;
  final Future<List<String>> Function(DateTime selectedDate, String trafficUnitId)? loadSlotsForDate;

  const PracticalTestBookingScreen({
    super.key,
    required this.appBarTitle,

    this.loadGovernorates,
    this.loadTrafficUnits,
    this.loadSlotsForDate,
  });

  @override
  Widget build(BuildContext context) {
    return GenericBookingScreen(
      appBarTitle: appBarTitle,
      headerTitle: 'اختبار القيادة العملي',
      bookingCardTitle: 'حجز موعد اختبار القيادة العملي',
      appointmentCardTitle: 'موعد الاختبار',
      secondaryDropdown: const SecondaryDropdownConfig(
        label: 'وحدة المرور',
        hint: 'اختر وحدة المرور',
        sheetTitle: 'اختر وحدة المرور',
        items: _kTrafficUnits,
      ),
      loadGovernorates: loadGovernorates,
      loadSecondaryOptions: loadTrafficUnits,
      loadSlotsForDate: loadSlotsForDate,
    );
  }
}

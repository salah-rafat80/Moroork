import 'package:flutter/material.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';

import '../practical_test/practical_test_booking_screen.dart';

// ── Dummy data ─────────────────────────────────────────────────────────────────

const List<String> _kTrafficUnits = [
  'العاشر من رمضان',
  'وحدة مرور الدقي',
  'وحدة مرور مدينة نصر',
  'وحدة مرور المعادي',
  'وحدة مرور الإسكندرية',
];

// ── Screen ─────────────────────────────────────────────────────────────────────

/// **Theory Test Booking Screen** — thin wrapper around [GenericBookingScreen].
///
/// Injects theory-test-specific labels and navigates to
/// [PracticalTestBookingScreen] on "التالي".
class TheoryTestBookingScreen extends StatelessWidget {
  /// The app bar title for this screen (e.g. "تجديد رخصة القيادة").
  final String appBarTitle;


  final Future<List<BookingSelectionOption>> Function()? loadGovernorates;
  final Future<List<BookingSelectionOption>> Function(String governorateId)?
  loadTrafficUnits;
  final Future<List<String>> Function(DateTime selectedDate, String trafficUnitId)? loadSlotsForDate;

  const TheoryTestBookingScreen({
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
      headerTitle: 'اختبار الاشارات النظري',
      bookingCardTitle: 'حجز موعد اختبار الاشارات النظري',
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

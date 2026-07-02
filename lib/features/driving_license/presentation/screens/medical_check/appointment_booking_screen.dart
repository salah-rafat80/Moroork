import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/time_slot_grid.dart';

// ── Appointment result model ───────────────────────────────────────────────────

/// Immutable value object returned to the caller when the user confirms.
@immutable
class AppointmentResult {
  final DateTime selectedDate;
  final String selectedSlot;
  final String? bookingNumber;
  final String? requestNumber;
  final String? trafficUnitAddress;
  final String? workingHours;

  const AppointmentResult({
    required this.selectedDate,
    required this.selectedSlot,
    this.bookingNumber,
    this.requestNumber,
    this.trafficUnitAddress,
    this.workingHours,
  });
}


// ── Screen ─────────────────────────────────────────────────────────────────────

/// Appointment booking screen — shown when the user taps "حجز الموعد".
///
/// Uses [CalendarCarousel] for the date picker and [TimeSlotGrid] for slots.
/// Pops with an [AppointmentResult] when the user taps "تأكيد الموعد".
class AppointmentBookingScreen extends StatefulWidget {
  /// Title displayed in the app bar. Passed down from the parent booking screen
  /// so it stays consistent with the current flow.
  final String appBarTitle;

  /// Title displayed above the calendar, e.g. "حجز موعد الكشف الطبي" or
  /// "حجز موعد اختبار القيادة العملي".
  final String bookingHeaderTitle;
  final Future<List<String>> Function(DateTime selectedDate)? loadSlotsForDate;

  const AppointmentBookingScreen({
    super.key,
    this.appBarTitle = 'اصدار رخصة قيادة',
    this.bookingHeaderTitle = 'حجز موعد الكشف الطبي',
    this.loadSlotsForDate,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DateTime _selectedDay;
  late DateTime _targetDateTime; // month displayed by the carousel

  String? _selectedSlot;
  late List<String> _slots;
  bool _isLoadingSlots = false;

  static const List<String> _kFallbackSlots = [
    '09:00-10:00 Am',
    '10:00-11:00 Am',
    '11:00-12:00 Pm',
    '12:00-01:00 Pm',
    '01:00-02:00 Pm',
    '02:00-03:00 Pm',
  ];

  bool get _canConfirm => _selectedSlot != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _targetDateTime = DateTime.now();
    _slots = const <String>[];
    _loadSlotsForDate(_selectedDay);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _loadSlotsForDate(DateTime selectedDate) async {
    final Future<List<String>> Function(DateTime selectedDate)? loader =
        widget.loadSlotsForDate;
    if (loader == null) {
      setState(() {
        _slots = List<String>.from(_kFallbackSlots);
      });
      return;
    }

    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final List<String> loaded = await loader(selectedDate);
      if (!mounted) {
        return;
      }
      setState(() {
        _slots = loaded;
        _selectedSlot = null;
        _isLoadingSlots = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _slots = const <String>[];
        _isLoadingSlots = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _extractErrorMessage(error, 'تعذر تحميل المواعيد المتاحة حالياً.'),
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  String _extractErrorMessage(Object error, String fallback) {
    final String raw = error.toString();
    const String exceptionPrefix = 'Exception: ';
    if (raw.startsWith(exceptionPrefix)) {
      final String message = raw.substring(exceptionPrefix.length).trim();
      if (message.isNotEmpty) {
        return message;
      }
    }
    if (raw.isNotEmpty) {
      return raw;
    }
    return fallback;
  }

  void _onConfirm() {
    if (!_canConfirm || _selectedSlot == null) {
      return;
    }

    Navigator.pop(
      context,
      AppointmentResult(
        selectedDate: _selectedDay,
        selectedSlot: _selectedSlot!,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ──────────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: widget.appBarTitle,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),

                  // ── Section title ──────────────────────────────────────
                  Text(
                    widget.bookingHeaderTitle,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Calendar (flutter_calendar_carousel) ───────────────
                  _StyledCalendar(
                    selectedDay: _selectedDay,
                    targetDateTime: _targetDateTime,
                    onDayPressed: (date, _) {
                      final DateTime today = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );
                      if (date.isBefore(today)) return;

                      setState(() {
                        _selectedDay = date;
                        _selectedSlot = null; // reset slot on date change
                      });
                      _loadSlotsForDate(date);
                    },
                    onTargetDateChanged: (date) {
                      setState(() => _targetDateTime = date);
                    },
                  ),
                  SizedBox(height: 16.h),

                  // ── Available slots label ──────────────────────────────
                  Text(
                    'المواعيد المتاحة',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.30,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // ── Time slot grid ─────────────────────────────────────
                  if (_isLoadingSlots)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_slots.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        'لا توجد مواعيد متاحة لهذا اليوم',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    TimeSlotGrid(
                      slots: _slots,
                      selectedSlot: _selectedSlot,
                      onSlotSelected: (slot) =>
                          setState(() => _selectedSlot = slot),
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // ── Bottom confirm button ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: _ConfirmButton(enabled: _canConfirm, onPressed: _onConfirm),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widget: styled CalendarCarousel wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _StyledCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime targetDateTime;
  final Function(DateTime, List<Event>) onDayPressed;
  final ValueChanged<DateTime> onTargetDateChanged;

  const _StyledCalendar({
    required this.selectedDay,
    required this.targetDateTime,
    required this.onDayPressed,
    required this.onTargetDateChanged,
  });

  // ── Header builder ─────────────────────────────────────────────────────────

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _monthLabel(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.year}';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: AppColors.greyBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Column(
        children: [
          // ── Green header with prev/next and month label ────────────────
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                // ← Previous month
                IconButton(
                  onPressed: () => onTargetDateChanged(
                    DateTime(targetDateTime.year, targetDateTime.month - 1),
                  ),
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 22.r,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Month + year label
                Expanded(
                  child: Text(
                    _monthLabel(targetDateTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // → Next month
                IconButton(
                  onPressed: () => onTargetDateChanged(
                    DateTime(targetDateTime.year, targetDateTime.month + 1),
                  ),
                  icon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 22.r,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── CalendarCarousel (no built-in header — we drew our own above) ─
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: CalendarCarousel<Event>(
              // ── Date state ───────────────────────────────────────────────
              selectedDateTime: selectedDay,
              targetDateTime: targetDateTime,
              onDayPressed: onDayPressed,
              onCalendarChanged: onTargetDateChanged,

              // ── Minimum selectable date (today and onwards) ──────────────
              minSelectedDate: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              inactiveDaysTextStyle: TextStyle(
                color: AppColors.greyIcon,
                fontSize: 13.sp,
                fontFamily: 'Inter',
              ),

              // ── Suppress built-in header ─────────────────────────────────
              showHeader: false,

              // ── Sizing ───────────────────────────────────────────────────
              height: 280.h,
              width: double.maxFinite,
              childAspectRatio: 1.2,

              // ── Week-day row style ────────────────────────────────────────
              weekdayTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              weekDayPadding: EdgeInsets.only(top: 5.h, bottom: 4.h),

              // ── Day text styles ──────────────────────────────────────────
              // Current month days
              daysTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              // Previous/next month days (dim them)
              prevDaysTextStyle: TextStyle(
                color: AppColors.greyIcon,
                fontSize: 13.sp,
                fontFamily: 'Inter',
              ),
              nextDaysTextStyle: TextStyle(
                color: AppColors.greyIcon,
                fontSize: 13.sp,
                fontFamily: 'Inter',
              ),
              // Weekend text same colour as weekdays
              weekendTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),

              // ── Selected day ─────────────────────────────────────────────
              selectedDayTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              selectedDayBorderColor: AppColors.primary,
              selectedDayButtonColor: AppColors.primary,

              // ── Today ────────────────────────────────────────────────────
              todayTextStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
              todayButtonColor: Colors.transparent,
              todayBorderColor: AppColors.primary,

              // ── Grid borders ─────────────────────────────────────────────
              daysHaveCircularBorder: true,
              isScrollable: false,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widget: confirm button
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _ConfirmButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: enabled ? AppColors.primary : AppColors.mutedGrey,
        ),
        alignment: Alignment.center,
        child: Text(
          'تأكيد الموعد',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

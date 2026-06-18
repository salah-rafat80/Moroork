import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/utils/date_time_formatter.dart';

/// A selectable 2-column grid of time slots.
///
/// Highlights the currently selected slot in green.
/// Calls [onSlotSelected] with the slot string when the user taps a row.
///
/// **Usage:**
/// ```dart
/// TimeSlotGrid(
///   slots: ['09:00-10:00 Am', '10:00-11:00 Am', ...],
///   selectedSlot: _selectedSlot,
///   onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
/// )
/// ```
class TimeSlotGrid extends StatelessWidget {
  /// All available time slots to display.
  final List<String> slots;

  /// The currently selected slot string (nullable = none selected).
  final String? selectedSlot;

  /// Called with the tapped slot string.
  final ValueChanged<String> onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.onSlotSelected,
    this.selectedSlot,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 165 / 38, // matches Figma slot cell ratio
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = slot == selectedSlot;

        return GestureDetector(
          onTap: () => onSlotSelected(slot),
          child: Container(
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.cardBg,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.w, color: AppColors.greyBorder),
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Text(
              DateTimeFormatter.formatTimeSlot(slot),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.cardBg
                    : AppColors.textPrimary,
                fontSize: 13.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.30,
              ),
            ),
          ),
        );
      },
    );
  }
}

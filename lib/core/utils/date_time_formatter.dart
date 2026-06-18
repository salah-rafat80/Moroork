/// Centralized utility for localized date and time formatting.
/// Handles Arabic calendar translation and normalized 12-hour AM/PM time slot display.
class DateTimeFormatter {
  const DateTimeFormatter._();

  /// Formats a [DateTime] into a localized Arabic date string (e.g., "25 أكتوبر 2025").
  static String formatDate(DateTime date) {
    const List<String> months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Parses and formats a raw time string (e.g., "09:00", "09:00 Am", "13:30", "01:30 PM", "09:30:00")
  /// into a localized Arabic 12-hour format with AM/PM indicators (e.g., "09:00 ص", "01:30 م").
  static String formatTime(String timeStr) {
    final String clean = timeStr.trim().toLowerCase();
    if (clean.isEmpty) return '';

    // Check if it already contains Arabic period indicators
    if (clean.contains('ص') || clean.contains('م')) {
      return timeStr;
    }

    // Determine AM/PM if explicitly present in the string
    bool? isPmExplicit;
    if (clean.endsWith('pm') || clean.contains('pm')) {
      isPmExplicit = true;
    } else if (clean.endsWith('am') || clean.contains('am')) {
      isPmExplicit = false;
    }

    // Clean up AM/PM and other non-digits/colons from the string to parse numbers
    final String timeOnly = clean
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll(RegExp(r'[a-z]'), '')
        .trim();

    final List<String> parts = timeOnly.split(':');
    if (parts.isEmpty) return timeStr;

    int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    // Handle 24-hour hour conversion and AM/PM determination
    bool isPm = false;
    if (isPmExplicit != null) {
      isPm = isPmExplicit;
      // Normalizing hour > 12 to 12-hour format
      if (hour > 12) {
        hour -= 12;
        isPm = true;
      } else if (hour == 0) {
        hour = 12;
      }
    } else {
      // Inferred from 24-hour hour
      if (hour >= 12) {
        isPm = true;
        if (hour > 12) {
          hour -= 12;
        }
      } else {
        isPm = false;
        if (hour == 0) {
          hour = 12;
        }
      }
    }

    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = minute.toString().padLeft(2, '0');
    final String period = isPm ? 'م' : 'ص';

    return '$hourStr:$minuteStr $period';
  }

  /// Normalizes and formats a time slot representation (which could be a single time
  /// like "09:00 Am" or a range like "09:00-10:00 Am" or "09:00 - 10:00") into a standardized Arabic 12-hour format
  /// (e.g., "09:00 ص - 10:00 ص" or "09:00 ص").
  static String formatTimeSlot(String slot) {
    if (slot.isEmpty) return '';

    // Handle range separator '-'
    if (slot.contains('-')) {
      final List<String> parts = slot.split('-');
      if (parts.length == 2) {
        final String start = parts[0].trim();
        final String end = parts[1].trim();

        final String formattedEnd = formatTime(end);
        final bool endIsPm = formattedEnd.contains('م');

        // Extract hour and minute from formattedEnd
        final String endTimeOnly = formattedEnd.split(' ').first;
        final List<String> endTimeParts = endTimeOnly.split(':');
        final int endHour = endTimeParts.isNotEmpty ? (int.tryParse(endTimeParts[0]) ?? 12) : 12;
        final int endMinute = endTimeParts.length > 1 ? (int.tryParse(endTimeParts[1]) ?? 0) : 0;

        // Check if start has an explicit period
        final String startLower = start.toLowerCase();
        final bool startHasPeriod = startLower.contains('am') ||
            startLower.contains('pm') ||
            startLower.contains('ص') ||
            startLower.contains('م');

        if (startHasPeriod) {
          return '${formatTime(start)} - $formattedEnd';
        }

        // Parse hour and minute from start
        final String startTimeOnly = startLower
            .replaceAll(RegExp(r'[^0-9:]'), '')
            .trim();
        final List<String> startTimeParts = startTimeOnly.split(':');
        if (startTimeParts.isEmpty || startTimeParts[0].isEmpty) {
          return '${formatTime(start)} - $formattedEnd';
        }

        final int startHour = int.tryParse(startTimeParts[0]) ?? 0;
        final int startMinute = startTimeParts.length > 1 ? (int.tryParse(startTimeParts[1]) ?? 0) : 0;

        // Convert end time to minutes of day
        final int endMinutes = ((endIsPm ? (endHour == 12 ? 12 : endHour + 12) : (endHour == 12 ? 0 : endHour))) * 60 + endMinute;

        // Try AM and PM for start
        final int startMinutesAm = ((startHour == 12 ? 0 : startHour)) * 60 + startMinute;
        final int startMinutesPm = ((startHour == 12 ? 12 : startHour + 12)) * 60 + startMinute;

        final int diffAm = endMinutes - startMinutesAm;
        final int diffPm = endMinutes - startMinutesPm;

        bool choosePm = false;
        if (diffAm >= 0 && diffPm >= 0) {
          choosePm = diffPm < diffAm;
        } else if (diffPm >= 0) {
          choosePm = true;
        } else if (diffAm >= 0) {
          choosePm = false;
        } else {
          choosePm = diffPm > diffAm;
        }

        final String formattedStartHour = startHour.toString().padLeft(2, '0');
        final String formattedStartMinute = startMinute.toString().padLeft(2, '0');
        final String startPeriod = choosePm ? 'م' : 'ص';
        final String formattedStart = '$formattedStartHour:$formattedStartMinute $startPeriod';

        return '$formattedStart - $formattedEnd';
      }
    }

    return formatTime(slot);
  }

  /// Extracts the start time in 24-hour HH:mm format from a selected slot string.
  /// Handles both English (AM/PM) and Arabic (ص/م) slots.
  static String extractRawStartTime(String selectedSlot) {
    if (selectedSlot.isEmpty) return '';

    // Split by dash to get the start time part
    final String firstPart = selectedSlot.split('-').first.trim();
    final String clean = firstPart.toLowerCase().replaceAll('.', '');

    // Check if it has an AM/PM period indicator (either English or Arabic)
    final bool isPm = clean.endsWith('pm') || clean.contains('pm') || clean.contains('م');
    final bool isAm = clean.endsWith('am') || clean.contains('am') || clean.contains('ص');

    // Extract digits and colons only
    final String timeOnly = clean
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll('ص', '')
        .replaceAll('م', '')
        .replaceAll(RegExp(r'[a-z]'), '')
        .trim();

    final List<String> pieces = timeOnly.split(':');
    if (pieces.isNotEmpty) {
      final int rawHour = int.tryParse(pieces[0]) ?? 0;
      final int minute = pieces.length > 1 ? (int.tryParse(pieces[1]) ?? 0) : 0;
      int hour24 = rawHour;

      if (isPm || isAm) {
        if (isPm) {
          hour24 = rawHour == 12 ? 12 : rawHour + 12;
        } else if (isAm) {
          hour24 = rawHour == 12 ? 0 : rawHour;
        }
      } else {
        // No explicit period: infer from rawHour (24-hour)
        if (hour24 >= 24) {
          hour24 = 0;
        }
      }
      return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    return firstPart;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'violation_model.freezed.dart';
part 'violation_model.g.dart';

/// Maps English violation type keys (from server) to Arabic display names.
/// Keys must match exactly what the server returns in violationType field.
const _violationTypeAr = <String, String>{
  // Server keys (verified from API response)
  'IllegalParking': 'انتظار خاطئ',
  'SpeedLimitExceeded': 'تجاوز السرعة المقررة',
  'RunningRedLight': 'تجاوز الإشارة الحمراء',
  'NoSeatBelt': 'عدم ارتداء حزام الأمان',
  'WrongWay': 'السير في الاتجاه الخاطئ',
  'NoLicense': 'قيادة بدون رخصة',
  'MobileUsing': 'استخدام الهاتف أثناء القيادة',
  'MobileUse': 'استخدام الهاتف أثناء القيادة',
  'Reckless': 'قيادة متهورة',
  'RecklessDriving': 'قيادة متهورة',
  'NoInsurance': 'قيادة بدون تأمين',
  'OverLoading': 'تجاوز الحمولة المقررة',
  'Overtaking': 'تجاوز خاطئ',
  'IllegalOvertaking': 'تجاوز خاطئ',
  'NoParkingZone': 'الوقوف في منطقة ممنوعة',
  'ExpiredRegistration': 'رخصة مركبة منتهية',
  'ExpiredLicense': 'رخصة قيادة منتهية',
  'DefectiveLighting': 'إضاءة معيبة',
  'NoRegistration': 'قيادة بدون تسجيل',
  'Speeding': 'تجاوز السرعة المقررة',
  'TrafficObstruction': 'تعطيل حركة المرور',
  'TrafficBlockage': 'إعاقة حركة المرور',
};

@freezed
class ViolationModel with _$ViolationModel {
  const ViolationModel._();

  const factory ViolationModel({
    @Default(0) int violationId,
    @Default('') String violationNumber,
    @Default('') String violationType,
    @Default('') String legalReference,
    @Default('') String description,
    @Default('') String location,
    @Default('') String violationDateTime,
    @Default(0.0) double fineAmount,
    @Default(0.0) double paidAmount,
    @Default(0.0) double remainingAmount,
    @Default('') String status,
    @Default('') String statusAr,
    @Default(false) bool isPayable,
  }) = _ViolationModel;

  factory ViolationModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationModelFromJson(json);

  /// Whether the violation is fully paid.
  bool get isPaid =>
      remainingAmount == 0 ||
      status.toLowerCase() == 'paid' ||
      statusAr == 'مدفوعة';

  /// A unique string ID to use as map key / selection key.
  String get id => violationId.toString();

  /// Payment date string shown in UI for paid violations.
  String? get paymentDate => isPaid ? '$time, $date' : null;

  /// The formatted date-time string to display.
  /// The server sends this as a pre-formatted Arabic string
  /// (e.g. "5 أبريل 2026 - 12:00 م"), so we display it directly.
  /// If it happens to be an ISO string, we format it properly.
  String get formattedDateTime {
    if (violationDateTime.isEmpty) return '';
    // Try ISO parse first
    try {
      final dt = DateTime.parse(violationDateTime);
      const months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      ];
      final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour < 12 ? 'ص' : 'م';
      return '$dateStr - $hour:$minute $amPm';
    } catch (_) {
      // Server already sent a formatted Arabic string — use as-is
      return violationDateTime;
    }
  }

  /// Legacy date getter — extracts only the date part from formattedDateTime.
  String get date {
    final full = formattedDateTime;
    if (full.contains(' - ')) return full.split(' - ').first;
    return full;
  }

  /// Legacy time getter — extracts only the time part from formattedDateTime.
  String get time {
    final full = formattedDateTime;
    if (full.contains(' - ')) return full.split(' - ').last;
    return '';
  }

  /// Arabic display name for the violation type.
  /// Falls back to violationType raw value if no translation found.
  String get titleAr => _violationTypeAr[violationType] ?? violationType;

  /// Legacy getter aliases (used by existing UI widgets).
  String get title => titleAr;
  String get articleNumber => legalReference;
  String get articleText => description;
  double get amount => remainingAmount > 0 ? remainingAmount : fineAmount;
}

@freezed
class ViolationsListModel with _$ViolationsListModel {
  const factory ViolationsListModel({
    @Default([]) List<ViolationModel> violations,
    @Default(0) int totalCount,
    @Default(0) int unpaidCount,
    @Default(0.0) double totalPayableAmount,
    @Default('') String message,
    @Default('') String messageAr,
  }) = _ViolationsListModel;

  factory ViolationsListModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationsListModelFromJson(json);
}

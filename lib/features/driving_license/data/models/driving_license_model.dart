// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:traffic/core/models/shared_models.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';

part 'driving_license_model.freezed.dart';
part 'driving_license_model.g.dart';

LicenseStatus _statusFromJson(dynamic status) {
  if (status is int) {
    if (status >= 0 && status < LicenseStatus.values.length) {
      return LicenseStatus.values[status];
    }
    return LicenseStatus.valid;
  }
  final statusStr = (status?.toString() ?? '').toLowerCase();
  if (statusStr.contains('expire') || statusStr.contains('منتهية')) {
    return LicenseStatus.expired;
  } else if (statusStr.contains('withdraw') || statusStr.contains('مسحوبة')) {
    return LicenseStatus.withdrawn;
  } else if (statusStr.contains('valid') || statusStr.contains('سارية')) {
    return LicenseStatus.valid;
  }
  return LicenseStatus.valid;
}

String _statusToJson(LicenseStatus status) => status.name;

@freezed
class DrivingLicenseModel with _$DrivingLicenseModel {
  const DrivingLicenseModel._();

  const factory DrivingLicenseModel({
    @Default(0) int id,
    @JsonKey(name: 'licenseNumber') @Default('') String drivingLicenseNumber,
    @JsonKey(name: 'category') @Default('') String category,
    @Default('') String governorate,
    @Default('') String licensingUnit,
    @Default('') String issueDate,
    @Default('') String expiryDate,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    @Default(LicenseStatus.valid) LicenseStatus status,
    @Default('') String citizenName,
    @Default(false) bool hasUnpaidViolations,
    DeliveryModel? delivery,
  }) = _DrivingLicenseModel;

  // Compatibility getters for legacy code
  String get licenseNumber => drivingLicenseNumber;
  String get licenseType => category;

  factory DrivingLicenseModel.fromJson(Map<String, dynamic> json) =>
      _$DrivingLicenseModelFromJson(json);

  /// Dummy data for UI development and fallback
  static List<DrivingLicenseModel> get dummyLicenses => [
        const DrivingLicenseModel(
          id: 1,
          drivingLicenseNumber: '11223344556677',
          category: 'خاصة',
          governorate: 'الجيزة',
          licensingUnit: 'وحدة مرور الدقي',
          status: LicenseStatus.withdrawn,
          issueDate: '10/6/2015',
          expiryDate: '10/6/2021',
          citizenName: 'محمد أحمد علي',
        ),
        const DrivingLicenseModel(
          id: 2,
          drivingLicenseNumber: '12345678901234',
          category: 'خاصة',
          governorate: 'الشرقية',
          licensingUnit: 'وحدة مرور العاشر',
          issueDate: '12/3/2020',
          expiryDate: '12/3/2026',
          citizenName: 'أحمد محمود حسن',
          hasUnpaidViolations: true,
        ),
      ];
}

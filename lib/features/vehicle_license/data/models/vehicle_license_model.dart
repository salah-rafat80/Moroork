// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:traffic/core/models/shared_models.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';

part 'vehicle_license_model.freezed.dart';
part 'vehicle_license_model.g.dart';

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
  } else if (statusStr.contains('suspend') || statusStr.contains('موقوفة')) {
    return LicenseStatus.suspended;
  }
  return LicenseStatus.valid;
}

String _statusToJson(LicenseStatus status) => status.name;

@freezed
class VehicleLicenseModel with _$VehicleLicenseModel {
  const VehicleLicenseModel._();

  const factory VehicleLicenseModel({
    @Default(0) int id,
    @JsonKey(name: 'vehicleLicenseNumber') @Default('') String vehicleLicenseNumber,
    String? plateNumber,
    @JsonKey(name: 'category') @Default('') String category,
    @Default('') String brand,
    @Default('') String model,
    @Default('') String governorate,
    @Default('') String licensingUnit,
    @Default('') String issueDate,
    @Default('') String expiryDate,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    @Default(LicenseStatus.valid) LicenseStatus status,
    @Default('') String citizenName,
    @Default(false) bool hasUnpaidViolations,
    DeliveryModel? delivery,
  }) = _VehicleLicenseModel;

  String get licenseNumber => vehicleLicenseNumber;
  String get licenseType => category;

  factory VehicleLicenseModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleLicenseModelFromJson(json);

  /// Dummy data for UI development and fallback
  static List<VehicleLicenseModel> get dummyLicenses => [
        const VehicleLicenseModel(
          id: 1,
          vehicleLicenseNumber: 'VL-100001',
          plateNumber: '٤٢١٣ س ج ر',
          category: 'ملاكي',
          brand: 'تويوتا',
          model: 'كورولا',
          governorate: 'القاهرة',
          licensingUnit: 'وحدة مرور مدينة نصر',
          issueDate: '2024-01-01',
          expiryDate: '2027-01-01',
          citizenName: 'أحمد محمود حسن',
        ),
      ];
}

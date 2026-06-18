import 'package:flutter/foundation.dart';
import 'package:traffic/core/utils/date_time_formatter.dart';

enum AppointmentType {
  medical('Medical'),
  driving('Driving'),
  technical('Technical');

  final String apiValue;
  const AppointmentType(this.apiValue);

  String get serviceTypeValue {
    switch (this) {
      case AppointmentType.medical:
        return 'كشف طبي';
      case AppointmentType.driving:
        return 'اختبار قيادة';
      case AppointmentType.technical:
        return 'فحص فني';
    }
  }
}

@immutable
class LocationLookupModel {
  final String id;
  final String name;

  const LocationLookupModel({required this.id, required this.name});

  factory LocationLookupModel.fromJson(Map<String, Object?> json) {
    final Object? rawId = json['id'] ?? json['governorateId'] ?? json['trafficUnitId'];
    final Object? rawName =
        json['name'] ?? json['governorateName'] ?? json['trafficUnitName'] ?? json['title'];
    return LocationLookupModel(
      id: rawId?.toString() ?? '',
      name: rawName?.toString() ?? '',
    );
  }
}

@immutable
class AppointmentSlotModel {
  final String startTime;
  final String? endTime;
  final bool isAvailable;

  const AppointmentSlotModel({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory AppointmentSlotModel.fromJson(Map<String, Object?> json) {
    final String startTime =
        (json['startTime'] ?? json['time'] ?? json['from'] ?? '').toString().trim();
    final String endTime = (json['endTime'] ?? json['to'] ?? '').toString().trim();
    final bool isAvailableRaw = json['isAvailable'] is bool ? json['isAvailable']! as bool : true;
    final String status = (json['status'] ?? '').toString().trim();
    final bool isAvailable = isAvailableRaw && status != 'ممتلئ' && status != 'غير متاح';

    return AppointmentSlotModel(
      startTime: startTime,
      endTime: (endTime.isEmpty || endTime == '00:00') ? null : endTime,
      isAvailable: isAvailable,
    );
  }

  String get displayLabel {
    if (endTime == null || endTime!.isEmpty) {
      return DateTimeFormatter.formatTimeSlot(startTime);
    }
    return DateTimeFormatter.formatTimeSlot('$startTime-$endTime');
  }
}

@immutable
class AppointmentBookingRequestModel {
  final String governorateId;
  final String trafficUnitId;
  final AppointmentType type;
  final String? serviceTypeOverride;
  final String date;
  final String startTime;
  /// The service request number returned from upload-documents (e.g. "LR-202612345").
  /// Required by the API to link the appointment to an active service application.
  final String? requestNumber;

  const AppointmentBookingRequestModel({
    required this.governorateId,
    required this.trafficUnitId,
    required this.type,
    this.serviceTypeOverride,
    required this.date,
    required this.startTime,
    this.requestNumber,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'requestNumber': requestNumber,
      'serviceType': serviceTypeOverride ?? type.serviceTypeValue,
      'governorateId': governorateId,
      'trafficUnitId': trafficUnitId,
      'date': date,
      'time': startTime,
    };
  }
}

@immutable
class AppointmentBookingResponseModel {
  final String serviceNumber;
  final String applicationId;
  final String date;
  final String startTime;
  final String status;
  final String type;
  final String? trafficUnitAddress;
  final String? workingHours;

  const AppointmentBookingResponseModel({
    required this.serviceNumber,
    required this.applicationId,
    required this.date,
    required this.startTime,
    required this.status,
    required this.type,
    this.trafficUnitAddress,
    this.workingHours,
  });

  factory AppointmentBookingResponseModel.fromJson(Map<String, Object?> json) {
    // Check if the data is nested under 'appointment' as per the new structure
    final Map<String, Object?> appointment = (json['appointment'] is Map)
        ? (json['appointment']! as Map<String, Object?>)
        : json;

    return AppointmentBookingResponseModel(
      serviceNumber: (appointment['bookingNumber'] ?? appointment['serviceNumber'] ?? '').toString(),
      applicationId: (appointment['applicationId'] ?? '').toString(),
      date: (appointment['date'] ?? '').toString(),
      startTime: (appointment['time'] ?? appointment['startTime'] ?? '').toString(),
      status: (appointment['status'] ?? '').toString(),
      type: (appointment['serviceName'] ?? appointment['type'] ?? '').toString(),
      trafficUnitAddress: appointment['trafficUnitAddress']?.toString(),
      workingHours: appointment['workingHours']?.toString(),
    );
  }
}

/// Snapshot of values currently produced by the renewal UI flow.
///
/// These values are read from existing local widget state and passed as-is to
/// the data handler. Some fields intentionally have no API mapping yet.
@immutable
class RenewalUiSnapshot {
  final bool isTermsAccepted;
  final String selectedLicenseNumber;
  final String? selectedGovernorate;
  final String? selectedTrafficUnit;
  final DateTime? selectedAppointmentDate;
  final String? selectedAppointmentSlot;

  const RenewalUiSnapshot({
    required this.isTermsAccepted,
    required this.selectedLicenseNumber,
    required this.selectedGovernorate,
    required this.selectedTrafficUnit,
    required this.selectedAppointmentDate,
    required this.selectedAppointmentSlot,
  });
}

@immutable
class AppointmentBookingMeta {
  final String bookingNumber;
  final String requestNumber;
  final String? trafficUnitAddress;
  final String? workingHours;

  const AppointmentBookingMeta({
    required this.bookingNumber,
    required this.requestNumber,
    this.trafficUnitAddress,
    this.workingHours,
  });
}

/// Renewal request payload model.
///
/// Mapped to `multipart/form-data` fields expected by
/// `POST /DrivingLicense/renewal-request`.
@immutable
class RenewalRequestModel {
  final String licenseNumber;
  final String? newCategory;

  const RenewalRequestModel({
    required this.licenseNumber,
    this.newCategory,
  });

  factory RenewalRequestModel.fromUiSnapshot({
    required RenewalUiSnapshot snapshot,
  }) {
    return RenewalRequestModel(
      licenseNumber: snapshot.selectedLicenseNumber.trim(),
    );
  }

  factory RenewalRequestModel.fromJson(Map<String, Object?> json) {
    return RenewalRequestModel(
      licenseNumber: (json['LicenseNumber'] ??
              json['licenseNumber'] ??
              json['drivingLicenseNumber'] ??
              '')
          .toString(),
      newCategory: json['NewCategory']?.toString(),
    );
  }

  Map<String, Object?> toJson() {
    final Map<String, Object?> json = <String, Object?>{
      'LicenseNumber': licenseNumber,
    };

    if (newCategory != null && newCategory!.trim().isNotEmpty) {
      json['NewCategory'] = newCategory!.trim();
    }

    return json;
  }
}

/// Renewal response model exposing only fields currently displayed by UI.
///
/// `requestNumber` is already displayed in booking summary UI (currently as a
/// static placeholder), so only that field is exposed.
@immutable
class RenewalResponseModel {
  final String requestNumber;

  const RenewalResponseModel({required this.requestNumber});

  factory RenewalResponseModel.fromJson(Map<String, Object?> json) {
    final Object? rawRequestNumber = json['requestNumber'];
    return RenewalResponseModel(
      requestNumber: rawRequestNumber?.toString() ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'requestNumber': requestNumber,
    };
  }
}

/// Address details for home delivery finalization.
@immutable
class FinalizeRenewalAddressModel {
  final String governorate;
  final String city;
  final String details;

  const FinalizeRenewalAddressModel({
    required this.governorate,
    required this.city,
    required this.details,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'governorate': governorate,
      'city': city,
      'details': details,
    };
  }
}

/// Request payload for `POST /DrivingLicense/finalize-renewal/{requestNumber}`.
///
/// `method`: 1 = TrafficUnit pickup, 2 = HomeDelivery.
/// `address`: required when method == 2.
@immutable
class FinalizeRenewalRequestModel {
  final int method;
  final FinalizeRenewalAddressModel? address;

  const FinalizeRenewalRequestModel({
    required this.method,
    this.address,
  });

  Map<String, Object?> toJson() {
    final Map<String, Object?> json = <String, Object?>{
      'method': method,
    };
    if (address != null) {
      json['address'] = address!.toJson();
    }
    return json;
  }
}

/// Response model for `POST /DrivingLicense/finalize-renewal/{requestNumber}`.
///
/// Maps the full license object returned after a successful finalization.
@immutable
class FinalizeRenewalFeesModel {
  final double baseFee;
  final double deliveryFee;
  final double totalAmount;

  const FinalizeRenewalFeesModel({
    required this.baseFee,
    required this.deliveryFee,
    required this.totalAmount,
  });

  factory FinalizeRenewalFeesModel.fromJson(Map<String, Object?> json) {
    return FinalizeRenewalFeesModel(
      baseFee: (json['baseFee'] as num? ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
    );
  }
}

@immutable
class FinalizeRenewalResponseModel {
  final int id;
  final String requestNumber;
  final String drivingLicenseNumber;
  final String category;
  final String governorate;
  final String licensingUnit;
  final String issueDate;
  final String expiryDate;
  final String status;
  final String citizenName;
  final String? deliveryMethod;
  final FinalizeRenewalFeesModel? fees;

  const FinalizeRenewalResponseModel({
    required this.id,
    required this.requestNumber,
    required this.drivingLicenseNumber,
    required this.category,
    required this.governorate,
    required this.licensingUnit,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    required this.citizenName,
    this.deliveryMethod,
    this.fees,
  });

  factory FinalizeRenewalResponseModel.fromJson(Map<String, Object?> json) {
    String? deliveryMethod;
    FinalizeRenewalFeesModel? fees;

    final Object? rawDelivery = json['delivery'];
    if (rawDelivery is Map<String, Object?>) {
      deliveryMethod = rawDelivery['method']?.toString();
    }

    final Object? rawFees = json['fees'];
    if (rawFees is Map<String, Object?>) {
      fees = FinalizeRenewalFeesModel.fromJson(rawFees);
    }

    return FinalizeRenewalResponseModel(
      id: json['id'] is int ? json['id']! as int : 0,
      requestNumber: (json['requestNumber'] ?? '').toString(),
      drivingLicenseNumber:
          (json['drivingLicenseNumber'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      governorate: (json['governorate'] ?? '').toString(),
      licensingUnit: (json['licensingUnit'] ?? '').toString(),
      issueDate: (json['issueDate'] ?? '').toString(),
      expiryDate: (json['expiryDate'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      citizenName: (json['citizenName'] ?? '').toString(),
      deliveryMethod: deliveryMethod,
      fees: fees,
    );
  }
}

/// Field flags for contract mismatches (UI-only and API-only fields).
class RenewalFieldMappingReport {
  static const List<String> uiFieldsWithoutApiMapping = <String>[
    'isTermsAccepted',
    'selectedGovernorate',
    'selectedTrafficUnit',
    'selectedAppointmentDate',
    'selectedAppointmentSlot',
  ];

  static const List<String> apiRequestFieldsWithoutUiSource = <String>[
    'NewCategory',
  ];

  static const List<String> apiResponseFieldsWithoutUiConsumer = <String>[
    'id',
    'currentCategory',
    'requestedCategory',
  ];
}

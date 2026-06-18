import 'package:equatable/equatable.dart';

enum SearchServiceType {
  drivingLicenseViolations,
  vehicleLicenseViolations,
  renewDrivingLicense,
  renewVehicleLicense,
  issueDrivingLicenseFirstTime,
  issueVehicleLicenseFirstTime,
  lostDamagedDrivingLicense,
  lostDamagedVehicleLicense,
}

class SearchSuggestion extends Equatable {
  final String title;
  final String category;
  final SearchServiceType serviceType;
  final List<String> keywords;

  const SearchSuggestion({
    required this.title,
    required this.category,
    required this.serviceType,
    required this.keywords,
  });

  @override
  List<Object?> get props => [title, category, serviceType, keywords];
}

// path: lib/features/home/presentation/widgets/search_navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:traffic/features/home/models/search_suggestion_model.dart';

// Import target navigation screens
import 'package:traffic/features/driving_license/presentation/screens/driving_license_screen.dart';
import 'package:traffic/features/driving_license/presentation/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/vehicle_license_screen.dart';
import 'package:traffic/features/vehicle_license/replacement_license/presentation/screens/vehicle_lost_license_selection_screen.dart';
import 'package:traffic/features/vehicle_license/violations_inquiry/presentation/screens/select_vehicle_violation_screen.dart';
import 'package:traffic/features/violations_inquiry/presentation/screens/select_license_screen.dart';
import 'package:traffic/features/lost_license/presentation/screens/lost_license_selection_screen.dart';

class SearchNavigationHelper {
  static void navigateToService(BuildContext context, SearchServiceType type) {
    Widget targetScreen;
    switch (type) {
      case SearchServiceType.drivingLicenseViolations:
        targetScreen = const SelectLicenseScreen();
        break;
      case SearchServiceType.vehicleLicenseViolations:
        targetScreen = const SelectVehicleViolationScreen();
        break;
      case SearchServiceType.renewDrivingLicense:
        targetScreen = const DrivingLicenseScreen(startWithRenewal: true);
        break;
      case SearchServiceType.renewVehicleLicense:
        targetScreen = const VehicleLicenseScreen(startWithRenewal: true);
        break;
      case SearchServiceType.issueDrivingLicenseFirstTime:
        targetScreen = const TermsAndConditionsScreen();
        break;
      case SearchServiceType.issueVehicleLicenseFirstTime:
        targetScreen = const VehicleLicenseScreen();
        break;
      case SearchServiceType.lostDamagedDrivingLicense:
        targetScreen = const LostLicenseSelectionScreen();
        break;
      case SearchServiceType.lostDamagedVehicleLicense:
        targetScreen = const VehicleLostLicenseSelectionScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }
}

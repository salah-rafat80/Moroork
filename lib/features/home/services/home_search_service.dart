import 'package:injectable/injectable.dart';
import '../models/search_suggestion_model.dart';

@lazySingleton
class HomeSearchService {
  final List<SearchSuggestion> allSuggestions = const [
    SearchSuggestion(
      title: 'استعلام وسداد مخالفات رخصة القيادة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.drivingLicenseViolations,
      keywords: ['مخالفات', 'استعلام', 'سداد', 'دفع', 'قيادة', 'رخصة القيادة', 'fine', 'violation', 'payment', 'driving'],
    ),
    SearchSuggestion(
      title: 'استعلام وسداد مخالفات رخصة المركبة',
      category: 'رخصة المركبة',
      serviceType: SearchServiceType.vehicleLicenseViolations,
      keywords: ['مخالفات', 'سيارة', 'مركبة', 'استعلام', 'سداد', 'دفع', 'رخصة المركبة', 'car', 'vehicle', 'fine', 'violation'],
    ),
    SearchSuggestion(
      title: 'تجديد رخصة القيادة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.renewDrivingLicense,
      keywords: ['تجديد', 'رخصة', 'قيادة', 'تجديد رخصة القيادة', 'driving', 'renew', 'renewal'],
    ),
    SearchSuggestion(
      title: 'تجديد رخصة المركبة',
      category: 'رخصة المركبة',
      serviceType: SearchServiceType.renewVehicleLicense,
      keywords: ['تجديد', 'مركبة', 'سيارة', 'تجديد رخصة السيارة', 'car', 'vehicle', 'renew', 'renewal'],
    ),
    SearchSuggestion(
      title: 'إصدار رخصة قيادة لأول مرة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.issueDrivingLicenseFirstTime,
      keywords: ['اصدار', 'اول مرة', 'جديد', 'رخصة قيادة', 'استخراج', 'driving', 'new', 'license'],
    ),
    SearchSuggestion(
      title: 'إصدار رخصة مركبة لأول مرة',
      category: 'رخصة المركبة',
      serviceType: SearchServiceType.issueVehicleLicenseFirstTime,
      keywords: ['اصدار', 'اول مرة', 'جديد', 'رخصة مركبة', 'ترخيص', 'سيارة', 'car', 'new', 'license'],
    ),
    SearchSuggestion(
      title: 'بدل فاقد / تالف رخصة قيادة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.lostDamagedDrivingLicense,
      keywords: ['بدل فاقد', 'تالف', 'ضائعة', 'مفقودة', 'رخصة قيادة', 'lost', 'damaged', 'license', 'driving'],
    ),
    SearchSuggestion(
      title: 'بدل فاقد / تالف رخصة مركبة',
      category: 'رخصة المركبة',
      serviceType: SearchServiceType.lostDamagedVehicleLicense,
      keywords: ['بدل فاقد', 'تالف', 'ضائعة', 'مفقودة', 'رخصة مركبة', 'lost', 'damaged', 'license', 'vehicle'],
    ),
  ];

  List<SearchSuggestion> search(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      // Default top 3 quick suggestions
      return allSuggestions.take(3).toList();
    }
    return allSuggestions.where((suggestion) {
      final matchesTitle = suggestion.title.toLowerCase().contains(cleanQuery);
      final matchesKeywords = suggestion.keywords.any((kw) => kw.toLowerCase().contains(cleanQuery));
      return matchesTitle || matchesKeywords;
    }).toList();
  }
}

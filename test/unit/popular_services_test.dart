// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/home/data/home_mock_data.dart';
import 'package:traffic/features/home/models/search_suggestion_model.dart';
import 'package:traffic/features/home/services/home_search_service.dart';

void main() {
  // ════════════════════════════════════════════════════════════
  // HomeMockData
  // ════════════════════════════════════════════════════════════
  group('HomeMockData — الخدمات الشائعة', () {
    test('popularServices تحتوي على 3 خدمات', () {
      expect(HomeMockData.popularServices.length, equals(3));
    });

    test('كل خدمة شائعة لها title و icon و color', () {
      for (final svc in HomeMockData.popularServices) {
        expect(svc.containsKey('title'), isTrue,
            reason: 'خدمة بدون title: $svc');
        expect(svc.containsKey('icon'), isTrue,
            reason: 'خدمة بدون icon: $svc');
        expect(svc.containsKey('color'), isTrue,
            reason: 'خدمة بدون color: $svc');
      }
    });

    test('أسماء الخدمات الشائعة الثلاثة صحيحة', () {
      final titles =
          HomeMockData.popularServices.map((s) => s['title'] as String).toList();
      expect(titles.any((t) => t.contains('مخالفات')), isTrue,
          reason: 'الخدمة الأولى يجب أن تكون استعلام مخالفات');
      expect(titles.any((t) => t.contains('رخصة') && t.contains('قيادة')),
          isTrue, reason: 'يجب أن توجد خدمة تجديد رخصة قيادة');
      expect(titles.any((t) => t.contains('رخصة') && t.contains('مركبة')),
          isTrue, reason: 'يجب أن توجد خدمة تجديد رخصة مركبة');
    });

    test('mainServices تحتوي على خدمتين أساسيتين', () {
      expect(HomeMockData.mainServices.length, equals(2));
    });

    test('mainServices لها title و icon و route', () {
      for (final svc in HomeMockData.mainServices) {
        expect(svc.containsKey('title'), isTrue);
        expect(svc.containsKey('icon'), isTrue);
        expect(svc.containsKey('route'), isTrue);
      }
    });

    test('routes الخدمات الأساسية صحيحة', () {
      final routes =
          HomeMockData.mainServices.map((s) => s['route'] as String).toList();
      expect(routes, contains('/driving-license'));
      expect(routes, contains('/vehicle-license'));
    });

    test('smartAssistant له title و icon', () {
      expect(HomeMockData.smartAssistant.containsKey('title'), isTrue);
      expect(HomeMockData.smartAssistant.containsKey('icon'), isTrue);
      expect(HomeMockData.smartAssistant['title'], equals('المساعد الذكي'));
    });
  });

  // ════════════════════════════════════════════════════════════
  // HomeSearchService — البحث
  // ════════════════════════════════════════════════════════════
  group('HomeSearchService — search()', () {
    late HomeSearchService service;

    setUp(() {
      service = HomeSearchService();
    });

    // ────────────────────────────────────────────────
    // استعلام فارغ → أول 3 نتائج
    // ────────────────────────────────────────────────
    test('query فارغ يُرجع أول 3 اقتراحات', () {
      final results = service.search('');
      expect(results.length, equals(3));
    });

    test('query مسافات فقط يُرجع أول 3 اقتراحات', () {
      final results = service.search('   ');
      expect(results.length, equals(3));
    });

    // ────────────────────────────────────────────────
    // استعلام بالعنوان
    // ────────────────────────────────────────────────
    test('"تجديد" يُرجع نتائج تجديد القيادة والمركبة', () {
      final results = service.search('تجديد');
      expect(results.length, greaterThanOrEqualTo(2));
      expect(
        results.any((r) => r.serviceType == SearchServiceType.renewDrivingLicense),
        isTrue,
      );
      expect(
        results.any((r) => r.serviceType == SearchServiceType.renewVehicleLicense),
        isTrue,
      );
    });

    test('"رخصة القيادة" يُرجع خدمات القيادة فقط', () {
      final results = service.search('رخصة القيادة');
      expect(results, isNotEmpty);
      expect(
        results.every((r) => r.category == 'رخصة القيادة'),
        isTrue,
      );
    });

    test('"مخالفات" يُرجع خدمتَي الاستعلام عن المخالفات', () {
      final results = service.search('مخالفات');
      expect(results.length, greaterThanOrEqualTo(2));
      expect(
        results.any(
          (r) => r.serviceType == SearchServiceType.drivingLicenseViolations,
        ),
        isTrue,
      );
      expect(
        results.any(
          (r) => r.serviceType == SearchServiceType.vehicleLicenseViolations,
        ),
        isTrue,
      );
    });

    test('"إصدار" يُرجع خدمات الإصدار لأول مرة', () {
      final results = service.search('إصدار');
      expect(results, isNotEmpty);
      expect(
        results.any(
            (r) => r.serviceType == SearchServiceType.issueDrivingLicenseFirstTime),
        isTrue,
      );
    });

    test('"بدل فاقد" يُرجع خدمات البدل', () {
      final results = service.search('بدل فاقد');
      expect(results, isNotEmpty);
      expect(
        results.any(
            (r) => r.serviceType == SearchServiceType.lostDamagedDrivingLicense),
        isTrue,
      );
    });

    // ────────────────────────────────────────────────
    // استعلام بالـ keywords
    // ────────────────────────────────────────────────
    test('"renew" (English keyword) يُرجع نتائج التجديد', () {
      final results = service.search('renew');
      expect(results, isNotEmpty);
      expect(
        results.any((r) =>
            r.serviceType == SearchServiceType.renewDrivingLicense ||
            r.serviceType == SearchServiceType.renewVehicleLicense),
        isTrue,
      );
    });

    test('"fine" (English keyword) يُرجع نتائج المخالفات', () {
      final results = service.search('fine');
      expect(results, isNotEmpty);
      expect(
        results.any((r) =>
            r.serviceType == SearchServiceType.drivingLicenseViolations ||
            r.serviceType == SearchServiceType.vehicleLicenseViolations),
        isTrue,
      );
    });

    test('"lost" (English keyword) يُرجع خدمات البدل', () {
      final results = service.search('lost');
      expect(results, isNotEmpty);
      expect(
        results.any((r) =>
            r.serviceType == SearchServiceType.lostDamagedDrivingLicense ||
            r.serviceType == SearchServiceType.lostDamagedVehicleLicense),
        isTrue,
      );
    });

    test('"سداد" keyword يُرجع نتائج المخالفات', () {
      final results = service.search('سداد');
      expect(results, isNotEmpty);
      expect(
        results.any((r) =>
            r.serviceType == SearchServiceType.drivingLicenseViolations ||
            r.serviceType == SearchServiceType.vehicleLicenseViolations),
        isTrue,
      );
    });

    // ────────────────────────────────────────────────
    // case-insensitive
    // ────────────────────────────────────────────────
    test('البحث case-insensitive — "RENEW" يُرجع نفس نتائج "renew"', () {
      final lower = service.search('renew');
      final upper = service.search('RENEW');
      expect(upper.length, equals(lower.length));
    });

    // ────────────────────────────────────────────────
    // عدم وجود نتائج
    // ────────────────────────────────────────────────
    test('query لا يطابق شيئاً يُرجع قائمة فارغة', () {
      final results = service.search('xyzبلاهلاه123');
      expect(results, isEmpty);
    });

    test('"مركبة" تُعطي نتائج رخصة المركبة', () {
      final results = service.search('مركبة');
      expect(results, isNotEmpty);
      expect(
        results.every((r) => r.category == 'رخصة المركبة'),
        isTrue,
      );
    });

    // ────────────────────────────────────────────────
    // allSuggestions — بيانات ثابتة
    // ────────────────────────────────────────────────
    test('allSuggestions تحتوي على 8 خدمات', () {
      expect(service.allSuggestions.length, equals(8));
    });

    test('كل suggestion له keywords غير فارغة', () {
      for (final s in service.allSuggestions) {
        expect(s.keywords, isNotEmpty,
            reason: '${s.title} بدون keywords');
      }
    });

    test('كل suggestion له title وcategory', () {
      for (final s in service.allSuggestions) {
        expect(s.title, isNotEmpty);
        expect(s.category, isNotEmpty);
      }
    });

    test('جميع SearchServiceTypes موجودة في allSuggestions', () {
      final types = service.allSuggestions.map((s) => s.serviceType).toSet();
      expect(types, contains(SearchServiceType.drivingLicenseViolations));
      expect(types, contains(SearchServiceType.vehicleLicenseViolations));
      expect(types, contains(SearchServiceType.renewDrivingLicense));
      expect(types, contains(SearchServiceType.renewVehicleLicense));
      expect(types, contains(SearchServiceType.issueDrivingLicenseFirstTime));
      expect(types, contains(SearchServiceType.issueVehicleLicenseFirstTime));
      expect(types, contains(SearchServiceType.lostDamagedDrivingLicense));
      expect(types, contains(SearchServiceType.lostDamagedVehicleLicense));
    });
  });

  // ════════════════════════════════════════════════════════════
  // SearchSuggestion — Equatable
  // ════════════════════════════════════════════════════════════
  group('SearchSuggestion — Equatable', () {
    const s1 = SearchSuggestion(
      title: 'تجديد رخصة القيادة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.renewDrivingLicense,
      keywords: ['تجديد', 'رخصة'],
    );
    const s2 = SearchSuggestion(
      title: 'تجديد رخصة القيادة',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.renewDrivingLicense,
      keywords: ['تجديد', 'رخصة'],
    );
    const s3 = SearchSuggestion(
      title: 'مخالفات',
      category: 'رخصة القيادة',
      serviceType: SearchServiceType.drivingLicenseViolations,
      keywords: ['مخالفات'],
    );

    test('نفس البيانات → متساويان', () {
      expect(s1, equals(s2));
    });

    test('بيانات مختلفة → غير متساويان', () {
      expect(s1, isNot(equals(s3)));
    });
  });
}

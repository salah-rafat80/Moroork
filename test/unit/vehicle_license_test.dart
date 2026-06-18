// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_model.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_type_model.dart';
import 'package:traffic/features/vehicle_license/data/models/vehicle_license_finalize_model.dart';
import 'package:traffic/features/vehicle_license/data/models/issue_replacement_response_model.dart';

void main() {
  // ════════════════════════════════════════════════════════
  // VehicleLicenseModel
  // ════════════════════════════════════════════════════════
  group('VehicleLicenseModel — parsing & edge cases', () {
    test('JSON فارغ تماماً يعطي قيم افتراضية آمنة لمنع توقف التطبيق', () {
      final model = VehicleLicenseModel.fromJson({});
      expect(model.id, equals(0));
      expect(model.vehicleLicenseNumber, equals(''));
      expect(model.status, equals(LicenseStatus.valid));
      expect(model.hasUnpaidViolations, isFalse);
      expect(model.plateNumber, isNull);
    });

    test('توافق الحقول مع المسميات القديمة والجديدة', () {
      final model = VehicleLicenseModel.fromJson({
        'id': 100,
        'vehicleLicenseNumber': 'VL-999',
        'category': 'ملاكي',
      });
      expect(model.id, equals(100));
      expect(model.vehicleLicenseNumber, equals('VL-999'));
      expect(model.licenseNumber, equals('VL-999')); // getter
      expect(model.licenseType, equals('ملاكي'));    // getter
    });

    group('تحويل الحالة _statusFromJson (بناءً على أسوأ الاحتمالات)', () {
      LicenseStatus parseStatus(dynamic statusVal) {
        return VehicleLicenseModel.fromJson({'status': statusVal}).status;
      }

      test('قيمة integer صحيحة تحول لـ Enum index', () {
        expect(parseStatus(0), equals(LicenseStatus.valid));
        expect(parseStatus(1), equals(LicenseStatus.expired));
        expect(parseStatus(2), equals(LicenseStatus.withdrawn));
        expect(parseStatus(3), equals(LicenseStatus.suspended));
      });

      test('حالة "منتهية" أو "expire" → LicenseStatus.expired', () {
        expect(parseStatus('expire'), equals(LicenseStatus.expired));
        expect(parseStatus('EXPIRED'), equals(LicenseStatus.expired));
        expect(parseStatus('منتهية'), equals(LicenseStatus.expired));
      });

      test('حالة "مسحوبة" أو "withdraw" → LicenseStatus.withdrawn', () {
        expect(parseStatus('withdraw'), equals(LicenseStatus.withdrawn));
        expect(parseStatus('WITHDRAWN'), equals(LicenseStatus.withdrawn));
        expect(parseStatus('مسحوبة'), equals(LicenseStatus.withdrawn));
      });

      test('حالة "موقوفة" أو "suspend" → LicenseStatus.suspended', () {
        expect(parseStatus('suspend'), equals(LicenseStatus.suspended));
        expect(parseStatus('SUSPENDED'), equals(LicenseStatus.suspended));
        expect(parseStatus('موقوفة'), equals(LicenseStatus.suspended));
      });

      test('حالة غير معروفة أو تالفة (مثل "corrupted_text") → fallback لـ LicenseStatus.valid لمنع كراش', () {
        expect(parseStatus('corrupted_text'), equals(LicenseStatus.valid));
        expect(parseStatus(999), equals(LicenseStatus.valid)); // index خارج الحدود
        expect(parseStatus(null), equals(LicenseStatus.valid));
      });
    });

    test('التحقق من بيانات dummyLicenses المضمنة', () {
      final dummies = VehicleLicenseModel.dummyLicenses;
      expect(dummies, isNotEmpty);
      expect(dummies.first.vehicleLicenseNumber, equals('VL-100001'));
      expect(dummies.first.plateNumber, equals('٤٢١٣ س ج ر'));
    });
  });

  // ════════════════════════════════════════════════════════
  // VehicleTypeModel & Brands & Models
  // ════════════════════════════════════════════════════════
  group('VehicleTypeModel — هيكل أنواع المركبات والماركات والموديلات', () {
    test('تحليل JSON سليم مع الماركات والموديلات', () {
      final json = {
        'value': 2,
        'name': 'Taxi',
        'nameAr': 'تاكسي',
        'brands': [
          {
            'name': 'Hyundai',
            'nameAr': 'هيونداي',
            'models': [
              {'name': 'Elantra', 'nameAr': 'إلنترا'},
              {'name': 'Accent', 'nameAr': ''}
            ]
          }
        ]
      };

      final type = VehicleTypeModel.fromJson(json);
      expect(type.value, equals(2));
      expect(type.displayName, equals('تاكسي'));
      expect(type.brandNames, contains('هيونداي'));

      final brand = type.brands.first;
      expect(brand.displayName, equals('هيونداي'));
      expect(brand.modelNames, contains('إلنترا'));
      expect(brand.modelNames, contains('Accent')); // fallback to English since nameAr is empty
    });

    test('تعامل آمن مع القوائم الفارغة أو الـ null في الماركات والموديلات', () {
      final json = {
        'value': 1,
        'name': 'Truck',
        'nameAr': '',
        'brands': null // أسوأ احتمال: سيرفر يرجع null
      };

      final type = VehicleTypeModel.fromJson(json);
      expect(type.displayName, equals('Truck')); // fallback to English name
      expect(type.brands, isEmpty);
      expect(type.brandNames, isEmpty);
    });

    test('فشل الموديل أو الماركة في الحصول على nameAr يعود للـ English name', () {
      const brand = VehicleBrandModel(name: 'Kia', nameAr: '', models: []);
      expect(brand.displayName, equals('Kia'));

      const model = VehicleModelItem(name: 'Cerato', nameAr: '');
      expect(model.displayName, equals('Cerato'));
    });

    test('التحقق من قائمة fallbackTypes لضمان عدم تعطل واجهة الاختيار عند فشل السيرفر', () {
      final fallbacks = VehicleTypeModel.fallbackTypes;
      expect(fallbacks.length, equals(7));
      expect(fallbacks.any((t) => t.nameAr == 'ملاكي'), isTrue);
      expect(fallbacks.any((t) => t.nameAr == 'دراجة نارية'), isTrue);
    });
  });

  // ════════════════════════════════════════════════════════
  // InsuranceCompanyModel
  // ════════════════════════════════════════════════════════
  group('InsuranceCompanyModel — شركات التأمين وتجنب الأخطاء', () {
    test('تحليل سليم لبيانات الشركة والرسوم', () {
      final json = {
        'id': 12,
        'name': 'Misr Insurance',
        'nameAr': 'مصر للتأمين',
        'fee': 450.50,
        'description': 'Comprehensive policy',
        'descriptionAr': 'تأمين شامل مميز',
        'logoPath': '/logos/misr.png'
      };

      final comp = InsuranceCompanyModel.fromJson(json);
      expect(comp.id, equals(12));
      expect(comp.displayName, equals('مصر للتأمين'));
      expect(comp.displayDescription, equals('تأمين شامل مميز'));
      expect(comp.fee, equals(450.50));
      expect(comp.logoPath, equals('/logos/misr.png'));
    });

    test('تعامل آمن مع null أو قيم غير صحيحة للرسوم (أسوأ الاحتمالات)', () {
      final json = {
        'id': 3,
        'name': 'Company X',
        'fee': null, // أسوأ احتمال
        'description': 'Description',
      };

      final comp = InsuranceCompanyModel.fromJson(json);
      expect(comp.fee, equals(0.0));
      expect(comp.displayName, equals('Company X'));
      expect(comp.displayDescription, equals('Description'));
    });

    test('التحويل للـ legacy Map المستخدم في بطاقات واجهة المستخدم دون كراش', () {
      const comp = InsuranceCompanyModel(
        id: 5,
        name: 'Allianz',
        nameAr: 'أليانز',
        fee: 300.0,
        description: 'Details',
        descriptionAr: 'تفاصيل',
        logoPath: 'path/to/logo',
      );

      final map = comp.toMap();
      expect(map['id'], equals(5));
      expect(map['name'], equals('أليانز'));
      expect(map['details'], equals('تفاصيل'));
      expect(map['fee'], equals(300.0));
      expect(map['logoPath'], equals('path/to/logo'));
    });
  });

  // ════════════════════════════════════════════════════════
  // VehicleLicenseFinalizeResponseModel
  // ════════════════════════════════════════════════════════
  group('VehicleLicenseFinalizeResponseModel — إنهاء الطلب', () {
    test('تحليل رقم الطلب والرسوم بشكل صحيح من حقول بديلة لضمان المرونة', () {
      final json = {
        'serviceRequestNumber': 'VR-882211',
        'fees': {
          'baseFee': 1000.0,
          'deliveryFee': 40.0,
          'totalAmount': 1040.0,
        }
      };

      final response = VehicleLicenseFinalizeResponseModel.fromJson(json);
      expect(response.requestNumber, equals('VR-882211'));
      expect(response.fees, isNotNull);
      expect(response.fees!.baseFee, equals(1000.0));
      expect(response.fees!.deliveryFee, equals(40.0));
      expect(response.fees!.totalAmount, equals(1040.0));
    });

    test('تحليل رقم الطلب من requestNumber العادي', () {
      final json = {
        'requestNumber': 'VR-123',
      };
      final response = VehicleLicenseFinalizeResponseModel.fromJson(json);
      expect(response.requestNumber, equals('VR-123'));
      expect(response.fees, isNull);
    });

    test('JSON فارغ → رقم طلب فارغ ورسوم null بدلاً من throwing exception', () {
      final response = VehicleLicenseFinalizeResponseModel.fromJson({});
      expect(response.requestNumber, equals(''));
      expect(response.fees, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // IssueReplacementResponseModel (Vehicle License)
  // ════════════════════════════════════════════════════════
  group('IssueReplacementResponseModel (Vehicle License) — بدل فاقد/تالف', () {
    test('تحليل ناجح مع الرسوم والرسائل الجانبية', () {
      final json = {
        'requestNumber': 'VR-REP-990',
        'status': 'UnderProcess',
        'citizenNationalId': '29901011234567',
        'serviceType': 'LostReplacement',
        'message': 'تم استلام طلب بدل الفاقد بنجاح',
        'fees': {
          'baseFee': 250.0,
          'deliveryFee': 30.0,
          'totalAmount': 280.0
        }
      };

      final response = IssueReplacementResponseModel.fromJson(json);
      expect(response.requestNumber, equals('VR-REP-990'));
      expect(response.status, equals('UnderProcess'));
      expect(response.citizenNationalId, equals('29901011234567'));
      expect(response.serviceType, equals('LostReplacement'));
      expect(response.message, equals('تم استلام طلب بدل الفاقد بنجاح'));
      expect(response.fees, isNotNull);
      expect(response.fees!.totalAmount, equals(280.0));
    });

    test('JSON فارغ → تعامل آمن مع غياب الرسوم والحقول الأساسية لمنع تجمد التطبيق', () {
      final response = IssueReplacementResponseModel.fromJson({});
      expect(response.requestNumber, equals(''));
      expect(response.status, equals(''));
      expect(response.citizenNationalId, equals(''));
      expect(response.serviceType, equals(''));
      expect(response.fees, isNull);
      expect(response.message, isNull);
    });
  });
}

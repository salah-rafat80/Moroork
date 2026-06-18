// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/core/utils/date_time_formatter.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'package:traffic/features/driving_license/data/models/driving_renewal_model.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_finalize_model.dart';
import 'package:traffic/features/driving_license/data/models/issue_replacement_response_model.dart';
import 'package:traffic/features/driving_license/domain/enums/license_status.dart';

void main() {
  // ════════════════════════════════════════════════════════
  // DrivingLicenseModel
  // ════════════════════════════════════════════════════════
  group('DrivingLicenseModel — fromJson', () {
    test('قيم افتراضية عند JSON فارغ', () {
      final m = DrivingLicenseModel.fromJson({});
      expect(m.id, equals(0));
      expect(m.drivingLicenseNumber, equals(''));
      expect(m.status, equals(LicenseStatus.valid));
      expect(m.hasUnpaidViolations, isFalse);
    });

    test('يُفسر الحقول الأساسية', () {
      final m = DrivingLicenseModel.fromJson({
        'id': 5,
        'licenseNumber': '12345678901234',
        'category': 'خاصة',
        'governorate': 'القاهرة',
        'licensingUnit': 'وحدة مرور مصر',
        'issueDate': '01/01/2020',
        'expiryDate': '01/01/2026',
        'citizenName': 'أحمد محمد',
        'hasUnpaidViolations': true,
      });
      expect(m.id, equals(5));
      expect(m.drivingLicenseNumber, equals('12345678901234'));
      expect(m.licenseNumber, equals('12345678901234')); // compat getter
      expect(m.licenseType, equals('خاصة'));             // compat getter
      expect(m.governorate, equals('القاهرة'));
      expect(m.citizenName, equals('أحمد محمد'));
      expect(m.hasUnpaidViolations, isTrue);
    });

    group('_statusFromJson — تحويل الحالة', () {
      LicenseStatus parse(dynamic v) =>
          DrivingLicenseModel.fromJson({'status': v}).status;

      test('"expired" → LicenseStatus.expired', () =>
          expect(parse('expired'), equals(LicenseStatus.expired)));
      test('"منتهية" → LicenseStatus.expired', () =>
          expect(parse('منتهية'), equals(LicenseStatus.expired)));
      test('"LICENCE_EXPIRED" → LicenseStatus.expired', () =>
          expect(parse('LICENCE_EXPIRED'), equals(LicenseStatus.expired)));
      test('"withdrawn" → LicenseStatus.withdrawn', () =>
          expect(parse('withdrawn'), equals(LicenseStatus.withdrawn)));
      test('"مسحوبة" → LicenseStatus.withdrawn', () =>
          expect(parse('مسحوبة'), equals(LicenseStatus.withdrawn)));
      test('"valid" → LicenseStatus.valid', () =>
          expect(parse('valid'), equals(LicenseStatus.valid)));
      test('"سارية" → LicenseStatus.valid', () =>
          expect(parse('سارية'), equals(LicenseStatus.valid)));
      test('null → LicenseStatus.valid (default)', () =>
          expect(parse(null), equals(LicenseStatus.valid)));
      test('int index 0 → LicenseStatus.valid', () =>
          expect(parse(0), equals(LicenseStatus.valid)));
      test('int index 1 → LicenseStatus.expired', () =>
          expect(parse(1), equals(LicenseStatus.expired)));
    });

    test('dummyLicenses تحتوي على 2 رخصة', () {
      expect(DrivingLicenseModel.dummyLicenses.length, equals(2));
    });

    test('أول رخصة dummy مسحوبة', () {
      expect(
        DrivingLicenseModel.dummyLicenses.first.status,
        equals(LicenseStatus.withdrawn),
      );
    });

    test('ثاني رخصة dummy لها مخالفات غير مدفوعة', () {
      expect(
        DrivingLicenseModel.dummyLicenses.last.hasUnpaidViolations,
        isTrue,
      );
    });
  });

  // ════════════════════════════════════════════════════════
  // AppointmentType
  // ════════════════════════════════════════════════════════
  group('AppointmentType', () {
    test('medical.apiValue == "Medical"', () =>
        expect(AppointmentType.medical.apiValue, equals('Medical')));
    test('driving.apiValue == "Driving"', () =>
        expect(AppointmentType.driving.apiValue, equals('Driving')));
    test('technical.apiValue == "Technical"', () =>
        expect(AppointmentType.technical.apiValue, equals('Technical')));
    test('medical.serviceTypeValue == "كشف طبي"', () =>
        expect(AppointmentType.medical.serviceTypeValue, equals('كشف طبي')));
    test('driving.serviceTypeValue == "اختبار قيادة"', () =>
        expect(AppointmentType.driving.serviceTypeValue, equals('اختبار قيادة')));
    test('technical.serviceTypeValue == "فحص فني"', () =>
        expect(AppointmentType.technical.serviceTypeValue, equals('فحص فني')));
  });

  // ════════════════════════════════════════════════════════
  // LocationLookupModel
  // ════════════════════════════════════════════════════════
  group('LocationLookupModel — fromJson', () {
    test('يُفسر id و name', () {
      final m = LocationLookupModel.fromJson({'id': '10', 'name': 'الجيزة'});
      expect(m.id, equals('10'));
      expect(m.name, equals('الجيزة'));
    });

    test('يقبل governorateId كـ id', () {
      final m = LocationLookupModel.fromJson(
          {'governorateId': '5', 'governorateName': 'القاهرة'});
      expect(m.id, equals('5'));
      expect(m.name, equals('القاهرة'));
    });

    test('يقبل trafficUnitId', () {
      final m = LocationLookupModel.fromJson(
          {'trafficUnitId': '99', 'trafficUnitName': 'مرور الدقي'});
      expect(m.id, equals('99'));
      expect(m.name, equals('مرور الدقي'));
    });

    test('يقبل title كـ name', () {
      final m = LocationLookupModel.fromJson({'id': '1', 'title': 'المنيا'});
      expect(m.name, equals('المنيا'));
    });

    test('JSON فارغ → قيم فارغة', () {
      final m = LocationLookupModel.fromJson({});
      expect(m.id, equals(''));
      expect(m.name, equals(''));
    });
  });

  // ════════════════════════════════════════════════════════
  // AppointmentSlotModel
  // ════════════════════════════════════════════════════════
  group('AppointmentSlotModel — fromJson', () {
    test('startTime من حقل startTime', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'isAvailable': true});
      expect(s.startTime, equals('09:00'));
      expect(s.isAvailable, isTrue);
    });

    test('startTime من حقل time', () {
      final s = AppointmentSlotModel.fromJson({'time': '10:30'});
      expect(s.startTime, equals('10:30'));
    });

    test('startTime من حقل from', () {
      final s = AppointmentSlotModel.fromJson({'from': '11:00'});
      expect(s.startTime, equals('11:00'));
    });

    test('endTime يكون null لو فارغ', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'endTime': ''});
      expect(s.endTime, isNull);
    });

    test('endTime يكون null لو "00:00"', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'endTime': '00:00'});
      expect(s.endTime, isNull);
    });

    test('endTime يُحفظ لو موجود وغير "00:00"', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'endTime': '10:00'});
      expect(s.endTime, equals('10:00'));
    });

    test('status "ممتلئ" يجعل isAvailable false', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'isAvailable': true, 'status': 'ممتلئ'});
      expect(s.isAvailable, isFalse);
    });

    test('status "غير متاح" يجعل isAvailable false', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'isAvailable': true, 'status': 'غير متاح'});
      expect(s.isAvailable, isFalse);
    });

    test('isAvailable = false من JSON يُحافظ عليه', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'isAvailable': false});
      expect(s.isAvailable, isFalse);
    });

    test('displayLabel بدون endTime يُرجع الوقت المنسق', () {
      final s = AppointmentSlotModel.fromJson({'startTime': '09:00'});
      expect(s.displayLabel, equals('09:00 ص'));
    });

    test('displayLabel مع endTime يُرجع نطاق', () {
      final s = AppointmentSlotModel.fromJson(
          {'startTime': '09:00', 'endTime': '10:00'});
      expect(s.displayLabel, contains('ص'));
    });
  });

  // ════════════════════════════════════════════════════════
  // AppointmentBookingRequestModel — toJson
  // ════════════════════════════════════════════════════════
  group('AppointmentBookingRequestModel — toJson', () {
    test('يُنتج JSON صحيح لموعد طبي', () {
      const req = AppointmentBookingRequestModel(
        governorateId: '3',
        trafficUnitId: '12',
        type: AppointmentType.medical,
        date: '2026-05-01',
        startTime: '09:00',
        requestNumber: 'LR-101',
      );
      final json = req.toJson();
      expect(json['requestNumber'], equals('LR-101'));
      expect(json['serviceType'], equals('كشف طبي'));
      expect(json['governorateId'], equals('3'));
      expect(json['trafficUnitId'], equals('12'));
      expect(json['date'], equals('2026-05-01'));
      expect(json['time'], equals('09:00'));
    });

    test('serviceTypeOverride يُحل محل serviceTypeValue', () {
      const req = AppointmentBookingRequestModel(
        governorateId: '1',
        trafficUnitId: '2',
        type: AppointmentType.driving,
        date: '2026-06-01',
        startTime: '10:00',
        serviceTypeOverride: 'اختبار قيادة مخصص',
      );
      final json = req.toJson();
      expect(json['serviceType'], equals('اختبار قيادة مخصص'));
    });

    test('requestNumber يكون null لو مش محدد', () {
      const req = AppointmentBookingRequestModel(
        governorateId: '1',
        trafficUnitId: '2',
        type: AppointmentType.technical,
        date: '2026-06-01',
        startTime: '11:00',
      );
      expect(req.toJson()['requestNumber'], isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // AppointmentBookingResponseModel — fromJson
  // ════════════════════════════════════════════════════════
  group('AppointmentBookingResponseModel — fromJson', () {
    test('يُفسر nested appointment', () {
      final resp = AppointmentBookingResponseModel.fromJson({
        'appointment': {
          'bookingNumber': 'BK-999',
          'applicationId': 'APP-1',
          'date': '2026-05-01',
          'time': '09:00',
          'status': 'confirmed',
          'serviceName': 'كشف طبي',
          'trafficUnitAddress': 'شارع النيل',
          'workingHours': '8:00 ص - 4:00 م',
        }
      });
      expect(resp.serviceNumber, equals('BK-999'));
      expect(resp.applicationId, equals('APP-1'));
      expect(resp.date, equals('2026-05-01'));
      expect(resp.startTime, equals('09:00'));
      expect(resp.status, equals('confirmed'));
      expect(resp.type, equals('كشف طبي'));
      expect(resp.trafficUnitAddress, equals('شارع النيل'));
      expect(resp.workingHours, equals('8:00 ص - 4:00 م'));
    });

    test('يُفسر flat JSON بدون appointment wrapper', () {
      final resp = AppointmentBookingResponseModel.fromJson({
        'serviceNumber': 'SN-100',
        'applicationId': 'APP-2',
        'date': '2026-06-01',
        'startTime': '10:00',
        'status': 'pending',
        'type': 'اختبار قيادة',
      });
      expect(resp.serviceNumber, equals('SN-100'));
      expect(resp.startTime, equals('10:00'));
    });

    test('JSON فارغ → قيم فارغة', () {
      final resp = AppointmentBookingResponseModel.fromJson({});
      expect(resp.serviceNumber, equals(''));
      expect(resp.trafficUnitAddress, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // RenewalRequestModel
  // ════════════════════════════════════════════════════════
  group('RenewalRequestModel', () {
    test('fromUiSnapshot يأخذ selectedLicenseNumber', () {
      const snapshot = RenewalUiSnapshot(
        isTermsAccepted: true,
        selectedLicenseNumber: '  12345678901234  ',
        selectedGovernorate: null,
        selectedTrafficUnit: null,
        selectedAppointmentDate: null,
        selectedAppointmentSlot: null,
      );
      final req = RenewalRequestModel.fromUiSnapshot(snapshot: snapshot);
      expect(req.licenseNumber, equals('12345678901234'));
    });

    test('toJson يُنتج LicenseNumber', () {
      const req = RenewalRequestModel(licenseNumber: 'ABC123');
      expect(req.toJson()['LicenseNumber'], equals('ABC123'));
    });

    test('toJson مع newCategory يضيف NewCategory', () {
      const req = RenewalRequestModel(licenseNumber: 'ABC', newCategory: 'عامة');
      expect(req.toJson()['NewCategory'], equals('عامة'));
    });

    test('toJson بدون newCategory لا يضيف NewCategory', () {
      const req = RenewalRequestModel(licenseNumber: 'ABC');
      expect(req.toJson().containsKey('NewCategory'), isFalse);
    });

    test('fromJson من LicenseNumber', () {
      final req = RenewalRequestModel.fromJson({'LicenseNumber': 'XYZ789'});
      expect(req.licenseNumber, equals('XYZ789'));
    });

    test('fromJson من licenseNumber (camelCase)', () {
      final req = RenewalRequestModel.fromJson({'licenseNumber': 'CAMEL123'});
      expect(req.licenseNumber, equals('CAMEL123'));
    });
  });

  // ════════════════════════════════════════════════════════
  // RenewalResponseModel
  // ════════════════════════════════════════════════════════
  group('RenewalResponseModel', () {
    test('fromJson يُفسر requestNumber', () {
      final r = RenewalResponseModel.fromJson({'requestNumber': 'DR-800'});
      expect(r.requestNumber, equals('DR-800'));
    });

    test('fromJson JSON فارغ → requestNumber فارغ', () {
      final r = RenewalResponseModel.fromJson({});
      expect(r.requestNumber, equals(''));
    });

    test('toJson يُنتج requestNumber', () {
      const r = RenewalResponseModel(requestNumber: 'DR-801');
      expect(r.toJson()['requestNumber'], equals('DR-801'));
    });
  });

  // ════════════════════════════════════════════════════════
  // FinalizeRenewalFeesModel
  // ════════════════════════════════════════════════════════
  group('FinalizeRenewalFeesModel — fromJson', () {
    test('يُفسر الرسوم الثلاثة', () {
      final f = FinalizeRenewalFeesModel.fromJson({
        'baseFee': 200,
        'deliveryFee': 50,
        'totalAmount': 250,
      });
      expect(f.baseFee, equals(200.0));
      expect(f.deliveryFee, equals(50.0));
      expect(f.totalAmount, equals(250.0));
    });

    test('null → 0.0', () {
      final f = FinalizeRenewalFeesModel.fromJson({});
      expect(f.baseFee, equals(0.0));
      expect(f.totalAmount, equals(0.0));
    });
  });

  // ════════════════════════════════════════════════════════
  // FinalizeRenewalResponseModel — fromJson
  // ════════════════════════════════════════════════════════
  group('FinalizeRenewalResponseModel — fromJson', () {
    test('يُفسر الحقول الأساسية', () {
      final r = FinalizeRenewalResponseModel.fromJson({
        'id': 42,
        'requestNumber': 'DR-900',
        'drivingLicenseNumber': '12345678901234',
        'category': 'خاصة',
        'governorate': 'الجيزة',
        'licensingUnit': 'مرور الدقي',
        'issueDate': '01/01/2026',
        'expiryDate': '01/01/2031',
        'status': 'active',
        'citizenName': 'محمد أحمد',
      });
      expect(r.id, equals(42));
      expect(r.requestNumber, equals('DR-900'));
      expect(r.drivingLicenseNumber, equals('12345678901234'));
      expect(r.category, equals('خاصة'));
      expect(r.citizenName, equals('محمد أحمد'));
    });

    test('يُفسر delivery.method', () {
      final r = FinalizeRenewalResponseModel.fromJson({
        'id': 1,
        'requestNumber': 'DR-901',
        'drivingLicenseNumber': 'X',
        'category': '',
        'governorate': '',
        'licensingUnit': '',
        'issueDate': '',
        'expiryDate': '',
        'status': '',
        'citizenName': '',
        'delivery': {'method': 'توصيل للمنزل'},
      });
      expect(r.deliveryMethod, equals('توصيل للمنزل'));
    });

    test('يُفسر fees', () {
      final r = FinalizeRenewalResponseModel.fromJson({
        'id': 1,
        'requestNumber': 'DR-902',
        'drivingLicenseNumber': '',
        'category': '',
        'governorate': '',
        'licensingUnit': '',
        'issueDate': '',
        'expiryDate': '',
        'status': '',
        'citizenName': '',
        'fees': {'baseFee': 300, 'deliveryFee': 0, 'totalAmount': 300},
      });
      expect(r.fees, isNotNull);
      expect(r.fees!.totalAmount, equals(300.0));
    });

    test('JSON فارغ → قيم افتراضية', () {
      final r = FinalizeRenewalResponseModel.fromJson({});
      expect(r.id, equals(0));
      expect(r.requestNumber, equals(''));
      expect(r.deliveryMethod, isNull);
      expect(r.fees, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // DrivingLicenseFinalizeResponseModel — fromJson
  // ════════════════════════════════════════════════════════
  group('DrivingLicenseFinalizeResponseModel — fromJson', () {
    test('يُفسر الحقول', () {
      final r = DrivingLicenseFinalizeResponseModel.fromJson({
        'requestNumber': 'LR-200',
        'citizenNationalId': '12345678901234',
        'serviceType': 'إصدار رخصة قيادة',
        'status': 'قيد التنفيذ',
        'submittedAt': '2026-01-01T00:00:00Z',
        'fees': {'baseFee': 150, 'deliveryFee': 0, 'totalAmount': 150},
      });
      expect(r.requestNumber, equals('LR-200'));
      expect(r.citizenNationalId, equals('12345678901234'));
      expect(r.serviceType, equals('إصدار رخصة قيادة'));
      expect(r.fees, isNotNull);
      expect(r.fees!.baseFee, equals(150.0));
    });

    test('JSON فارغ → قيم فارغة', () {
      final r = DrivingLicenseFinalizeResponseModel.fromJson({});
      expect(r.requestNumber, equals(''));
      expect(r.fees, isNull);
      expect(r.submittedAt, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // IssueReplacementResponseModel — fromJson
  // ════════════════════════════════════════════════════════
  group('IssueReplacementResponseModel — fromJson', () {
    test('يُفسر الحقول', () {
      final r = IssueReplacementResponseModel.fromJson({
        'requestNumber': 'RL-300',
        'status': 'قيد التنفيذ',
        'citizenNationalId': '99988877766655',
        'serviceType': 'بدل فاقد',
        'fees': {'baseFee': 100, 'deliveryFee': 25, 'totalAmount': 125},
      });
      expect(r.requestNumber, equals('RL-300'));
      expect(r.status, equals('قيد التنفيذ'));
      expect(r.citizenNationalId, equals('99988877766655'));
      expect(r.serviceType, equals('بدل فاقد'));
      expect(r.fees, isNotNull);
      expect(r.fees!.deliveryFee, equals(25.0));
    });

    test('fees null لو مش موجود', () {
      final r = IssueReplacementResponseModel.fromJson({
        'requestNumber': 'RL-301',
        'status': '',
        'citizenNationalId': '',
        'serviceType': '',
      });
      expect(r.fees, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  // DateTimeFormatter
  // ════════════════════════════════════════════════════════
  group('DateTimeFormatter.formatDate', () {
    test('يُنسق التاريخ بالعربي', () {
      final result = DateTimeFormatter.formatDate(DateTime(2026, 4, 5));
      expect(result, equals('5 أبريل 2026'));
    });

    test('يناير شهر 1', () {
      expect(DateTimeFormatter.formatDate(DateTime(2026, 1, 1)),
          equals('1 يناير 2026'));
    });

    test('ديسمبر شهر 12', () {
      expect(DateTimeFormatter.formatDate(DateTime(2026, 12, 31)),
          equals('31 ديسمبر 2026'));
    });
  });

  group('DateTimeFormatter.formatTime', () {
    test('09:00 (24h) → 09:00 ص', () =>
        expect(DateTimeFormatter.formatTime('09:00'), equals('09:00 ص')));
    test('13:30 (24h) → 01:30 م', () =>
        expect(DateTimeFormatter.formatTime('13:30'), equals('01:30 م')));
    test('00:00 → 12:00 ص', () =>
        expect(DateTimeFormatter.formatTime('00:00'), equals('12:00 ص')));
    test('12:00 → 12:00 م', () =>
        expect(DateTimeFormatter.formatTime('12:00'), equals('12:00 م')));
    test('09:00 Am → 09:00 ص', () =>
        expect(DateTimeFormatter.formatTime('09:00 Am'), equals('09:00 ص')));
    test('01:30 PM → 01:30 م', () =>
        expect(DateTimeFormatter.formatTime('01:30 PM'), equals('01:30 م')));
    test('نص يحتوي ص يُرجع كما هو', () =>
        expect(DateTimeFormatter.formatTime('09:00 ص'), equals('09:00 ص')));
    test('فارغ → فارغ', () =>
        expect(DateTimeFormatter.formatTime(''), equals('')));
  });

  group('DateTimeFormatter.extractRawStartTime', () {
    test('09:00 ص → 09:00', () =>
        expect(DateTimeFormatter.extractRawStartTime('09:00 ص'), equals('09:00')));
    test('01:30 م → 13:30', () =>
        expect(DateTimeFormatter.extractRawStartTime('01:30 م'), equals('13:30')));
    test('09:00 AM → 09:00', () =>
        expect(DateTimeFormatter.extractRawStartTime('09:00 AM'), equals('09:00')));
    test('12:00 PM → 12:00', () =>
        expect(DateTimeFormatter.extractRawStartTime('12:00 PM'), equals('12:00')));
    test('فارغ → فارغ', () =>
        expect(DateTimeFormatter.extractRawStartTime(''), equals('')));
    test('slot range يأخذ الأول فقط "09:00 ص - 10:00 ص"', () =>
        expect(DateTimeFormatter.extractRawStartTime('09:00 ص - 10:00 ص'),
            equals('09:00')));
  });
}

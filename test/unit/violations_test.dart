// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/violations_inquiry/data/models/violation_model.dart';

// ────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────
ViolationModel _makeViolation({
  int id = 1,
  String number = 'VIO-001',
  String type = 'SpeedLimitExceeded',
  double fineAmount = 500.0,
  double paidAmount = 0.0,
  double remainingAmount = 500.0,
  String status = 'unpaid',
  String statusAr = 'غير مدفوعة',
  bool isPayable = true,
  String dateTime = '2026-04-05T12:00:00.000Z',
}) {
  return ViolationModel(
    violationId: id,
    violationNumber: number,
    violationType: type,
    fineAmount: fineAmount,
    paidAmount: paidAmount,
    remainingAmount: remainingAmount,
    status: status,
    statusAr: statusAr,
    isPayable: isPayable,
    violationDateTime: dateTime,
    legalReference: 'مادة 55',
    description: 'وصف المخالفة',
    location: 'شارع النيل',
  );
}

void main() {
  // ════════════════════════════════════════════════════════════
  // ViolationModel — الحقول الأساسية
  // ════════════════════════════════════════════════════════════
  group('ViolationModel — الحقول الأساسية', () {
    test('id يُرجع violationId كـ String', () {
      final v = _makeViolation(id: 42);
      expect(v.id, equals('42'));
    });

    test('articleNumber يُرجع legalReference', () {
      final v = _makeViolation();
      expect(v.articleNumber, equals('مادة 55'));
    });

    test('articleText يُرجع description', () {
      final v = _makeViolation();
      expect(v.articleText, equals('وصف المخالفة'));
    });

    test('title يُرجع titleAr', () {
      final v = _makeViolation(type: 'RunningRedLight');
      expect(v.title, equals(v.titleAr));
    });
  });

  // ════════════════════════════════════════════════════════════
  // ViolationModel.titleAr — ترجمة أنواع المخالفات
  // ════════════════════════════════════════════════════════════
  group('ViolationModel.titleAr — ترجمة المخالفات', () {
    String title(String type) => _makeViolation(type: type).titleAr;

    test('SpeedLimitExceeded → تجاوز السرعة المقررة', () {
      expect(title('SpeedLimitExceeded'), equals('تجاوز السرعة المقررة'));
    });

    test('RunningRedLight → تجاوز الإشارة الحمراء', () {
      expect(title('RunningRedLight'), equals('تجاوز الإشارة الحمراء'));
    });

    test('NoSeatBelt → عدم ارتداء حزام الأمان', () {
      expect(title('NoSeatBelt'), equals('عدم ارتداء حزام الأمان'));
    });

    test('IllegalParking → انتظار خاطئ', () {
      expect(title('IllegalParking'), equals('انتظار خاطئ'));
    });

    test('WrongWay → السير في الاتجاه الخاطئ', () {
      expect(title('WrongWay'), equals('السير في الاتجاه الخاطئ'));
    });

    test('NoLicense → قيادة بدون رخصة', () {
      expect(title('NoLicense'), equals('قيادة بدون رخصة'));
    });

    test('MobileUsing → استخدام الهاتف أثناء القيادة', () {
      expect(title('MobileUsing'), equals('استخدام الهاتف أثناء القيادة'));
    });

    test('MobileUse (alias) → استخدام الهاتف أثناء القيادة', () {
      expect(title('MobileUse'), equals('استخدام الهاتف أثناء القيادة'));
    });

    test('Reckless → قيادة متهورة', () {
      expect(title('Reckless'), equals('قيادة متهورة'));
    });

    test('RecklessDriving (alias) → قيادة متهورة', () {
      expect(title('RecklessDriving'), equals('قيادة متهورة'));
    });

    test('NoInsurance → قيادة بدون تأمين', () {
      expect(title('NoInsurance'), equals('قيادة بدون تأمين'));
    });

    test('OverLoading → تجاوز الحمولة المقررة', () {
      expect(title('OverLoading'), equals('تجاوز الحمولة المقررة'));
    });

    test('Overtaking → تجاوز خاطئ', () {
      expect(title('Overtaking'), equals('تجاوز خاطئ'));
    });

    test('IllegalOvertaking (alias) → تجاوز خاطئ', () {
      expect(title('IllegalOvertaking'), equals('تجاوز خاطئ'));
    });

    test('NoParkingZone → الوقوف في منطقة ممنوعة', () {
      expect(title('NoParkingZone'), equals('الوقوف في منطقة ممنوعة'));
    });

    test('ExpiredRegistration → رخصة مركبة منتهية', () {
      expect(title('ExpiredRegistration'), equals('رخصة مركبة منتهية'));
    });

    test('ExpiredLicense → رخصة قيادة منتهية', () {
      expect(title('ExpiredLicense'), equals('رخصة قيادة منتهية'));
    });

    test('DefectiveLighting → إضاءة معيبة', () {
      expect(title('DefectiveLighting'), equals('إضاءة معيبة'));
    });

    test('NoRegistration → قيادة بدون تسجيل', () {
      expect(title('NoRegistration'), equals('قيادة بدون تسجيل'));
    });

    test('Speeding → تجاوز السرعة المقررة', () {
      expect(title('Speeding'), equals('تجاوز السرعة المقررة'));
    });

    test('TrafficObstruction → تعطيل حركة المرور', () {
      expect(title('TrafficObstruction'), equals('تعطيل حركة المرور'));
    });

    test('TrafficBlockage → إعاقة حركة المرور', () {
      expect(title('TrafficBlockage'), equals('إعاقة حركة المرور'));
    });

    test('نوع غير موجود → يُرجع الـ key كما هو (fallback)', () {
      expect(title('UnknownViolationType'), equals('UnknownViolationType'));
    });

    test('نوع فارغ → يُرجع string فارغ', () {
      expect(title(''), equals(''));
    });
  });

  // ════════════════════════════════════════════════════════════
  // ViolationModel.isPaid
  // ════════════════════════════════════════════════════════════
  group('ViolationModel.isPaid', () {
    test('remainingAmount == 0 → مدفوعة', () {
      final v = _makeViolation(remainingAmount: 0, status: 'unpaid');
      expect(v.isPaid, isTrue);
    });

    test('status == "paid" → مدفوعة', () {
      final v = _makeViolation(remainingAmount: 100, status: 'paid');
      expect(v.isPaid, isTrue);
    });

    test('statusAr == "مدفوعة" → مدفوعة', () {
      final v = _makeViolation(
          remainingAmount: 100, status: 'unpaid', statusAr: 'مدفوعة');
      expect(v.isPaid, isTrue);
    });

    test('remainingAmount > 0 && status != paid → غير مدفوعة', () {
      final v = _makeViolation(
          remainingAmount: 300, status: 'unpaid', statusAr: 'غير مدفوعة');
      expect(v.isPaid, isFalse);
    });

    test('دفع جزئي → غير مدفوعة كاملاً', () {
      final v = _makeViolation(
          fineAmount: 500,
          paidAmount: 200,
          remainingAmount: 300,
          status: 'partial');
      expect(v.isPaid, isFalse);
    });
  });

  // ════════════════════════════════════════════════════════════
  // ViolationModel.amount
  // ════════════════════════════════════════════════════════════
  group('ViolationModel.amount', () {
    test('remainingAmount > 0 → يُرجع remainingAmount', () {
      final v = _makeViolation(fineAmount: 500, remainingAmount: 300);
      expect(v.amount, equals(300.0));
    });

    test('remainingAmount == 0 → يُرجع fineAmount', () {
      final v = _makeViolation(fineAmount: 500, remainingAmount: 0);
      expect(v.amount, equals(500.0));
    });

    test('كلاهما 0 → يُرجع 0', () {
      final v = _makeViolation(fineAmount: 0, remainingAmount: 0);
      expect(v.amount, equals(0.0));
    });
  });

  // ════════════════════════════════════════════════════════════
  // ViolationModel.formattedDateTime
  // ════════════════════════════════════════════════════════════
  group('ViolationModel.formattedDateTime', () {
    test('ISO date يُحول لعربي صحيح', () {
      final v = _makeViolation(dateTime: '2026-04-05T12:00:00.000Z');
      final result = v.formattedDateTime;
      expect(result, contains('5'));
      expect(result, contains('أبريل'));
      expect(result, contains('2026'));
    });

    test('ISO date AM/PM صحيح — 12:00 → م', () {
      final v = _makeViolation(dateTime: '2026-04-05T12:00:00.000Z');
      expect(v.formattedDateTime, contains('م'));
    });

    test('ISO date صباح — 08:30 → ص', () {
      final v = _makeViolation(dateTime: '2026-04-05T08:30:00.000Z');
      expect(v.formattedDateTime, contains('ص'));
    });

    test('String عربي مسبق الفورمات يُعرض كما هو', () {
      const preFormatted = '5 أبريل 2026 - 12:00 م';
      final v = _makeViolation(dateTime: preFormatted);
      expect(v.formattedDateTime, equals(preFormatted));
    });

    test('dateTime فارغ يُرجع string فارغ', () {
      final v = _makeViolation(dateTime: '');
      expect(v.formattedDateTime, equals(''));
    });

    test('date getter يُرجع جزء التاريخ فقط', () {
      final v = _makeViolation(dateTime: '2026-04-05T08:30:00.000Z');
      final date = v.date;
      expect(date, isNot(contains(' - ')));
      expect(date, contains('2026'));
    });

    test('time getter يُرجع جزء الوقت فقط', () {
      final v = _makeViolation(dateTime: '2026-04-05T08:30:00.000Z');
      final time = v.time;
      expect(time, isNot(contains('2026')));
      expect(time, anyOf(contains('ص'), contains('م')));
    });

    test('date مع string عربي يُقسم صح', () {
      const preFormatted = '5 أبريل 2026 - 12:00 م';
      final v = _makeViolation(dateTime: preFormatted);
      expect(v.date, equals('5 أبريل 2026'));
      expect(v.time, equals('12:00 م'));
    });

    test('paymentDate تكون null لو غير مدفوعة', () {
      final v = _makeViolation(remainingAmount: 300, status: 'unpaid');
      expect(v.paymentDate, isNull);
    });

    test('paymentDate تحتوي على التاريخ لو مدفوعة', () {
      final v = _makeViolation(
          remainingAmount: 0, status: 'paid', dateTime: '2026-04-05T12:00:00.000Z');
      expect(v.paymentDate, isNotNull);
      expect(v.paymentDate, contains('أبريل'));
    });
  });

  // ════════════════════════════════════════════════════════════
  // ViolationsListModel
  // ════════════════════════════════════════════════════════════
  group('ViolationsListModel — قائمة المخالفات', () {
    test('قيم افتراضية عند إنشاء فارغ', () {
      const list = ViolationsListModel();
      expect(list.violations, isEmpty);
      expect(list.totalCount, equals(0));
      expect(list.unpaidCount, equals(0));
      expect(list.totalPayableAmount, equals(0.0));
      expect(list.message, equals(''));
    });

    test('يحتفظ بقائمة المخالفات', () {
      final v = _makeViolation();
      final list = ViolationsListModel(
        violations: [v],
        totalCount: 1,
        unpaidCount: 1,
        totalPayableAmount: 500.0,
        messageAr: 'تم العثور على مخالفة',
      );
      expect(list.violations.length, equals(1));
      expect(list.totalCount, equals(1));
      expect(list.totalPayableAmount, equals(500.0));
      expect(list.messageAr, equals('تم العثور على مخالفة'));
    });

    test('fromJson مع بيانات كاملة', () {
      final json = {
        'violations': [],
        'totalCount': 5,
        'unpaidCount': 3,
        'totalPayableAmount': 1500.0,
        'message': 'Found violations',
        'messageAr': 'تم العثور على مخالفات',
      };
      final list = ViolationsListModel.fromJson(json);
      expect(list.totalCount, equals(5));
      expect(list.unpaidCount, equals(3));
      expect(list.totalPayableAmount, equals(1500.0));
    });

    test('fromJson مع violations فارغة', () {
      final json = {'violations': <dynamic>[]};
      final list = ViolationsListModel.fromJson(json);
      expect(list.violations, isEmpty);
    });
  });

  // ════════════════════════════════════════════════════════════
  // UX Logic — منطق واجهة المستخدم
  // ════════════════════════════════════════════════════════════
  group('UX Logic — عرض المخالفات', () {
    test('مخالفة غير مدفوعة قابلة للدفع', () {
      final v = _makeViolation(isPayable: true, remainingAmount: 500);
      expect(v.isPayable, isTrue);
      expect(v.isPaid, isFalse);
    });

    test('مخالفة مدفوعة غير قابلة للدفع مرة أخرى', () {
      final v = _makeViolation(
          isPayable: false, remainingAmount: 0, status: 'paid');
      expect(v.isPaid, isTrue);
    });

    test('amount يُستخدم لعرض المبلغ المتبقي للدفع', () {
      final v = _makeViolation(fineAmount: 500, remainingAmount: 500);
      expect(v.amount, equals(500.0));
    });

    test('مخالفات متعددة في قائمة تحتفظ بترتيبها', () {
      final v1 = _makeViolation(id: 1, type: 'SpeedLimitExceeded');
      final v2 = _makeViolation(id: 2, type: 'RunningRedLight');
      final v3 = _makeViolation(id: 3, type: 'NoSeatBelt');
      final list = ViolationsListModel(
        violations: [v1, v2, v3],
        totalCount: 3,
      );
      expect(list.violations[0].titleAr, equals('تجاوز السرعة المقررة'));
      expect(list.violations[1].titleAr, equals('تجاوز الإشارة الحمراء'));
      expect(list.violations[2].titleAr, equals('عدم ارتداء حزام الأمان'));
    });

    test('totalPayableAmount يعكس مجموع المبالغ المتبقية', () {
      const list = ViolationsListModel(
        totalPayableAmount: 1200.0,
        unpaidCount: 3,
      );
      expect(list.totalPayableAmount, equals(1200.0));
      expect(list.unpaidCount, equals(3));
    });
  });
}

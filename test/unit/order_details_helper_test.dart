import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/orders/domain/entities/order_model.dart';
import 'package:traffic/features/orders/presentation/utils/order_details_helper.dart';

// ────────────────────────────────────────────────
// Helper: ينشئ OrderModel بسرعة للـ tests
// ────────────────────────────────────────────────
OrderModel _makeOrder({
  String id = 'DR-001',
  String title = 'إصدار رخصة قيادة',
  OrderStatus status = OrderStatus.pending,
  String statusLabel = '',
  String? stepCode,
}) {
  return OrderModel(
    id: id,
    title: title,
    date: '2026-01-01T00:00:00Z',
    status: status,
    statusLabel: statusLabel,
    stepCode: stepCode,
  );
}

void main() {
  // ────────────────────────────────────────────────
  // hasMedicalFailure
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.hasMedicalFailure', () {
    test('يُكشف عند stepCode == MEDICAL_EXAM_FAILED', () {
      final order = _makeOrder(stepCode: 'MEDICAL_EXAM_FAILED');
      expect(OrderDetailsHelper.hasMedicalFailure(order), isTrue);
    });

    test('يُكشف عند label يحتوي "راسب" + "الكشف"', () {
      final order = _makeOrder(statusLabel: 'راسب في الكشف الطبي');
      expect(OrderDetailsHelper.hasMedicalFailure(order), isTrue);
    });

    test('يُكشف عند label يحتوي "راسب" + "طبي"', () {
      final order = _makeOrder(statusLabel: 'راسب في الفحص الطبي');
      expect(OrderDetailsHelper.hasMedicalFailure(order), isTrue);
    });

    test('لا يُكشف عند label عادي', () {
      final order = _makeOrder(statusLabel: 'قيد التنفيذ');
      expect(OrderDetailsHelper.hasMedicalFailure(order), isFalse);
    });

    test('لا يُكشف عند stepCode مختلف', () {
      final order = _makeOrder(stepCode: 'PAYMENT');
      expect(OrderDetailsHelper.hasMedicalFailure(order), isFalse);
    });
  });

  // ────────────────────────────────────────────────
  // hasPracticalFailure
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.hasPracticalFailure', () {
    test('يُكشف عند stepCode == DRIVING_TEST_FAILED', () {
      final order = _makeOrder(stepCode: 'DRIVING_TEST_FAILED');
      expect(OrderDetailsHelper.hasPracticalFailure(order), isTrue);
    });

    test('يُكشف عند stepCode == PRACTICAL_TEST_FAILED', () {
      final order = _makeOrder(stepCode: 'PRACTICAL_TEST_FAILED');
      expect(OrderDetailsHelper.hasPracticalFailure(order), isTrue);
    });

    test('يُكشف عند label يحتوي "راسب" + "اختبار"', () {
      final order = _makeOrder(statusLabel: 'راسب في اختبار القيادة');
      expect(OrderDetailsHelper.hasPracticalFailure(order), isTrue);
    });

    test('لا يُكشف بدون stepCode أو label مطابق', () {
      final order = _makeOrder(statusLabel: 'قيد التنفيذ');
      expect(OrderDetailsHelper.hasPracticalFailure(order), isFalse);
    });
  });

  // ────────────────────────────────────────────────
  // hasTechnicalFailure
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.hasTechnicalFailure', () {
    test('يُكشف عند stepCode == TECHNICAL_INSPECTION_FAILED', () {
      final order = _makeOrder(stepCode: 'TECHNICAL_INSPECTION_FAILED');
      expect(OrderDetailsHelper.hasTechnicalFailure(order), isTrue);
    });

    test('يُكشف عند label يحتوي "راسب" + "الفحص"', () {
      final order = _makeOrder(statusLabel: 'راسب في الفحص الفني');
      expect(OrderDetailsHelper.hasTechnicalFailure(order), isTrue);
    });

    test('يُكشف عند label يحتوي "راسب" + "فني"', () {
      final order = _makeOrder(statusLabel: 'راسب بالفحص الفني');
      expect(OrderDetailsHelper.hasTechnicalFailure(order), isTrue);
    });

    test('لا يُكشف بدون stepCode أو label مطابق', () {
      final order = _makeOrder(statusLabel: 'بانتظار الموعد');
      expect(OrderDetailsHelper.hasTechnicalFailure(order), isFalse);
    });
  });

  // ────────────────────────────────────────────────
  // isOrderFailed
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.isOrderFailed', () {
    test('يُكشف عند status == failed', () {
      final order = _makeOrder(status: OrderStatus.failed, statusLabel: 'مرفوض');
      expect(OrderDetailsHelper.isOrderFailed(order), isTrue);
    });

    test('يُكشف عند label يحتوي "عدم اجتياز"', () {
      final order = _makeOrder(statusLabel: 'عدم اجتياز الاختبار');
      expect(OrderDetailsHelper.isOrderFailed(order), isTrue);
    });

    test('يُكشف عند label يحتوي "لم يجتز"', () {
      final order = _makeOrder(statusLabel: 'لم يجتز المتقدم الاختبار');
      expect(OrderDetailsHelper.isOrderFailed(order), isTrue);
    });

    test('يُكشف عند stepCode يعني فشل طبي', () {
      final order = _makeOrder(stepCode: 'MEDICAL_EXAM_FAILED');
      expect(OrderDetailsHelper.isOrderFailed(order), isTrue);
    });

    test('لا يُكشف للطلبات النشطة', () {
      final order = _makeOrder(statusLabel: 'قيد التنفيذ');
      expect(OrderDetailsHelper.isOrderFailed(order), isFalse);
    });

    test('لا يُكشف للطلبات المكتملة', () {
      final order = _makeOrder(status: OrderStatus.completed, statusLabel: 'مكتمل');
      expect(OrderDetailsHelper.isOrderFailed(order), isFalse);
    });
  });

  // ────────────────────────────────────────────────
  // showFinalizeButton
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.showFinalizeButton', () {
    test('يظهر لطلب تجديد رخصة قيادة في حالة pending', () {
      final order = _makeOrder(
        title: 'تجديد رخصة قيادة',
        statusLabel: 'قيد التنفيذ',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });

    test('يظهر لطلب إصدار رخصة قيادة في حالة needsData', () {
      final order = _makeOrder(
        status: OrderStatus.needsData,
        statusLabel: 'مطلوب استكمال بيانات',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });

    test('يظهر لتجديد رخصة مركبة في حالة awaitingService', () {
      final order = _makeOrder(
        title: 'تجديد رخصة مركبة',
        status: OrderStatus.awaitingService,
        statusLabel: 'بانتظار الموعد',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });

    test('يظهر عند حالة فشل طبي قابلة للإعادة', () {
      final order = _makeOrder(
        status: OrderStatus.failed,
        statusLabel: 'راسب في الكشف الطبي',
        stepCode: 'MEDICAL_EXAM_FAILED',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });

    test('يختفي عند انتظار نتيجة الكشف الطبي', () {
      final order = _makeOrder(
        status: OrderStatus.awaitingService,
        statusLabel: 'في انتظار نتيجة الكشف الطبي',
        stepCode: 'MEDICAL_EXAM_RESULT_WAITING',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يختفي عند انتظار نتيجة الفحص الفني', () {
      final order = _makeOrder(
        title: 'تجديد رخصة مركبة',
        status: OrderStatus.awaitingService,
        statusLabel: 'نتيجة الفحص الفني',
        stepCode: 'TECHNICAL_INSPECTION_RESULT_WAITING',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يختفي عند انتظار نتيجة اختبار القيادة', () {
      final order = _makeOrder(
        status: OrderStatus.awaitingService,
        statusLabel: 'نتيجة اختبار القيادة',
        stepCode: 'DRIVING_TEST_RESULT_WAITING',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يختفي للطلبات المكتملة', () {
      final order = _makeOrder(
        title: 'تجديد رخصة قيادة',
        status: OrderStatus.completed,
        statusLabel: 'مكتمل',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يختفي لخدمات غير مدعومة', () {
      final order = _makeOrder(
        title: 'استعلام عن مخالفات',
        statusLabel: 'قيد التنفيذ',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يختفي عند فشل عام غير قابل للإعادة', () {
      final order = _makeOrder(
        title: 'تجديد رخصة قيادة',
        status: OrderStatus.failed,
        statusLabel: 'عدم اجتياز — مرفوض نهائياً',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isFalse);
    });

    test('يظهر لطلب بدل فاقد رخصة مركبة في حالة pending', () {
      final order = _makeOrder(
        title: 'استخراج بدل فاقد - رخصة مركبة',
        id: 'RPL-2026-301',
        statusLabel: 'في انتظار الدفع',
        stepCode: 'PAYMENT',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });

    test('يظهر لطلب بدل تالف رخصة قيادة في حالة pending', () {
      final order = _makeOrder(
        title: 'اصدار بدل تالف رخصة قيادة',
        id: 'RPL-2026-302',
        statusLabel: 'في انتظار الدفع',
        stepCode: 'PAYMENT',
      );
      expect(OrderDetailsHelper.showFinalizeButton(order), isTrue);
    });
  });

  // ────────────────────────────────────────────────
  // getButtonLabel
  // ────────────────────────────────────────────────
  group('OrderDetailsHelper.getButtonLabel', () {
    test('stepCode PAYMENT → سداد الرسوم', () {
      final order = _makeOrder(stepCode: 'PAYMENT');
      expect(OrderDetailsHelper.getButtonLabel(order), equals('سداد الرسوم'));
    });

    test('statusLabel يحتوي "في انتظار الدفع" → سداد الرسوم', () {
      final order = _makeOrder(statusLabel: 'في انتظار الدفع');
      expect(OrderDetailsHelper.getButtonLabel(order), equals('سداد الرسوم'));
    });

    test('MEDICAL_EXAM_FAILED → إعادة حجز الكشف الطبي', () {
      final order = _makeOrder(
        stepCode: 'MEDICAL_EXAM_FAILED',
        statusLabel: 'راسب في الكشف الطبي',
      );
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('إعادة حجز الكشف الطبي'),
      );
    });

    test('DRIVING_TEST_FAILED → إعادة حجز اختبار القيادة', () {
      final order = _makeOrder(
        stepCode: 'DRIVING_TEST_FAILED',
        statusLabel: 'راسب في اختبار القيادة',
      );
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('إعادة حجز اختبار القيادة'),
      );
    });

    test('TECHNICAL_INSPECTION_FAILED → إعادة حجز الفحص الفني', () {
      final order = _makeOrder(
        stepCode: 'TECHNICAL_INSPECTION_FAILED',
        statusLabel: 'راسب في الفحص الفني',
      );
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('إعادة حجز الفحص الفني'),
      );
    });

    test('MEDICAL_EXAM_BOOKING_WAITING → حجز الكشف الطبي', () {
      final order = _makeOrder(stepCode: 'MEDICAL_EXAM_BOOKING_WAITING');
      expect(OrderDetailsHelper.getButtonLabel(order), equals('حجز الكشف الطبي'));
    });

    test('PRACTICAL_TEST_BOOKING_WAITING → حجز اختبار القيادة', () {
      final order = _makeOrder(stepCode: 'PRACTICAL_TEST_BOOKING_WAITING');
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('حجز اختبار القيادة'),
      );
    });

    test('TECHNICAL_INSPECTION_BOOKING_WAITING → حجز الفحص الفني', () {
      final order = _makeOrder(stepCode: 'TECHNICAL_INSPECTION_BOOKING_WAITING');
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('حجز الفحص الفني'),
      );
    });

    test('MEDICAL_EXAM_RESULT_WAITING → في انتظار نتيجة الكشف الطبي', () {
      final order = _makeOrder(stepCode: 'MEDICAL_EXAM_RESULT_WAITING');
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('في انتظار نتيجة الكشف الطبي'),
      );
    });

    test('TECHNICAL_INSPECTION_RESULT_WAITING → في انتظار نتيجة الفحص الفني', () {
      final order = _makeOrder(stepCode: 'TECHNICAL_INSPECTION_RESULT_WAITING');
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('في انتظار نتيجة الفحص الفني'),
      );
    });

    test('stepCode غير معروف → استكمال الإجراءات', () {
      final order = _makeOrder(stepCode: 'UNKNOWN_STEP');
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('استكمال الإجراءات'),
      );
    });

    test('بدون stepCode ولا label → استكمال الإجراءات', () {
      final order = _makeOrder();
      expect(
        OrderDetailsHelper.getButtonLabel(order),
        equals('استكمال الإجراءات'),
      );
    });
  });
}

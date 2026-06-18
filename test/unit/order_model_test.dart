// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/orders/domain/entities/order_model.dart';

void main() {
  group('OrderModel — fromJson parsing', () {
    test('يعطي قيم افتراضية عند JSON فارغ', () {
      final model = OrderModel.fromJson({});
      expect(model.id, equals(''));
      expect(model.title, equals('طلب خدمة'));
      expect(model.status, equals(OrderStatus.pending));
      expect(model.statusLabel, equals(''));
    });

    test('يفسر حقول JSON الصحيحة', () {
      final model = OrderModel.fromJson({
        'requestNumber': 'DR-800',
        'serviceType': 'تجديد رخصة قيادة',
        'submittedAt': '2026-01-01T00:00:00Z',
        'status': 'قيد التنفيذ',
        'stepCode': 'PAYMENT',
        'referenceId': 42,
      });

      expect(model.id, equals('DR-800'));
      expect(model.title, equals('تجديد رخصة قيادة'));
      expect(model.date, equals('2026-01-01T00:00:00Z'));
      expect(model.statusLabel, equals('قيد التنفيذ'));
      expect(model.stepCode, equals('PAYMENT'));
      expect(model.referenceId, equals(42));
    });

    test('يفسر OrderFees بشكل صحيح', () {
      final model = OrderModel.fromJson({
        'requestNumber': 'DR-999',
        'status': 'قيد التنفيذ',
        'fees': {
          'baseFee': 250.0,
          'deliveryFee': 50.0,
          'totalAmount': 300.0,
        },
      });
      expect(model.fees, isNotNull);
      expect(model.fees!.baseFee, equals(250.0));
      expect(model.fees!.deliveryFee, equals(50.0));
      expect(model.fees!.totalAmount, equals(300.0));
    });

    test('يُهمل fees إذا لم تكن Map', () {
      final model = OrderModel.fromJson({
        'requestNumber': 'DR-999',
        'status': 'قيد التنفيذ',
        'fees': 'invalid_value',
      });
      expect(model.fees, isNull);
    });

    test('يفسر OrderDelivery بشكل صحيح', () {
      final model = OrderModel.fromJson({
        'requestNumber': 'VR-001',
        'status': 'مكتمل',
        'delivery': {'method': 'توصيل', 'address': 'شارع النيل'},
      });
      expect(model.delivery, isNotNull);
      expect(model.delivery!.method, equals('توصيل'));
      expect(model.delivery!.address, equals('شارع النيل'));
    });

    test('يفسر OrderPayment بشكل صحيح', () {
      final model = OrderModel.fromJson({
        'requestNumber': 'DR-101',
        'status': 'قيد التنفيذ',
        'payment': {
          'status': 'paid',
          'transactionId': 'TXN-123',
          'amount': 300.0,
          'timestamp': '2026-01-01T10:00:00Z',
        },
      });
      expect(model.payment, isNotNull);
      expect(model.payment!.paymentStatus, equals('paid'));
      expect(model.payment!.transactionId, equals('TXN-123'));
      expect(model.payment!.amount, equals(300.0));
    });
  });

  group('OrderModel — _parseStatus', () {
    OrderStatus parse(String s) =>
        OrderModel.fromJson({'requestNumber': 'X', 'status': s}).status;

    test('قيد التنفيذ → pending', () {
      expect(parse('قيد التنفيذ'), equals(OrderStatus.pending));
    });

    test('قيد الانتظار → pending', () {
      expect(parse('قيد الانتظار'), equals(OrderStatus.pending));
    });

    test('مكتمل → completed', () {
      expect(parse('مكتمل'), equals(OrderStatus.completed));
    });

    test('مرفوض → failed', () {
      expect(parse('مرفوض'), equals(OrderStatus.failed));
    });

    test('failed (English) → failed', () {
      expect(parse('REQUEST_FAILED'), equals(OrderStatus.failed));
    });

    test('تم اجتياز → passed', () {
      expect(parse('تم اجتياز الاختبار'), equals(OrderStatus.passed));
    });

    test('استكمال → needsData', () {
      expect(parse('استكمال الطلب'), equals(OrderStatus.needsData));
    });

    test('بانتظار الموعد → awaitingService', () {
      expect(parse('بانتظار الموعد'), equals(OrderStatus.awaitingService));
    });

    test('قيمة غير معروفة → pending (default)', () {
      expect(parse('حالة غريبة'), equals(OrderStatus.pending));
    });
  });

  group('OrderFees — fromJson', () {
    test('يتعامل مع null بشكل صحيح', () {
      final fees = OrderFees.fromJson({
        'baseFee': null,
        'deliveryFee': null,
        'totalAmount': null,
      });
      expect(fees.baseFee, equals(0.0));
      expect(fees.deliveryFee, equals(0.0));
      expect(fees.totalAmount, equals(0.0));
    });

    test('يحول int إلى double', () {
      final fees = OrderFees.fromJson({
        'baseFee': 100,
        'deliveryFee': 25,
        'totalAmount': 125,
      });
      expect(fees.baseFee, isA<double>());
      expect(fees.totalAmount, equals(125.0));
    });
  });

  group('OrderDelivery — fromJson', () {
    test('يسمح بقيم null', () {
      final delivery = OrderDelivery.fromJson({});
      expect(delivery.method, isNull);
      expect(delivery.address, isNull);
    });

    test('يحول أي نوع إلى String', () {
      final delivery = OrderDelivery.fromJson({'method': 123, 'address': true});
      expect(delivery.method, equals('123'));
      expect(delivery.address, equals('true'));
    });
  });
}

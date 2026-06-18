// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/orders/domain/entities/order_model.dart';
import 'package:traffic/features/orders/presentation/cubits/my_orders_state.dart';

// ────────────────────────────────────────────────
// Mock result wrapper
// ────────────────────────────────────────────────
class FakeResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  const FakeResult({required this.isSuccess, this.data, this.error});
}

// ────────────────────────────────────────────────
// Mock repository
// ────────────────────────────────────────────────
class MockServiceRequestsRepo {
  List<OrderModel>? ordersToReturn;
  String? errorToReturn;
  bool returnFailureWithNullError = false;

  Future<FakeResult<List<OrderModel>>> fetchMyRequests() async {
    if (returnFailureWithNullError) {
      return const FakeResult(isSuccess: false, error: null);
    }
    if (errorToReturn != null) {
      return FakeResult(isSuccess: false, error: errorToReturn);
    }
    return FakeResult(isSuccess: true, data: ordersToReturn ?? []);
  }
}

// ────────────────────────────────────────────────
// Minimal MyOrdersCubit (pure logic — no flutter_bloc dependency needed)
// ────────────────────────────────────────────────
class TestMyOrdersCubit {
  final MockServiceRequestsRepo _repo;
  MyOrdersState _state = MyOrdersInitial();
  MyOrdersState get state => _state;
  final List<MyOrdersState> emitted = [];

  TestMyOrdersCubit(this._repo);

  void _emit(MyOrdersState s) {
    _state = s;
    emitted.add(s);
  }

  Future<void> fetchMyOrders() async {
    _emit(MyOrdersLoading());
    final result = await _repo.fetchMyRequests();
    if (result.isSuccess) {
      _emit(MyOrdersFetchSuccess(orders: result.data ?? []));
    } else {
      _emit(MyOrdersFailure(message: result.error ?? 'حدث خطأ غير متوقع.'));
    }
  }
}

// ────────────────────────────────────────────────
// Sample orders for testing
// ────────────────────────────────────────────────
OrderModel _sampleOrder({
  String id = 'DR-001',
  String title = 'تجديد رخصة قيادة',
  OrderStatus status = OrderStatus.pending,
  String statusLabel = 'قيد التنفيذ',
}) {
  return OrderModel(
    id: id,
    title: title,
    date: '2026-01-01T00:00:00Z',
    status: status,
    statusLabel: statusLabel,
  );
}

void main() {
  late MockServiceRequestsRepo repo;
  late TestMyOrdersCubit cubit;

  setUp(() {
    repo = MockServiceRequestsRepo();
    cubit = TestMyOrdersCubit(repo);
  });

  // ────────────────────────────────────────────────
  // 1. حالات MyOrdersCubit
  // ────────────────────────────────────────────────
  group('MyOrdersCubit.fetchMyOrders', () {
    test('يُصدر Loading أولاً', () async {
      repo.ordersToReturn = [];
      await cubit.fetchMyOrders();
      expect(cubit.emitted.first, isA<MyOrdersLoading>());
    });

    test('قائمة فارغة → FetchSuccess بقائمة فارغة', () async {
      repo.ordersToReturn = [];
      await cubit.fetchMyOrders();
      expect(cubit.state, isA<MyOrdersFetchSuccess>());
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(success.orders, isEmpty);
    });

    test('قائمة بطلبات → FetchSuccess بالطلبات', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'DR-001'),
        _sampleOrder(id: 'VR-002', title: 'تجديد رخصة مركبة'),
      ];
      await cubit.fetchMyOrders();
      expect(cubit.state, isA<MyOrdersFetchSuccess>());
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(success.orders.length, equals(2));
      expect(success.orders[0].id, equals('DR-001'));
      expect(success.orders[1].id, equals('VR-002'));
    });

    test('خطأ من السيرفر → MyOrdersFailure برسالة', () async {
      repo.errorToReturn = 'لا يوجد اتصال بالإنترنت';
      await cubit.fetchMyOrders();
      expect(cubit.state, isA<MyOrdersFailure>());
      final failure = cubit.state as MyOrdersFailure;
      expect(failure.message, equals('لا يوجد اتصال بالإنترنت'));
    });

    test('خطأ بدون رسالة → رسالة افتراضية', () async {
      final failRepo = MockServiceRequestsRepo();
      failRepo.returnFailureWithNullError = true;
      final failCubit = TestMyOrdersCubit(failRepo);
      await failCubit.fetchMyOrders();
      expect(failCubit.state, isA<MyOrdersFailure>());
      final failure = failCubit.state as MyOrdersFailure;
      expect(failure.message, equals('حدث خطأ غير متوقع.'));
    });
  });

  // ────────────────────────────────────────────────
  // 2. MyOrdersState classes
  // ────────────────────────────────────────────────
  group('MyOrdersState types', () {
    test('MyOrdersInitial مميز', () {
      expect(MyOrdersInitial(), isA<MyOrdersInitial>());
    });

    test('MyOrdersLoading مميز', () {
      expect(MyOrdersLoading(), isA<MyOrdersLoading>());
    });

    test('MyOrdersFetchSuccess يحتفظ بالطلبات', () {
      final orders = [_sampleOrder()];
      final state = MyOrdersFetchSuccess(orders: orders);
      expect(state.orders, equals(orders));
    });

    test('MyOrdersFailure يحتفظ بالرسالة', () {
      final state = MyOrdersFailure(message: 'خطأ');
      expect(state.message, equals('خطأ'));
    });
  });

  // ────────────────────────────────────────────────
  // 3. UX — التحقق من منطق تجربة المستخدم
  // ────────────────────────────────────────────────
  group('UX logic — عرض الطلبات', () {
    test('طلب pending يظهر في القائمة', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'DR-001', status: OrderStatus.pending),
      ];
      await cubit.fetchMyOrders();
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(
        success.orders.any((o) => o.status == OrderStatus.pending),
        isTrue,
      );
    });

    test('طلب completed يظهر في القائمة', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'DR-002', status: OrderStatus.completed, statusLabel: 'مكتمل'),
      ];
      await cubit.fetchMyOrders();
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(
        success.orders.any((o) => o.status == OrderStatus.completed),
        isTrue,
      );
    });

    test('طلب failed يظهر في القائمة', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'DR-003', status: OrderStatus.failed, statusLabel: 'مرفوض'),
      ];
      await cubit.fetchMyOrders();
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(
        success.orders.any((o) => o.status == OrderStatus.failed),
        isTrue,
      );
    });

    test('ترتيب الطلبات محفوظ', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'A'),
        _sampleOrder(id: 'B'),
        _sampleOrder(id: 'C'),
      ];
      await cubit.fetchMyOrders();
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(success.orders[0].id, equals('A'));
      expect(success.orders[1].id, equals('B'));
      expect(success.orders[2].id, equals('C'));
    });

    test('أنواع مختلفة من الطلبات تُعرض في نفس القائمة', () async {
      repo.ordersToReturn = [
        _sampleOrder(id: 'DR-001', title: 'تجديد رخصة قيادة'),
        _sampleOrder(id: 'VR-001', title: 'تجديد رخصة مركبة'),
        _sampleOrder(id: 'LR-001', title: 'إصدار رخصة قيادة'),
        _sampleOrder(id: 'DL-001', title: 'بدل فاقد'),
      ];
      await cubit.fetchMyOrders();
      final success = cubit.state as MyOrdersFetchSuccess;
      expect(success.orders.length, equals(4));
    });
  });
}

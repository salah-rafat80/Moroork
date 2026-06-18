import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic/features/orders/domain/entities/order_model.dart';
import 'package:traffic/features/orders/presentation/order_details_screen.dart';
import 'package:traffic/features/orders/presentation/cubits/order_details_cubit.dart';
import 'package:traffic/features/orders/data/repositories/service_requests_repository.dart';
import 'package:traffic/features/driving_license/presentation/screens/document_upload/widgets/first_license_booking_helper.dart';
import 'package:traffic/features/driving_license/presentation/cubits/driving_renewal_cubit.dart';
import 'package:traffic/features/driving_license/data/repositories/driving_renewal_repository.dart';
import 'package:traffic/features/profile/data/repositories/profile_repository.dart';
import 'package:traffic/injection_container.dart';

class FakeFirstLicenseBookingHelper implements FirstLicenseBookingHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeServiceRequestsRepository implements ServiceRequestsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeOrderDetailsCubit extends OrderDetailsCubit {
  FakeOrderDetailsCubit()
      : super(
          FakeFirstLicenseBookingHelper(),
          FakeServiceRequestsRepository(),
        );
}

class FakeDrivingLicenseRenewalDataHandler implements DrivingLicenseRenewalDataHandler {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeDrivingRenewalCubit extends DrivingRenewalCubit {
  FakeDrivingRenewalCubit()
      : super(
          dataHandler: FakeDrivingLicenseRenewalDataHandler(),
          profileRepository: FakeProfileRepository(),
        );
}

void main() {
  setUp(() {
    getIt.registerFactory<OrderDetailsCubit>(() => FakeOrderDetailsCubit());
    getIt.registerFactory<DrivingRenewalCubit>(() => FakeDrivingRenewalCubit());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets(
    'finalize button opens renewal finalize delivery screen without Provider<ApiClient>',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const OrderModel order = OrderModel(
        id: 'DR-801',
        title: 'تجديد رخصة قيادة',
        date: '2026-04-21T00:00:00Z',
        status: OrderStatus.pending,
        statusLabel: 'قيد التنفيذ',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) {
            return const MaterialApp(
              home: OrderDetailsScreen(order: order),
            );
          },
        ),
      );

      expect(find.text('استكمال الإجراءات'), findsOneWidget);

      await tester.tap(find.text('استكمال الإجراءات'));
      await tester.pumpAndSettle();

      expect(find.text('استكمال تجديد رخصة القيادة'), findsOneWidget);
      final Object? exception = tester.takeException();
      if (exception != null) {
        expect(exception.toString(), isNot(contains('ProviderNotFoundException')));
      }
    },
  );
}


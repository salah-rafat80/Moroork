import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../driving_license/presentation/screens/finalize/finalize_driving_license_screen.dart';
import '../../../vehicle_license/renewal_license/presentation/screens/vehicle_renewal_delivery_screen.dart';
import '../../../vehicle_license/renewal_license/presentation/screens/vehicle_technical_inspection_screen.dart';
import '../../../vehicle_license/renewal_license/data/models/renewal_vehicle_license_model.dart';
import '../../../vehicle_license/presentation/cubits/vehicle_renewal_cubit.dart';
import '../../../driving_license/presentation/cubits/driving_license_cubit.dart';
import '../../../driving_license/presentation/cubits/driving_renewal_cubit.dart';
import '../../../lost_license/presentation/screens/delivery_method_screen.dart';
import '../../../driving_license/presentation/screens/medical_check/medical_check_screen.dart';
import '../../../driving_license/presentation/screens/practical_test/practical_test_booking_screen.dart';
import '../../../driving_license/presentation/screens/document_upload/widgets/first_license_booking_helper.dart';
import 'package:traffic/core/widgets/generic_booking_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/vehicle_inspection_booking_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/screens/finalize_vehicle_license_screen.dart';
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_cubit.dart';
import '../../domain/entities/order_model.dart';
import 'package:traffic/injection_container.dart';
import '../cubits/order_details_cubit.dart';
import 'package:traffic/core/features/checkout/generic_order_review_screen.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/api/order_payment_cache.dart';

class OrderDetailsHelper {
  static bool hasMedicalFailure(OrderModel order) {
    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;
    return step == 'MEDICAL_EXAM_FAILED' ||
        (label.contains('راسب') && (label.contains('الكشف') || label.contains('طبي')));
  }

  static bool hasPracticalFailure(OrderModel order) {
    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;
    return step == 'DRIVING_TEST_FAILED' ||
        step == 'PRACTICAL_TEST_FAILED' ||
        (label.contains('راسب') && (label.contains('اختبار') || label.contains('قيادة')));
  }

  static bool hasTechnicalFailure(OrderModel order) {
    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;
    return step == 'TECHNICAL_INSPECTION_FAILED' ||
        (label.contains('راسب') && (label.contains('الفحص') || label.contains('فني')));
  }

  static bool _isRebookableFailure(OrderModel order) {
    return hasMedicalFailure(order) ||
        hasPracticalFailure(order) ||
        hasTechnicalFailure(order);
  }

  static bool isOrderFailed(OrderModel order) {
    final String label = order.statusLabel;
    return order.status == OrderStatus.failed ||
        _isRebookableFailure(order) ||
        label.contains('عدم اجتياز') ||
        label.contains('لم يجتز') ||
        label.toLowerCase().contains('failed');
  }

  static bool showFinalizeButton(OrderModel order) {
    final bool isSupportedProcedure =
        order.title.contains('تجديد رخصة') ||
        order.title.contains('تجديد رخصة قيادة') ||
        order.title.contains('إصدار رخصة قيادة') ||
        order.title.contains('تجديد رخصة مركبة') ||
        order.title.contains('إصدار رخصة مركبة') ||
        order.title.contains('اصدار رخصة مركبة');

    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;

    // حالات الانتظار السلبي — المستخدم لا يستطيع فعل شيء، الزر لا يفيده
    final bool isPassiveWaiting =
        (step == 'MEDICAL_EXAM_RESULT_WAITING' ||
         step == 'TECHNICAL_INSPECTION_RESULT_WAITING' ||
         step == 'DRIVING_TEST_RESULT_WAITING' ||
         step == 'PRACTICAL_TEST_RESULT_WAITING' ||
         label.contains('نتيجة الكشف الطبي') ||
         label.contains('نتيجة الفحص الفني') ||
         label.contains('نتيجة اختبار القيادة') ||
         label.contains('نتيجة اختبار') ||
         label.contains('نتيجة الامتحان') ||
         label.contains('في انتظار نتيجة')) &&
        !_isRebookableFailure(order);

    // الحالات التي يملك فيها المستخدم إجراءً حقيقياً
    final bool isActionable =
        order.status == OrderStatus.pending ||
        order.status == OrderStatus.needsData ||
        order.status == OrderStatus.awaitingService ||
        _isRebookableFailure(order);

    final bool isGeneralFailure = isOrderFailed(order) && !_isRebookableFailure(order);

    return isSupportedProcedure &&
        isActionable &&
        !isGeneralFailure &&
        !isPassiveWaiting;
  }

  static String getButtonLabel(OrderModel order) {
    final String step = order.stepCode ?? '';
    final String statusLabel = order.statusLabel;

    if (step == 'PAYMENT' || statusLabel.contains('في انتظار الدفع')) {
      return 'سداد الرسوم';
    } else if (hasMedicalFailure(order)) {
      return 'إعادة حجز الكشف الطبي';
    } else if (hasPracticalFailure(order)) {
      return 'إعادة حجز اختبار القيادة';
    } else if (hasTechnicalFailure(order)) {
      return 'إعادة حجز الفحص الفني';
    } else if (step == 'MEDICAL_EXAM_BOOKING_WAITING' ||
        statusLabel.contains('حجز الكشف الطبي')) {
      return 'حجز الكشف الطبي';
    } else if (step == 'PRACTICAL_TEST_BOOKING_WAITING' ||
        step == 'DRIVING_TEST_BOOKING_WAITING' ||
        step == 'DRIVING_SCHOOL_BOOKING_WAITING' ||
        statusLabel.contains('حجز اختبار القيادة') ||
        statusLabel.contains('حجز مدرسة القيادة') ||
        statusLabel.contains('حجز موعد الاختبار')) {
      return 'حجز اختبار القيادة';
    } else if (step == 'MEDICAL_EXAM_RESULT_WAITING' ||
        statusLabel.contains('نتيجة الكشف الطبي')) {
      return 'في انتظار نتيجة الكشف الطبي';
    } else if (step == 'TECHNICAL_INSPECTION_BOOKING_WAITING' ||
        statusLabel.contains('حجز الفحص الفني')) {
      return 'حجز الفحص الفني';
    } else if (step == 'TECHNICAL_INSPECTION_RESULT_WAITING' ||
        statusLabel.contains('نتيجة الفحص الفني')) {
      return 'في انتظار نتيجة الفحص الفني';
    }
    return 'استكمال الإجراءات';
  }

  static Future<void> handleFinalizePressed(
    BuildContext context,
    OrderModel order,
  ) async {
    final String requestNumber = order.id.trim();
    if (requestNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر استكمال الطلب: رقم الطلب غير متاح.',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    final String step = order.stepCode ?? '';
    final String statusLabel = order.statusLabel;

    if (step == 'PAYMENT' || statusLabel.contains('في انتظار الدفع')) {
      final applicant = await ApplicantDetails.getActualDetails();

      final cachedData = await OrderPaymentCache.get(requestNumber);

      double baseFee = order.fees?.baseFee ?? 0;
      double deliveryFee = order.fees?.deliveryFee ?? 0;
      double totalAmount = order.fees?.totalAmount ?? 0;
      String paymentMethodLabel = (order.delivery?.method?.isNotEmpty == true)
          ? order.delivery!.method!
          : 'الاستلام من وحدة المرور';
      String orderType = order.title;

      if (cachedData != null) {
        if (cachedData.baseFee > 0) baseFee = cachedData.baseFee;
        if (cachedData.deliveryFee > 0) deliveryFee = cachedData.deliveryFee;
        if (cachedData.totalAmount > 0) totalAmount = cachedData.totalAmount;
        if (cachedData.paymentMethodLabel.isNotEmpty) {
          paymentMethodLabel = cachedData.paymentMethodLabel;
        }
        if (cachedData.orderType.isNotEmpty) {
          orderType = cachedData.orderType;
        }
      }

      final List<FeeItem> items = [];
      String baseFeeLabel = 'رسوم تجديد الرخصة';
      if (orderType.contains('إصدار')) {
        baseFeeLabel = 'رسوم إصدار الرخصة';
      } else if (orderType.contains('بدل')) {
        baseFeeLabel = 'رسوم إصدار بدل رخصة';
      }

      if (baseFee > 0) {
        items.add(FeeItem(label: baseFeeLabel, amount: '$baseFee جنية مصري'));
      }
      if (deliveryFee > 0) {
        items.add(
          FeeItem(label: 'رسوم التوصيل', amount: '$deliveryFee جنية مصري'),
        );
      }
      if (items.isEmpty) {
        items.add(
          FeeItem(label: 'إجمالي الرسوم', amount: '$totalAmount جنية مصري'),
        );
      }
      final fees = FeesDetails(items: items, total: '$totalAmount جنية مصري');

      final orderSummary = OrderSummary(
        orderType: orderType,
        paymentMethod: paymentMethodLabel,
        orderId: order.id,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenericOrderReviewScreen(
              appBarTitle: orderType,
              applicantDetails: applicant,
              orderSummary: orderSummary,
              feesDetails: fees,
              serviceRequestNumber: order.id,
              paymentAmountOverride: totalAmount > 0 ? totalAmount : null,
            ),
          ),
        );
      }
      return;
    }

    final String title = order.title;

    if (title.contains('تجديد رخصة مركبة') || requestNumber.startsWith('VR-')) {
      // ─── تجديد رخصة مركبة ─────────────────────────────────────────
      if (hasTechnicalFailure(order) ||
          step == 'TECHNICAL_INSPECTION_BOOKING_WAITING' ||
          statusLabel.contains('حجز الفحص الفني')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<VehicleRenewalCubit>(
              create: (_) => getIt<VehicleRenewalCubit>(),
              child: VehicleTechnicalInspectionScreen(
                vehicle: RenewalVehicleLicenseModel(
                  plateNumber: order.id,
                  vehicleType: order.title,
                  expiryDate: '',
                  status: RenewalLicenseStatus.valid,
                  needsTechnicalInspection: true,
                ),
                requestNumber: requestNumber,
              ),
            ),
          ),
        );
      } else if (step == 'TECHNICAL_INSPECTION_RESULT_WAITING' ||
          statusLabel.contains('نتيجة الفحص الفني')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى الانتظار لحين إرسال نتيجة الفحص الفني من مركز الفحص المعتمد.',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // الخطوة النهائية: شاشة الاستلام
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleRenewalDeliveryScreen(
              requestNumber: requestNumber,
              plateNumber: order.id,
              vehicle: RenewalVehicleLicenseModel(
                plateNumber: order.id,
                vehicleType: order.title,
                expiryDate: '',
                status: RenewalLicenseStatus.valid,
              ),
            ),
          ),
        );
      }
    } else if (title.contains('إصدار رخصة مركبة') ||
        title.contains('اصدار رخصة مركبة') ||
        requestNumber.startsWith('VL-')) {
      // ─── إصدار رخصة مركبة ─────────────────────────────────────────
      if (hasTechnicalFailure(order) ||
          step == 'TECHNICAL_INSPECTION_BOOKING_WAITING' ||
          statusLabel.contains('حجز الفحص الفني')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<VehicleRenewalCubit>(
              create: (_) => getIt<VehicleRenewalCubit>(),
              child: VehicleInspectionBookingScreen(
                requestNumber: requestNumber,
              ),
            ),
          ),
        );
      } else if (step == 'TECHNICAL_INSPECTION_RESULT_WAITING' ||
          statusLabel.contains('نتيجة الفحص الفني')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى الانتظار لحين إرسال نتيجة الفحص الفني من مركز الفحص المعتمد.',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // الخطوة النهائية: إتمام الترخيص
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<VehicleLicenseCubit>(
              create: (_) => getIt<VehicleLicenseCubit>(),
              child: FinalizeVehicleLicenseScreen(requestNumber: requestNumber),
            ),
          ),
        );
      }
    } else if (title.contains('إصدار رخصة قيادة') ||
        requestNumber.startsWith('LR-') ||
        requestNumber.startsWith('DL-')) {
      // ─── إصدار رخصة قيادة ─────────────────────────────────────────
      if (hasMedicalFailure(order) ||
          step == 'MEDICAL_EXAM_BOOKING_WAITING' ||
          statusLabel.contains('حجز الكشف الطبي')) {
        await startMedicalBooking(context, requestNumber);
      } else if (hasPracticalFailure(order) ||
          step == 'PRACTICAL_TEST_BOOKING_WAITING' ||
          step == 'DRIVING_TEST_BOOKING_WAITING' ||
          step == 'DRIVING_SCHOOL_BOOKING_WAITING' ||
          statusLabel.contains('حجز اختبار القيادة') ||
          statusLabel.contains('حجز مدرسة القيادة') ||
          statusLabel.contains('حجز موعد الاختبار')) {
        await startPracticalBooking(context, requestNumber);
      } else if (step == 'MEDICAL_EXAM_RESULT_WAITING' ||
          statusLabel.contains('نتيجة الكشف الطبي')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى الانتظار لحين إرسال نتيجة الكشف الطبي من المركز الطبي المعتمد.',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // الخطوة النهائية: إتمام رخصة القيادة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<DrivingLicenseCubit>(
              create: (_) => getIt<DrivingLicenseCubit>(),
              child: FinalizeDrivingLicenseScreen(requestNumber: requestNumber),
            ),
          ),
        );
      }
    } else if (title.contains('تجديد رخصة قيادة') ||
        title.contains('تجديد رخصة') ||
        requestNumber.startsWith('DR-')) {
      // ─── تجديد رخصة قيادة ─────────────────────────────────────────
      if (hasMedicalFailure(order) ||
          step == 'MEDICAL_EXAM_BOOKING_WAITING' ||
          statusLabel.contains('حجز الكشف الطبي')) {
        await startMedicalBooking(context, requestNumber);
      } else if (hasPracticalFailure(order) ||
          step == 'PRACTICAL_TEST_BOOKING_WAITING' ||
          step == 'DRIVING_TEST_BOOKING_WAITING' ||
          step == 'DRIVING_SCHOOL_BOOKING_WAITING' ||
          statusLabel.contains('حجز اختبار القيادة') ||
          statusLabel.contains('حجز مدرسة القيادة') ||
          statusLabel.contains('حجز موعد الاختبار')) {
        await startPracticalBooking(context, requestNumber);
      } else if (step == 'MEDICAL_EXAM_RESULT_WAITING' ||
          statusLabel.contains('نتيجة الكشف الطبي')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى الانتظار لحين إرسال نتيجة الكشف الطبي من المركز الطبي المعتمد.',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // ... الخطوة النهائية: اختيار طريقة الاستلام
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<DrivingRenewalCubit>(
              create: (_) => getIt<DrivingRenewalCubit>(),
              child: DeliveryMethodScreen.renewalFinalize(
                renewalRequestNumber: requestNumber,
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لم يتم دعم استكمال هذه الخدمة بعد.',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  static Future<void> startMedicalBooking(
    BuildContext context,
    String requestNumber,
  ) async {
    final bookingHelper = getIt<FirstLicenseBookingHelper>();
    final BookingFlowData? medicalData = await Navigator.push<BookingFlowData>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicalCheckScreen(
          appBarTitle: 'اصدار رخصة قيادة',
          loadGovernorates: bookingHelper.loadGovernorates,
          loadMedicalCenters: bookingHelper.loadTrafficUnits,
          loadSlotsForDate: bookingHelper.loadMedicalSlots,
        ),
      ),
    );

    if (medicalData != null && context.mounted) {
      context.read<OrderDetailsCubit>().submitMedicalAppointment(
        medicalData.selectedGovernorateId ?? '',
        medicalData.selectedSecondaryId ?? '',
        medicalData.selectedDate,
        medicalData.selectedSlot,
        requestNumber,
      );
    }
  }

  static Future<void> startPracticalBooking(
    BuildContext context,
    String requestNumber,
  ) async {
    final bookingHelper = getIt<FirstLicenseBookingHelper>();
    final BookingFlowData? practicalData =
        await Navigator.push<BookingFlowData>(
          context,
          MaterialPageRoute(
            builder: (_) => PracticalTestBookingScreen(
              appBarTitle: 'اصدار رخصة قيادة',
              loadGovernorates: bookingHelper.loadGovernorates,
              loadTrafficUnits: bookingHelper.loadTrafficUnits,
              loadSlotsForDate: bookingHelper.loadDrivingSlots,
            ),
          ),
        );

    if (practicalData != null && context.mounted) {
      context.read<OrderDetailsCubit>().submitDrivingAppointment(
        practicalData.selectedGovernorateId ?? '',
        practicalData.selectedSecondaryId ?? '',
        practicalData.selectedDate,
        practicalData.selectedSlot,
        requestNumber,
      );
    }
  }
}

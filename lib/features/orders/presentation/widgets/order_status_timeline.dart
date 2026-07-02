import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/order_model.dart';
import 'timeline_step_item.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({super.key, required this.order});

  List<_StepData> _buildSteps() {
    final String requestDate = order.date.isNotEmpty
        ? order.date
        : 'تم التقديم بنجاح';
    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;

    // Check failed states independently
    final bool isMedicalFailed =
        step == 'MEDICAL_EXAM_FAILED' ||
        (label.contains('راسب') && (label.contains('الكشف') || label.contains('طبي')));

    final bool isTechnicalFailed =
        step == 'TECHNICAL_INSPECTION_FAILED' ||
        (label.contains('راسب') && (label.contains('الفحص') || label.contains('فني')));

    final bool isSchoolOrTestFailed =
        step == 'DRIVING_TEST_FAILED' ||
        step == 'PRACTICAL_TEST_FAILED' ||
        (label.contains('راسب') && (label.contains('اختبار') || label.contains('قيادة')));

    final bool isAnyFailed = isMedicalFailed ||
        isTechnicalFailed ||
        isSchoolOrTestFailed ||
        order.status == OrderStatus.failed ||
        label.contains('عدم اجتياز') ||
        label.contains('لم يجتز') ||
        label.toLowerCase().contains('failed');

    final bool isMedicalActive =
        (step == 'MEDICAL_EXAM' ||
            step == 'MEDICAL_EXAM_BOOKING_WAITING' ||
            step == 'MEDICAL_EXAM_RESULT_WAITING' ||
            label.contains('الكشف الطبي') ||
            label.contains('طبي')) &&
        !isMedicalFailed;

    final bool isTechnicalActive =
        (step == 'TECHNICAL_INSPECTION' ||
            step == 'TECHNICAL_INSPECTION_BOOKING_WAITING' ||
            step == 'TECHNICAL_INSPECTION_RESULT_WAITING' ||
            label.contains('الفحص الفني') ||
            label.contains('الفحص')) &&
        !isTechnicalFailed;

    final bool isMedicalOrTechActive = isMedicalActive || isTechnicalActive;
    final bool isMedicalOrTechFailed = isMedicalFailed || isTechnicalFailed;

    final bool isSchoolOrTestActive =
        (step == 'DRIVING_SCHOOL' ||
            step == 'DRIVING_TEST' ||
            step == 'DRIVING_SCHOOL_BOOKING_WAITING' ||
            step == 'DRIVING_TEST_BOOKING_WAITING' ||
            step == 'PRACTICAL_TEST_BOOKING_WAITING' ||
            label.contains('مدرسة') ||
            label.contains('اختبار')) &&
        !isSchoolOrTestFailed;

    final bool isPaymentActive =
        (step == 'PAYMENT' ||
            order.status == OrderStatus.needsData ||
            label.contains('دفع') ||
            label.contains('رسوم') ||
            label.contains('استكمال'));

    final bool isCompleted = order.status == OrderStatus.completed;

    // Determine completion of previous stages
    const bool isSubmittedDone = true;

    // Delivery method status
    final bool isDeliveryDone =
        (order.delivery?.method?.isNotEmpty == true) || isPaymentActive || isCompleted;

    final bool isMedicalDone =
        !isMedicalOrTechFailed &&
        (isCompleted ||
            (!isMedicalOrTechActive &&
                (isSchoolOrTestActive || !isDeliveryDone || isPaymentActive)));

    final bool isSchoolTestDone =
        !isSchoolOrTestFailed &&
        (isCompleted ||
            (!isSchoolOrTestActive && (!isDeliveryDone || isPaymentActive)));

    final bool isPrevRequiredStepsDone = order.title.contains('تجديد')
        ? isMedicalDone
        : (order.title.contains('مركبة') ? isMedicalDone : (isMedicalDone && isSchoolTestDone));

    final bool isDeliveryActive =
        isPrevRequiredStepsDone && !isDeliveryDone && !isAnyFailed;

    final bool isPaymentDone = isCompleted;

    final List<_StepData> stepsList = [];

    // Step 1: تم تقديم الطلب
    stepsList.add(_StepData(
      title: 'تم تقديم الطلب',
      dateSubtitle: requestDate,
      descSubtitle:
          'تم استلام طلب استخراج الرخصة بنجاح والتحقق من المستندات الأولية.',
      isCompleted: isSubmittedDone,
      isCurrent:
          !isMedicalOrTechActive &&
          !isSchoolOrTestActive &&
          !isDeliveryActive &&
          !isPaymentActive &&
          !isCompleted &&
          !isAnyFailed,
    ));

    // Step 2: الفحص والكشف الطبي (أو الفحص الفني للمركبة)
    final bool isVehicle = order.title.contains('مركبة');
    stepsList.add(_StepData(
      title: isVehicle ? 'الفحص الفني للمركبة' : 'الفحص والكشف الطبي',
      dateSubtitle: (isMedicalOrTechActive || isMedicalOrTechFailed) ? requestDate : '',
      descSubtitle: isMedicalOrTechFailed
          ? (label.isNotEmpty
                ? label
                : 'لا يمكنك استكمال الطلب لعدم اجتياز الفحص/الكشف.')
          : (isMedicalOrTechActive
                ? (isVehicle
                      ? 'بانتظار إجراء الفحص الفني المعتمد للمركبة.'
                      : 'بانتظار إجراء الكشف الطبي أو الفحص الفني المعتمد لإرفاقه بالطلب.')
                : (isMedicalDone
                      ? (isVehicle
                            ? 'تم اجتياز الفحص الفني بنجاح.'
                            : 'تم اجتياز الفحص والكشف الطبي بنجاح.')
                      : (isVehicle
                            ? 'مرحلة الفحص الفني للمركبة.'
                            : 'مرحلة الفحص الطبي المعتمد.'))),
      isCompleted: isMedicalDone,
      isCurrent: isMedicalOrTechActive,
      isFailed: isMedicalOrTechFailed,
    ));

    // Step 3: التدريب والاختبارات (فقط لإصدار رخصة قيادة جديدة)
    final bool isDrivingIssue = order.title.contains('إصدار رخصة قيادة') ||
        order.title.contains('اصدار رخصة قيادة');
    if (isDrivingIssue) {
      stepsList.add(_StepData(
        title: 'التدريب والاختبارات',
        dateSubtitle: (isSchoolOrTestActive || isSchoolOrTestFailed) ? requestDate : '',
        descSubtitle: isSchoolOrTestFailed
            ? (label.isNotEmpty
                  ? label
                  : 'لا يمكنك استكمال الطلب لعدم اجتياز اختبار القيادة.')
            : (isSchoolOrTestActive
                  ? 'جاري جدولة وحضور محاضرات مدرسة القيادة والاختبارين النظري والعملي.'
                  : (isSchoolTestDone
                        ? 'تم اجتياز التدريب والاختبارات بنجاح.'
                        : 'مرحلة التدريب والاختبارات الميدانية.')),
        isCompleted: isSchoolTestDone,
        isCurrent: isSchoolOrTestActive,
        isFailed: isSchoolOrTestFailed,
      ));
    }

    // Step 4: تحديد طريقة الاستلام
    stepsList.add(_StepData(
      title: 'تحديد طريقة الاستلام',
      dateSubtitle: isDeliveryActive ? requestDate : '',
      descSubtitle: isDeliveryActive
          ? 'يرجى تحديد طريقة استلام الرخصة (توصيل للمنزل أو استلام من وحدة المرور).'
          : (isDeliveryDone
                ? 'تم اختيار طريقة الاستلام: ${order.delivery?.method ?? 'الاستلام من وحدة المرور'}.'
                : 'مرحلة تحديد طريقة استلام الرخصة.'),
      isCompleted: isDeliveryDone,
      isCurrent: isDeliveryActive,
    ));

    // Step 5: سداد الرسوم
    stepsList.add(_StepData(
      title: 'سداد الرسوم وإصدار الرخصة',
      dateSubtitle: isPaymentActive ? requestDate : '',
      descSubtitle: isPaymentActive
          ? 'يرجى سداد الرسوم المقررة لاستكمال طباعة الرخصة.'
          : (isPaymentDone
                ? 'تم سداد الرسوم وتأكيد الإصدار.'
                : 'مرحلة سداد الرسوم والطباعة.'),
      isCompleted: isPaymentDone,
      isCurrent: isPaymentActive,
    ));

    // Step 6: اكتمال الطلب والتسليم
    stepsList.add(_StepData(
      title: 'اكتمال الطلب والتسليم',
      dateSubtitle: isCompleted ? requestDate : '',
      descSubtitle: isCompleted
          ? 'تم طباعة رخصة القيادة بنجاح وتسليمها للمواطن.'
          : 'مرحلة التسليم النهائي للرخصة.',
      isCompleted: isCompleted,
      isCurrent: isCompleted,
    ));

    return stepsList;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final String step = order.stepCode ?? '';
    final String label = order.statusLabel;

    final bool isMedicalFailed =
        step == 'MEDICAL_EXAM_FAILED' ||
        (label.contains('راسب') && (label.contains('الكشف') || label.contains('طبي')));

    final bool isTechnicalFailed =
        step == 'TECHNICAL_INSPECTION_FAILED' ||
        (label.contains('راسب') && (label.contains('الفحص') || label.contains('فني')));

    final bool isSchoolOrTestFailed =
        step == 'DRIVING_TEST_FAILED' ||
        step == 'PRACTICAL_TEST_FAILED' ||
        (label.contains('راسب') && (label.contains('اختبار') || label.contains('قيادة')));

    final bool isAnyFailed = isMedicalFailed ||
        isTechnicalFailed ||
        isSchoolOrTestFailed ||
        order.status == OrderStatus.failed ||
        label.contains('عدم اجتياز') ||
        label.contains('لم يجتز') ||
        label.toLowerCase().contains('failed');

    final bool isCompleted = order.status == OrderStatus.completed;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isAnyFailed
                ? AppColors.darkRed
                : isCompleted
                ? AppColors.primary
                : AppColors.dividerGrey,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'سجل الحالة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 16.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return TimelineStepItem(
                title: step.title,
                dateSubtitle: step.dateSubtitle,
                descSubtitle: step.descSubtitle,
                isCompleted: step.isCompleted,
                isCurrent: step.isCurrent,
                isFailed: step.isFailed,
                isLastStep: index == steps.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepData {
  String title;
  String dateSubtitle;
  String descSubtitle;
  bool isCompleted;
  bool isCurrent;
  bool isFailed;

  _StepData({
    required this.title,
    required this.dateSubtitle,
    required this.descSubtitle,
    required this.isCompleted,
    this.isCurrent = false,
    this.isFailed = false,
  });
}

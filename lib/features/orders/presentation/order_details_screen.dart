import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/service_screen_appbar.dart';
import 'package:traffic/injection_container.dart';
import '../domain/entities/order_model.dart';
import 'widgets/failed_order_alert.dart';
import 'widgets/finalize_order_button.dart';
import 'widgets/order_loading_overlay.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/order_summary_header_card.dart';

import 'package:traffic/features/orders/presentation/cubits/my_orders_cubit.dart';

import 'cubits/order_details_cubit.dart';
import 'utils/order_details_helper.dart';

/// ─── Outer shell ──────────────────────────────────────────────
/// تنشئ الـ BlocProvider وتُمرّر الـ order المبدئية للـ View
class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderDetailsCubit>(
      create: (_) => getIt<OrderDetailsCubit>(),
      child: _OrderDetailsView(initialOrder: order),
    );
  }
}

/// ─── View (StatefulWidget) ─────────────────────────────────────
/// تجلب التحديثات من السيرفر في initState وتبني الـ UI على البيانات الطازجة
class _OrderDetailsView extends StatefulWidget {
  final OrderModel initialOrder;

  const _OrderDetailsView({required this.initialOrder});

  @override
  State<_OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<_OrderDetailsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// الـ order الفعلي المُعتمد لبناء الـ UI
  /// يبدأ بالقيمة المُمررة ويُستبدل بالبيانات الطازجة من السيرفر فور وصولها
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.initialOrder;
    // ✅ جلب أحدث حالة للطلب من السيرفر بمجرد فتح الشاشة
    context.read<OrderDetailsCubit>().fetchOrderDetails(
          widget.initialOrder.id,
          widget.initialOrder,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsCubit, OrderDetailsState>(
      listener: (context, state) {
        // ✅ تحديث _currentOrder بمجرد وصول البيانات الطازجة من السيرفر
        if (state is OrderDetailsRefreshed) {
          setState(() => _currentOrder = state.freshOrder);

        } else if (state is OrderDetailsFetchFailed) {
          // لا نعطّل الشاشة — نكتفي بإشعار خفيف والاستمرار بالبيانات القديمة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تعذّر تحديث بيانات الطلب، يتم عرض آخر بيانات متاحة.',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );

        } else if (state is OrderDetailsMedicalBookingSuccess) {
          try {
            context.read<MyOrdersCubit>().fetchMyOrders();
          } catch (_) {}

          if (OrderDetailsHelper.hasMedicalFailure(_currentOrder)) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'تم إعادة حجز موعد الكشف الطبي بنجاح! يمكنك متابعة طلبك من قائمة طلباتي.',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'تم حجز موعد الكشف الطبي بنجاح! جاري الانتقال لحجز اختبار القيادة...',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            OrderDetailsHelper.startPracticalBooking(
                context, state.requestNumber);
          }

        } else if (state is OrderDetailsPracticalBookingSuccess) {
          try {
            context.read<MyOrdersCubit>().fetchMyOrders();
          } catch (_) {}
          Navigator.of(context).pop();

          final isRebook = OrderDetailsHelper.hasPracticalFailure(_currentOrder);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRebook
                    ? 'تم إعادة حجز موعد اختبار القيادة بنجاح! يمكنك متابعة طلبك من قائمة طلباتي.'
                    : 'تم حجز موعد اختبار القيادة بنجاح! تم استكمال جميع حجز المواعيد.',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.primary,
            ),
          );

        } else if (state is OrderDetailsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.lightGreyBg,
            drawer: const AppDrawer(),
            body: Column(
              children: [
                ServiceScreenAppBar(
                  title: "طلباتي",
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                    // نُعيد بناء الـ body فقط عند تغير حالات التحديث
                    buildWhen: (prev, curr) =>
                        curr is OrderDetailsLoadingDetails ||
                        curr is OrderDetailsRefreshed ||
                        curr is OrderDetailsFetchFailed,
                    builder: (context, state) {
                      final isRefreshing = state is OrderDetailsLoadingDetails;
                      return _buildScrollableBody(isRefreshing: isRefreshing);
                    },
                  ),
                ),
                // ✅ زر الاستكمال يعتمد دائماً على _currentOrder المحدَّثة
                if (OrderDetailsHelper.showFinalizeButton(_currentOrder))
                  FinalizeOrderButton(
                    label: OrderDetailsHelper.getButtonLabel(_currentOrder),
                    onPressed: () => OrderDetailsHelper.handleFinalizePressed(
                        context, _currentOrder),
                  ),
              ],
            ),
          ),
          // Loading overlay للعمليات الثقيلة (حجز مواعيد)
          BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            buildWhen: (prev, curr) =>
                curr is OrderDetailsLoading ||
                curr is OrderDetailsInitial ||
                curr is OrderDetailsMedicalBookingSuccess ||
                curr is OrderDetailsPracticalBookingSuccess ||
                curr is OrderDetailsFailure,
            builder: (context, state) {
              if (state is OrderDetailsLoading) {
                return const OrderLoadingOverlay();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableBody({required bool isRefreshing}) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16.r,
        right: 16.r,
        top: 24.h,
        bottom: 16.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان مع مؤشر تحميل خفيف أثناء جلب التحديثات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isRefreshing)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // ✅ يعتمد على _currentOrder الطازجة دائماً
          OrderSummaryHeaderCard(order: _currentOrder),
          if (OrderDetailsHelper.isOrderFailed(_currentOrder)) ...[
            SizedBox(height: 16.h),
            FailedOrderAlert(statusLabel: _currentOrder.statusLabel),
          ],
          SizedBox(height: 24.h),
          OrderStatusTimeline(order: _currentOrder),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

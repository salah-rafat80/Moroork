import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:traffic/features/profile/presentation/widgets/profile_header.dart';
import 'package:traffic/core/widgets/empty_state_widget.dart';
import 'cubits/my_orders_cubit.dart';
import 'cubits/my_orders_state.dart';
import 'order_details_screen.dart';
import 'widgets/order_item_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyOrdersScreenView();
  }
}

class _MyOrdersScreenView extends StatelessWidget {
  const _MyOrdersScreenView();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      body: Column(
        children: [
          const ProfileHeader(title: 'طلباتي'),
          Expanded(
            child: BlocBuilder<MyOrdersCubit, MyOrdersState>(
              builder: (context, state) {
                if (state is MyOrdersLoading) {
                  return Center(
                    child: Lottie.asset(
                      'assets/animations/Sandy Loading.json',
                      width: 200.w,
                      height: 200.h,
                    ),
                  );
                } else if (state is MyOrdersFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp),
                    ),
                  );
                } else if (state is MyOrdersFetchSuccess) {
                  final orders = state.orders;
                  if (orders.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'لا توجد طلبات أو مواعيد حالياً',
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      return OrderItemCard(
                        order: orders[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(order: orders[index]),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

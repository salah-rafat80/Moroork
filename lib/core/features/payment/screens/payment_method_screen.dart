import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic/core/features/payment/presentation/cubits/payment_cubit.dart';
import 'package:traffic/core/features/payment/presentation/cubits/payment_state.dart';
import 'package:traffic/core/features/payment/models/payment_intent.dart';
import 'package:traffic/core/features/payment/screens/payment_webview_screen.dart';
import 'package:traffic/core/features/payment/widgets/payment_option_card.dart';
import 'package:traffic/core/features/payment/widgets/payment_summary_card.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/injection_container.dart';

class PaymentMethodScreen extends StatelessWidget {
  final PaymentIntent paymentIntent;

  const PaymentMethodScreen({super.key, required this.paymentIntent});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PaymentCubit>(),
      child: _PaymentMethodScreenContent(paymentIntent: paymentIntent),
    );
  }
}

class _PaymentMethodScreenContent extends StatefulWidget {
  final PaymentIntent paymentIntent;

  const _PaymentMethodScreenContent({required this.paymentIntent});

  @override
  State<_PaymentMethodScreenContent> createState() =>
      _PaymentMethodScreenContentState();
}

class _PaymentMethodScreenContentState
    extends State<_PaymentMethodScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isVisaSelected = true;
  DateTime? _lastClickTime;
  bool _isVerifyingDialogShown = false;

  void _onNextPressed(BuildContext context) {
    final now = DateTime.now();
    developer.log('Button Click Timestamp: $now', name: 'PaymentMethodScreen');

    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) < const Duration(seconds: 2)) {
      developer.log(
        'Ignored duplicate button click (debounced)',
        name: 'PaymentMethodScreen',
      );
      return;
    }
    _lastClickTime = now;

    if (_isVisaSelected) {
      final hasServiceRequest =
          widget.paymentIntent.serviceRequestNumber != null &&
          widget.paymentIntent.serviceRequestNumber!.isNotEmpty;
      final hasViolations =
          widget.paymentIntent.violationIds != null &&
          widget.paymentIntent.violationIds!.isNotEmpty;

      if (!hasServiceRequest && !hasViolations) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('بيانات الطلب غير متاحة')));
        return;
      }
      developer.log(
        'Initiating payment for: ${widget.paymentIntent.serviceRequestNumber} or ${widget.paymentIntent.violationIds}',
        name: 'PaymentMethodScreen',
      );
      context.read<PaymentCubit>().initiatePayment(
        serviceRequestNumber: widget.paymentIntent.serviceRequestNumber,
        violationIds: widget.paymentIntent.violationIds,
        amount: widget.paymentIntent.amount,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text(
          'تم الدفع بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            fontSize: 20.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 64.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'تم استلام المبلغ بنجاح، وتأكيد طلبك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.deepGrey,
                fontFamily: 'Tajawal',
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SizedBox(
                width: 150.w,
                child: PrimaryButton(
                  label: 'العودة للرئيسية',
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          developer.log(
            'State Transition: ${state.runtimeType}',
            name: 'PaymentMethodScreen',
          );
          if (state is PaymentInitSuccess) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebviewScreen(
                  paymentUrl: state.response.paymentUrl,
                  merchantOrderId: state.response.merchantOrderId,
                  paymentId: state.response.paymentId.toString(),
                  requestNumber: widget.paymentIntent.serviceRequestNumber,
                ),
              ),
            );

            // Verify status via backend immediately
            if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
              context.read<PaymentCubit>().verifyPayment(state.response.merchantOrderId);
            }
          } else if (state is PaymentVerifying) {
            _isVerifyingDialogShown = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomLoadingIndicator(color: AppColors.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'جاري التحقق من عملية الدفع...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is PaymentVerifySuccess) {
            if (_isVerifyingDialogShown) {
              Navigator.of(context).pop();
              _isVerifyingDialogShown = false;
            }
            _showSuccessDialog();
          } else if (state is PaymentVerifyFailure) {
            if (_isVerifyingDialogShown) {
              Navigator.of(context).pop();
              _isVerifyingDialogShown = false;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: AppColors.alertRed,
              ),
            );
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: AppColors.alertRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentLoading || state is PaymentVerifying;

          return Column(
            children: [
              // App bar
              ServiceScreenAppBar(
                title: widget.paymentIntent.orderType,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Section title
                      Text(
                        'تأكيد وسيلة دفع',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Summary card
                      PaymentSummaryCard(paymentIntent: widget.paymentIntent),
                      SizedBox(height: 16.h),

                      // Payment option (Visa/MC)
                      PaymentOptionCard(
                        title: 'فيزا/ ماستر كارد',
                        subtitle: 'Visa/Mastercard',
                        logoAssetPath: 'assets/visa_mc_logo.png',
                        isSelected: _isVisaSelected,
                        onTap: () {
                          setState(() {
                            _isVisaSelected = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: isLoading
                    ? Center(
                        child: CustomLoadingIndicator(color: AppColors.primary),
                      )
                    : PrimaryButton(
                        label: 'التالي',
                        onPressed: _isVisaSelected
                            ? () => _onNextPressed(context)
                            : null,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
